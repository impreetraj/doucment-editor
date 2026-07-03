import 'package:editing_file/screens/execl_screen.dart';
import 'package:flutter/material.dart';
// import 'package:uuid/uuid.dart';
import 'editor_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _docIdController = TextEditingController();
  final TextEditingController _userIdController = TextEditingController();
  
  
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Editor And Excel'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.edit_document, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 20),
            TextField(
              controller: _docIdController,
              decoration: const InputDecoration(
                labelText: 'Document ID Enter',
                hintText: 'my-first-doc',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.file_copy),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _userIdController,
              decoration: const InputDecoration(
                labelText: 'Enter your name',
                hintText: 'Enter name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.file_copy),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                if (_docIdController.text.trim().isNotEmpty) {
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ExcelScreen(
                        excelId: _docIdController.text.trim(),
                        userName: _userIdController.text.trim(), 
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(' Document ID need')),
                  );
                }
              },
              icon: const Icon(Icons.login),
              label: const Text('Join Excel Sheet', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                if (_docIdController.text.trim().isNotEmpty) {
                  
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditorScreen(
                        documentId: _docIdController.text.trim(),
                        userId: _userIdController.text.trim(), 
                      ),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(' Document ID need')),
                  );
                }
              },
              icon: const Icon(Icons.login),
              label: const Text('Join Document Editor', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
