import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({super.key});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  bool _isUploading = false;

  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> _deleteImage(String imageName) async {
    try {
      await supabase.storage
          .from('user-images')
          .remove(['${supabase.auth.currentUser!.id}/$imageName']);
      setState(() {});
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong'),
        ),
      );
    }
  }

  Future _getMyFiles() async {
    final List<FileObject> results = await supabase.storage
        .from('user-images')
        .list(path: supabase.auth.currentUser!.id);
    List<Map<String, String>> myImages = [];

    for (var image in results) {
      final getUrl = supabase.storage
          .from('user-images')
          .getPublicUrl('${supabase.auth.currentUser!.id}/${image.name}');
      myImages.add({'name': image.name, 'url': getUrl});
    }
    return myImages;
  }

  Future<void> _uploadFile() async {
    var pickedFile = await FilePicker.platform
        .pickFiles(allowMultiple: false, type: FileType.image);

    if (pickedFile != null) {
      setState(() {
        _isUploading = true;
      });

      try {
        File file = File(pickedFile.files.first.path!);
        String filename = pickedFile.files.first.name;
        String uploadedUrl = await supabase.storage
            .from('user-images')
            .upload('${supabase.auth.currentUser!.id}/$filename', file);

        setState(() {
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('File uploaded successfully'),
          backgroundColor: Colors.green,
        ));
      } catch (error) {
        setState(() {
          _isUploading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Something went wrong'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Storage'),
      ),
      body: FutureBuilder(
        future: _getMyFiles(),
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
                child: Text('Error occurred while fetching data'));
          }

          if (!snapshot.hasData || snapshot.data.isEmpty) {
            return const Center(child: Text('No image available'));
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemBuilder: (context, index) {
              Map imageData = snapshot.data[index];
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 200,
                    width: 300,
                    child: Image.network(imageData['url'], fit: BoxFit.cover),
                  ),
                  IconButton(
                    onPressed: () {
                      _deleteImage(imageData['name']);
                    },
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                  ),
                ],
              );
            },
            separatorBuilder: (context, index) {
              return const Divider(thickness: 2, color: Colors.black);
            },
            itemCount: snapshot.data.length,
          );
        },
      ),
      floatingActionButton: _isUploading
          ? const CircularProgressIndicator()
          : FloatingActionButton(
              onPressed: _uploadFile,
              child: const Icon(Icons.photo),
            ),
    );
  }
}
