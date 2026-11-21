import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Resolves the database location without relocating an existing SQLite file.
Future<File> resolveDatabaseFile({
  bool? isWindows,
  Future<Directory> Function()? documentsDirectory,
  Future<Directory> Function()? supportDirectory,
}) async {
  final documents =
      await (documentsDirectory ?? getApplicationDocumentsDirectory)();
  final legacyFile = File(p.join(documents.path, 'focuspilot.sqlite'));
  if (!(isWindows ?? Platform.isWindows) || await legacyFile.exists()) {
    // Keep earlier installations on their original file, including its WAL.
    return legacyFile;
  }

  final support = await (supportDirectory ?? getApplicationSupportDirectory)();
  await support.create(recursive: true);
  return File(p.join(support.path, 'focuspilot.sqlite'));
}
