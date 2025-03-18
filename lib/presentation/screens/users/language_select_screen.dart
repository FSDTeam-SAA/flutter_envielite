import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_guide/core/controller/admin_controller.dart';
import 'package:tour_guide/presentation/screens/users/route_view_screen.dart';

class LanguageSelectScreen extends StatelessWidget {
  const LanguageSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.find<AdminController>();

    // Play the intro audio when the screen is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // controller.getRouteData(controller.selectedRoute.toString());
      // controller.
      controller.getIntroAudio().then((introAudio) {
        if (introAudio.isNotEmpty) {
          controller.audioService.playAudio(introAudio);
        }
      });
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Select Language')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SizedBox(
              width: constraints.maxWidth < 600 ? double.infinity : 600,
              child:
                  controller.predefinedLanguages.isEmpty
                      ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'No languages available. Please check back later.',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      )
                      : Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: ListView.builder(
                          itemCount: controller.predefinedLanguages.length,
                          itemBuilder: (context, index) {
                            final language =
                                controller.predefinedLanguages[index];
                            final greeting =
                                controller.greetings[language] ?? "";

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 8.0,
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  // Handle language selection
                                  controller.selectedLanguage.value = language;
                                  Get.to(() => RouteViewScreen());
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 20.0,
                                  ),
                                  textStyle: const TextStyle(fontSize: 18),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: Stack(
                                    alignment:
                                        Alignment
                                            .center, // Centers the language text
                                    children: [
                                      // Greeting (left-aligned)
                                      Align(
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          greeting,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),

                                      // Language (center-aligned)
                                      Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          language,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
            ),
          );
        },
      ),
    );
  }
}
