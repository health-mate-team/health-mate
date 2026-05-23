class CodeDto {
  const CodeDto({
    required this.id,
    required this.groupId,
    required this.displayOrder,
    required this.labels,
    this.emoji,
    this.numericValue,
    required this.metadata,
  });

  factory CodeDto.fromJson(Map<String, dynamic> json) => CodeDto(
        id: json['id'] as String,
        groupId: json['groupId'] as String,
        displayOrder: json['displayOrder'] as int,
        labels: Map<String, String>.from(json['labels'] as Map),
        emoji: json['emoji'] as String?,
        numericValue: json['numericValue'] as int?,
        metadata: json['metadata'] != null
            ? Map<String, String>.from(json['metadata'] as Map)
            : const {},
      );

  final String id;
  final String groupId;
  final int displayOrder;
  final Map<String, String> labels;
  final String? emoji;
  final int? numericValue;
  final Map<String, String> metadata;

  String get labelKo => labels['ko'] ?? '';
}
