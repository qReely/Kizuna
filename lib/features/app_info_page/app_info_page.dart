import 'package:flutter/material.dart';
import 'package:manga_reader_app/core/widgets/section_header/section_header.dart';

class AppInfoPage extends StatelessWidget {
  const AppInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("App Info"),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          SectionHeader(title: 'Application Information'),
          _buildInfoTile(
            context,
            title: 'Kizuna - Manga Reading app',
            subtitle: 'Version 1.0.4',
          ),
          Divider(),
          SectionHeader(title: 'Contact'),
          _buildInfoTile(
            context,
            title: 'Email',
            subtitle: 'qreeldev@gmail.com',
          ),
          Divider(),
        ],
      ),
    );
  }
  Widget _buildInfoTile(BuildContext context, {required String title, required String subtitle}) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}