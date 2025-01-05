import 'package:http/http.dart' as http;

class SpotifyApi {
  Future<void> searchTrack(String query) async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/search?q=$query&type=track'),
      headers: {
        'Authorization':
            'Bearer BQDX10SrLJLBog0Hf412NuKfUCzbo_P9oSH2tnq2bgFgU3hgm_aEax_juH-zhyLwwUDrP2x0tjLlv7xJqsPrqhjrJf_GXNa1YdVZXQnqOHoHOjaDRtc1_pozpSxtaVF22bNr-f4YILBXaU1aNCQrdArLI3U7aE9TC0L9KpZIurLgKG1wp-V9Iig-oqS4CuxnwOtiVKClFhwInafhuSniF6QgzlnsTHI',
      },
    );

    if (response.statusCode == 200) {
      print('Search successful');
    } else {
      print('Failed to search track');
    }
  }
}
