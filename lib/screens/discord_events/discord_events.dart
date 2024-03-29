import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:jiffy/jiffy.dart';
import 'package:kyber_mod_manager/logic/event_cubic.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DiscordEvents extends StatefulWidget {
  const DiscordEvents({Key? key}) : super(key: key);

  @override
  _DiscordEventsState createState() => _DiscordEventsState();
}

class _DiscordEventsState extends State<DiscordEvents> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventCubic, EventCubicState>(
      bloc: BlocProvider.of<EventCubic>(context),
      builder: (context, state) {
        return ScaffoldPage.scrollable(
          header: PageHeader(
            title: Text(translate('events.title')),
          ),
          children: [
            if (state.events.isEmpty)
              Center(
                child: Text(translate('events.no_events')),
              ),
            if (state.events.isNotEmpty)
              ...state.events.map(
                (e) => Card(
                  child: ListTile(
                    trailing: HyperlinkButton(
                      onPressed: () {
                        launchUrlString("discord://-/events/305338604316655616/${e.id!}");
                      },
                      child: const Text("Open In Discord"),
                    ),
                    title: Text(
                      e.name ?? '',
                      style: FluentTheme.of(context).typography.subtitle,
                    ),
                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          child: Markdown(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            data: e.description ?? "",
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            selectable: true,
                            onTapLink: (text, href, title) async {
                              if (href == null) {
                                return;
                              }

                              final uri = Uri.parse(href);
                              if (!(await canLaunchUrl(uri))) return;
                              await launchUrl(uri);
                            },
                          ),
                        ),
                        const Divider(),
                        const SizedBox(
                          height: 12,
                        ),
                        Row(
                          children: [
                            Text(
                              Jiffy.parseFromDateTime(e.scheduledStartTime!).fromNow(),
                              style: FluentTheme.of(context).typography.body?.copyWith(
                                    fontSize: 12,
                                    color: FluentTheme.of(context).typography.body?.color?.withOpacity(.8),
                                  ),
                            ),
                            if (e.userCount != null) ...[
                              Container(
                                width: 1,
                                height: 10,
                                color: Colors.white,
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                              ),
                              Text(
                                translate('events.interested', args: {'count': e.userCount ?? -1}),
                                style: FluentTheme.of(context).typography.body?.copyWith(
                                      fontSize: 12,
                                      color: FluentTheme.of(context).typography.body?.color?.withOpacity(.8),
                                    ),
                              ),
                            ],
                            if (e.creator?.username != null) ...[
                              Container(
                                width: 1,
                                height: 10,
                                color: Colors.white,
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                              ),
                              Text(
                                e.creator!.username!,
                                style: FluentTheme.of(context).typography.body?.copyWith(
                                      fontSize: 12,
                                      color: FluentTheme.of(context).typography.body?.color?.withOpacity(.8),
                                    ),
                              ),
                            ],
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              )
          ],
        );
      },
    );
  }
}
