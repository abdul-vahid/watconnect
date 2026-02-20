import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:whatsapp/salesforce/controller/chat_message_controller.dart';
import 'package:whatsapp/salesforce/controller/sf_file_upload_controller.dart';
import 'package:whatsapp/salesforce/controller/drawer_controller.dart';
import 'package:whatsapp/salesforce/controller/template_controller.dart';
import 'package:whatsapp/salesforce/model/drawer_list_item_model.dart';
import 'package:whatsapp/salesforce/screens/sf_message_chat_screen.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';

class ForwardMessageScreen extends StatefulWidget {
  final String? message;
  final String? attachmentUrl;
  final String? contentType;
  final String? templateId;
  final List<String>? templateParams;
  final List<Map<String, dynamic>>? multipleMessages; 
  final List<Map<String, dynamic>>? multipleAttachments; 

  const ForwardMessageScreen({
    Key? key,
    this.message,
    this.attachmentUrl,
    this.contentType,
    this.templateId,
    this.templateParams,
    this.multipleMessages,
    this.multipleAttachments,
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
    // If it's a template, forward the template
    else if (widget.templateId != null && widget.templateId!.isNotEmpty) {
      await _forwardTemplate(
        chatController: chatController,
        phoneNumber: phoneNumber,
        countryCode: countryCode,
        templateId: widget.templateId!,
        templateParams: widget.templateParams ?? [],
      );
    }
    // If it's an attachment, implement file forwarding
    else if (widget.attachmentUrl != null && widget.attachmentUrl!.isNotEmpty) {
      await _forwardAttachment(
        chatController: chatController,
        phoneNumber: phoneNumber,
        countryCode: countryCode,
        attachmentUrl: widget.attachmentUrl!,
        contentType: widget.contentType ?? '',
      );
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

  Widget _buildMultipleMessagesPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Messages to forward:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.multipleMessages!.length} messages',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Show previews of all messages
          Column(
            children: widget.multipleMessages!.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> message = entry.value;
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        message['message'] ?? 'No message content',
                        style: const TextStyle(fontSize: 14),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleAttachmentsPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Attachments to forward:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.multipleAttachments!.length} images',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Show previews of all attachments
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: widget.multipleAttachments!.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> attachment = widget.multipleAttachments![index];
              String? contentType = attachment['contentType'];
              String? attachmentUrl = attachment['attachmentUrl'];
              
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: contentType?.contains('image') == true && attachmentUrl != null
                    ? Image.network(
                        attachmentUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 30,
                              color: Colors.grey,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: Icon(
                          _getAttachmentIcon(contentType ?? ''),
                          size: 30,
                          color: Colors.grey,
                        ),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  IconData _getAttachmentIcon(String contentType) {
    if (contentType.contains('pdf')) {
      return Icons.picture_as_pdf;
    } else if (contentType.contains('audio')) {
      return Icons.audiotrack;
    } else if (contentType.contains('video')) {
      return Icons.video_file;
    } else if (contentType.contains('text')) {
      return Icons.text_snippet;
    } else {
      return Icons.insert_drive_file;
    }
  }

  // Future<void> _saveImageToGallery() async {
  //   if (widget.attachmentUrl == null || widget.attachmentUrl!.isEmpty) {
  //     EasyLoading.showToast('No image to save');
  //     return;
  //   }

  //   try {
  //     EasyLoading.show(status: 'Saving image to gallery...');

  //     // Check and request storage permission
  //     var status = await Permission.storage.request();
  //     if (!status.isGranted) {
  //       EasyLoading.dismiss();
  //       EasyLoading.showToast('Storage permission required to save images');
  //       return;
  //     }

  //     // Download the image
  //     final response = await http.get(Uri.parse(widget.attachmentUrl!));
  //     if (response.statusCode == 200) {
  //       // Save to gallery
  //       final result = await ImageGallerySaver.saveImage(
  //         response.bodyBytes,
  //         quality: 100,
  //         name: "watconnect_image_${DateTime.now().millisecondsSinceEpoch}",
  //       );

  //       EasyLoading.dismiss();
        
  //       if (result['isSuccess'] == true) {
  //         EasyLoading.showToast('Image saved to gallery successfully');
  //       } else {
  //         EasyLoading.showToast('Failed to save image to gallery');
  //       }
  //     } else {
  //       throw Exception('Failed to download image');
  //     }
  //   } catch (e) {
  //     EasyLoading.dismiss();
  //     EasyLoading.showToast('Error saving image: ${e.toString().split(':').first}');
  //     debugPrint('Save image error: $e');
  //   }
  // }

  Future<void> _forwardTemplate({
    required ChatMessageController chatController,
    required String phoneNumber,
    required String countryCode,
    required String templateId,
    required List<String> templateParams,
  }) async {
    try {
      // Get the template controller
      final templateController = Provider.of<TemplateController>(context, listen: false);
      
      // Show loading
      EasyLoading.show(status: 'Forwarding template...');
      
      // Forward the template
      final fullNumber = "$countryCode$phoneNumber";
      await templateController.sendTemplateApiCall(
        tempId: templateId,
        usrNumber: fullNumber,
        params: templateParams,
      );
      
      EasyLoading.dismiss();
      EasyLoading.showToast('Template forwarded successfully');
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showToast('Failed to forward template: ${e.toString().split(':').first}');
      debugPrint('Forward template error: $e');
    }
  }

  Future<void> _forwardAttachment({
    required ChatMessageController chatController,
    required String phoneNumber,
    required String countryCode,
    required String attachmentUrl,
    required String contentType,
  }) async {
    try {
      // Show loading
      EasyLoading.show(status: 'Forwarding attachment...');
      
      // Get the file upload controller
      final sfFileUploadController = Provider.of<SfFileUploadController>(context, listen: false);
      
      // For image forwarding, we need to download the image first and then upload it
      if (contentType.contains('image')) {
        // Download the image from the URL
        final response = await http.get(Uri.parse(attachmentUrl));
        if (response.statusCode == 200) {
          // Create a temporary file
          final tempDir = await getTemporaryDirectory();
          final fileName = attachmentUrl.split('/').last;
          final tempFile = File('${tempDir.path}/$fileName');
          
          // Write the image data to the temporary file
          await tempFile.writeAsBytes(response.bodyBytes);
          
          // Upload and send the file
          final fullNumber = "$countryCode$phoneNumber";
          await sfFileUploadController.uploadFiledb(
            tempFile, 
            countryCode, 
            "", // No caption for forwarded images
            phoneNumber
          );
          
          // Clean up temporary file
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
          
          EasyLoading.dismiss();
          EasyLoading.showToast('Image forwarded successfully');
        } else {
          throw Exception('Failed to download image');
        }
      } else {
        // For other file types, show a message that forwarding is not supported yet
        EasyLoading.dismiss();
        EasyLoading.showToast('File forwarding not supported yet');
      }
    } catch (e) {
      EasyLoading.dismiss();
      EasyLoading.showToast('Failed to forward attachment: ${e.toString().split(':').first}');
      debugPrint('Forward attachment error: $e');
    }
  }

  Future<void> _forwardAttachmentToContact({
    required String phoneNumber,
    required String countryCode,
    required String attachmentUrl,
    required String contentType,
  }) async {
    try {
      // Get the file upload controller
      final sfFileUploadController = Provider.of<SfFileUploadController>(context, listen: false);
      
      // For image forwarding, download and upload the image
      if (contentType.contains('image')) {
        // Download the image from the URL
        final response = await http.get(Uri.parse(attachmentUrl));
        if (response.statusCode == 200) {
          // Create a temporary file
          final tempDir = await getTemporaryDirectory();
          final fileName = attachmentUrl.split('/').last;
          final tempFile = File('${tempDir.path}/$fileName');
          
          // Write the image data to the temporary file
          await tempFile.writeAsBytes(response.bodyBytes);
          
          // Upload and send the file
          await sfFileUploadController.uploadFiledb(
            tempFile, 
            countryCode, 
            "", // No caption for forwarded images
            phoneNumber
          );
          
          // Clean up temporary file
          if (await tempFile.exists()) {
            await tempFile.delete();
          }
        } else {
          throw Exception('Failed to download image');
        }
      }
    } catch (e) {
      debugPrint('Forward attachment to contact error: $e');
      // Don't show error to user during batch forwarding to avoid spam
    }
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

        // Handle multiple messages
        if (widget.multipleMessages != null && widget.multipleMessages!.isNotEmpty) {
          for (Map<String, dynamic> messageData in widget.multipleMessages!) {
            String? message = messageData['message'];
            if (message != null && message.isNotEmpty) {
              await chatController.sendMessageApiCall(
                msg: message,
                usrNumber: phoneNumber,
                code: countryCode,
              );
              await Future.delayed(const Duration(milliseconds: 200)); // Small delay between messages
            }
          }
          successCount++;
        }
        // Handle multiple attachments
        else if (widget.multipleAttachments != null && widget.multipleAttachments!.isNotEmpty) {
          for (Map<String, dynamic> attachmentData in widget.multipleAttachments!) {
            String? attachmentUrl = attachmentData['attachmentUrl'];
            String? contentType = attachmentData['contentType'];
            
            if (attachmentUrl != null && attachmentUrl.isNotEmpty && contentType != null) {
              await _forwardAttachmentToContact(
                phoneNumber: phoneNumber,
                countryCode: countryCode,
                attachmentUrl: attachmentUrl,
                contentType: contentType,
              );
              await Future.delayed(const Duration(milliseconds: 300)); // Small delay between attachments
            }
          }
          successCount++;
        }
        // Handle single message
        else if (widget.message != null && widget.message!.isNotEmpty) {
          await chatController.sendMessageApiCall(
            msg: "${widget.message!}",
            usrNumber: phoneNumber,
            code: countryCode,
          );
          successCount++;
        }
        // Forward template
        else if (widget.templateId != null && widget.templateId!.isNotEmpty) {
          await _forwardTemplate(
            chatController: chatController,
            phoneNumber: phoneNumber,
            countryCode: countryCode,
            templateId: widget.templateId!,
            templateParams: widget.templateParams ?? [],
          );
          successCount++;
        }
        // Forward single attachment
        else if (widget.attachmentUrl != null && widget.attachmentUrl!.isNotEmpty) {
          await _forwardAttachmentToContact(
            phoneNumber: phoneNumber,
            countryCode: countryCode,
            attachmentUrl: widget.attachmentUrl!,
            contentType: widget.contentType ?? '',
          );
          successCount++;
        }

        // Add delay between contacts to avoid rate limiting
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
          // Always show send button when contacts are selected, regardless of message/attachment
          if (selectedContacts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _forwardToSelectedContacts,
              tooltip: 'Forward to ${selectedContacts.length} contacts',
            ),
          // Only show search icon when no contacts are selected
          if (selectedContacts.isEmpty)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {}, // Search functionality can be implemented here if needed
              tooltip: 'Search contacts',
            ),
        ],
      ),
      body: Column(
        children: [
          // Message/Attachment Preview - Handle multiple items
          if (widget.multipleMessages != null && widget.multipleMessages!.isNotEmpty) ...[
            _buildMultipleMessagesPreview(),
          ] else if (widget.multipleAttachments != null && widget.multipleAttachments!.isNotEmpty) ...[
            _buildMultipleAttachmentsPreview(),
          ] else if (widget.message != null && widget.message!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Message to forward:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.message!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ] else if (widget.attachmentUrl != null && widget.attachmentUrl!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Attachment to forward:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      // Save button for images
                      // if (widget.contentType?.contains('image') ?? false)
                      //   ElevatedButton.icon(
                      //     // onPressed: _saveImageToGallery,
                      //     icon: const Icon(Icons.save_alt, size: 18),
                      //     label: const Text('Save'),
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: Theme.of(context).primaryColor,
                      //       foregroundColor: Colors.white,
                      //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(8),
                      //       ),
                      //     ),
                      //   ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Preview the attachment
                  if (widget.contentType?.contains('image') ?? false)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        widget.attachmentUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            width: double.infinity,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getAttachmentIcon(widget.contentType ?? ''),
                            size: 32,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.contentType?.split('/').last.toUpperCase() ?? 'FILE',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Attachment file',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
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