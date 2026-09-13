import 'package:flutter/material.dart';
import 'package:ultimate_salon_owner_flutter/app/env.dart';

class AppImage {
  static bool isValidPath(String? path) {
    if (path == null) return false;
    final value = path.trim();
    if (value.isEmpty) return false;
    final lower = value.toLowerCase();
    return lower != 'na' &&
        lower != 'n/a' &&
        lower != 'null' &&
        lower != 'undefined' &&
        lower != 'none';
  }

  static String? url(String? path) {
    if (!isValidPath(path)) return null;
    final value = path!.trim();
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    return '${Environments.imageURL}$value';
  }
}

class AppNetImage extends StatelessWidget {
  final String? path;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final String errorAsset;

  const AppNetImage({
    Key? key,
    this.path,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorAsset = 'assets/images/notfound.png',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final url = AppImage.url(path);
    final fallback = placeholder ??
        Image.asset(
          'assets/images/placeholder.jpeg',
          fit: fit,
          width: width,
          height: height,
        );
    if (url == null) return fallback;

    return FadeInImage(
      image: NetworkImage(url),
      placeholder: const AssetImage('assets/images/placeholder.jpeg'),
      imageErrorBuilder: (_, __, ___) {
        return placeholder ??
            Image.asset(
              errorAsset,
              fit: fit,
              width: width,
              height: height,
            );
      },
      fit: fit,
      width: width,
      height: height,
    );
  }
}
