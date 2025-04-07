import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:ui';

import '../../core/theme/theme.dart';
import '../home/controller/homecontroller.dart';

class DynamicPageScreen extends StatelessWidget {
  final String title;
  final String slug;

  const DynamicPageScreen({Key? key, required this.title, required this.slug})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the HomeController
    final HomeController controller = Get.find<HomeController>();

    // Fetch page content when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchPageContent(slug);
    });

    final isDarkMode = Get.isDarkMode;

    return Scaffold(
      backgroundColor:
          isDarkMode ? const Color(0xFF1A1A2E) : const Color(0xFFF8F9FE),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        centerTitle: true,
        scrolledUnderElevation: 0,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: Builder(
          builder: (BuildContext context) {
            return Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDarkMode
                    ? Colors.black.withOpacity(0.3)
                    : Colors.white.withOpacity(0.8),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.5)
                        : Colors.grey.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.8),
                  width: 1,
                ),
              ),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      size: 18,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            );
          },
        ),
        toolbarHeight: 70,
        title: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.2)
                    : Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.8),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.black.withOpacity(0.2)
                        : Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background design elements
          Positioned.fill(
            child: isDarkMode
                ? Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1A1A2E),
                          Color(0xFF16213E),
                        ],
                      ),
                    ),
                  )
                : Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFF8F9FE),
                          Color(0xFFEDF1FD),
                        ],
                      ),
                    ),
                  ),
          ),
          // Decorative circles
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CustomTheme.loginGradientStart.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: CustomTheme.loginGradientEnd.withOpacity(0.1),
              ),
            ),
          ),

          // Content Area
          SafeArea(
            child: Obx(() {
              // Show loading indicator while content is being fetched
              if (controller.isPageLoading.value) {
                return Center(
                  child: CircularProgressIndicator(
                    color: CustomTheme.loginGradientStart,
                  ),
                );
              }

              // Process HTML content to ensure proper display
              String processedContent =
                  _processHtmlContent(controller.pageContent.value);

              // Display the page content using Html widget for rich text rendering
              return SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Container(
                  width: MediaQuery.of(context).size.width - 32,
                  child: Html(
                    data: processedContent,
                    style: {
                      'body': Style(
                        fontSize: FontSize(16),
                        lineHeight: LineHeight(1.5),
                        width: Width.auto(),
                        maxLines: null,
                        textOverflow: TextOverflow.clip,
                      ),
                      'h1, h2, h3, h4, h5, h6': Style(
                        display: Display.block,
                        width: Width.auto(),
                      ),
                      'p': Style(
                        width: Width.auto(),
                        textAlign: TextAlign.left,
                      ),
                      'div': Style(
                        width: Width.auto(),
                      ),
                    },
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // Simplified HTML processing function that addresses both issues
  String _processHtmlContent(String html) {
    // Fix width issues
    html = html.replaceAll(RegExp(r'width:\s*\d+px'), 'width: auto');
    html = html.replaceAll('width: 1250px', 'width: auto');

    // Fix display issues
    html =
        html.replaceAll(RegExp(r'display:\s*inline-block'), 'display: block');

    // Add CSS to fix vertical text and ensure proper wrapping
    const String fixStyles = '''
    <style>
      * {
        white-space: normal !important;
        word-break: break-word !important;
        max-width: 100% !important;
      }
      h1, h2, h3, h4, h5, h6, p, div, span {
        display: block !important;
        white-space: normal !important;
      }
    </style>
    ''';

    // Wrap the content with our style fixes
    if (html.contains('<head>')) {
      return html.replaceFirst('<head>', '<head>$fixStyles');
    } else {
      return '<html><head>$fixStyles</head><body>$html</body></html>';
    }
  }
}
