import 'package:permission_handler/permission_handler.dart';

class QRScannerService {
  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.camera.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      // Open app settings
      await openAppSettings();
      return false;
    }

    return false;
  }

  static bool isValidBoxId(String scannedData) {
    // Add your validation logic here
    // For example, check if it starts with "BOX-" and has correct format
    return scannedData.isNotEmpty &&
        (scannedData.startsWith('BOX-') || scannedData.length >= 5);
  }

  static String formatBoxId(String scannedData) {
    // Format the scanned data to match your box ID format
    if (scannedData.startsWith('BOX-')) {
      return scannedData.toUpperCase();
    }
    return 'BOX-${scannedData.toUpperCase()}';
  }
}