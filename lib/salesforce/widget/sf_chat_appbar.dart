import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';

class SfChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SfChatAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: GestureDetector(
        onTap: () async {
          // Optional: Add profile tap action
        },
        child: Row(
          children: [
            const CircleAvatar(
              backgroundImage: NetworkImage(
                'https://www.w3schools.com/w3images/avatar2.png',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Consumer<DashBoardController>(
                builder: (context, dbRef, child) {
                  return Text(
                    dbRef.selectedContactInfo?.name ?? "",
                    style: const TextStyle(color: Colors.white),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        Consumer<ChatMessageController>(builder: (context, msgCtrol, child) {
          return msgCtrol.msgDeleteList.isEmpty
              ? SizedBox()
              : InkWell(
                  onTap: () {
                    DashBoardController dbController =
                        Provider.of(context, listen: false);

                    String code =
                        dbController.selectedContactInfo?.countryCode ?? "91";
                    String num =
                        dbController.selectedContactInfo?.whatsappNumber ?? "";
                    String whatsappNum = "$code$num";
                    msgCtrol.chatMsgDeleteApiCall(whatsappNum);
                  },
                  child: Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                );
        }),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (String value) {
            if (value == 'Clear Chat') {
              ChatMessageController messageController =
                  Provider.of(context, listen: false);
              DashBoardController dbController =
                  Provider.of(context, listen: false);

              String usrNumber =
                  dbController.selectedContactInfo?.whatsappNumber ?? "";
              String code =
                  dbController.selectedContactInfo?.countryCode ?? "91";
              var wpNum = "$code$usrNumber";
              messageController.deleteHistoryApiCall(wpNum);
            }
          },
          itemBuilder: (BuildContext context) => const [
            PopupMenuItem<String>(
              value: 'Clear Chat',
              child: Text('Clear Chat'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
