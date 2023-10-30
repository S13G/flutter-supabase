import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditPage extends StatefulWidget {
  const EditPage({super.key, required this.editData, required this.editID});

  final String editData;
  final int editID;

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  bool _isLoading = false;
  final _titleController = TextEditingController();
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> _updateData() async {
    if (_titleController.text != '') {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      await supabase
          .from('todos')
          .update({'title': _titleController.text}).match(
        {'id': widget.editID},
      );
      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await supabase.from('todos').delete().match(
        {'id': widget.editID},
      );
      Navigator.of(context).pop();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.editData;
  }

  @override
  void dispose() {
    _titleController.dispose();
    supabase.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Data'),
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
                : Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton(
                          onPressed: _updateData,
                          child: const Text('Update'),
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Divider(),
                      ElevatedButton.icon(
                        onPressed: _deleteData,
                        icon: const Icon(Icons.delete),
                        label: const Text('Delete'),
                        style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.red)),
                      )
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
