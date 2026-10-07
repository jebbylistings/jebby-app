import 'dart:io';

import 'package:jebby/models/listing_draft.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Keeps listing draft photos in app documents so paths survive restarts.
class ListingDraftPhotos {
  static const _subdir = 'listing_draft_photos';

  static Future<Directory> draftDirectory() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(base.path, _subdir));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static bool isManagedPath(String path) {
    return path.contains('/$_subdir/') || path.contains('\\$_subdir\\');
  }

  /// Copies [tempPath] from image_picker into permanent draft storage.
  static Future<String> persistPickedFile(String tempPath) async {
    final src = File(tempPath);
    if (!await src.exists()) return tempPath;

    final dir = await draftDirectory();
    var ext = p.extension(tempPath).toLowerCase();
    if (ext.isEmpty || ext.length > 5) ext = '.jpg';
    final name = '${DateTime.now().millisecondsSinceEpoch}$ext';
    final dest = File(p.join(dir.path, name));
    await src.copy(dest.path);
    return dest.path;
  }

  static Future<void> deleteManagedFile(String path) async {
    if (!isManagedPath(path)) return;
    try {
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  static List<ListingPhotoRef> pruneMissingLocalPhotos(
    List<ListingPhotoRef> photos,
  ) {
    final kept = photos.where((photo) {
      if (photo.kind != ListingPhotoKind.local) return true;
      return File(photo.path).existsSync();
    }).toList();
    if (kept.isEmpty) return kept;
    if (!kept.any((p) => p.isCover)) {
      kept[0] = kept[0].copyWith(isCover: true);
    }
    return normalizeCoverFirst(kept);
  }

  /// Puts the cover photo at index 0 so UI order matches marketplace primary image.
  static List<ListingPhotoRef> normalizeCoverFirst(List<ListingPhotoRef> photos) {
    if (photos.length <= 1) {
      if (photos.length == 1) {
        return [photos.first.copyWith(isCover: true)];
      }
      return photos;
    }
    var coverIndex = photos.indexWhere((p) => p.isCover);
    if (coverIndex < 0) coverIndex = 0;
    if (coverIndex == 0) {
      return [
        photos.first.copyWith(isCover: true),
        ...photos.skip(1).map((p) => p.copyWith(isCover: false)),
      ];
    }
    final list = [...photos];
    final cover = list.removeAt(coverIndex);
    list.insert(0, cover);
    return [
      for (var i = 0; i < list.length; i++) list[i].copyWith(isCover: i == 0),
    ];
  }
}
