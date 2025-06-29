import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  const apiKey = '8e9c7e67d47a5eb566632d281ffbcfe1';
  const baseUrl = 'https://api.themoviedb.org/3';
  
  print('Testing TMDB API connection...');
  
  try {
    // Test 1: Configuration endpoint
    final configResponse = await http.get(
      Uri.parse('$baseUrl/configuration?api_key=$apiKey'),
    );
    
    if (configResponse.statusCode == 200) {
      print('✅ TMDB API configuration test passed');
    } else {
      print('❌ TMDB API configuration test failed: ${configResponse.statusCode}');
    }
    
    // Test 2: Popular movies
    final moviesResponse = await http.get(
      Uri.parse('$baseUrl/movie/popular?api_key=$apiKey&page=1'),
    );
    
    if (moviesResponse.statusCode == 200) {
      final data = jsonDecode(moviesResponse.body);
      final results = data['results'] as List;
      print('✅ Popular movies test passed - found ${results.length} movies');
      
      if (results.isNotEmpty) {
        final firstMovie = results.first;
        print('   First movie: ${firstMovie['title']}');
      }
    } else {
      print('❌ Popular movies test failed: ${moviesResponse.statusCode}');
    }
    
    // Test 3: Guest session
    final guestResponse = await http.get(
      Uri.parse('$baseUrl/authentication/guest_session/new?api_key=$apiKey'),
    );
    
    if (guestResponse.statusCode == 200) {
      final data = jsonDecode(guestResponse.body);
      if (data['success'] == true) {
        print('✅ Guest session test passed');
        print('   Guest session ID: ${data['guest_session_id']}');
      }
    } else {
      print('❌ Guest session test failed: ${guestResponse.statusCode}');
    }
    
    print('\n🎬 TMDB API tests completed!');
    
  } catch (e) {
    print('❌ Error during API tests: $e');
  }
}
