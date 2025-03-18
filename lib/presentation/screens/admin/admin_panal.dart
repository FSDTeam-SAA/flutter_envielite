import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tour_guide/core/controller/admin_controller.dart';
// import 'package:tour_guide/presentation/screens/admin/admin_edit_screen.dart';

class AdminPanel extends GetView<AdminController> {
  const AdminPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        // actions: _buildAppBarActions(),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth:
                      constraints.maxWidth > 800
                          ? 600
                          : constraints.maxWidth - 32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildRouteDropdown(),
                    const SizedBox(height: 20),
                    _buildLanguageDropdown(),
                    const SizedBox(height: 20),
                    _buildActionButtons(),
                    const SizedBox(height: 20),
                    _buildPOIList(),
                    const SizedBox(height: 20),
                    _buildPointButton(),
                    const SizedBox(height: 20),
                    _buildFileAndSaveButtons(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // List<Widget> _buildAppBarActions() {
  //   return [
  //     Obx(
  //       () => TextButton(
  //         onPressed:
  //             controller.isRouteAndLanguageSelected.value
  //                 ? () => Get.to(() => RouteEditScreen())
  //                 : null,
  //         child: const Text('Edit', style: TextStyle(color: Colors.white)),
  //       ),
  //     ),
  //   ];
  // }

  Widget _buildRouteDropdown() {
    return Obx(
      () => DropdownButtonFormField<String>(
        value:
            controller.selectedRoute.value.isEmpty
                ? null
                : controller.selectedRoute.value,
        decoration: _inputDecoration('Select Route to Manage:'),
        items:
            controller.predefinedRoutes.map((route) {
              return DropdownMenuItem(value: route, child: Text(route));
            }).toList(),
        onChanged: (value) {
          controller.selectedRoute.value = value!;
          controller.loadSavedData();
        },
      ),
    );
  }

  Widget _buildLanguageDropdown() {
    return Obx(
      () => DropdownButtonFormField<String>(
        value:
            controller.selectedLanguage.value.isEmpty
                ? null
                : controller.selectedLanguage.value,
        decoration: _inputDecoration('Select Language:'),
        items:
            controller.predefinedLanguages.map((lang) {
              return DropdownMenuItem(value: lang, child: Text(lang));
            }).toList(),
        onChanged: (value) {
          controller.selectedLanguage.value = value!;
          controller.loadSavedData();
        },
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () => controller.selectIntroAudio(),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50), // Button height
          ),
          child: const Text('Add/Update Intro Audio'),
        ),
        const SizedBox(height: 10),
        Obx(
          () =>
              controller.selectedIntroAudio.value.isNotEmpty
                  ? Text(
                    'Selected: ${controller.selectedIntroAudio.value.split('/').last}',
                  )
                  : SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildPOIList() {
    return Obx(
      () => Column(
        children: List.generate(controller.pois.length, (index) {
          if (index >= controller.searchResults.length ||
              index >= controller.searchControllers.length ||
              index >= controller.latControllers.length ||
              index >= controller.lngControllers.length ||
              index >= controller.audioPaths.length) {
            return const SizedBox.shrink(); // Skip invalid indices
          }

          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Obx(
                    () => TextFormField(
                      controller: controller.searchControllers[index],
                      decoration: _inputDecoration(
                        'Search location (online only)',
                      ),
                      onChanged: (query) {
                        controller.onSearchTextChanged(query, index);
                      },
                    ),
                  ),

                  const SizedBox(height: 5),

                  Obx(() {
                    if (index >= controller.searchLoadingStates.length) {
                      return const SizedBox.shrink();
                    }
                    return controller.searchLoadingStates[index].value
                        ? const LinearProgressIndicator(
                          color: Colors.black,
                          backgroundColor: Colors.white,
                          minHeight: 2,
                        )
                        : const SizedBox.shrink();
                  }),

                  const SizedBox(height: 10),

                  Obx(() {
                    if (index >= controller.searchResults.length) {
                      return const SizedBox.shrink(); // Skip invalid indices
                    }
                    // if (controller.searchResults[index].isEmpty) {
                    //   return const Padding(
                    //     padding: EdgeInsets.symmetric(vertical: 8),
                    //     child: Text(
                    //       'No results found.',
                    //       style: TextStyle(color: Colors.grey),
                    //     ),
                    //   );
                    // }
                    return Container(
                      constraints: BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: controller.searchResults[index].length,
                        itemBuilder: (context, searchIndex) {
                          final location =
                              controller.searchResults[index][searchIndex];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              title: Text(location['display_name']),
                              onTap: () {
                                controller.selectLocation(location, index);
                              },
                            ),
                          );
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller.latControllers[index],
                          decoration: _inputDecoration('Latitude'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: controller.lngControllers[index],
                          decoration: _inputDecoration('Longitude'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     controller.selectAudio(index);
                  //   },
                  //   child: const Text('Choose File'),
                  // ),
                  // Choose File Button with Icon
                  OutlinedButton.icon(
                    onPressed: () {
                      controller.selectAudio(index);
                    },
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Choose File'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),

                  // Display Selected File Name
                  Obx(() {
                    final audioPath = controller.audioPaths[index];
                    return audioPath.isNotEmpty
                        ? Text(
                          'Selected: ${audioPath.split('/').last}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        )
                        : const SizedBox.shrink();
                  }),

                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () => controller.removePointOfInterest(index),
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text('Remove'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPointButton() {
    return Obx(
      () => ElevatedButton(
        onPressed:
            controller.isRouteAndLanguageSelected.value
                ? () => controller.addPointOfInterest()
                : null,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ), // Button height
        child: const Text('Add Point of Interest'),
      ),
    );
  }

  Widget _buildFileAndSaveButtons() {
    return Column(
      children: [
        Obx(
          () => ElevatedButton(
            onPressed:
                controller.isRouteAndLanguageSelected.value
                    ? () => controller.saveChanges()
                    : null,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ), // Button height
            child: const Text('Save Changes'),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String labelText, {IconData? icon}) {
    return InputDecoration(
      labelText: labelText,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      suffixIcon: icon != null ? Icon(icon) : null,
    );
  }
}
