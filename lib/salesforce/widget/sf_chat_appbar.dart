// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/salesforce/widget/sf_call_history_dialog.dart';
import 'package:whatsapp/utils/app_constants.dart';
import 'package:whatsapp/views/view/call/call_screen.dart';
// import 'package:provider/provider.dart';
// import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
// import 'package:whatsapp/salesforce/controller/drawer_controller.dart';

class SfChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SfChatAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        "Chats",
        style: TextStyle(color: Colors.white),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: InkWell(
            onTap: () {
              ChatMessageController chatController =
                  Provider.of(context, listen: false);

              DashBoardController dbProvider =
                  Provider.of(context, listen: false);
              var wpCode = dbProvider.selectedContactInfo?.countryCode ?? "91";
              var wpNum = dbProvider.selectedContactInfo?.whatsappNumber ?? "";
              String fullNum = wpCode + wpNum;
              chatController
                  .callHistoryApiCall(userNumber: fullNum)
                  .then((value) {
                showSfCallDialog(dbProvider.selectedContactInfo?.name ?? "",
                    context, chatController.callHistoryList, () async {
                  final prefs = await SharedPreferences.getInstance();
                  final token =
                      prefs.getString(SharedPrefsConstants.sfNodeToken) ?? "";
                  if (token.isEmpty) {
                    EasyLoading.showToast("Something went wrong");
                  } else {
                    final decoded = JwtDecoder.decode(token);
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CallScreen(
                            token: token,
                            userData: decoded,
                            // parentId: widget.id ?? "",
                            wpNumber: fullNum,
                            leadName:
                                dbProvider.selectedContactInfo?.name ?? ""),
                      ),
                    );
                  }
                });
              });
            },
            child: const Icon(
              Icons.call,
              color: Colors.white,
            ),
          ),
        )
      ],

      //  GestureDetector(
      //   onTap: () async {
      //     // Optional: Add profile tap action
      //   },
      //   child: Row(
      //     children: [
      //       const CircleAvatar(
      //         backgroundImage: NetworkImage(
      //           'https://www.w3schools.com/w3images/avatar2.png',
      //         ),
      //       ),
      //       const SizedBox(width: 10),
      //       Expanded(
      //         child: Consumer<DashBoardController>(
      //           builder: (context, dbRef, child) {
      //             return Text(
      //               dbRef.selectedContactInfo?.name ?? "",
      //               style: const TextStyle(color: Colors.white),
      //             );
      //           },
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
      // actions: [
      //   Consumer<ChatMessageController>(builder: (context, msgCtrol, child) {
      //     return msgCtrol.msgDeleteList.isEmpty
      //         ? const SizedBox()
      //         : InkWell(
      //             onTap: () {
      //               DashBoardController dbController =
      //                   Provider.of(context, listen: false);

      //               String code =
      //                   dbController.selectedContactInfo?.countryCode ?? "91";
      //               String num =
      //                   dbController.selectedContactInfo?.whatsappNumber ?? "";
      //               String whatsappNum = "$code$num";
      //               msgCtrol.chatMsgDeleteApiCall(whatsappNum);
      //             },
      //             child: const Icon(
      //               Icons.delete,
      //               color: Colors.white,
      //             ),
      //           );
      //   }),
      //   PopupMenuButton<String>(
      //     icon: const Icon(Icons.more_vert, color: Colors.white),
      //     onSelected: (String value) {
      //       if (value == 'Clear Chat') {
      //         ChatMessageController messageController =
      //             Provider.of(context, listen: false);
      //         DashBoardController dbController =
      //             Provider.of(context, listen: false);

      //         String usrNumber =
      //             dbController.selectedContactInfo?.whatsappNumber ?? "";
      //         String code =
      //             dbController.selectedContactInfo?.countryCode ?? "91";
      //         var wpNum = "$code$usrNumber";
      //         messageController.deleteHistoryApiCall(wpNum);
      //       }
      //     },
      //     itemBuilder: (BuildContext context) => const [
      //       PopupMenuItem<String>(
      //         value: 'Clear Chat',
      //         child: Text('Clear Chat'),
      //       ),
      //     ],
      //   ),
      // ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
