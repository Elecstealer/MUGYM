import 'package:flutter/material.dart';
import 'package:mugym/screens/mix_screen.dart';
import 'package:mugym/screens/mypage_new.dart'; //임시 mypage
import 'package:mugym/screens/playlist_screen.dart';
import 'package:mugym/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  final String username; // 사용자 이름
  final int userId; // 사용자 ID

  const HomeScreen({super.key, required this.username, required this.userId});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedExercise = '런닝'; // 선택된 운동 타입
  List<dynamic> trackList = []; // 새로운 발견 트랙 목록
  late Future<List<dynamic>> userPlaylists; // 사용자 플레이리스트

  @override
  void initState() {
    super.initState();
    userPlaylists = fetchUserPlaylists(widget.userId);
    fetchInitialTracks(selectedExercise);
  }
  
  void fetchInitialTracks(String exerciseType) async {
  try {
    final tracks = await ApiService.fetchTracksByType(exerciseType);
    setState(() {
      trackList = tracks;
    });
  } catch (e) {
    print('Error fetching initial tracks: $e');
  }
}

  Future<List<dynamic>> fetchUserPlaylists(int userId) async {
    final url = Uri.parse('http://10.0.2.2:8000/auth/user/$userId/playlists/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['playlists'];
    } else {
      throw Exception('Failed to load playlists');
    }
  }

  void onExerciseSelected(String exerciseType) async {
    setState(() {
      selectedExercise = exerciseType; // 선택된 운동 타입 갱신
    });

    try {
      final tracks = await ApiService.fetchTracksByType(exerciseType);
      setState(() {
        trackList = tracks; // API로 불러온 트랙 설정
      });
    } catch (e) {
      print('Error fetching tracks: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                'assets/icons/mugym_logo(small).png',
                width: 28,
                height: 28,
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MyPage( 
                            userId: widget.userId,
                            username: widget.username,)),
                  );
                },
                child: const Text(
                  'MY',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff111111),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0xFFFFFFFF),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, 
              children: [
              const Text(
                '내 플레이리스트',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff111111),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyPage( 
                            userId: widget.userId,
                            username: widget.username,)),
                  );
                },
                child: const Text(
                  '전체보기 >',
                  style: TextStyle(
                    fontFamily: 'Pretendard',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF777777),
                  ),
                ),
              )
            ]),
            const SizedBox(height: 12),
            FutureBuilder<List<dynamic>>(
              future: userPlaylists,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('오류 발생: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      '저장된 플레이리스트가 없습니다.',
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff777777),
                      ),
                    ),
                  );
                }

                final playlists = snapshot.data!;
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: playlists.map<Widget>((playlist) {
                      final albumCover = playlist['tracks'].isNotEmpty
                          ? playlist['tracks'][0]['album_cover']
                          : null;

                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => PlaylistScreen(
                                      playlistName: playlist['playlist_name'],
                                      tracks: playlist['tracks'],
                                      userId: widget.userId,
                                    ),
                                  ),
                                );
                              },
                              child: PlaylistBox(
                                playlistName: playlist['playlist_name'],
                                albumCover: albumCover,
                              ),
                            ),
                          );
                    }).toList(),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            const Row(
              children: [
                Text(
                  '나만의 믹스 만들기',
                  style: TextStyle(
                    fontFamily: 'Pretenard',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff111111),
                  ),
                ),
                SizedBox(width: 8),
                Image(
                  image: AssetImage('assets/images/AI_beta_button.png'),
                  width: 59,
                  height: 18,
                ),
              ],
            ),
            const SizedBox(height: 2),
            const Text(
              '운동 시간에 맞게 AI가 자동으로 노래를 선곡해줘요.',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xff777777),
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MixScreen(userId: widget.userId),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF638DFF), Color(0xFF51D888)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(500),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15.0),
                    child: Text(
                      '${widget.username}님만의 믹스 생성하러 가기 >',
                      style: const TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xffffffff),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 새로운 발견 섹션
            const Text(
              '새로운 발견',
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xff111111),
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ExercisePlaylist(
                    text: '런닝',
                    isSelected: selectedExercise == '런닝',
                    onSelected: () => onExerciseSelected('런닝'),
                  ),
                  const SizedBox(width: 6),
                  ExercisePlaylist(
                    text: '요가',
                    isSelected: selectedExercise == '요가',
                    onSelected: () => onExerciseSelected('요가'),
                  ),
                  const SizedBox(width: 6),
                  ExercisePlaylist(
                    text: '필라테스',
                    isSelected: selectedExercise == '필라테스',
                    onSelected: () => onExerciseSelected('필라테스'),
                  ),
                  const SizedBox(width: 6),
                  ExercisePlaylist(
                    text: '웨이트',
                    isSelected: selectedExercise == '웨이트',
                    onSelected: () => onExerciseSelected('웨이트'),
                  ),
                  const SizedBox(width: 6),
                  ExercisePlaylist(
                    text: '클라이밍',
                    isSelected: selectedExercise == '클라이밍',
                    onSelected: () => onExerciseSelected('클라이밍'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Column(
              children: trackList.take(4).map((track) {
                return Column(
                  children: [
                    ListTile(
                      leading: Image.network(
                        track['album_cover'],
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                      title: Text(
                        track['track_name'],
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff111111),
                        ),
                      ),
                      subtitle: Text(
                        track['artist_name'],
                        style: const TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff777777),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              }).toList(),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlaylistScreen(
                      playlistName: '새로운 발견 전체 목록',
                      tracks: trackList,
                      userId: widget.userId,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xffefefef),
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: const Text(
                '목록 전체 보기',
                style: TextStyle(
                  fontFamily: 'Pretendard',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff111111),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExercisePlaylist extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onSelected;

  const ExercisePlaylist({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onSelected,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xff638DFF) : const Color(0xffefefef),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            if (isSelected)
              const BoxShadow(
                color: Colors.black26,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Pretendard',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : const Color(0xff111111),
          ),
        ),
      ),
    );
  }
}


class PlaylistBox extends StatelessWidget {
  final String playlistName;
  final String? albumCover;

  const PlaylistBox({
    super.key,
    required this.playlistName,
    this.albumCover,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Column(
        children: [
          Stack(
            children: <Widget>[
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: const Color(0xFF777777),
                  image: albumCover != null
                      ? DecorationImage(
                          image: NetworkImage(albumCover!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(180),
                    image: const DecorationImage(
                      image: AssetImage(
                          'assets/images/playlist_button(small).png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: const Alignment(0, 0),
            child: Text(
              playlistName,
              style: const TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xff111111),
              ),
            ),
          ),
        ],
      ),
    );
  }
}