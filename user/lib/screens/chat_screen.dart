//
//
//
// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:intl/intl.dart';
// import 'package:encrypt/encrypt.dart' as encrypt;
//
// class ChatScreen extends StatefulWidget {
//   final String rideRequestId;
//   final String userId;
//   final String userName;
//   final String helperId;
//   final String helperName;
//
//   const ChatScreen({
//     Key? key,
//     required this.rideRequestId,
//     required this.userId,
//     required this.userName,
//     required this.helperId,
//     required this.helperName,
//   }) : super(key: key);
//
//   @override
//   _ChatScreenState createState() => _ChatScreenState();
// }
//
// class _ChatScreenState extends State<ChatScreen> {
//   final DatabaseReference _chatRef = FirebaseDatabase.instance.ref().child("Chats");
//   final DatabaseReference _unseenMessagesRef = FirebaseDatabase.instance.ref().child("UnseenMessages");
//   final TextEditingController _messageController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//
//   List<Map<String, dynamic>> _messages = [];
//   Color _chatColor = Colors.blueAccent;
//   bool _isSending = false;
//
//   // AES Encryption Setup
//   static const String _keyString = '12345678901234567890123456789012';
//   static const String _ivString = '1234567890123456';
//
//   late final encrypt.Key _key;
//   late final encrypt.IV _iv;
//   late final encrypt.Encrypter _encrypter;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeEncryption();
//     _loadMessages();
//     _resetUnseenCount();
//     _listenForNewMessages();
//   }
//
//   @override
//   void dispose() {
//     _messageController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   void _initializeEncryption() {
//     _key = encrypt.Key.fromUtf8(_keyString);
//     _iv = encrypt.IV.fromUtf8(_ivString);
//     _encrypter = encrypt.Encrypter(encrypt.AES(_key));
//   }
//
//   String _encryptMessage(String message) {
//     final encrypted = _encrypter.encrypt(message, iv: _iv);
//     return encrypted.base64;
//   }
//
//   String _decryptMessage(String encryptedMessage) {
//     try {
//       final encrypted = encrypt.Encrypted.fromBase64(encryptedMessage);
//       return _encrypter.decrypt(encrypted, iv: _iv);
//     } catch (e) {
//       return '[Message could not be decrypted]';
//     }
//   }
//
//   void _loadMessages() {
//     _chatRef.child(widget.rideRequestId).onChildAdded.listen((event) {
//       if (event.snapshot.value != null) {
//         final data = event.snapshot.value as Map<dynamic, dynamic>;
//         final message = Map<String, dynamic>.from(data);
//
//         if (message['message'] != null) {
//           message['message'] = _decryptMessage(message['message'] as String);
//         }
//
//         setState(() {
//           _messages.add(message);
//           _messages.sort((a, b) => (a["timestamp"] as int).compareTo(b["timestamp"] as int));
//         });
//
//         _scrollToBottom();
//       }
//     });
//   }
//
//   void _scrollToBottom() {
//     Future.delayed(const Duration(milliseconds: 100), () {
//       if (_scrollController.hasClients) {
//         _scrollController.animateTo(
//           _scrollController.position.maxScrollExtent,
//           duration: const Duration(milliseconds: 200),
//           curve: Curves.easeOut,
//         );
//       }
//     });
//   }
//
//   void _listenForNewMessages() {
//     _chatRef.child(widget.rideRequestId).onChildAdded.listen((event) {
//       if (event.snapshot.value != null) {
//         final data = event.snapshot.value as Map<dynamic, dynamic>;
//         final message = Map<String, dynamic>.from(data);
//
//         if (message['senderId'] != widget.userId) {
//           _updateUnseenCount(widget.userId);
//         }
//       }
//     });
//   }
//
//   void _resetUnseenCount() {
//     _unseenMessagesRef
//         .child(widget.rideRequestId)
//         .child(widget.userId)
//         .set(0);
//   }
//
//   void _updateUnseenCount(String userId) {
//     _unseenMessagesRef
//         .child(widget.rideRequestId)
//         .child(userId)
//         .get()
//         .then((snapshot) {
//       int currentCount = snapshot.exists ? int.parse(snapshot.value.toString()) : 0;
//       _unseenMessagesRef
//           .child(widget.rideRequestId)
//           .child(userId)
//           .set(currentCount + 1);
//     });
//   }
//
//   Future<void> _sendMessage() async {
//     if (_messageController.text.isNotEmpty && !_isSending) {
//       final messageText = _messageController.text;
//       _messageController.clear();
//
//       setState(() {
//         _isSending = true;
//       });
//
//       try {
//         final encryptedMessage = _encryptMessage(messageText);
//         final now = DateTime.now();
//
//         final messageData = {
//           "senderId": widget.userId,
//           "senderName": widget.userName,
//           "message": encryptedMessage,
//           "timestamp": now.millisecondsSinceEpoch,
//           "status": "sent",
//         };
//
//         await _chatRef.child(widget.rideRequestId).push().set(messageData);
//         _updateUnseenCount(widget.helperId);
//
//       } catch (e) {
//         // Show error snackbar
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to send message: ${e.toString()}'),
//             backgroundColor: Colors.red,
//           ),
//         );
//
//         // Restore the message text for retry
//         _messageController.text = messageText;
//       } finally {
//         setState(() {
//           _isSending = false;
//         });
//       }
//     }
//   }
//
//   void _changeChatColor(Color color) {
//     setState(() {
//       _chatColor = color;
//     });
//   }
//
//   String _formatTimestamp(int timestamp) {
//     final now = DateTime.now();
//     final messageTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
//     final difference = now.difference(messageTime);
//
//     if (difference.inDays == 0) {
//       return DateFormat('hh:mm a').format(messageTime);
//     } else if (difference.inDays == 1) {
//       return 'Yesterday ${DateFormat('hh:mm a').format(messageTime)}';
//     } else {
//       return DateFormat('MMM dd, hh:mm a').format(messageTime);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: _chatColor,
//         iconTheme: const IconThemeData(color: Colors.white),
//         title: Text(
//           "Chat with ${widget.helperName}",
//           style: const TextStyle(color: Colors.white),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.delete, color: Colors.white),
//             onPressed: () {
//               showDialog(
//                 context: context,
//                 builder: (context) => AlertDialog(
//                   title: const Text('Delete Chat'),
//                   content: const Text('Are you sure you want to delete this chat?'),
//                   actions: [
//                     TextButton(
//                       child: const Text('Cancel'),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                     TextButton(
//                       child: const Text('Delete'),
//                       onPressed: () {
//                         _chatRef.child(widget.rideRequestId).remove();
//                         Navigator.pop(context);
//                         Navigator.pop(context);
//                       },
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//           PopupMenuButton<Color>(
//             onSelected: _changeChatColor,
//             itemBuilder: (BuildContext context) {
//               return [
//                 const PopupMenuItem(
//                   value: Colors.blueAccent,
//                   child: Text('Blue', style: TextStyle(color: Colors.blueAccent)),
//                 ),
//                 const PopupMenuItem(
//                   value: Colors.green,
//                   child: Text('Green', style: TextStyle(color: Colors.green)),
//                 ),
//                 const PopupMenuItem(
//                   value: Colors.red,
//                   child: Text('Red', style: TextStyle(color: Colors.red)),
//                 ),
//                 const PopupMenuItem(
//                   value: Colors.purple,
//                   child: Text('Purple', style: TextStyle(color: Colors.purple)),
//                 ),
//               ];
//             },
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               controller: _scrollController,
//               padding: const EdgeInsets.symmetric(vertical: 10),
//               itemCount: _messages.length,
//               itemBuilder: (context, index) {
//                 final message = _messages[index];
//                 final isCurrentUser = message["senderId"] == widget.userId;
//                 final timestamp = _formatTimestamp(message["timestamp"]);
//
//                 return Align(
//                   alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//                     constraints: BoxConstraints(
//                       maxWidth: MediaQuery.of(context).size.width * 0.75,
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       mainAxisAlignment: isCurrentUser
//                           ? MainAxisAlignment.end
//                           : MainAxisAlignment.start,
//                       crossAxisAlignment: CrossAxisAlignment.end,
//                       children: [
//                         if (!isCurrentUser)
//                           Padding(
//                             padding: const EdgeInsets.only(right: 10),
//                             child: CircleAvatar(
//                               radius: 18,
//                               backgroundColor: Colors.blue,
//                               child: const Icon(
//                                 Icons.person,
//                                 color: Colors.white,
//                                 size: 20,
//                               ),
//                             ),
//                           ),
//                         Flexible(
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                                 vertical: 10, horizontal: 14),
//                             decoration: BoxDecoration(
//                               color: isCurrentUser ? _chatColor : Colors.grey[200],
//                               borderRadius: BorderRadius.only(
//                                 topLeft: const Radius.circular(20),
//                                 topRight: const Radius.circular(20),
//                                 bottomLeft: isCurrentUser
//                                     ? const Radius.circular(20)
//                                     : const Radius.circular(0),
//                                 bottomRight: isCurrentUser
//                                     ? const Radius.circular(0)
//                                     : const Radius.circular(20),
//                               ),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.1),
//                                   blurRadius: 5,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ],
//                             ),
//                             child: Column(
//                               crossAxisAlignment: isCurrentUser
//                                   ? CrossAxisAlignment.end
//                                   : CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   message["message"] ?? "[Decryption Failed]",
//                                   style: TextStyle(
//                                     color: isCurrentUser ? Colors.white : Colors.black87,
//                                     fontSize: 16,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 6),
//                                 Row(
//                                   mainAxisSize: MainAxisSize.min,
//                                   children: [
//                                     Text(
//                                       timestamp,
//                                       style: TextStyle(
//                                         fontSize: 12,
//                                         color: isCurrentUser ? Colors.white70 : Colors.black54,
//                                       ),
//                                     ),
//                                     if (isCurrentUser) ...[
//                                       const SizedBox(width: 4),
//                                       Icon(
//                                         Icons.done_all,
//                                         size: 14,
//                                         color: message["status"] == "read"
//                                             ? Colors.white
//                                             : Colors.white70,
//                                       ),
//                                     ],
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                         if (isCurrentUser)
//                           Padding(
//                             padding: const EdgeInsets.only(left: 10),
//                             child: CircleAvatar(
//                               radius: 18,
//                               backgroundColor: Colors.green,
//                               child: const Icon(
//                                 Icons.person,
//                                 color: Colors.white,
//                                 size: 20,
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _messageController,
//                     enabled: !_isSending,
//                     decoration: InputDecoration(
//                       hintText: _isSending ? "Sending..." : "Type a message...",
//                       filled: true,
//                       fillColor: Colors.grey[100],
//                       contentPadding: const EdgeInsets.symmetric(
//                           vertical: 15, horizontal: 20),
//                       suffixIcon: IconButton(
//                         icon: Icon(
//                           Icons.send,
//                           color: _isSending ? Colors.grey : Colors.blue,
//                         ),
//                         onPressed: _isSending ? null : _sendMessage,
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(50),
//                         borderSide: BorderSide.none,
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(50),
//                         borderSide: const BorderSide(color: Colors.grey, width: 1),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(50),
//                         borderSide: BorderSide(color: _chatColor, width: 1.5),
//                       ),
//                     ),
//                     onSubmitted: (_) => _sendMessage(),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class ChatScreen extends StatefulWidget {
  final String rideRequestId;
  final String userId;
  final String userName;
  final String helperId;
  final String helperName;

  const ChatScreen({
    Key? key,
    required this.rideRequestId,
    required this.userId,
    required this.userName,
    required this.helperId,
    required this.helperName,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final DatabaseReference _chatRef = FirebaseDatabase.instance.ref().child("Chats");
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  Color _chatColor = Colors.blueAccent;
  bool _isSending = false;

  // AES Encryption Setup
  static const String _keyString = '12345678901234567890123456789012';
  static const String _ivString = '1234567890123456';
  late final encrypt.Key _key;
  late final encrypt.IV _iv;
  late final encrypt.Encrypter _encrypter;

  @override
  void initState() {
    super.initState();
    _initializeEncryption();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeEncryption() {
    _key = encrypt.Key.fromUtf8(_keyString);
    _iv = encrypt.IV.fromUtf8(_ivString);
    _encrypter = encrypt.Encrypter(encrypt.AES(_key));
  }

  String _encryptMessage(String message) {
    final encrypted = _encrypter.encrypt(message, iv: _iv);
    return encrypted.base64;
  }

  String _decryptMessage(String encryptedMessage) {
    try {
      final encrypted = encrypt.Encrypted.fromBase64(encryptedMessage);
      return _encrypter.decrypt(encrypted, iv: _iv);
    } catch (e) {
      return '[Message could not be decrypted]';
    }
  }

  void _loadMessages() {
    _chatRef.child(widget.rideRequestId).onChildAdded.listen((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        final message = Map<String, dynamic>.from(data);
        if (message['message'] != null) {
          message['message'] = _decryptMessage(message['message'] as String);
        }
        setState(() {
          _messages.add(message);
          _messages.sort((a, b) => (a["timestamp"] as int).compareTo(b["timestamp"] as int));
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isNotEmpty && !_isSending) {
      final messageText = _messageController.text;
      _messageController.clear();
      setState(() {
        _isSending = true;
      });
      try {
        final encryptedMessage = _encryptMessage(messageText);
        final now = DateTime.now();
        final messageData = {
          "senderId": widget.userId,
          "senderName": widget.userName,
          "message": encryptedMessage,
          "timestamp": now.millisecondsSinceEpoch,
          "status": "sent",
        };
        await _chatRef.child(widget.rideRequestId).push().set(messageData);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        _messageController.text = messageText;
      } finally {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _changeChatColor(Color color) {
    setState(() {
      _chatColor = color;
    });
  }

  String _formatTimestamp(int timestamp) {
    final now = DateTime.now();
    final messageTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final difference = now.difference(messageTime);
    if (difference.inDays == 0) {
      return DateFormat('hh:mm a').format(messageTime);
    } else if (difference.inDays == 1) {
      return 'Yesterday ${DateFormat('hh:mm a').format(messageTime)}';
    } else {
      return DateFormat('MMM dd, hh:mm a').format(messageTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: _chatColor,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "Chat with ${widget.helperName}",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Chat'),
                  content: const Text('Are you sure you want to delete this chat?'),
                  actions: [
                    TextButton(
                      child: const Text('Cancel'),
                      onPressed: () => Navigator.pop(context),
                    ),
                    TextButton(
                      child: const Text('Delete'),
                      onPressed: () {
                        _chatRef.child(widget.rideRequestId).remove();
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          PopupMenuButton<Color>(
            onSelected: _changeChatColor,
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(
                  value: Colors.blueAccent,
                  child: Text('Blue', style: TextStyle(color: Colors.blueAccent)),
                ),
                const PopupMenuItem(
                  value: Colors.green,
                  child: Text('Green', style: TextStyle(color: Colors.green)),
                ),
                const PopupMenuItem(
                  value: Colors.red,
                  child: Text('Red', style: TextStyle(color: Colors.red)),
                ),
                const PopupMenuItem(
                  value: Colors.purple,
                  child: Text('Purple', style: TextStyle(color: Colors.purple)),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isCurrentUser = message["senderId"] == widget.userId;
                final timestamp = _formatTimestamp(message["timestamp"]);
                return Align(
                  alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!isCurrentUser)
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.blue,
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                            decoration: BoxDecoration(
                              color: isCurrentUser ? _chatColor : Colors.grey[200],
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(20),
                                topRight: const Radius.circular(20),
                                bottomLeft: isCurrentUser ? const Radius.circular(20) : const Radius.circular(0),
                                bottomRight: isCurrentUser ? const Radius.circular(0) : const Radius.circular(20),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  message["message"] ?? "[Decryption Failed]",
                                  style: TextStyle(
                                    color: isCurrentUser ? Colors.white : Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      timestamp,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isCurrentUser ? Colors.white70 : Colors.black54,
                                      ),
                                    ),
                                    if (isCurrentUser) ...[
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.done_all,
                                        size: 14,
                                        color: Colors.white70,
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (isCurrentUser)
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.green,
                              child: const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    enabled: !_isSending,
                    decoration: InputDecoration(
                      hintText: _isSending ? "Sending..." : "Type a message...",
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          Icons.send,
                          color: _isSending ? Colors.grey : Colors.blue,
                        ),
                        onPressed: _isSending ? null : _sendMessage,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: const BorderSide(color: Colors.grey, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(color: _chatColor, width: 1.5),
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}