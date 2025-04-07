import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../application/image_description/image_description_bloc.dart';
import '../../../domain/models/image_description.dart';
import '../../../domain/repositories/image_description_repository.dart';

class ImageDescriptionScreen extends StatefulWidget {
  const ImageDescriptionScreen({super.key});

  @override
  State<ImageDescriptionScreen> createState() => _ImageDescriptionScreenState();
}

class _ImageDescriptionScreenState extends State<ImageDescriptionScreen> {
  final _descriptionController = TextEditingController();
  File? _currentImage;
  int _currentImageIndex = 0;
  bool _isLiked = false;
  bool _showFeedback = false;
  double _aiScore = 0.0;
  String _mistakes = '';
  String _suggestions = '';

  // Mock data for testing - replace with actual data from backend
  final List<ImageDescription> _mockImages = [
    ImageDescription(
      id: '1',
      imageUrl: 'https://example.com/image1.jpg',
      createdAt: DateTime.now(),
    ),
    ImageDescription(
      id: '2',
      imageUrl: 'https://example.com/image2.jpg',
      createdAt: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentImage();
  }

  void _loadCurrentImage() {
    // TODO: Replace with actual image loading from backend
    if (_mockImages.isNotEmpty) {
      // Simulate loading image from URL
      // In real implementation, you would:
      // 1. Download the image
      // 2. Save it locally
      // 3. Set _currentImage to the local file
    }
  }

  void _clearInput() {
    _descriptionController.clear();
  }

  void _submitDescription() {
    if (_descriptionController.text.trim().isEmpty) {
      Get.snackbar(
        'Error',
        'Please enter a description',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    context.read<ImageDescriptionBloc>().add(
          GetAiScore(_descriptionController.text),
        );

    context.read<ImageDescriptionBloc>().add(
          GetAiFeedback(_descriptionController.text),
        );
  }

  void _onLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
    // TODO: Update like status in backend
  }

  void _onDislike() {
    setState(() {
      _isLiked = !_isLiked;
    });
    // TODO: Update dislike status in backend
  }

  void _onNext() {
    if (_currentImageIndex < _mockImages.length - 1) {
      setState(() {
        _currentImageIndex++;
        _loadCurrentImage();
      });
    } else {
      Get.snackbar(
        'Info',
        'You have reached the last image',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _onPrevious() {
    if (_currentImageIndex > 0) {
      setState(() {
        _currentImageIndex--;
        _loadCurrentImage();
      });
    } else {
      Get.snackbar(
        'Info',
        'You are at the first image',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _toggleFeedback() {
    setState(() {
      _showFeedback = !_showFeedback;
      if (_showFeedback) {
        _aiScore = 8.5;
        _mistakes = 'Minor grammar issues in the third sentence.';
        _suggestions =
            'Try using more descriptive adjectives and vary your sentence structure.';
      }
    });
  }

  Future<void> _generateImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _currentImage = File(image.path);
      });
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ImageDescriptionBloc(
        repository: context.read<ImageDescriptionRepository>(),
      ),
      child: BlocListener<ImageDescriptionBloc, ImageDescriptionState>(
        listener: (context, state) {
          if (state is AiScoreLoaded) {
            setState(() {
              _aiScore = state.score;
            });
          } else if (state is AiFeedbackLoaded) {
            setState(() {
              _suggestions = state.feedback;
            });
          } else if (state is ImageDescriptionError) {
            Get.snackbar(
              'Error',
              state.message,
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Describe Image'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
            ),
            actions: [
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.tealAccent
                      : const Color(0xFF3B82F6),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                position: PopupMenuPosition.under,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                        Icon(
                          Icons.clear_all,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.tealAccent
                              : const Color(0xFF3B82F6),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text('Clear Input'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'generate',
                    child: Row(
                      children: [
                        Icon(
                          Icons.image,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.tealAccent
                              : const Color(0xFF3B82F6),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text('Select Image'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'feedback',
                    child: Row(
                      children: [
                        Icon(
                          Icons.feedback,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.tealAccent
                              : const Color(0xFF3B82F6),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(_showFeedback ? 'Hide Feedback' : 'Show Feedback'),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 'clear':
                      _clearInput();
                      break;
                    case 'generate':
                      _generateImage();
                      break;
                    case 'feedback':
                      _toggleFeedback();
                      break;
                  }
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.blue.shade900.withOpacity(0.3)
                      : Colors.blue.shade50,
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.purple.shade900.withOpacity(0.3)
                      : Colors.purple.shade50,
                ],
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Image display area with enhanced styling
                        Container(
                          height: MediaQuery.of(context).size.height * 0.5,
                          margin: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey.shade900.withOpacity(0.8)
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 1,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _currentImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(16),
                                  child: Image.file(
                                    _currentImage!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_outlined,
                                        size: 64,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'No image selected',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),

                        // Action icons row with enhanced styling
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey.shade900.withOpacity(0.8)
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                spreadRadius: 1,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildActionButton(
                                icon: Icons.thumb_up,
                                color: _isLiked ? Colors.green : Colors.grey,
                                onPressed: _onLike,
                              ),
                              _buildActionButton(
                                icon: Icons.thumb_down,
                                color: !_isLiked ? Colors.red : Colors.grey,
                                onPressed: _onDislike,
                              ),
                              _buildActionButton(
                                icon: Icons.arrow_back,
                                onPressed: _onPrevious,
                              ),
                              _buildActionButton(
                                icon: Icons.arrow_forward,
                                onPressed: _onNext,
                              ),
                            ],
                          ),
                        ),

                        // Feedback section with enhanced styling
                        if (_showFeedback)
                          Container(
                            margin: const EdgeInsets.all(16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey.shade900.withOpacity(0.8)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  spreadRadius: 1,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.feedback_outlined,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.tealAccent
                                              : const Color(0xFF3B82F6),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'AI Feedback',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.tealAccent.withOpacity(0.2)
                                            : const Color(0xFF3B82F6)
                                                .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.star,
                                            size: 16,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.tealAccent
                                                    : const Color(0xFF3B82F6),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Score: $_aiScore/10',
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.tealAccent
                                                  : const Color(0xFF3B82F6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                if (_mistakes.isNotEmpty) ...[
                                  _buildFeedbackSection(
                                    title: 'Mistakes',
                                    content: _mistakes,
                                    icon: Icons.error_outline,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.redAccent
                                        : const Color(0xFFEF4444),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                if (_suggestions.isNotEmpty)
                                  _buildFeedbackSection(
                                    title: 'Suggestions',
                                    content: _suggestions,
                                    icon: Icons.lightbulb_outline,
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.tealAccent
                                        : const Color(0xFF3B82F6),
                                  ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Input section with enhanced styling
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade900.withOpacity(0.8)
                        : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 1,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          hintText: 'Describe the image...',
                          hintStyle: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey.shade700
                                  : Colors.grey.shade300,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.tealAccent
                                  : const Color(0xFF3B82F6),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey.shade800.withOpacity(0.5)
                                  : Colors.grey.shade50,
                          prefixIcon: IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: _clearInput,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                          ),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.image),
                                onPressed: _generateImage,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.tealAccent
                                    : const Color(0xFF3B82F6),
                              ),
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.tealAccent
                                      : const Color(0xFF3B82F6),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.send),
                                  onPressed: _submitDescription,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        maxLines: 3,
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    Color? color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey.shade800.withOpacity(0.5)
            : Colors.grey.shade100,
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon),
        color: color ??
            (Theme.of(context).brightness == Brightness.dark
                ? Colors.white70
                : Colors.grey.shade700),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildFeedbackSection({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white70
                : Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
