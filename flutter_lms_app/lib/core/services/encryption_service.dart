import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;

/// Service for encrypting and decrypting files for secure offline storage.
/// Uses AES encryption with a hardcoded key to prevent unauthorized access.
class EncryptionService {
  // Hardcoded AES key for encryption (in production, this should be securely managed)
  static const String _keyString = 'my32lengthsupersecretnooneknows1'; // 32 characters
  static final encrypt.Key _key = encrypt.Key.fromUtf8(_keyString);
  static final encrypt.IV _iv = encrypt.IV.fromLength(16); // 16 bytes IV

  static final encrypt.Encrypter _encrypter = encrypt.Encrypter(encrypt.AES(_key));

  /// Encrypts the given bytes using AES encryption.
  /// Returns the encrypted bytes.
  static Uint8List encryptBytes(Uint8List data) {
    final encrypted = _encrypter.encryptBytes(data, iv: _iv);
    return Uint8List.fromList(encrypted.bytes);
  }

  /// Decrypts the given encrypted bytes using AES decryption.
  /// Returns the original bytes.
  static Uint8List decryptBytes(Uint8List encryptedData) {
    final encrypted = encrypt.Encrypted(encryptedData);
    final decrypted = _encrypter.decryptBytes(encrypted, iv: _iv);
    return Uint8List.fromList(decrypted);
  }

  /// Encrypts a file by reading its bytes, encrypting them, and saving as .enc file.
  /// This method is used during the download process.
  static Future<void> encryptFile(String inputPath, String outputPath) async {
    // Note: In actual implementation, read file bytes, encrypt, and write to outputPath
    // For now, placeholder - actual file I/O would be handled in DownloadService
  }

  /// Decrypts an encrypted file to a temporary location for playback.
  /// Returns the path to the decrypted temporary file.
  static Future<String> decryptFileToTemp(String encryptedPath) async {
    // Note: In actual implementation, read encrypted file, decrypt, write to temp file, return temp path
    // For now, placeholder - actual file I/O would be handled in VideoPlayerScreen
    return '';
  }
}