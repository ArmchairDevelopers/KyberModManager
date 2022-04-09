import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/api/kyber/server_response.dart';
import 'package:kyber_mod_manager/constants/maps.dart';
import 'package:kyber_mod_manager/constants/modes.dart';
import 'package:kyber_mod_manager/screens/join_server_dialog/join_dialog.dart';
import 'package:kyber_mod_manager/utils/types/mode.dart';

material.DataRow Server(BuildContext context, KyberServer server) {
  final Mode mode = modes.where((element) => element.mode == server.mode).first;
  final dynamic map = maps.singleWhere((element) => element['map'] == server.map);

  return material.DataRow(
    cells: [
      material.DataCell(
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  server.name.trimRight(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                server.requiresPassword ? const Icon(FluentIcons.lock, size: 14) : Container(),
              ],
            ),
            Text('${mode.name} - ${map['name']} - ${server.host}'),
          ],
        ),
      ),
      material.DataCell(
        Text(
          '${server.users}/${server.maxPlayers}',
          textAlign: TextAlign.center,
        ),
      ),
      material.DataCell(
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.network(server.proxy.flag, width: 20),
            const SizedBox(width: 10),
            Text(
              server.proxy.name,
            ),
          ],
        ),
      ),
      material.DataCell(
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FilledButton(
              child: Row(
                children: [
                  const Icon(FluentIcons.people),
                  const SizedBox(width: 8),
                  Text(translate('join')),
                ],
              ),
              onPressed: () {
                showDialog(context: context, builder: (context) => ServerDialog(server: server));
              },
            )
          ],
        ),
      ),
    ],
  );
}
