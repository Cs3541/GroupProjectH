import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/photo_model.dart';
import '../presenters/photo_presenter.dart';
import 'photo_gallery_screen.dart';

class PhotoUploadScreen extends StatefulWidget {
  const PhotoUploadScreen({super.key});

  @override
  State<PhotoUploadScreen> createState() => _PhotoUploadScreenState();
}

class _PhotoUploadScreenState extends State<PhotoUploadScreen> {
  final PhotoPresenter presenter = PhotoPresenter();

  DateTime selectedDate = DateTime.now();
  Photo? selectedPhoto;
  Uint8List? photoBytes;
  XFile? selectedImage;

  Future<void> selectDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  Future<void> selectPhoto() async {
  final photo = await presenter.pickPhoto(selectedDate);

  if (photo != null) {
    setState(() {
      selectedPhoto = photo;
      selectedImage = XFile(photo.path);
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Progress Photo'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('When was this photo taken?'),

            Text(
              '${selectedDate.month}/${selectedDate.day}/${selectedDate.year}',
            ),

            ElevatedButton(
              onPressed: selectDate,
              child: const Text('Choose Date'),
            ),

           ElevatedButton(
              onPressed: selectPhoto,
              child: const Text('Select Photo'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PhotoGalleryScreen(
                      presenter: presenter,
                    ),
                  ),
                );
              },
              child: const Text('View Photo Gallery'),
            ),

            if (selectedImage != null)
              FutureBuilder(
                key: ValueKey(selectedImage!.path),
                future: selectedImage!.readAsBytes(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Could not load photo');
                  }

                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  return Image.memory(
                    snapshot.data!,
                    width: 250,
                    height: 250,
                  );
                },
              ),

            if (photoBytes != null && selectedPhoto != null) ...[
              const SizedBox(height: 20),

              Image.memory(
                photoBytes!,
                width: 250,
                height: 250,
                fit: BoxFit.cover,
              ),

              const SizedBox(height: 10),

              Text(
                'Date Taken: ${selectedPhoto!.dateTaken.month}/${selectedPhoto!.dateTaken.day}/${selectedPhoto!.dateTaken.year}',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
