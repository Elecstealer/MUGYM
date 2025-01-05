import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class PlayScreen extends StatefulWidget {
  final String playlistName;
  final List<dynamic> tracks;

  const PlayScreen({
    super.key,
    required this.playlistName,
    required this.tracks,
  });

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  final player = AudioPlayer();
  int currentTrackIndex = 0;
  bool isLoading = true;
  Duration? totalDuration;

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _playCurrentTrack();
  }

  Future<void> _playCurrentTrack() async {
    try {
      final track = widget.tracks[currentTrackIndex];
      final yt = YoutubeExplode();
      final searchQuery = "${track['track_name']} ${track['artist_name']}";
      final video = (await yt.search.search(searchQuery)).first;
      final manifest =
          await yt.videos.streamsClient.getManifest(video.id.value);
      final audioUrl = manifest.audioOnly.last.url.toString();

      await player.setSourceUrl(audioUrl);
      player.play(UrlSource(audioUrl));

      totalDuration = video.duration;

      setState(() {
        isLoading = false;
      });

      player.onPlayerComplete.listen((_) {
        if (currentTrackIndex < widget.tracks.length - 1) {
          setState(() {
            currentTrackIndex++;
            isLoading = true;
          });
          _playCurrentTrack();
        }
      });
    } catch (e) {
      print("Error playing track: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTrack = widget.tracks[currentTrackIndex];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 앨범 커버
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(
                      currentTrack['album_cover'],
                      height: 300,
                      width: 300,
                      fit: BoxFit.cover,
                    ),
                  ),

                  // 노래 제목 및 가수 이름
                  Column(
                    children: [
                      Text(
                        currentTrack['track_name'],
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentTrack['artist_name'],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),

                  // 진행 바
                  StreamBuilder<Duration>(
                    stream: player.onPositionChanged,
                    builder: (context, snapshot) {
                      final position = snapshot.data ?? Duration.zero;
                      return ProgressBar(
                        progress: position,
                        total: totalDuration ?? const Duration(minutes: 4),
                        onSeek: (duration) {
                          player.seek(duration);
                        },
                        progressBarColor: Colors.black,
                        baseBarColor: Colors.grey[300]!,
                        thumbColor: Colors.black,
                      );
                    },
                  ),

                  // 컨트롤 버튼
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: () {
                          // 셔플 버튼 로직
                        },
                        icon: Image.asset(
                          'assets/images/shuffle.png',
                          width: 28,
                          height: 28,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (currentTrackIndex > 0) {
                            setState(() {
                              currentTrackIndex--;
                              isLoading = true;
                            });
                            _playCurrentTrack();
                          }
                        },
                        icon: Image.asset(
                          'assets/images/skip_to_prev.png',
                          width: 48,
                          height: 48,
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          if (player.state == PlayerState.playing) {
                            await player.pause();
                          } else {
                            await player.resume();
                          }
                          setState(() {});
                        },
                        icon: Icon(
                          player.state == PlayerState.playing
                              ? Icons.pause_circle
                              : Icons.play_circle,
                          size: 64,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (currentTrackIndex < widget.tracks.length - 1) {
                            setState(() {
                              currentTrackIndex++;
                              isLoading = true;
                            });
                            _playCurrentTrack();
                          }
                        },
                        icon: Image.asset(
                          'assets/images/skip_to_next.png',
                          width: 48,
                          height: 48,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // 반복 버튼 로직
                        },
                        icon: Image.asset(
                          'assets/images/repeat.png',
                          width: 28,
                          height: 28,
                        ),
                      ),
                    ],
                  ),

                  // 하단 버튼
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 플레이리스트 버튼
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // 이전 화면으로 이동
                        },
                        icon: Image.asset(
                          'assets/images/playlist.png',
                          width: 28,
                          height: 28,
                        ),
                      ),

                      // 좋아요 버튼
                      IconButton(
                        onPressed: () {
                          // 좋아요 로직 (추후 구현 가능)
                          print("좋아요 버튼 클릭됨!");
                        },
                        icon: Image.asset(
                          'assets/images/heart.png',
                          width: 28,
                          height: 28,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
