import 'package:flutter/material.dart';
import 'package:pabase/pages/create_page.dart';
import 'package:pabase/pages/edit_page.dart';
import 'package:pabase/pages/upload_page.dart'; // Import the UploadPage
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SupabaseClient supabase = Supabase.instance.client;
  late Stream<List<Map<String, dynamic>>> _readStream;

  @override
  void initState() {
    // Set up a real-time stream to get and display user-specific data from Supabase.
    _readStream = supabase
        .from('todos')
        .stream(primaryKey: ['id'])
        .eq('user_id', supabase.auth.currentUser!.id)
        .order('id', ascending: false);
    super.initState();
  }

  void logout() async {
    // Handle user logout using Supabase.
    await supabase.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Flutter'),
        actions: [
          // Button to navigate to the UploadPage for uploading files.
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const UploadPage(),
                ),
              );
            },
            icon: const Icon(Icons.upload_file),
          ),
          IconButton(
            onPressed: logout, // Trigger the logout function.
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
        child: StreamBuilder(
          stream: _readStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return const Center(
                child: Text('Error loading data'),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No data available'),
              );
            }

            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var data = snapshot.data![index];
                return ListTile(
                  title: Text(data['title']),
                  trailing: IconButton(
                    onPressed: () {
                      // Navigate to the EditPage to edit specific data.
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditPage(
                            editData: data['title'],
                            editID: data['id'],
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                    color: Colors.red,
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          // Navigate to the CreatePage to add new data.
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CreatePage(),
            ),
          );
        },
      ),
    );
  }
}
