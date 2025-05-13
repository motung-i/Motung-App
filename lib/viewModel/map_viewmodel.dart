import 'package:geolocator/geolocator.dart';

class MapViewmodel {
  Future<bool> checkServiceEnabled() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    return serviceEnabled;
  }

  Future<bool> checkPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      return false;
    }
    return true;
  }

  Future<Position> getCurrentLocation() async {
    final position = await Geolocator.getCurrentPosition();
    return position;
  }

  Future<LocationPermission> requestPermission() async {
    final permission = await Geolocator.requestPermission();
    return permission;
  }
}
