import 'package:fluent_ui/fluent_ui.dart';

class TranslationDelegate extends LocalizationsDelegate<FluentLocalizations> {
  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<FluentLocalizations> load(Locale locale) async => _TranslationDelegate();

  @override
  bool shouldReload(covariant LocalizationsDelegate<FluentLocalizations> old) => false;
}

class _TranslationDelegate implements FluentLocalizations {
  @override
  String get backButtonTooltip => 'Back';

  @override
  String get closeButtonLabel => 'Close';
  
  @override
  String get searchLabel => 'Search';

  @override
  String get closeNavigationTooltip => 'Close Navigation';

  @override
  String get openNavigationTooltip => 'Open Navigation';

  @override
  String get clickToSearch => 'Click to search';

  @override
  String get modalBarrierDismissLabel => 'Dismiss';

  @override
  String get minimizeWindowTooltip => 'Minimze';

  @override
  String get restoreWindowTooltip => 'Restore';

  @override
  String get closeWindowTooltip => 'Close';

  @override
  String get dialogLabel => 'Dialog';

  @override
  String get cutActionLabel => 'Cut';

  @override
  String get copyActionLabel => 'Copy';

  @override
  String get pasteActionLabel => 'Paste';

  @override
  String get selectAllActionLabel => 'Select all';

  @override
  String get newTabLabel => 'Add new tab';

  @override
  String get closeTabLabel => 'Close tab (Ctrl+F4)';

  @override
  String get scrollTabBackwardLabel => 'Scroll tab list backward';

  @override
  String get scrollTabForwardLabel => 'Scroll tab list forward';

  @override
  String get noResultsFoundLabel => 'No results found';

  String get _ctrlCmd {
    return 'Ctrl';
  }

  @override
  String get cutShortcut => '$_ctrlCmd+X';

  @override
  String get copyShortcut => '$_ctrlCmd+C';

  @override
  String get pasteShortcut => '$_ctrlCmd+V';

  @override
  String get selectAllShortcut => '$_ctrlCmd+A';

  @override
  String get copyActionTooltip => 'Copy the selected content to the clipboard';

  @override
  String get cutActionTooltip => 'Remove the selected content and put it in the clipboard';

  @override
  String get pasteActionTooltip => 'Inserts the contents of the clipboard at the current location';

  @override
  String get selectAllActionTooltip => 'Select all content';
}
