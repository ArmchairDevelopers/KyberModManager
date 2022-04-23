import 'dart:ffi';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ffi/ffi.dart';
import 'package:kyber_mod_manager/constants/api_constants.dart';
import 'package:kyber_mod_manager/main.dart';
import 'package:kyber_mod_manager/utils/types/process_details.dart';
import 'package:logging/logging.dart';
import 'package:version/version.dart';
import 'package:win32/win32.dart';

class DllInjector {
  static final DynamicLibrary _kernel32 = DynamicLibrary.open("kernel32.dll");

  static File get _file => File('$applicationDocumentsDirectory\\Kyber.dll');

  static Future<Version> getLatestKyberVersion() =>
      Dio().get<String>('$KYBER_API_BASE_URL/version/launcher').then((value) => Version.parse(value.data!.replaceAll('\n', '')));

  static Future downloadDll() async {
    var version = await getLatestKyberVersion();
    Logger.root.info('Downloading Kyber V$version');
    box.put('kyberVersion', version.toString());
    await Dio().download(KYBER_DLL_LINK, _file.path).catchError((e) {
      Logger.root.severe('Error while downloading Kyber.dll: $e');
    });
  }

  static Future checkForUpdates() async {
    if (!_file.existsSync()) {
      return downloadDll();
    }

    if (!box.containsKey('kyberVersion')) {
      return downloadDll();
    }

    var currentVersion = Version.parse(box.get('kyberVersion'));
    var latestVersion = await getLatestKyberVersion();

    if (latestVersion > currentVersion) {
      return downloadDll();
    }

    Logger.root.info('Newest Kyber version is already installed.');
  }

  static bool inject() {
    int pid = getBattlefrontPID();
    if (pid == -1) {
      return false;
    }

    if (isInjected(pid)) {
      Logger.root.info('Already injected');
      return true;
    }

    String injectedModuleName = '$applicationDocumentsDirectory\\Kyber.dll';
    final moduleExists = FileSystemEntity.typeSync(injectedModuleName) != FileSystemEntityType.notFound;
    if (!moduleExists) {
      throw Exception('Module not found');
    }

    final injectedModule = File(injectedModuleName).absolute.path;
    final targetHandle = OpenProcess(PROCESS_CREATE_THREAD | PROCESS_QUERY_INFORMATION | PROCESS_VM_OPERATION | PROCESS_VM_WRITE | PROCESS_VM_READ, 0, pid);
    if (targetHandle == INVALID_HANDLE_VALUE) {
      throw Exception('Failed to open process');
    }

    final hKrnl32 = GetModuleHandle('kernel32.dll'.toNativeUtf16());
    if (hKrnl32 == NULL) {
      throw Exception('Failed to get kernel32.dll handle');
    }

    final pfnVirtualAllocEx =
        _kernel32.lookupFunction<Pointer Function(IntPtr, Pointer, IntPtr, Uint32, Uint32), Pointer Function(int, Pointer, int, int, int)>('VirtualAllocEx');
    final allocMemSize = (injectedModule.length + 1) * sizeOf<Uint8>();
    final allocMemAddress = pfnVirtualAllocEx(targetHandle, nullptr, allocMemSize, MEM_COMMIT | MEM_RESERVE, PAGE_READWRITE);

    if (allocMemAddress.address == 0) {
      throw Exception('Failed to allocate memory');
    }

    final writeSuccess = WriteProcessMemory(targetHandle, allocMemAddress.cast<Void>(), injectedModule.toNativeUtf8().cast<Void>(), allocMemSize, nullptr);
    if (writeSuccess != TRUE) {
      throw Exception('Failed to write memory');
    }

    final pfnCreateRemoteThread = _kernel32.lookupFunction<IntPtr Function(IntPtr, Pointer, IntPtr, Pointer, Pointer, Uint32, Pointer<Uint32>),
        int Function(int, Pointer, int, Pointer, Pointer, int, Pointer<Uint32>)>('CreateRemoteThread');
    final pLoadLibraryA = Pointer.fromAddress(GetProcAddress(hKrnl32, 'LoadLibraryA'.toNativeUtf8()).address);
    var r = pfnCreateRemoteThread(targetHandle, nullptr, 0, pLoadLibraryA, allocMemAddress, 0, nullptr);
    if (r == 0) {
      throw Exception('Failed to create remote thread');
    }

    Logger.root.info('Injected');
    return true;
  }

