import 'package:image_picker/image_picker.dart';
import '../models/photo_model.dart';

class PhotoPresenter {
  final ImagePicker _picker = ImagePicker();
  final List<Photo> _photos = [];

  Future<Photo?> pickPhoto(DateTime dateTaken) async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      final photo = Photo(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        path: image.path,
        dateTaken: dateTaken,
        dateUploaded: DateTime.now(),
      );

      _photos.add(photo);
      return photo;
    }

    return null;
  }
  
  void toggleFavorite(Photo photo) {
  photo.isFavorite = !photo.isFavorite;
  } 

  List<Photo> getAllPhotos() {
    return List.unmodifiable(_photos);
  }

  List<Photo> getPhotosNewestFirst() {
  final photos = List<Photo>.from(_photos);
  photos.sort((a, b) => b.dateTaken.compareTo(a.dateTaken));
  return photos;
  }

  Photo? getPhotoById(String id) {
    for (final photo in _photos) {
      if (photo.id == id) {
        return photo;
      }
    }
    return null;
  }
}
