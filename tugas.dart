import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BookListScreen(),
    );
  }
}

class BookListScreen extends StatelessWidget {
  const BookListScreen({super.key});

  List<Map<String, String>> get books => List.generate(10, (index) {
    return {
      'title': 'Book ${index + 1}',
      'author': 'Author ${index + 1}',
      'description': 'Description ${index + 1}',
      'pdf': 'assets/pdf/book${index + 1}.pdf',
    };
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book List (10 Books)')),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: books.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              leading: const Icon(Icons.book),
              title: Text(books[index]['title']!),
              subtitle: Text(books[index]['author']!),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookDetailScreen(
                      title: books[index]['title']!,
                      author: books[index]['author']!,
                      description: books[index]['description']!,
                      pdfPath: books[index]['pdf']!,
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

class BookDetailScreen extends StatelessWidget {
  final String title;
  final String author;
  final String description;
  final String pdfPath;

  const BookDetailScreen({
    super.key,
    required this.title,
    required this.author,
    required this.description,
    required this.pdfPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Title: $title',
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Author: $author',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Text(description),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ReadingBookFile(pdfPath: pdfPath),
                  ),
                );
              },
              child: const Text('Read the Book'),
            ),
          ],
        ),
      ),
    );
  }
}

class ReadingBookFile extends StatefulWidget {
  final String pdfPath;

  const ReadingBookFile({super.key, required this.pdfPath});

  @override
  State<ReadingBookFile> createState() => _ReadingBookFileState();
}

class _ReadingBookFileState extends State<ReadingBookFile> {
  String? localPath;
  String? error;

  @override
  void initState() {
    super.initState();
    loadPdf();
  }

  Future<void> loadPdf() async {
    try {
      print("Load PDF: ${widget.pdfPath}");

      final bytes = await rootBundle.load(widget.pdfPath);

      final dir = await getApplicationDocumentsDirectory();
      final file = File("${dir.path}/${widget.pdfPath.split('/').last}");

      await file.writeAsBytes(bytes.buffer.asUint8List(), flush: true);

      print("PDF berhasil disimpan: ${file.path}");

      setState(() {
        localPath = file.path;
      });
    } catch (e) {
      print("ERROR LOAD PDF: $e");
      setState(() {
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // biar gak hitam
      appBar: AppBar(title: const Text("Reading Book")),
      body: error != null
          ? Center(
        child: Text(
          "Error:\n$error",
          textAlign: TextAlign.center,
        ),
      )
          : localPath == null
          ? const Center(child: CircularProgressIndicator())
          : PDFView(filePath: localPath!),
    );
  }
}