  static bool isInjected([int? pid]) {
    pid ??= getBattlefrontPID();

    if (pid == -1) {
      return false;
    }

    final hProcess = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, pid);
    final hMods = calloc<HMODULE>(1024);
    final cbNeeded = calloc<DWORD>();

    if (EnumProcessModules(hProcess, hMods, sizeOf<HMODULE>() * 1024, cbNeeded) == 1) {
      for (var i = 0; i < (cbNeeded.value ~/ sizeOf<HMODULE>()); i++) {
        final szModName = wsalloc(MAX_PATH);
        final hModule = hMods.elementAt(i).value;

        if (GetModuleFileNameEx(hProcess, hModule, szModName, MAX_PATH) != 0 && szModName.toDartString().toLowerCase().contains('kyber')) {
          _cleanup(hMods, cbNeeded, hProcess, szModName);
          return true;
        }
        free(szModName);
      }
    }

    _cleanup(hMods, cbNeeded, hProcess);
    return false;
  }

  static int getBattlefrontPID() {
    final processes = <ProcessDetails>[];

    _withMemory<void, Uint32>(sizeOf<Uint32>() * 2048, (pProcesses) {
      _withMemory<void, Uint32>(sizeOf<Uint32>(), (pReturned) {
        if (EnumProcesses(pProcesses.cast(), sizeOf<Uint32>() * 2048, pReturned.cast()) == 0) {
          return;
        }

        final cProcesses = pReturned.value / sizeOf<Uint32>();
        for (var i = 0; i < cProcesses; i++) {
          final pid = pProcesses.elementAt(i).value;
          final name = getWindowsProcessName(pid);
          if (pid != 0 && name.toLowerCase().contains('starwarsbattlefrontii.exe')) {
            processes.add(ProcessDetails(pid, name, '0K'));
          }
        }
      });
    });

    return processes.isEmpty ? -1 : processes.first.pid;
  }

  static String getWindowsProcessName(int processID) {
    var name = '<unknown>';

    final hProcess = OpenProcess(
      PROCESS_QUERY_INFORMATION | PROCESS_VM_READ,
      FALSE,
      processID,
    );
    try {
      if (NULL != hProcess) {
        _withMemory<void, Uint32>(sizeOf<Uint32>(), (phMod) {
          _withMemory<void, Uint32>(sizeOf<Uint32>(), (pcbNeeded) {
            if (EnumProcessModules(hProcess, phMod.cast(), sizeOf<Uint32>(), pcbNeeded) == 1) {
              _withMemory<void, Utf16>(MAX_PATH * sizeOf<Uint16>(), (pszProcessName) {
                GetModuleBaseName(
                  hProcess,
                  phMod.value,
                  pszProcessName,
                  MAX_PATH,
                );

                name = pszProcessName.toDartString();
              });
            }
          });
        });
      }
    } finally {
      CloseHandle(hProcess);
    }
    return name;
  }

  static R _withMemory<R, T extends NativeType>(int size, R Function(Pointer<T> memory) action) {
    final memory = calloc<Int8>(size);
    try {
      return action(memory.cast());
    } finally {
      calloc.free(memory);
    }
  }

  static void _cleanup(Pointer<IntPtr> hMods, Pointer<Uint32> cb, int process, [Pointer<Utf16>? name]) {
    if (name != null) {
      free(name);
    }
    free(cb);
    free(hMods);
    CloseHandle(process);
  }
}
