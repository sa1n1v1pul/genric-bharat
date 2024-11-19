import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class SocialMediaSection extends StatelessWidget {
  const SocialMediaSection({Key? key}) : super(key: key);

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      if (!await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception('Could not launch $urlString');
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      // You might want to show a snackbar or dialog here to inform the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 50),
      child: Column(
        children: [
          // Logo and Text
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 48,
                  color: Colors.blue[200],
                ),
                const SizedBox(height: 16),
                Text(
                  'Affordable healthcare',
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.blue[200],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'for every Indian',
                  style: TextStyle(
                    fontSize: 28,
                    color: Colors.blue[200],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Social Media Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Facebook
              _buildSocialIcon(
                FontAwesomeIcons.facebookF,
                'https://www.facebook.com/profile.php?id=61566317623633',
                Colors.blue,
              ),
              const SizedBox(width: 32),
              // YouTube
              _buildSocialIcon(
                FontAwesomeIcons.youtube,
                'https://www.youtube.com/demo',
                Colors.red,
              ),
              const SizedBox(width: 32),
              // Instagram
              _buildSocialIcon(
                FontAwesomeIcons.instagram,
                'https://www.instagram.com/demo',
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialIcon(IconData icon, String url, Color color) {
    return InkWell(
      onTap: () => _launchURL(url),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 30,
          color: color,
        ),
      ),
    );
  }
}
