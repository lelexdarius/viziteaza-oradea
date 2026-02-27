import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Widget reutilizabil pentru imagini cu caching persistent.
/// - URL http/https → CachedNetworkImage (salvat pe disc, nu se reîncarcă)
/// - Orice altceva → Image.asset
class AppCachedImage extends StatelessWidget {
  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? fallback;

  const AppCachedImage({
    Key? key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.fallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!url.startsWith('http')) {
      return Image.asset(url, fit: fit, width: width, height: height);
    }
    return CachedNetworkImage(
      imageUrl: url,
      fit: fit,
      width: width,
      height: height,
      fadeInDuration: const Duration(milliseconds: 180),
      fadeOutDuration: const Duration(milliseconds: 100),
      memCacheWidth: width != null ? (width! * 2).toInt() : null,
      placeholder: (_, __) => Container(color: const Color(0xFFE8F1F4)),
      errorWidget: (_, __, ___) =>
          fallback ??
          Container(
            color: const Color(0xFFE0E0E0),
            child: const Icon(
              Icons.broken_image_outlined,
              color: Colors.grey,
              size: 32,
            ),
          ),
    );
  }
}
