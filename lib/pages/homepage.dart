import 'package:flutter/material.dart';
import 'package:pabase/pages/create_page.dart';
import 'package:pabase/pages/edit_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final SupabaseClient supabase = Supabase.instance.client;

    // syntax to fetch data
    Future<List> readData() async {
      final result = await supabase.from('todos').select();
      return result;
    }

    void logout() async {
      await supabase.auth.signOut();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Flutter'),
        actions: [
          IconButton(
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Center(
          child: FutureBuilder(
        future: readData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return const Center(
                child: Text('No data available'),
              );
            }
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var data = snapshot.data![index];
              return ListTile(
                title: Text(data['title']),
                trailing: IconButton(
                  onPressed: () {
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
      )),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
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
