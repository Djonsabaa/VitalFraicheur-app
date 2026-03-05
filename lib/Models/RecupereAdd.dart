import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

Future<String?> getAdresse() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if( !serviceEnabled ) {
    return null;
  }
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return null;
    }
  }
  Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
  if (placemarks.isNotEmpty) {
    final place = placemarks.first;
    return "${place.street}, ${place.locality}, ${place.country}";
}
return null;
}