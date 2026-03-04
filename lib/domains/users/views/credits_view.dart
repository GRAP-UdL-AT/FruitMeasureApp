import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fruit_measure_app/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class CreditsView extends StatelessWidget {
  const CreditsView({super.key});

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {}
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final websiteUrl = loc.creditsWebsiteUrl;

    return Scaffold(
      appBar: AppBar(title: Text(loc.creditsMenuItem), centerTitle: true),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    loc.creditsDevelopmentText,
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  Builder(
                    builder: (context) {
                      final websiteText = loc.creditsWebsiteText(websiteUrl);
                      final urlIndex = websiteText.indexOf(websiteUrl);
                      if (urlIndex == -1) {
                        return Text(
                          websiteText,
                          textAlign: TextAlign.left,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        );
                      }
                      return RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(text: websiteText.substring(0, urlIndex)),
                            TextSpan(
                              text: websiteUrl,
                              style: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer:
                                  TapGestureRecognizer()
                                    ..onTap = () => _launchURL(websiteUrl),
                            ),
                            TextSpan(
                              text: websiteText.substring(
                                urlIndex + websiteUrl.length,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 32),
                  const Column(
                    children: [
                      // Universitat de Lleida
                      _LogoWidget(
                        imagePath: 'assets/logos/lleida-logo.png',
                        height: 122,
                      ),
                      SizedBox(height: 24),
                      // IRTA
                      _LogoWidget(
                        imagePath: 'assets/logos/logos_IRTA.png',
                        height: 60,
                      ),
                      SizedBox(height: 24),
                      // Generalitat de Catalunya
                      _LogoWidget(
                        imagePath:
                            'assets/logos/generalitat-departament-logo.png',
                        height: 55,
                      ),
                      SizedBox(height: 24),
                      // Gobierno de España
                      _LogoWidget(
                        imagePath: 'assets/logos/gobEspaña-logo.png',
                        height: 87,
                      ),
                      SizedBox(height: 24),
                      // Unión Europea
                      _LogoWidget(
                        imagePath: 'assets/logos/UE-logo.png',
                        height: 72,
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Divider(height: 1, thickness: 1),
                  const SizedBox(height: 24),
                  Text(
                    loc.yoloLicenseTitle,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    loc.yoloLicenseText,
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LogoWidget extends StatelessWidget {
  const _LogoWidget({required this.imagePath, this.height = 80});

  final String imagePath;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Container(
        height: height,
        width: double.infinity,
        alignment: Alignment.center,
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return SizedBox(
              height: height,
              child: const Center(
                child: Icon(Icons.image_not_supported, color: Colors.grey),
              ),
            );
          },
        ),
      ),
    );
  }
}
