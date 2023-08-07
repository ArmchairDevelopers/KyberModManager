import 'package:auto_size_text/auto_size_text.dart';
import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:jiffy/jiffy.dart';
import 'package:kyber_mod_manager/constants/maps.dart';
import 'package:kyber_mod_manager/constants/modes.dart';
import 'package:kyber_mod_manager/screens/dialogs/join_server_dialog/join_dialog.dart';
import 'package:kyber_mod_manager/utils/types/freezed/kyber_server.dart';
import 'package:kyber_mod_manager/utils/types/mode.dart';

material.DataRow Server(BuildContext context, KyberServer server) {
  var dataAutoSizeGroup = AutoSizeGroup();
  final double width = MediaQuery.of(context).size.width;
  final bool showColumn = !(width > 700 && width < 1270);
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
                Container(
                  constraints: BoxConstraints(
                    maxWidth: width * (showColumn ? 0.22 : 0.3),
                  ),
                  child: Text(
                    server.name.trimRight(),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                server.requiresPassword ? const Icon(FluentIcons.lock, size: 14) : Container(),
              ],
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * (showColumn ? 0.22 : 0.3),
              height: 20,
              child: Row(
                children: [
                  if (server.official) ...[
                    AutoSizeText(
                      '${mode.name} - ${map['name']} - ',
                      minFontSize: 10,
                      group: dataAutoSizeGroup,
                    ),
                    SvgPicture.network("https://kyber.gg/logo.svg", width: 15, height: 15),
                    const SizedBox(width: 4),
                    AutoSizeText(
                      'Kyber',
                      minFontSize: 10,
                      group: dataAutoSizeGroup,
                      style: const TextStyle(
                        color: Color(0xfffbb10a),
                        fontWeight: FontWeight.bold,
                        shadows: <Shadow>[
                          Shadow(
                            offset: Offset(0.5, 0.5),
                            blurRadius: 8.0,
                            color: Color(0xfff2c35a),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (!server.official)
                    AutoSizeText(
                      '${mode.name} - ${map['name']} - ${server.host.isNotEmpty ? server.host : 'Unknown'}',
                      minFontSize: 10,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      material.DataCell(
        Text(
          '${server.users}/${server.maxPlayers}',
          textAlign: TextAlign.center,
        ),
      ),
      if (showColumn)
        material.DataCell(SizedBox(
          width: MediaQuery.of(context).size.width * .07,
          child: AutoSizeText(
            Jiffy.parseFromMillisecondsSinceEpoch(server.startedAt).fromNow(),
            maxLines: 1,
          ),
        )),
      material.DataCell(
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          SvgPicture.network(server.proxy.flag, width: 20),
          const SizedBox(
            width: 5,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width * (showColumn ? .095 : 0.12),
            height: 20,
            child: Align(
              alignment: Alignment.centerLeft,
              child: AutoSizeText(
                server.proxy.name,
                minFontSize: 9,
                maxLines: 1,
              ),
            ),
          )
        ]),
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
