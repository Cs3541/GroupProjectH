import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/photo_model.dart';
import '../presenters/photo_presenter.dart';
import 'photo_gallery_screen.dart';

class PhotoUploadScreen extends StatefulWidget {
  final PhotoPresenter presenter;

  const PhotoUploadScreen({
    super.key,
    required this.presenter,
  });

  @override
  State<PhotoUploadScreen> createState() =>
      _PhotoUploadScreenState();
}

class _PhotoUploadScreenState
    extends State<PhotoUploadScreen> {

  DateTime selectedDate = DateTime.now();

  Photo? selectedPhoto;
  XFile? selectedImage;

  // Select the date the photo was taken
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

  // Select a photo from the device gallery
  Future<void> selectPhoto() async {
    final photo = await widget.presenter.pickPhoto(selectedDate);

    if (!mounted) return;

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              const Text(
                'When was this photo taken?',
              ),

              const SizedBox(height: 8),

              Text(
                '${selectedDate.month}/${selectedDate.day}/${selectedDate.year}',
              ),

              const SizedBox(height: 12),

              // Choose date button
              ElevatedButton(
                onPressed: selectDate,
                child: const Text('Choose Date'),
              ),

              // Select photo button
              ElevatedButton(
                onPressed: selectPhoto,
                child: const Text('Select Photo'),
              ),

              const SizedBox(height: 12),

              // View gallery button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PhotoGalleryScreen(
                        presenter: widget.presenter,
                      ),
                    ),
                  );
                },

                child: const Text('View Photo Gallery'),
              ),

              const SizedBox(height: 20),

              // Display selected image
              if (selectedImage != null)
                FutureBuilder<Uint8List>(
                  key: ValueKey(selectedImage!.path),

                  future: selectedImage!.readAsBytes(),

                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Text(
                        'Could not load photo',
                      );
                    }

                    if (!snapshot.hasData) {
                      return const CircularProgressIndicator();
                    }

                    return Image.memory(
                      snapshot.data!,
                      width: 250,
                      height: 250,
                      fit: BoxFit.cover,
                    );
                  },
                ),

              // Display selected photo date
              if (selectedPhoto != null) ...[
                const SizedBox(height: 16),

                Text(
                  'Date Taken: '
                  '${selectedPhoto!.dateTaken.month}/'
                  '${selectedPhoto!.dateTaken.day}/'
                  '${selectedPhoto!.dateTaken.year}',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}