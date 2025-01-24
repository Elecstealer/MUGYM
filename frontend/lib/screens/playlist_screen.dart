import 'package:flutter/material.dart';
import 'dart:math'; // 랜덤 재생에 필요
import 'play_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PlaylistScreen extends StatefulWidget {
  final String playlistName;
  final List<dynamic> tracks;
  final int userId;
  final int mypageflag;

  const PlaylistScreen({
    super.key,
    required this.playlistName,
    required this.tracks,
    required this.userId,
    required this.mypageflag,
  });

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  late String _playlistName;
  final TextEditingController _textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _playlistName = widget.playlistName;
    _textEditingController.text = _playlistName;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void playAllTracks(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PlayScreen(
        playlistName: _playlistName,
        tracks: widget.tracks,
      ),
    ));
  }

  void playRandomTrack(BuildContext context) {
    if (widget.tracks.isNotEmpty) {
      final randomTrack = widget.tracks[Random().nextInt(widget.tracks.length)];
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PlayScreen(
          playlistName: '랜덤 트랙: ${randomTrack['track_name']}',
          tracks: [randomTrack], // 랜덤 트랙만 넘김
        ),
      ));
    }
  }

  Future<void> savePlaylist(BuildContext context) async {
    final url = Uri.parse('http://10.0.2.2:8000/auth/save_playlist/');
    final body = jsonEncode({
      'userId': widget.userId,
      'exercise_type': _playlistName,
      'tracks': widget.tracks.map((track) {
        return {
          'track_id': track['track_id'],
          'track_name': track['track_name'],
          'artist_name': track['artist_name'],
          'album_cover': track['album_cover'],
          'duration_ms': track['duration_ms'],
        };
      }).toList(),
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('플레이리스트가 저장되었습니다!')),
        );
      } else if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('이미 저장된 플레이리스트입니다.')),
        );
      } else {
        final error = jsonDecode(response.body)['error'];
        throw Exception(error ?? '저장 중 문제가 발생했습니다.');
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('오류 발생'),
            content: Text('플레이리스트 저장 중 오류가 발생했습니다: $e'),
          );
        },
      );
    }
  }

  Future<void> deletePlaylist(BuildContext context) async {
    final url = Uri.parse('http://10.0.2.2:8000/auth/delete_playlist/');
    final body = jsonEncode({
      'userId': widget.userId,
      'playlistName': _playlistName,
      'tracks': widget.tracks.map((track) {
        return {
          'track_id': track['track_id'],
          'track_name': track['track_name'],
          'artist_name': track['artist_name'],
          'album_cover': track['album_cover'],
          'duration_ms': track['duration_ms'],
        };
      }).toList(),
    });

    try {
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('플레이리스트가 삭제되었습니다.')),
        );
      } else {
        final error = jsonDecode(response.body)['error'];
        throw Exception(error ?? '삭제 중 문제가 발생했습니다.');
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('오류 발생'),
            content: Text('플레이리스트 삭제 중 오류가 발생했습니다: $e'),
          );
        },
      );
    }
  }

  Future<void> updatePlaylistName(String newName) async {
    final url = Uri.parse('http://10.0.2.2:8000/auth/update_playlist_name/');
    final body = jsonEncode({
      'userId': widget.userId,
      'playlistName': _playlistName, // 기존 플레이리스트 이름
      'newName': newName,
      'tracks': widget.tracks.map((track) {
        return {
          'track_id': track['track_id'],
          'track_name': track['track_name'],
          'artist_name': track['artist_name'],
          'album_cover': track['album_cover'],
          'duration_ms': track['duration_ms'],
        };
      }).toList(),
    });

    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('플레이리스트 이름이 변경되었습니다.')),
        );
        setState(() {
          _playlistName = newName; // 상태 업데이트
        });
      } else {
        final error = jsonDecode(response.body)['error'];
        throw Exception(error ?? '이름 변경 중 문제가 발생했습니다.');
      }
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('오류 발생'),
            content: Text('플레이리스트 이름 변경 중 오류가 발생했습니다: $e'),
          );
        },
      );
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
            Navigator.of(context).pop(true);
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
                  if (widget.mypageflag != 1)
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
                if (value == 'savePlaylist') {
                  savePlaylist(context);
                } else if (value == 'deletePlaylist') {
                  deletePlaylist(context);
                }
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
                  image: widget.tracks.isNotEmpty
                      ? DecorationImage(
                          image:
                              NetworkImage(widget.tracks.first['album_cover']),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _playlistName,
                    style: const TextStyle(
                      fontFamily: 'Pretendard',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff111111),
                    ),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () async {
                      final newName = await showDialog<String>(
                        context: context,
                        builder: (BuildContext context) {
                          String tempName = _playlistName;
                          return AlertDialog(
                            backgroundColor: const Color(0xffffffff),
                            title: const Text('플레이리스트 이름 변경',
                                style: TextStyle(
                                  fontFamily: 'Pretendard',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff111111),
                                )),
                            content: TextField(
                              onChanged: (value) {
                                tempName = value;
                              },
                              controller: _textEditingController,
                              decoration: const InputDecoration(
                                hintText: "새 이름을 입력하세요",
                              ),
                              autofocus: true,
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('취소'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(tempName);
                                },
                                child: const Text('저장'),
                              ),
                            ],
                          );
                        },
                      );
                      
                      if (newName != null && newName.isNotEmpty) {
                        await updatePlaylistName(newName); // API 호출
                        setState(() {
                          _playlistName = newName; // 상태 업데이트
                        });
                      }
                    },
                    child: const Icon(
                      Icons.edit_outlined,
                      color: Color(0xff777777),
                      size: 20,
                    ),
                  ),
                ],
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
              ...widget.tracks.map((track) {
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
