// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import 'chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Hard-coded message boards as per requirements
    final List<Map<String, dynamic>> messageBoards = [
      {
        'name': 'General Discussion',
        'icon': Icons.chat,
        'boardId': 'general',
      },
      {
        'name': 'Announcements',
        'icon': Icons.campaign,
        'boardId': 'announcements',
      },
      {
        'name': 'Help & Support',
        'icon': Icons.help,
        'boardId': 'help',
      },
      {
        'name': 'Random',
        'icon': Icons.casino,
        'boardId': 'random',
      },
      {
        'name': 'Study Group',
        'icon': Icons.school,
        'boardId': 'study',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Boards'),
      ),
      drawer: const AppDrawer(),
      body: ListView.builder(
        itemCount: messageBoards.length,
        itemBuilder: (context, index) {
          final board = messageBoards[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(
                  board['icon'] as IconData,
                  color: Colors.white,
                ),
              ),
              title: Text(
                board['name'] as String,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      boardName: board['name'] as String,
                      boardId: board['boardId'] as String,
                    ),
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
