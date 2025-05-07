import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NoticeUploadScreen extends StatefulWidget {
  const NoticeUploadScreen({super.key});

  @override
  _NoticeUploadScreenState createState() => _NoticeUploadScreenState();
}

class _NoticeUploadScreenState extends State<NoticeUploadScreen> {
  PlatformFile? pickedFile;
  bool isUploading = false;

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
      withData: true, // Important for web/Android
    );

    if (result != null && result.files.single.bytes != null) {
      setState(() {
        pickedFile = result.files.first;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("❗ No file selected or file unreadable")),
      );
    }
  }

  Future<void> uploadToSupabase() async {
    if (pickedFile == null || pickedFile!.bytes == null) return;

    setState(() {
      isUploading = true;
    });

    try {
      final Uint8List fileBytes = pickedFile!.bytes!;
      final String fileName =
          'notice_${DateTime.now().millisecondsSinceEpoch}_${pickedFile!.name}';

      // Upload to Supabase Storage
      await Supabase.instance.client.storage
          .from('notices')
          .uploadBinary(fileName, fileBytes);

      // Get Public URL
      final publicUrl = Supabase.instance.client.storage
          .from('notices')
          .getPublicUrl(fileName);

      // Save the file URL in Firestore
      await FirebaseFirestore.instance.collection('notices').add({
        'fileName': pickedFile!.name,
        'Fileurl': publicUrl,  // Save the Supabase URL here
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ File uploaded and saved")),
      );

      setState(() {
        pickedFile = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Upload failed: $e")),
      );
    }

    setState(() {
      isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("📄 Upload Notice"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD1C4E9), Color(0xFFB39DDB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            width: 360,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.shade100,
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(3, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "📝 Select & Upload Notice",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
                const SizedBox(height: 24),
                if (pickedFile != null)
                  Card(
                    color: Colors.deepPurple.shade50,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(Icons.insert_drive_file, color: Colors.deepPurple, size: 30),
                      title: Text(pickedFile!.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: isUploading ? null : pickFile,
                  icon: const Icon(Icons.attach_file),
                  label: const Text("Pick PDF / Word File"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: (pickedFile != null && !isUploading) ? uploadToSupabase : null,
                  icon: isUploading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : const Icon(Icons.cloud_upload),
                  label: isUploading
                      ? const Text("Uploading...")
                      : const Text("Upload"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}














/*import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class NoticeUploadScreen extends StatefulWidget {
  @override
  _NoticeUploadScreenState createState() => _NoticeUploadScreenState();
}

class _NoticeUploadScreenState extends State<NoticeUploadScreen> {
  PlatformFile? pickedFile;

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null) {
      setState(() {
        pickedFile = result.files.first;
      });
    }
  }

  Future<String?> uploadPDFtoCloudinary() async {
    final file = File(pickedFile!.path!);
    final cloudName = 'dhtudkpaa';
    final uploadPreset = 'Class_time_table'; // Create it in Cloudinary

    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/auto/upload');

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final res = await http.Response.fromStream(response);
      final data = jsonDecode(res.body);
      return data['secure_url']; // URL of uploaded PDF
    } else {
      return null;
    }
  }

  Future<void> uploadFile() async {
    if (pickedFile == null) return;

    try {
      final url = await uploadPDFtoCloudinary();

      if (url != null) {
        await FirebaseFirestore.instance.collection('notices').add({
          'fileName': pickedFile!.name,
          'fileUrl': url,
          'uploadedAt': Timestamp.now(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ File uploaded successfully')),
        );

        setState(() {
          pickedFile = null;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Upload to Cloudinary failed')),
        );
      }
    } catch (e) {
      print('Upload error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Upload failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("📄 Upload Notice"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD1C4E9), Color(0xFFB39DDB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            width: 360,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.deepPurple.shade100,
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(3, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "📝 Select & Upload Notice",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                ),
                const SizedBox(height: 24),
                if (pickedFile != null)
                  Card(
                    color: Colors.deepPurple.shade50,
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: Icon(Icons.insert_drive_file, color: Colors.deepPurple, size: 30),
                      title: Text(pickedFile!.name, style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: pickFile,
                  icon: Icon(Icons.attach_file),
                  label: Text("Pick PDF / Word File"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: uploadFile,
                  icon: Icon(Icons.cloud_upload),
                  label: Text("Upload"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}*/
