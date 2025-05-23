import 'package:equatable/equatable.dart';

/// ImageFeedbackEntity represents feedback on a user's image description
class ImageFeedbackEntity extends Equatable {
  /// Improved version of the user's description
  final String betterVersion;

  /// Explanation of what was changed and why
  final String explanation;

  /// Creates a ImageFeedbackEntity instance
  const ImageFeedbackEntity({
    required this.betterVersion,
    required this.explanation,
  });

  @override
  List<Object?> get props => [betterVersion, explanation];
}
