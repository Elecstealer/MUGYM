import 'package:flutter/material.dart';
import 'package:mugym/screens/playlist_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MyPage extends StatefulWidget {
  final String username; // 사용자 이름
  final int userId; // 사용자 ID

  const MyPage({super.key, required this.username, required this.userId});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  late Future<List<dynamic>> userPlaylists;

  @override
  void initState() {
    super.initState();
    userPlaylists = fetchPlaylists(widget.userId); // 플레이리스트 데이터 가져오기
  }

  Future<List<dynamic>> fetchPlaylists(int userId) async {
    final url = Uri.parse('http://10.0.2.2:8000/auth/user/$userId/playlists/');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['playlists'];
    } else {
      throw Exception('Failed to load playlists');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff222222),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        backgroundColor: const Color(0xff222222),
        automaticallyImplyLeading: false,
        title: GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Image.asset(
            'assets/images/arrow.png',
            width: 24,
            height: 24,
            color: const Color(0xffFFFFFF),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding:
                  const EdgeInsets.only(top: 15.0, left: 24.0, right: 24.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: const Color(0xffd9d9d9),
                          // image: DecorationImage(
                          //   image: AssetImage('assets/images/profile.png'),
                          //   fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.username,
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffFFFFFF),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            '내 정보 보기',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xffdadada),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 55),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 24),
              height: MediaQuery.of(context).size.height - 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xffffffff),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(25),
                  topRight: Radius.circular(25),
                ),
              ),
              child: FutureBuilder<List<dynamic>>(
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff777777),
                        ),
                      ),
                    );
                  }

                  final playlists = snapshot.data!;
                  return ListView.builder(
                    itemCount: playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = playlists[index];
                      return GestureDetector(
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
                        child: PlaylistBox(playlistName: playlist['playlist_name']),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PlaylistBox extends StatelessWidget {
  // playlist box widget
  final String playlistName;

  const PlaylistBox({
    super.key,
    required this.playlistName,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Stack(
          children: <Widget>[
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: const Color(0xFF777777),
              ),
            ),
            Positioned(
              bottom: 5,
              left: 5,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(180),
                  image: const DecorationImage(
                    image:
                        AssetImage('assets/images/playlist_button(small).png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            )
          ],
        ),
        const SizedBox(width: 10),
        Align(
          alignment: const Alignment(0, 0),
          child: Text(
            playlistName,
            style: const TextStyle(
              fontFamily: 'Pretendard',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xff111111),
            ),
          ),
        ),
      ],
    );
  }
}
