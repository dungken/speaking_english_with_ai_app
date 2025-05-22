import 'package:mobile_clean_architecture/features/image_description/domain/entities/image_entity.dart';

/// ImageModel represents image data returned from the API
class ImageModel extends ImageEntity {
  /// Creates an ImageModel instance
  const ImageModel({
    required super.id,
    required super.name,
    required super.detailDescription,
  });

  /// Creates an ImageModel instance from JSON data
  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'] as String,
      name: json['name'] as String,
      detailDescription: json['detail_description'] as String,
    );
  }

  /// Converts the ImageModel instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'detail_description': detailDescription,
    };
  }
}
