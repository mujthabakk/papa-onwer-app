class CoordinateValidator {
  static String? validateLatitude(String value) {
    if (value.isEmpty) {
      return 'Please enter the latitude';
    }
    if (value.endsWith('.')) {
      return 'The number cannot end with a decimal point';
    }
    final lat = double.tryParse(value);
    if (lat == null) {
      return 'Please enter a valid number for latitude';
    }
    if (lat < -90 || lat > 90) {
      return 'Invalid latitude. Latitude should be between -90 and 90';
    }
    return null;
  }

  static String? validateLongitude(String value) {
    if (value.isEmpty) {
      return 'Please enter the longitude';
    }
    if (value.endsWith('.')) {
      return 'The number cannot end with a decimal point';
    }
    final lng = double.tryParse(value);
    if (lng == null) {
      return 'Please enter a valid number for longitude';
    }
    if (lng < -180 || lng > 180) {
      return 'Invalid longitude. Longitude should be between -180 and 180';
    }
    return null;
  }
}
