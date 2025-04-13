import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:beacon/providers/p2p_provider.dart';
import 'package:beacon/providers/auth_provider.dart';
import 'package:beacon/screens/chat_detail_screen.dart';
import 'package:beacon/utils/theme.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final p2pProvider = Provider.of<P2PProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    
    final connectedPeers = p2pProvider.connectedPeers;
    final messages = p2pProvider.messages;
    
    // Group messages by peer
    final Map<String, List<dynamic>> chatsByPeer = {};
    
    for (final peer in connectedPeers) {
      chatsByPeer[peer.id] = [
        peer,
        messages
            .where((msg) => msg.senderId == peer.id || msg.senderId == authProvider.userId)
            .toList()
      ];
    }
    
    if (chatsByPeer.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AppTheme.mediumGrey,
            ),
            SizedBox(height: 16),
            Text(
              'No chats available',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.darkGrey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Connect with peers to start chatting',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.darkGrey,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: chatsByPeer.length,
      itemBuilder: (context, index) {
        final peerId = chatsByPeer.keys.elementAt(index);
        final peer = chatsByPeer[peerId]![0];
        final peerMessages = chatsByPeer[peerId]![1] as List;
        
        // Sort messages by timestamp
        peerMessages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        
        final lastMessage = peerMessages.isNotEmpty ? peerMessages.first : null;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 2,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor,
              child: Text(
                peer.name.isNotEmpty ? peer.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(peer.name),
            subtitle: lastMessage != null
                ? Text(
                    lastMessage.type == 'text'
                        ? lastMessage.content
                        : '[${lastMessage.type}]',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : const Text('No messages yet'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (lastMessage != null)
                  Text(
                    _formatMessageTime(lastMessage.timestamp),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.darkGrey,
                    ),
                  ),
                const SizedBox(height: 4),
                if (peerMessages.any((msg) => !msg.isRead && msg.senderId == peer.id))
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '',
                      style: TextStyle(fontSize: 8),
                    ),
                  ),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatDetailScreen(peer: peer),
                ),
              );
            },
          ),
        );
      },
    );
  }

  String _formatMessageTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);
    
    if (messageDate == today) {
      return DateFormat.Hm().format(dateTime);
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat.MMMd().format(dateTime);
    }
  }
}