import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ShareService {
  static Future<void> shareTrailer({
    required String title,
    required String url,
    String? description,
  }) async {
    try {
      final shareText = _buildShareText(title, url, description);
      
      // Copy to clipboard as fallback
      await Clipboard.setData(ClipboardData(text: shareText));
      
      // Try to launch share intent if available
      if (await canLaunchUrl(Uri.parse('mailto:'))) {
        final subject = Uri.encodeComponent('Check out this trailer: $title');
        final body = Uri.encodeComponent(shareText);
        final emailUrl = 'mailto:?subject=$subject&body=$body';
        
        await launchUrl(Uri.parse(emailUrl));
      } else {
        // Platform doesn't support sharing, text is already copied to clipboard
        throw Exception('Sharing not supported on this platform. Link copied to clipboard.');
      }
    } catch (e) {
      // Fallback: just copy to clipboard
      final shareText = _buildShareText(title, url, description);
      await Clipboard.setData(ClipboardData(text: shareText));
      throw Exception('Link copied to clipboard');
    }
  }
  
  static Future<void> shareApp() async {
    const appUrl = 'https://github.com/your-repo/cinemer'; // Replace with actual app URL
    const shareText = 'Check out Cinemer - the ultimate movie, TV show & anime app! $appUrl';
    
    try {
      await Clipboard.setData(const ClipboardData(text: shareText));
      
      if (await canLaunchUrl(Uri.parse('mailto:'))) {
        final subject = Uri.encodeComponent('Check out Cinemer App');
        final body = Uri.encodeComponent(shareText);
        final emailUrl = 'mailto:?subject=$subject&body=$body';
        
        await launchUrl(Uri.parse(emailUrl));
      } else {
        throw Exception('App link copied to clipboard');
      }
    } catch (e) {
      await Clipboard.setData(const ClipboardData(text: shareText));
      throw Exception('App link copied to clipboard');
    }
  }
  
  static Future<void> shareContent({
    required String title,
    required String type, // 'movie', 'tv', 'anime'
    String? overview,
    double? rating,
  }) async {
    try {
      final shareText = _buildContentShareText(title, type, overview, rating);
      
      await Clipboard.setData(ClipboardData(text: shareText));
      
      if (await canLaunchUrl(Uri.parse('mailto:'))) {
        final subject = Uri.encodeComponent('Check out this $type: $title');
        final body = Uri.encodeComponent(shareText);
        final emailUrl = 'mailto:?subject=$subject&body=$body';
        
        await launchUrl(Uri.parse(emailUrl));
      } else {
        throw Exception('Content info copied to clipboard');
      }
    } catch (e) {
      final shareText = _buildContentShareText(title, type, overview, rating);
      await Clipboard.setData(ClipboardData(text: shareText));
      throw Exception('Content info copied to clipboard');
    }
  }
  
  static String _buildShareText(String title, String url, String? description) {
    final buffer = StringBuffer();
    buffer.writeln('🎬 $title');
    if (description != null && description.isNotEmpty) {
      buffer.writeln();
      buffer.writeln(description);
    }
    buffer.writeln();
    buffer.writeln('Watch here: $url');
    buffer.writeln();
    buffer.writeln('Shared via Cinemer App');
    return buffer.toString();
  }
  
  static String _buildContentShareText(String title, String type, String? overview, double? rating) {
    final buffer = StringBuffer();
    
    final emoji = type == 'movie' ? '🎬' : type == 'tv' ? '📺' : '🌟';
    buffer.writeln('$emoji $title');
    
    if (rating != null && rating > 0) {
      buffer.writeln('⭐ Rating: ${rating.toStringAsFixed(1)}/10');
    }
    
    if (overview != null && overview.isNotEmpty) {
      buffer.writeln();
      buffer.writeln(overview);
    }
    
    buffer.writeln();
    buffer.writeln('Discovered via Cinemer App');
    return buffer.toString();
  }
}
