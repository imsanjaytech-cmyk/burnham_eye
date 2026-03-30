class Inspection {
  final String id;
  final String title;
  final String location;
  final String description;
  final DateTime date;
  final String status;

  Inspection({
    required this.id,
    required this.title,
    required this.location,
    required this.description,
    required this.date,
    required this.status,
  });

  /// Factory constructor to create Inspection from JSON
  factory Inspection.fromJson(Map<String, dynamic> json) {
    return Inspection(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      description: json['description'] ?? '',
      date: json['date'] is DateTime ? json['date'] : DateTime.now(),
      status: json['status'] ?? 'Pending',
    );
  }

  /// Convert Inspection to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'description': description,
      'date': date,
      'status': status,
    };
  }

  /// Create a copy of Inspection with optional field updates
  Inspection copyWith({
    String? id,
    String? title,
    String? location,
    String? description,
    DateTime? date,
    String? status,
  }) {
    return Inspection(
      id: id ?? this.id,
      title: title ?? this.title,
      location: location ?? this.location,
      description: description ?? this.description,
      date: date ?? this.date,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'Inspection(id: $id, title: $title, location: $location, status: $status)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Inspection &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          location == other.location &&
          description == other.description &&
          date == other.date &&
          status == other.status;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      location.hashCode ^
      description.hashCode ^
      date.hashCode ^
      status.hashCode;
}