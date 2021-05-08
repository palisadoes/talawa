//flutter packages are called here
import 'package:flutter/material.dart';

//pages are called here
import 'package:provider/provider.dart';
import 'package:talawa/controllers/events_controller.dart';
import 'package:talawa/utils/custom_toast.dart';
import 'package:talawa/utils/gql_client.dart';
import 'package:talawa/utils/uidata.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';
import 'package:talawa/views/pages/chat/chat.dart';

class Groups extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        key: const Key('GROUPS_APP_BAR'),
        title: const Text(
          'Chats',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder(
        future: Provider.of<EventController>(
          context,
          listen: false,
        ).getEventsOnInitialise(),
        builder: (BuildContext context, AsyncSnapshot<void> snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (Provider.of<EventController>(context).isScreenEmpty) {
            return Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  Container(
                    alignment: Alignment.center,
                    //Text for empty chat groups
                    child: const Text(
                      "Register in an event to start chatting",
                      key: Key('empty_chat_group'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  const Spacer(),
                  //Shows spinner while fetching is performed
                  //else shows a refresh text button with icon
                  !Provider.of<EventController>(context).isDataFetched
                      ? const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : TextButton.icon(
                          key: const Key('click_to_refresh_button'),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Click to Refresh..'),
                          onPressed: () async {
                            try {
                              await Provider.of<EventController>(context,
                                      listen: false)
                                  .getEvents();
                            } catch (e) {
                              CustomToast.exceptionToast(msg: e.toString());
                            }
                          },
                        ),
                ],
              ),
            );
          }

          final List displayedEvents =
              Provider.of<EventController>(context).getDisplayedEvents;

          return RefreshIndicator(
            onRefresh: () async {
              try {
                await Provider.of<EventController>(
                  context,
                  listen: false,
                ).getEvents();
              } catch (e) {
                CustomToast.exceptionToast(msg: e.toString());
              }
            },
            child: ListView.builder(
              itemCount: displayedEvents.length,
              itemBuilder: (context, index) {
                final String _groupName = '${displayedEvents[index]['title']}';
                final String _imgSrc =
                    displayedEvents[index]['organization']['image'] as String;
                final String _imgRoute =
                    Provider.of<GraphQLConfiguration>(context).displayImgRoute;

                return Card(
                  child: ListTile(
                    title: Text(_groupName),
                    leading: CircleAvatar(
                      backgroundColor: UIData.secondaryColor,
                      child: _imgSrc == null
                          ? Image.asset(UIData.talawaLogo)
                          : NetworkImage(_imgRoute + _imgSrc) as Widget,
                    ),
                    trailing: const Icon(Icons.arrow_right),
                    onTap: () {
                      pushNewScreen(
                        context,
                        screen: Chat(groupName: _groupName),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
