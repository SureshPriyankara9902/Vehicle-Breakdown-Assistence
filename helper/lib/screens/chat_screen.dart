import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String rideRequestId;
  final String userName;
  final String helperName;

  const ChatScreen({
    Key? key,
    required this.rideRequestId,
    required this.userName,
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
  String? _currentUserId;
  bool _isSending = false;
  Color _chatColor = Colors.blueAccent;

  // Secure Key & IV
  final _key = encrypt.Key.fromUtf8('12345678901234567890123456789012');
  final _iv = encrypt.IV.fromUtf8('1234567890123456');
  late final encrypt.Encrypter _encrypter;

  @override
  void initState() {
    super.initState();
    _encrypter = encrypt.Encrypter(encrypt.AES(_key));
    _getCurrentUser();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
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
      print('Decryption error: $e');
      return '[Decryption Failed]';
    }
  }

  void _getCurrentUser() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.uid;
      });
    }
  }

  void _loadMessages() {
    _chatRef.child(widget.rideRequestId).onChildAdded.listen((event) {
      if (event.snapshot.value != null) {
        final messageData = Map<String, dynamic>.from(event.snapshot.value as Map<Object?, Object?>);
        if (messageData['message'] != null) {
          messageData['message'] = _decryptMessage(messageData['message']);
        }
        setState(() {
          _messages.add(messageData);
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
    if (_messageController.text.isNotEmpty && _currentUserId != null && !_isSending) {
      final messageText = _messageController.text;
      _messageController.clear();
      setState(() {
        _isSending = true;
      });
      try {
        final encryptedMessage = _encryptMessage(messageText);
        final now = DateTime.now().millisecondsSinceEpoch;
        final messageData = {
          "senderId": _currentUserId,
          "senderName": (_currentUserId == FirebaseAuth.instance.currentUser?.uid) ? widget.userName : widget.helperName,
          "message": encryptedMessage,
          "timestamp": now,
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
          "Chat with ${widget.userName}",
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
                final isCurrentUser = message["senderId"] == _currentUserId;
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
                                  message["message"] ?? "[Message not available]",
                                  style: TextStyle(
                                    color: isCurrentUser ? Colors.white : Colors.black87,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _formatTimestamp(message["timestamp"]),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isCurrentUser ? Colors.white70 : Colors.black54,
                                  ),
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
