import 'package:flutter/material.dart';

class ArtWorkImage extends StatelessWidget {
  final String? imageUrl;

  const ArtWorkImage({super.key, this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: imageUrl != null
              ? NetworkImage(imageUrl!)
              : const AssetImage('assets/images/album_placeholder.png')
                  as ImageProvider,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
