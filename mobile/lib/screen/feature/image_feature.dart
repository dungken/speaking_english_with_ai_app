import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../controller/image_controller.dart';
import '../../helper/global.dart';
import '../../widgets/custom_btn.dart';
import '../../widgets/custom_loading.dart';

/// 📌 **ImageFeature Screen**
///
/// This screen allows users to generate AI-powered images by inputting text.
/// Users can also download, share, and view generated images.
class ImageFeature extends StatefulWidget {
  const ImageFeature({super.key});

  @override
  State<ImageFeature> createState() => _ImageFeatureState();
}

class _ImageFeatureState extends State<ImageFeature> {
  /// 🔹 **Image Controller Instance**
  ///
  /// Manages AI image generation, image list, download, and sharing functionalities.
  final _c = ImageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 📌 **App Bar with Share Button**
      appBar: AppBar(
        title: const Text('AI Image Creator'),

        // 🔄 **Share Button (Visible Only When Image is Ready)**
        actions: [
          Obx(
            () => _c.status.value == Status.complete
                ? IconButton(
                    padding: const EdgeInsets.only(right: 6),
                    onPressed: _c.shareImage, // Calls share image function
                    icon: const Icon(Icons.share),
                  )
                : const SizedBox(),
          ),
        ],
      ),

      // 📌 **Download Button (Visible When Image is Ready)**
      floatingActionButton: Obx(() => _c.status.value == Status.complete
          ? Padding(
              padding: const EdgeInsets.only(right: 6, bottom: 6),
              child: FloatingActionButton(
                onPressed: _c.downloadImage, // Calls download function
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                child: const Icon(Icons.save_alt_rounded, size: 26),
              ),
            )
          : const SizedBox()),

      // 📌 **Body Section**
      body: ListView(
        physics: const BouncingScrollPhysics(), // Smooth scrolling effect
        padding: EdgeInsets.only(
          top: mq.height * .02, // Top padding
          bottom: mq.height * .1, // Bottom padding
          left: mq.width * .04,
          right: mq.width * .04,
        ),
        children: [
          // 📝 **Text Input Field for Image Prompt**
          TextFormField(
            controller: _c.textC, // Controller for user input
            textAlign: TextAlign.center,
            minLines: 2,
            maxLines: null,
            onTapOutside: (e) => FocusScope.of(context)
                .unfocus(), // Hide keyboard when tapping outside
            decoration: const InputDecoration(
              hintText:
                  'Imagine something wonderful & innovative\nType here & I will create for you 😃',
              hintStyle: TextStyle(fontSize: 13.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),

          // 🖼 **Generated AI Image Display**
          Container(
            height: mq.height * .5,
            margin: EdgeInsets.symmetric(vertical: mq.height * .015),
            alignment: Alignment.center,
            child:
                Obx(() => _aiImage()), // Displays AI-generated image or loader
          ),

          // 🔄 **Horizontal Scrollable Image List (Previously Generated Images)**
          Obx(
            () => _c.imageList.isEmpty
                ? const SizedBox()
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.only(bottom: mq.height * .03),
                    physics: const BouncingScrollPhysics(),
                    child: Wrap(
                      spacing: 10,
                      children: _c.imageList
                          .map(
                            (e) => InkWell(
                              onTap: () {
                                _c.url.value = e; // Updates the selected image
                              },
                              child: ClipRRect(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(8)),
                                child: CachedNetworkImage(
                                  imageUrl: e,
                                  height: 100,
                                  errorWidget: (context, url, error) =>
                                      const SizedBox(), // Handles image load failure
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
          ),

          // 🎨 **Create Image Button**
          CustomBtn(
            onTap: _c.searchAiImage, // Calls AI image generation function
            text: 'Create',
          ),
        ],
      ),
    );
  }

  /// 🔹 **AI Image Widget**
  ///
  /// This widget displays:
  /// - A Lottie animation before an image is generated
  /// - A loading indicator while the image is being generated
  /// - The generated AI image when available
  Widget _aiImage() => ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: switch (_c.status.value) {
          Status.none =>
            Lottie.asset('assets/lottie/ai_play.json', height: mq.height * .3),
          Status.complete => CachedNetworkImage(
              imageUrl: _c.url.value,
              placeholder: (context, url) => const CustomLoading(),
              errorWidget: (context, url, error) => const SizedBox(),
            ),
          Status.loading => const CustomLoading(), // Shows loading indicator
        },
      );
}
