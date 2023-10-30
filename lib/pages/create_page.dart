import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreatePage extends StatefulWidget {
  const CreatePage({super.key});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  bool _isLoading = false; // Flag to track loading state
  final _titleController = TextEditingController();

  final SupabaseClient supabase = Supabase.instance.client; // Supabase client

  // Function to insert data into the 'todos' table
  Future _insertData() async {
    setState(() {
      _isLoading = true; // Set loading state to true
    });

    try {
      String userId = supabase.auth.currentUser!.id;
      // Insert data into 'todos' table with title and user_id
      final data = await supabase
          .from('todos')
          .insert({'title': _titleController.text, 'user_id': userId});
      Navigator.of(context).pop(); // Navigate back to the previous screen
    } catch (error) {
      print('Error Inserting data');
      setState(() {
        _isLoading = false; // Set loading state to false
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong'),
        ),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _titleController.dispose(); // Dispose of the controller
    supabase.dispose(); // Dispose of the Supabase client
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Enter a title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : ElevatedButton(
                    onPressed: _insertData,
                    child: const Text('Create'),
                  ),
          ],
        ),
      ),
    );
  }
}
