import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/api_service.dart';
import 'playlist_screen.dart';

class MixScreen extends StatefulWidget {
  final int userId;

  const MixScreen({super.key, required this.userId});

  @override
  _MixScreenState createState() => _MixScreenState();
}

class _MixScreenState extends State<MixScreen> {
  String username = ''; // username 저장
  String selectedExercise = '선택하기';
  String selectedTime = '입력하기';
  bool isLoading = true;

  // 믹스 생성 팝업창
  void addDialog(context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return GestureDetector(
          onVerticalDragDown: (_) {
            Navigator.of(context).pop();
          },
          child: Container(
            color: const Color(0xFF737373),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      constraints: const BoxConstraints(
                        minHeight: 400,
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SpinKitWave(
                              color: Color(0xff777777),
                              size: 30,
                              duration: Duration(seconds: 2),
                            ),
                            SizedBox(height: 20),
                            Text(
                              'AI가 플레이리스트를 생성 중입니다...',
                              style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Color(0xff111111),
                              ),
                            ),
                            SizedBox(height: 40),
                            mixLoadingPlaylist(),
                            SizedBox(height: 14),
                            mixLoadingPlaylist(),
                            SizedBox(height: 14),
                            mixLoadingPlaylist(),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void generatePlaylist(BuildContext context) async {
    if (selectedExercise == '선택하기' || selectedTime == '입력하기') {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            title: Text('입력 오류'),
            content: Text('운동 종류와 시간을 모두 입력해주세요.'),
          );
        },
      );
      return;
    }

    // 로딩 다이얼로그 표시
    addDialog(context);

    try {
      await Future.delayed(const Duration(seconds: 2));
      final playlist =
          await ApiService.fetchPlaylist(selectedExercise, selectedTime);

      Navigator.of(context).pop(); // 로딩 팝업 닫기
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PlaylistScreen(
          playlistName: selectedExercise,
          tracks: playlist['tracks'],
        ),
      ));
    } catch (e) {
      Navigator.of(context).pop(); // 로딩 팝업 닫기
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('오류 발생'),
            content: Text('플레이리스트 생성 중 오류가 발생했습니다: $e'),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffffffff),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 24.0),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/mix_image.png',
                    width: 166,
                    height: 174,
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'AI가 만들어주는\n나만의 음악 믹스',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '단 30초면 음악을 고르는 \n번거로움 없이 나만의 플레이리스트가 자동 생성돼요.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      color: Color(0xff777777),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xffefefef),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 13.0, horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '운동 종류',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff111111),
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: const Color(0xffffffff),
                                    title: const Text('운동 종류 선택',
                                        style: TextStyle(
                                          fontFamily: 'Pretendard',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xff111111),
                                        )),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        ListTile(
                                          title: const Text('런닝'),
                                          onTap: () {
                                            setState(() {
                                              selectedExercise = '런닝';
                                            });
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        ListTile(
                                          title: const Text('웨이트'),
                                          onTap: () {
                                            setState(() {
                                              selectedExercise = '웨이트';
                                            });
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        ListTile(
                                          title: const Text('요가'),
                                          onTap: () {
                                            setState(() {
                                              selectedExercise = '요가';
                                            });
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        ListTile(
                                          title: const Text('필라테스'),
                                          onTap: () {
                                            setState(() {
                                              selectedExercise = '필라테스';
                                            });
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        ListTile(
                                          title: const Text('클라이밍'),
                                          onTap: () {
                                            setState(() {
                                              selectedExercise = '클라이밍';
                                            });
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        ListTile(
                                          title: const Text('사이클링'),
                                          onTap: () {
                                            setState(() {
                                              selectedExercise = '사이클링';
                                            });
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('닫기'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Text(
                              selectedExercise,
                              style: const TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff777777),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(
                      minHeight: 0,
                      minWidth: 0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xffefefef),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 13.0, horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '운동 시간',
                            style: TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff111111),
                            ),
                          ),
                          TextField(
                            onChanged: (value) {
                              setState(() {
                                selectedTime = value;
                              });
                            },
                            decoration: const InputDecoration(
                              hintText: '입력하기',
                              suffixText: '분',
                              hintStyle: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff777777),
                              ),
                              suffixStyle: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xff777777),
                              ),
                              border: InputBorder.none,
                              filled: true,
                              fillColor: Color(0xffefefef),
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: 0.0,
                                  horizontal: 0.0), // Adjusted padding
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: const TextStyle(
                              fontFamily: 'Pretendard',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff777777),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xff111111),
                      borderRadius: BorderRadius.circular(500),
                    ),
                    child: Center(
                      child: GestureDetector(
                        onTap: () => generatePlaylist(context),
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 15.0),
                          child: Text(
                            '생성하기',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xffffffff),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class mixLoadingPlaylist extends StatelessWidget {
  const mixLoadingPlaylist({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: const Color(0xfff5f5f5),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 230,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: const Color(0xfff5f5f5),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 195,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: const Color(0xfff5f5f5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
