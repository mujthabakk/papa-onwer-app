import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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

class OfferImagePickerTile extends StatelessWidget {
  final XFile? file;
  final String? existingUrl;
  final VoidCallback onPick;
  final VoidCallback? onClear;

  const OfferImagePickerTile({
    Key? key,
    this.file,
    this.existingUrl,
    required this.onPick,
    this.onClear,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasFile = file != null && file!.path.isNotEmpty;
    final hasUrl = AppImage.isValidPath(existingUrl);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Offer image',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 4),
          const Text(
            'Optional. JPG, PNG or WEBP.',
            style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: onPick,
            borderRadius: BorderRadius.circular(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 140,
                width: double.infinity,
                color: const Color(0xFFF3F4F6),
                child: hasFile
                    ? Image.file(File(file!.path), fit: BoxFit.cover)
                    : hasUrl
                        ? AppNetImage(path: existingUrl, fit: BoxFit.cover)
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined,
                                  size: 36, color: Color(0xFF9CA3AF)),
                              SizedBox(height: 6),
                              Text(
                                'Tap to add image',
                                style: TextStyle(color: Color(0xFF6B7280)),
                              ),
                            ],
                          ),
              ),
            ),
          ),
          if (hasFile && onClear != null)
            TextButton(
              onPressed: onClear,
              child: const Text('Remove selected image'),
            ),
        ],
      ),
    );
  }
}
