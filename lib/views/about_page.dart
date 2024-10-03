import 'package:flutter/material.dart';
import 'package:chatty/constant/app_color.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.chevron_left,
            color: AppColors.backgroundColor,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          "About",
          style: TextStyle(color: AppColors.darkGray),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About JustLive',
              style: TextStyle(color: AppColors.darkGray),
            ),
            const SizedBox(height: 14),
            const Text(
              'JustLive is a modern messaging application that allows you to stay connected with your friends and family. It offers features like real-time messaging, media sharing, and more.',
              style: TextStyle(color: AppColors.darkGray),
            ),
            const SizedBox(height: 14),
            const Text(
              'Version 1.0.0',
              style: TextStyle(color: AppColors.darkGray),
            ),
            const SizedBox(height: 14),
            const Text(
              'Developed by JustLive Team',
              style: TextStyle(color: AppColors.darkGray),
            ),
            const SizedBox(height: 14),
            const Text(
              'Key Features',
              style: TextStyle(
                color: AppColors.darkGray,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '• Real-time messaging\n• Media sharing\n• User-friendly interface\n• Secure and private communication',
              style: TextStyle(color: AppColors.darkGray),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () {
                _showContactBottomSheet(context);
              },
              child: const Text(
                'Contact Us',
                style: TextStyle(
                  color: AppColors.backgroundColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 14),
            GestureDetector(
              onTap: () {
                // Navigate to privacy policy page or open a URL
              },
              child: Text(
                'Privacy Policy',
                style: const TextStyle(color: AppColors.backgroundColor).copyWith(
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Support',
              style: TextStyle(
                color: AppColors.darkGray,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'For support, please visit our support page or contact us at support@justlive.com.',
              style: TextStyle(color: AppColors.darkGray),
            ),
            const SizedBox(height: 14),
            const Text(
              'Feedback',
              style: TextStyle(
                color: AppColors.darkGray,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'We value your feedback! Please let us know your thoughts and suggestions at feedback@justlive.com.',
              style: TextStyle(color: AppColors.darkGray),
            ),
            const SizedBox(height: 14),
            const Text(
              'Credits: Special thanks to all contributors and libraries used.',
              style: TextStyle(color: AppColors.darkGray),
            ),
          ],
        ),
      ),
    );
  }


void _showContactBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center( // Center the "Contact Us" text
              child: const Text(
                'Contact Us',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Email: support@justlive.com',
              style: TextStyle(
                color: AppColors.darkGray,
                  fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Phone: +123-456-7890',
              style: TextStyle(
                color: AppColors.darkGray,
                 fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Website: www.justlive.com',
              style: TextStyle(
                color: AppColors.darkGray,
                 fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.redColor, // Set the background color to red
                  foregroundColor: AppColors.white, // Set the text color to white
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      );
    },
  );
}
}