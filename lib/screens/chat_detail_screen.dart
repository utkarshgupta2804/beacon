import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:beacon/providers/p2p_provider.dart';
import 'package:beacon/providers/auth_provider.dart';
import 'package:beacon/models/peer.dart';
import 'package:beacon/models/message.dart';
import 'package:beacon/utils/theme.dart';
import 'package:intl/intl.dart';

class ChatDetailScreen extends StatefulWidget {
  final Peer peer;

  const ChatDetailScreen({
    Key? key,
    required this.peer,
  }) : super(key: key);

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    
    // Mark messages as read
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _markMessagesAsRead();
    });
    
    // Listen for new messages
    final p2pProvider = Provider.of<P2PProvider>(context, listen: false);
    p2pProvider.messageStream.listen((message) {
      if (message.senderId == widget.peer.id) {
        // Mark new messages as read if this chat is open
        message.isRead = true;
        
        // Scroll to bottom
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  void _markMessagesAsRead() {
    final p2pProvider = Provider.of<P2PProvider>(context, listen: false);
    final messages = p2pProvider.messages;
    
    for (final message in messages) {
      if (message.senderId == widget.peer.id && !message.isRead) {
        message.isRead = true;
      }
    }
  }

  Future<void> _handleSendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    
    final p2pProvider = Provider.of<P2PProvider>(context, listen: false);
    final success = await p2pProvider.sendMessage(
      widget.peer.id,
      message,
      'text',
    );
    
    if (success) {
      _messageController.clear();
      setState(() {
        _isComposing = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send message'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p2pProvider = Provider.of<P2PProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    final messages = p2pProvider.messages
        .where((msg) => 
            msg.senderId == widget.peer.id || 
            (msg.senderId == authProvider.userId && msg.content.isNotEmpty))
        .toList();
    
    // Sort messages by timestamp (newest first for the ListView.builder)
    messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              radius: 16,
              child: Text(
                widget.peer.name.isNotEmpty ? widget.peer.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.peer.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.peer.isOnline ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.peer.isOnline ? Colors.green : Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              // Implement call functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('P2P call feature coming soon'),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showOptionsMenu(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text(
                      'No messages yet',
                      style: TextStyle(
                        color: AppTheme.darkGrey,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    reverse: true,
                    padding: const EdgeInsets.all(8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMe = message.senderId == authProvider.userId;
                      
                      // Check if we need to show the date header
                      final showDateHeader = index == messages.length - 1 || 
                          !_isSameDay(messages[index].timestamp, messages[index + 1].timestamp);
                      
                      return Column(
                        children: [
                          if (showDateHeader)
                            _DateHeader(date: message.timestamp),
                          _MessageBubble(
                            message: message,
                            isMe: isMe,
                          ),
                        ],
                      );
                    },
                  ),
          ),
          
          // Message input
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                // Attachment button
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  color: AppTheme.darkGrey,
                  onPressed: () {
                    // Implement attachment functionality
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Attachment feature coming soon'),
                      ),
                    );
                  },
                ),
                
                // Message input field
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message',
                      border: InputBorder.none,
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (text) {
                      setState(() {
                        _isComposing = text.trim().isNotEmpty;
                      });
                    },
                  ),
                ),
                
                // Send button
                IconButton(
                  icon: const Icon(Icons.send),
                  color: _isComposing ? AppTheme.primaryColor : AppTheme.darkGrey,
                  onPressed: _isComposing ? _handleSendMessage : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('View Info'),
            onTap: () {
              Navigator.pop(context);
              // Implement view info functionality
            },
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Share Location'),
            onTap: () {
              Navigator.pop(context);
              // Implement share location functionality
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Clear Chat', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              // Implement clear chat functionality
            },
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final Message message;
  final bool isMe;

  const _MessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isMe ? AppTheme.primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat.Hm().format(message.timestamp),
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.5),
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    message.isRead ? Icons.done_all : Icons.done,
                    size: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final DateTime date;

  const _DateHeader({
    Key? key,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _formatDate(date),
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.darkGrey,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat.yMMMd().format(dateTime);
    }
  }
}