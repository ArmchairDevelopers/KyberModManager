import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/api/kyber/server_response.dart';
import 'package:kyber_mod_manager/screens/server_browser/widgets/server.dart';
import 'package:kyber_mod_manager/utils/services/kyber_api_service.dart';

class ServerBrowser extends StatefulWidget {
  const ServerBrowser({Key? key}) : super(key: key);

  @override
  _ServerBrowserState createState() => _ServerBrowserState();
}

class _ServerBrowserState extends State<ServerBrowser> {
  final prefix = 'server_browser';
  ServerResponse? response;
  bool loading = false;
  int page = 1;

  @override
  void initState() {
    loadPage(page);
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  void loadPage(int page) async {
    setState(() {
      this.page = page;
      loading = true;
    });
    await KyberApiService.getServers(page).then(
      (value) => setState(() {
        response = value;
        loading = false;
        this.page = value.pageCount > page ? 1 : page;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      bottomBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Button(
              onPressed: page == 1 ? null : () => loadPage(page - 1),
              child: Text(translate('$prefix.prev_page')),
            ),
            Text(translate('$prefix.current_page', args: {'0': page, '1': response?.pageCount})),
            Button(
              onPressed: page == response?.pageCount || response?.pageCount == null || response?.pageCount == 0 ? null : () => loadPage(page + 1),
              child: Text(translate('$prefix.next_page')),
            ),
          ],
        ),
      ),
      header: PageHeader(
        title: Text(translate('$prefix.title')),
        commandBar: CommandBar(
          mainAxisAlignment: MainAxisAlignment.end,
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.refresh),
              onPressed: () => loadPage(page),
            ),
          ],
        ),
      ),
      content: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: loading ? MediaQuery.of(context).size.height - 160 : null,
          child: loading ? const Center(child: ProgressRing()) : FadeIn(duration: const Duration(milliseconds: 100), child: buildTable()),
        ),
      ),
    );
  }

  Widget buildTable() {
    final width = MediaQuery.of(context).size.width;
    final color = FluentTheme.of(context).typography.body!.color!;
    return material.DataTable(
      dataRowHeight: 80,
      columns: [
        material.DataColumn(
          label: SizedBox(
            child: Text(
              translate('$prefix.table.info'),
              style: TextStyle(
                color: color.withOpacity(.5),
              ),
            ),
          ),
        ),
        material.DataColumn(
          label: SizedBox(
            child: Text(
              translate('$prefix.table.players'),
              style: TextStyle(
                color: color.withOpacity(.5),
              ),
            ),
          ),
        ),
        if (!(width > 700 && width < 1270))
          material.DataColumn(
            label: SizedBox(
              child: Text(
                translate('$prefix.table.started'),
                style: TextStyle(
                  color: color.withOpacity(.5),
                ),
              ),
            ),
          ),
        material.DataColumn(
          label: SizedBox(
            child: Text(
              translate('$prefix.table.location'),
              style: TextStyle(
                color: color.withOpacity(.5),
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        const material.DataColumn(
          label: Text(''),
        ),
      ],
      rows: response?.servers.map((server) => Server(context, server)).toList() ?? [],
    );
  }
}
