import 'package:flutter/material.dart';
import 'dart:math'; // 랜덤 재생에 필요
import 'play_screen.dart';

class PlaylistScreen extends StatelessWidget {
  final String playlistName;
  final List<dynamic> tracks;

  const PlaylistScreen({
    super.key,
    required this.playlistName,
    required this.tracks,
  });

  void playAllTracks(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PlayScreen(
        playlistName: playlistName,
        tracks: tracks,
      ),
    ));
  }

  void playRandomTrack(BuildContext context) {
    if (tracks.isNotEmpty) {
      final randomTrack = tracks[Random().nextInt(tracks.length)];
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PlayScreen(
          playlistName: '랜덤 트랙: ${randomTrack['track_name']}',
          tracks: [randomTrack], // 랜덤 트랙만 넘김
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xffffffff),
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Image.asset(
            'assets/images/arrow.png',
            width: 24,
            height: 24,
          ),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              showMenu(
                context: context,
                position: const RelativeRect.fromLTRB(100, 80, 0, 0),
                items: [
                  const PopupMenuItem(
                    value: 'savePlaylist',
                    child: Row(
                      children: [
                        Icon(Icons.playlist_add_rounded,
                            color: Color(0xff777777)),
                        SizedBox(width: 2),
                        Text('플레이리스트 저장'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'deletePlaylist',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outlined, color: Color(0xff777777)),
                        SizedBox(width: 2),
                        Text('재생 목록 삭제'),
                      ],
                    ),
                  ),
                ],
              ).then((value) {
                if (value == 'savePlaylist') {}
                else if (value == 'deletePlaylist') {}
              });
            },
            child: Image.asset('assets/images/more_menu.png',
                width: 24, height: 24),
          ),
          const SizedBox(width: 24),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 165,
                width: 165,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: const Color(0xff777777),
                  image: tracks.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(tracks.first['album_cover']),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 25),
              Text(
                playlistName,
                style: const TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff111111),
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 48,
                    width: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(500),
                      color: const Color(0xff111111),
                    ),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () => playAllTracks(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff111111),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(500),
                          ),
                        ),
                        child: const Text(
                          '모두 재생',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xffffffff),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 21),
                  Container(
                    height: 48,
                    width: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(500),
                      color: const Color(0xffffffff),
                      border: Border.all(
                        color: const Color(0xff111111),
                        width: 1,
                      ),
                    ),
                    child: Center(
                      child: ElevatedButton(
                        onPressed: () => playRandomTrack(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(500),
                          ),
                        ),
                        child: const Text(
                          '랜덤 재생',
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xff111111),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 25),
              ...tracks.map((track) {
                return Column(
                  children: [
                    ListTile(
                      leading: Image.network(
                        track['album_cover'],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                      title: Text(
                        track['track_name'],
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff111111),
                        ),
                      ),
                      subtitle: Text(
                        track['artist_name'],
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 14,
                          color: Color(0xff777777),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
