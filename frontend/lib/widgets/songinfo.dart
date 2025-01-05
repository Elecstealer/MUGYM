import 'package:flutter/material.dart';
import 'package:mugym/screens/play_screen.dart';

class SongInfo extends StatelessWidget {
  final String songTitle;
  final String albumName;
  final String singerName;
  // final String imagePath;

  const SongInfo({
    super.key,
    required this.songTitle,
    required this.albumName,
    required this.singerName,
    // required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const PlayScreen(
                    playlistName: "1234",
                    tracks: [],
                  )),
        );
      },
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.5),
              color: const Color(0xFF777777),
              // image: DecorationImage(
              //   image: AssetImage(imagePath),
              //   fit: BoxFit.cover,
              // ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                songTitle,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff111111),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    singerName,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff777777),
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Text(
                    '•',
                    style: TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff777777),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    albumName,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Color(0xff777777),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
