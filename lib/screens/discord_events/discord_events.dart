import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:jiffy/jiffy.dart';
import 'package:linkable/linkable.dart';
import 'package:kyber_mod_manager/logic/event_cubic.dart';
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
    return ScaffoldPage(
      header: PageHeader(
        title: Text(translate('events.title')),
      ),
      content: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: BlocBuilder<EventCubic, EventCubicState>(
          bloc: BlocProvider.of<EventCubic>(context),
          builder: (context, state) {
            if (state.events.isEmpty) {
              return Center(
                child: Text(translate('events.no_events')),
              );
            }

            return ListView.builder(
              itemBuilder: (context, index) {
                return Card(
                  child: ListTile(
                    trailing: Row(
                      children: [
                        Button(
                          onPressed: () {
                            launchUrlString("discord://-/events/305338604316655616/${state.events[index].id!}");
                          },
                          child: const Text("Open In Discord"),
                        )
                      ],
                    ),
                    title: Text(state.events[index].name ?? ''),
                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Linkable(
                          text: state.events[index].description ?? '',
                          linkColor: FluentTheme.of(context).accentColor.normal,
                          style: FluentTheme.of(context).typography.body,
                          textColor: FluentTheme.of(context).typography.body?.color,
                        ),
                        Row(
                          children: [
                            Text(
                              Jiffy.parseFromDateTime(state.events[index].scheduledStartTime!).fromNow(),
                              style: FluentTheme.of(context).typography.body?.copyWith(
                                    fontSize: 12,
                                    color: FluentTheme.of(context).typography.body?.color?.withOpacity(.8),
                                  ),
                            ),
                            if (state.events[index].userCount != null) ...[
                              Container(
                                width: 1,
                                height: 10,
                                color: Colors.white,
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                              ),
                              Text(
                                translate('events.interested', args: {'count': state.events[index].userCount ?? -1}),
                                style: FluentTheme.of(context).typography.body?.copyWith(
                                      fontSize: 12,
                                      color: FluentTheme.of(context).typography.body?.color?.withOpacity(.8),
                                    ),
                              ),
                            ],
                            if (state.events[index].creator?.username != null) ...[
                              Container(
                                width: 1,
                                height: 10,
                                color: Colors.white,
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                              ),
                              Text(
                                state.events[index].creator!.username!,
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
                );
              },
              itemCount: state.events.length,
            );
          },
        ),
      ),
    );
  }
}
