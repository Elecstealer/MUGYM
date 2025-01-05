import "package:flutter/material.dart";
import 'package:mugym/screens/playlist_screen.dart';
import 'package:table_calendar/table_calendar.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

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
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'OOO님',
                            style: TextStyle(
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
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height - 200,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 35),
                      const Text(
                        '내 플레이리스트',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff111111),
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PlaylistScreen(playlistName: '플레이리스트1', tracks: [],),
                            ),
                          );
                        },
                        child: const PlaylistBox(playlistName: '플레이리스트1'),
                      ),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PlaylistScreen(playlistName: '플레이리스트2', tracks: [],),
                            ),
                          );
                        },
                        child: const PlaylistBox(playlistName: '플레이리스트2'),
                      ),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PlaylistScreen(playlistName: '플레이리스트3', tracks: [],),
                            ),
                          );
                        },
                        child: const PlaylistBox(playlistName: '플레이리스트3'),
                      ),
                      const SizedBox(height: 15),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  const PlaylistScreen(playlistName: '플레이리스트4', tracks: [],),
                            ),
                          );
                        },
                        child: const PlaylistBox(playlistName: '플레이리스트4'),
                      ),
                      const SizedBox(height: 35),
                      const Text(
                        '내 운동 기록',
                        style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff111111),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TableCalendar(
                        firstDay: DateTime.utc(2024, 1, 1),
                        lastDay: DateTime.utc(2099, 12, 31),
                        focusedDay: DateTime.now(),
                        calendarFormat: CalendarFormat.week,
                        headerVisible: false,
                        daysOfWeekVisible: true,
                        onDaySelected: (selectedDay, focusedDay) {
                          // Handle day selection
                        },
                        calendarStyle: const CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Color(0xff777777),
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Color(
                                0xFF638DFF), // Change this to your desired color
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xffefefef),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            '운동 기록을 여기에 표시합니다.',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xff111111),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
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
                // image: const DecorationImage(
                //   image: AssetImage('assets/images/playlist1.jpg'),
                //   fit: BoxFit.cover,
                // ),
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
