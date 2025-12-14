// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import 'chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const List<Map<String, dynamic>> _boards = [
    {'name': 'General Discussion', 'icon': Icons.chat, 'id': 'general'},
    {'name': 'Announcements', 'icon': Icons.campaign, 'id': 'announcements'},
    {'name': 'Help & Support', 'icon': Icons.help, 'id': 'help'},
    {'name': 'Random', 'icon': Icons.casino, 'id': 'random'},
    {'name': 'Study Group', 'icon': Icons.school, 'id': 'study'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Message Boards')),
      drawer: const AppDrawer(),
      body: ListView.builder(
        itemCount: _boards.length,
        itemBuilder: (context, index) {
          final board = _boards[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(board['icon'] as IconData, color: Colors.white),
              ),
              title: Text(
                board['name'] as String,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    boardName: board['name'] as String,
                    boardId: board['id'] as String,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
