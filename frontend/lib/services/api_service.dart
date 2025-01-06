import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000';

  static Future<Map<String, dynamic>> fetchPlaylist(
      String exercise, String time) async {
    
    final exerciseMapping = {
      '런닝': 'running',
      '요가': 'yoga',
      '필라테스': 'pilates',
      '웨이트': 'weight',
      '클라이밍': 'climbing',
      '사이클링': 'cycling',
    };
    final englishExercise = exerciseMapping[exercise] ?? exercise;

    final url = Uri.parse(
        '$baseUrl/auth/get_multiple_tracks/?exercise=$englishExercise&time=$time');
    final response = await http.get(url);


    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load playlist');
    }
  }

  static Future<List<dynamic>> fetchTracksByType(String exercise) async {
    // 한글 운동 타입을 영어로 변환
    final exerciseMapping = {
      '런닝': 'running',
      '요가': 'yoga',
      '필라테스': 'pilates',
      '웨이트': 'weight',
      '클라이밍': 'climbing',
      '사이클링': 'cycling',
    };
    final englishExercise = exerciseMapping[exercise] ?? exercise;

    final url = Uri.parse(
        '$baseUrl/auth/get_tracks_by_type/?exercise=$englishExercise');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['tracks'];
    } else {
      throw Exception('Failed to fetch tracks for $exercise');
    }
  }

  static Future<Map<String, dynamic>> loginUser(
      String email, String password) async {
    final url = Uri.parse('$baseUrl/auth/user/login/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }

  // user_id로 username 가져오기
  static Future<String> getUsername(int userId) async {
    final url = Uri.parse('$baseUrl/auth/user/get_username/$userId/');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['username'];
      } else {
        throw Exception('Failed to fetch username');
      }
    } catch (e) {
      throw Exception('Error fetching username: $e');
    }
  }

  static Future<Map<String, dynamic>> savePlaylist(
      int userId, String exercisetype, List<dynamic> tracks) async {
    final url = Uri.parse('$baseUrl/auth/save_playlist/');
    final exerciseMapping = {
      '런닝': 'running',
      '요가': 'yoga',
      '필라테스': 'pilates',
      '웨이트': 'weight',
      '클라이밍': 'climbing',
      '사이클링': 'cycling',
    };
    final exerciseeng = exerciseMapping[exercisetype] ?? exercisetype;
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        'exercise_type': exerciseeng,
        'tracks': tracks.map((track) {
          return {
            'track_id': track['track_id'],
            'track_name': track['track_name'],
            'artist_name': track['artist_name'],
            'album_cover': track['album_cover'],
            'duration_ms': track['duration_ms'],
          };
        }).toList(),
      }),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to save playlist');
    }
  }
}
