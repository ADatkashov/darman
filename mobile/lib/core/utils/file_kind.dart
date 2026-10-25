enum FileKind { jpeg, png, pdf }

/// Detects the real file type from magic bytes; file names and MIME hints are never trusted.
FileKind? detectFileKind(List<int> b) {
  if (b.length >= 3 && b[0] == 0xFF && b[1] == 0xD8 && b[2] == 0xFF) return FileKind.jpeg;
  if (b.length >= 8 && b[0] == 0x89 && b[1] == 0x50 && b[2] == 0x4E && b[3] == 0x47) return FileKind.png;
  if (b.length >= 5 && b[0] == 0x25 && b[1] == 0x50 && b[2] == 0x44 && b[3] == 0x46 && b[4] == 0x2D) return FileKind.pdf;
  return null;
}

String extensionFor(FileKind k) => switch (k) {
  FileKind.jpeg => 'jpg',
  FileKind.png => 'png',
  FileKind.pdf => 'pdf',
};
