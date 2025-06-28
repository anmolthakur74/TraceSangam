import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static Position? _currentPosition;
  static String? _currentAddress;

  // Request location permission and enable location services
  static Future<bool> requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, request user to enable it.
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try requesting permissions again
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return false;
    }

    // When we reach here, permissions are granted and we can continue accessing the position
    return true;
  }

  // Get current location with better error handling
  static Future<Position?> getCurrentLocation() async {
    try {
      // Check and request permissions first
      bool hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        print('Location permission denied');
        return null;
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location services are disabled');
        return null;
      }

      // Get current position with high accuracy
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15), // Increased timeout
      );

      _currentPosition = position;
      print('Location obtained: ${position.latitude}, ${position.longitude}');
      return position;
    } catch (e) {
      print('Error getting location: $e');
      return null;
    }
  }

  // Get address from coordinates with better error handling
  static Future<String?> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
        localeIdentifier: 'en', // Use English locale
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Build a comprehensive address
        List<String> addressParts = [];

        // Add street number and name
        if (place.name != null && place.name!.isNotEmpty && place.name != place.locality) {
          addressParts.add(place.name!);
        }

        if (place.street != null && place.street!.isNotEmpty && place.street != place.name) {
          addressParts.add(place.street!);
        }

        // Add area/locality
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }

        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }

        // Add administrative area (state/province)
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }

        // Add country
        if (place.country != null && place.country!.isNotEmpty) {
          addressParts.add(place.country!);
        }

        // Add postal code if available
        if (place.postalCode != null && place.postalCode!.isNotEmpty) {
          addressParts.add(place.postalCode!);
        }

        String address = addressParts.join(', ');
        _currentAddress = address;
        print('Address obtained: $address');
        return address;
      }
      return null;
    } catch (e) {
      print('Error getting address: $e');
      // Return coordinates as fallback
      return 'Lat: ${latitude.toStringAsFixed(6)}, Lng: ${longitude.toStringAsFixed(6)}';
    }
  }

  // Get current location with address - main method
  static Future<Map<String, dynamic>?> getCurrentLocationWithAddress() async {
    try {
      print('Starting location detection...');

      Position? position = await getCurrentLocation();
      if (position == null) {
        print('Failed to get position');
        return null;
      }

      print('Position obtained, getting address...');
      String? address = await getAddressFromCoordinates(
          position.latitude,
          position.longitude
      );

      Map<String, dynamic> locationData = {
        'position': position,
        'address': address ?? 'Location: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
        'latitude': position.latitude,
        'longitude': position.longitude,
        'accuracy': position.accuracy,
        'timestamp': position.timestamp,
        'coordinates': '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}',
      };

      print('Location data prepared: ${locationData['address']}');
      return locationData;
    } catch (e) {
      print('Error in getCurrentLocationWithAddress: $e');
      return null;
    }
  }

  // Format coordinates for display
  static String formatCoordinates(double latitude, double longitude) {
    return '${latitude.toStringAsFixed(6)}, ${longitude.toStringAsFixed(6)}';
  }

  // Check location permission status
  static Future<LocationPermission> checkPermissionStatus() async {
    return await Geolocator.checkPermission();
  }

  // Open location settings
  static Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  // Open app settings
  static Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  // Get permission status as string
  static Future<String> getPermissionStatusString() async {
    LocationPermission permission = await checkPermissionStatus();
    switch (permission) {
      case LocationPermission.denied:
        return 'Location permission denied';
      case LocationPermission.deniedForever:
        return 'Location permission permanently denied';
      case LocationPermission.whileInUse:
        return 'Location permission granted';
      case LocationPermission.always:
        return 'Location permission granted (always)';
      default:
        return 'Location permission unknown';
    }
  }

  // Check if location services are enabled
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }
}
