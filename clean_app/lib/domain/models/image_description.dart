class ImageDescription {
  final String id;
  final String imageUrl;
  final String? userDescription;
  final double? aiScore;
  final DateTime createdAt;
  final bool isLiked;

  ImageDescription({
    required this.id,
    required this.imageUrl,
    this.userDescription,
    this.aiScore,
    required this.createdAt,
    this.isLiked = false,
  });

  factory ImageDescription.fromJson(Map<String, dynamic> json) {
    return ImageDescription(
      id: json['id'],
      imageUrl: json['imageUrl'],
      userDescription: json['userDescription'],
      aiScore: json['aiScore'],
      createdAt: DateTime.parse(json['createdAt']),
      isLiked: json['isLiked'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'userDescription': userDescription,
      'aiScore': aiScore,
      'createdAt': createdAt.toIso8601String(),
      'isLiked': isLiked,
    };
  }

  ImageDescription copyWith({
    String? id,
    String? imageUrl,
    String? userDescription,
    double? aiScore,
    DateTime? createdAt,
    bool? isLiked,
  }) {
    return ImageDescription(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      userDescription: userDescription ?? this.userDescription,
      aiScore: aiScore ?? this.aiScore,
      createdAt: createdAt ?? this.createdAt,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}
