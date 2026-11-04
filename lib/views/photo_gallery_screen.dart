import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../presenters/photo_presenter.dart';

class PhotoGalleryScreen extends StatefulWidget {
  final PhotoPresenter presenter;

  const PhotoGalleryScreen({
    super.key,
    required this.presenter,
  });

  @override
  State<PhotoGalleryScreen> createState() =>
      _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState
    extends State<PhotoGalleryScreen> {

  @override
  Widget build(BuildContext context) {
    final photos = widget.presenter.getPhotosNewestFirst();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Photos'),
      ),

      body: photos.isEmpty
          ? const Center(
              child: Text('No progress photos yet.'),
            )
          : ListView.builder(
              itemCount: photos.length,

              itemBuilder: (context, index) {
                final photo = photos[index];

                return Column(
                  children: [
                    const SizedBox(height: 16),

                    FutureBuilder<Uint8List>(
                      key: ValueKey(photo.path),

                      future: XFile(photo.path).readAsBytes(),

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

                    const SizedBox(height: 8),

                    Text(
                      '${photo.dateTaken.month}/${photo.dateTaken.day}/${photo.dateTaken.year}',
                    ),

                    IconButton(
                      icon: Icon(
                        photo.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,

                        color: photo.isFavorite
                            ? Colors.red
                            : Colors.grey,
                      ),

                      onPressed: () {
                        setState(() {
                          widget.presenter.toggleFavorite(photo);
                        });
                      },
                    ),

                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
    );
  }
}