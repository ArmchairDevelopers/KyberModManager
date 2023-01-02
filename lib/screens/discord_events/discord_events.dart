import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:jiffy/jiffy.dart';
import 'package:kyber_mod_manager/logic/event_cubic.dart';

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
        commandBar: CommandBar(
          mainAxisAlignment: MainAxisAlignment.end,
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.add),
              label: Text(translate('events.subscribe')),
              onPressed: () {
                // TODO: Add subscribe
              },
            ),
          ],
        ),
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
                    title: Text(state.events[index].name ?? ''),
                    subtitle: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(state.events[index].description ?? ''),
                        Row(
                          children: [
                            Text(Jiffy(state.events[index].scheduledStartTime).fromNow()),
                            if (state.events[index].userCount != null) ...[
                              const Divider(),
                              Text(translate('events.interested', args: {'count': state.events[index].userCount ?? -1})),
                            ],
                            if (state.events[index].creator?.username != null) ...[
                              const Divider(),
                              Text(state.events[index].creator!.username!),
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
