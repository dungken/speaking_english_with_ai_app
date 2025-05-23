import 'package:equatable/equatable.dart';

/// ImageEntity represents the core data structure for image data
class ImageEntity extends Equatable {
  /// Unique identifier for the image
  final String id;

  /// URL or path to access the image
  final String name;

  /// AI-generated detailed description of the image
  final String detailDescription;

  /// Creates an ImageEntity instance
  const ImageEntity({
    required this.id,
    required this.name,
    required this.detailDescription,
  });

  @override
  List<Object?> get props => [id, name, detailDescription];
}
