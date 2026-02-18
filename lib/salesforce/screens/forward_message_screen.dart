import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/salesforce/model/chat_history_model.dart';
import 'package:whatsapp/salesforce/model/drawer_list_item_model.dart';
import 'package:whatsapp/salesforce/screens/sf_message_chat_screen.dart';
import 'package:whatsapp/utils/app_utils.dart';

class ForwardMessageScreen extends StatefulWidget {
  final String? message;
  final String? attachmentUrl;
  final String? contentType;

  const ForwardMessageScreen({
    Key? key,
    this.message,
    this.attachmentUrl,
    this.contentType,
  }) : super(key: key);

  @override
  State<ForwardMessageScreen> createState() => _ForwardMessageScreenState();
}

class _ForwardMessageScreenState extends State<ForwardMessageScreen> {
  List<SfDrawerItemModel> filteredContacts = [];
  List<SfDrawerItemModel> selectedContacts = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  void _loadContacts() {
    final dashBoardController = Provider.of<DashBoardController>(context, listen: false);
    // Get all contacts - recent chats and pinned
    List<SfDrawerItemModel> allContacts = [];

    // Add pinned contacts
    allContacts.addAll(dashBoardController.pinnedConfigItems);
    
    // Add recent chats
    allContacts.addAll(dashBoardController.sfRecentChatList);

    // Remove duplicates based on phone number
    Set<String> uniqueNumbers = <String>{};
    filteredContacts = allContacts.where((contact) {
      String phoneNumber = "${contact.countryCode ?? ''}${contact.whatsappNumber ?? ''}";
      if (uniqueNumbers.contains(phoneNumber)) {
        return false;
      }
      uniqueNumbers.add(phoneNumber);
      return true;
    }).toList();

    setState(() {});
  }

  void _filterContacts(String query) {
    final dashBoardController = Provider.of<DashBoardController>(context, listen: false);
    List<SfDrawerItemModel> allContacts = [];

    // Add pinned contacts
    allContacts.addAll(dashBoardController.pinnedConfigItems);
    
    // Add recent chats
    allContacts.addAll(dashBoardController.sfRecentChatList);

    // Remove duplicates based on phone number
    Set<String> uniqueNumbers = <String>{};
    List<SfDrawerItemModel> uniqueContacts = allContacts.where((contact) {
      String phoneNumber = "${contact.countryCode ?? ''}${contact.whatsappNumber ?? ''}";
      if (uniqueNumbers.contains(phoneNumber)) {
        return false;
      }
      uniqueNumbers.add(phoneNumber);
      return true;
    }).toList();

    if (query.isEmpty) {
      filteredContacts = uniqueContacts;
    } else {
      filteredContacts = uniqueContacts.where((contact) {
        String name = contact.name?.toLowerCase() ?? '';
        String phoneNumber = "${contact.countryCode ?? ''}${contact.whatsappNumber ?? ''}";
        return name.contains(query.toLowerCase()) || phoneNumber.contains(query);
      }).toList();
    }

    setState(() {});
  }

  void _forwardToContact(SfDrawerItemModel contact) async {
    final chatController = Provider.of<ChatMessageController>(context, listen: false);
    final dashBoardController = Provider.of<DashBoardController>(context, listen: false);

    // Set the selected contact to navigate to their chat
    dashBoardController.setSelectedContaactInfo(contact);

    String phoneNumber = "${contact.whatsappNumber ?? ''}";
    String countryCode = "${contact.countryCode ?? '91'}";

    // If it's a text message, send it directly
    if (widget.message != null && widget.message!.isNotEmpty) {
      await chatController.sendMessageApiCall(
        msg: "${widget.message!}",
        usrNumber: phoneNumber,
        code: countryCode,
      );
    }
    // If it's an attachment, you would need to implement file forwarding
    else if (widget.attachmentUrl != null && widget.attachmentUrl!.isNotEmpty) {
      // For now, we'll show a message - in a real implementation you would forward the file
      // await chatController.sendFileToContact(
      //   attachmentUrl: widget.attachmentUrl!,
      //   contentType: widget.contentType ?? '',
      //   usrNumber: phoneNumber,
      //   code: countryCode,
      // );
    }

    // Show success message first
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message forwarded successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    // Navigate to the chat screen with the selected contact
    Navigator.pop(context); // Close the forward screen first
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SfMessageChatScreen(
          isFromRecentChat: false,
        ),
      ),
    );
  }

  void _forwardToSelectedContacts() async {
    if (selectedContacts.isEmpty) return;

    final chatController = Provider.of<ChatMessageController>(context, listen: false);
    final dashBoardController = Provider.of<DashBoardController>(context, listen: false);

    int successCount = 0;
    int totalContacts = selectedContacts.length;

    // Show loading indicator
    EasyLoading.show(status: 'Forwarding to $totalContacts contacts...');

    try {
      for (int i = 0; i < selectedContacts.length; i++) {
        final contact = selectedContacts[i];
        
        // Set the selected contact
        dashBoardController.setSelectedContaactInfo(contact);

        String phoneNumber = "${contact.whatsappNumber ?? ''}";
        String countryCode = "${contact.countryCode ?? '91'}";

        // Forward the message
        if (widget.message != null && widget.message!.isNotEmpty) {
          await chatController.sendMessageApiCall(
            msg: "FW: ${widget.message!}",
            usrNumber: phoneNumber,
            code: countryCode,
          );
          successCount++;
        }
        // Forward attachment
        else if (widget.attachmentUrl != null && widget.attachmentUrl!.isNotEmpty) {
          // For attachments, you would implement file forwarding logic here
          successCount++;
        }

        // Add small delay between forwards to avoid rate limiting
        if (i < selectedContacts.length - 1) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }

      EasyLoading.dismiss();
      
      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully forwarded to $successCount/$totalContacts contacts'),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // Close the screen
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

    } catch (e) {
      EasyLoading.dismiss();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error forwarding messages: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Forward Message'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (selectedContacts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _forwardToSelectedContacts,
              tooltip: 'Forward to ${selectedContacts.length} contacts',
            ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _filterContacts,
              decoration: const InputDecoration(
                hintText: 'Search contacts...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
              ),
            ),
          ),
          
          // Contacts list
          Expanded(
            child: filteredContacts.isEmpty
                ? const Center(
                    child: Text(
                      'No contacts available',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contact = filteredContacts[index];
                      String phoneNumber = "${contact.countryCode ?? ''}${contact.whatsappNumber ?? ''}";

                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Theme.of(context).primaryColor,
                            child: Text(
                              contact.name?.isNotEmpty == true
                                  ? contact.name![0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(contact.name ?? 'Unknown Contact'),
                          subtitle: Text("${contact.countryCode ?? ''}${contact.whatsappNumber ?? ''}"),
                          trailing: Icon(
                            selectedContacts.contains(contact) 
                              ? Icons.check_circle 
                              : Icons.circle_outlined,
                            color: selectedContacts.contains(contact) 
                              ? Theme.of(context).primaryColor 
                              : Colors.grey,
                          ),
                          onTap: () {
                            setState(() {
                              if (selectedContacts.contains(contact)) {
                                selectedContacts.remove(contact);
                              } else {
                                selectedContacts.add(contact);
                              }
                            });
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}