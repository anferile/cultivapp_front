import 'package:flutter/material.dart';

enum CropStatus { active, growing, harvested, cancelled }

extension CropStatusExtension on CropStatus {
  String get label {
    switch (this) {
      case CropStatus.active:
        return 'Activo';
      case CropStatus.growing:
        return 'En crecimiento';
      case CropStatus.harvested:
        return 'Cosechado';
      case CropStatus.cancelled:
        return 'Cancelado';
    }
  }

  Color get color {
    switch (this) {
      case CropStatus.active:
        return const Color(0xFF4CAF50);
      case CropStatus.growing:
        return const Color(0xFF8BC34A);
      case CropStatus.harvested:
        return const Color(0xFFFDD835);
      case CropStatus.cancelled:
        return const Color(0xFF9E9E9E);
    }
  }

  IconData get icon {
    switch (this) {
      case CropStatus.active:
        return Icons.grass;
      case CropStatus.growing:
        return Icons.trending_up;
      case CropStatus.harvested:
        return Icons.agriculture;
      case CropStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }
}

class Crop {
  final String id;
  final String name;
  final String type;
  final String location;
  final DateTime sowingDate;
  final CropStatus status;
  final DateTime createdAt;
  final bool isArchived;
  final String? archiveReason;
  final DateTime? archivedAt;

  Crop({
    required this.id,
    required this.name,
    required this.type,
    required this.location,
    required this.sowingDate,
    required this.status,
    required this.createdAt,
    this.isArchived = false,
    this.archiveReason,
    this.archivedAt,
  });

  Crop copyWith({
    String? id,
    String? name,
    String? type,
    String? location,
    DateTime? sowingDate,
    CropStatus? status,
    DateTime? createdAt,
    bool? isArchived,
    String? archiveReason,
    DateTime? archivedAt,
  }) {
    return Crop(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      location: location ?? this.location,
      sowingDate: sowingDate ?? this.sowingDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      isArchived: isArchived ?? this.isArchived,
      archiveReason: archiveReason ?? this.archiveReason,
      archivedAt: archivedAt ?? this.archivedAt,
    );
  }
}

enum ActivityType { irrigation, fertilization, fumigation, harvest, other }

extension ActivityTypeExtension on ActivityType {
  String get label {
    switch (this) {
      case ActivityType.irrigation:
        return 'Riego';
      case ActivityType.fertilization:
        return 'Fertilización';
      case ActivityType.fumigation:
        return 'Fumigación';
      case ActivityType.harvest:
        return 'Cosecha';
      case ActivityType.other:
        return 'Otro';
    }
  }

  Color get color {
    switch (this) {
      case ActivityType.irrigation:
        return const Color(0xFF1976D2);
      case ActivityType.fertilization:
        return const Color(0xFF388E3C);
      case ActivityType.fumigation:
        return const Color(0xFFF57C00);
      case ActivityType.harvest:
        return const Color(0xFFFDD835);
      case ActivityType.other:
        return const Color(0xFF757575);
    }
  }

  IconData get icon {
    switch (this) {
      case ActivityType.irrigation:
        return Icons.water_drop;
      case ActivityType.fertilization:
        return Icons.eco;
      case ActivityType.fumigation:
        return Icons.air;
      case ActivityType.harvest:
        return Icons.agriculture;
      case ActivityType.other:
        return Icons.more_horiz;
    }
  }
}

class Activity {
  final String id;
  final String cropId;
  final ActivityType type;
  final DateTime date;
  final String description;
  final double cost;
  final DateTime createdAt;

  Activity({
    required this.id,
    required this.cropId,
    required this.type,
    required this.date,
    required this.description,
    required this.cost,
    required this.createdAt,
  });
}

class Expense {
  final String id;
  final String cropId;
  final String description;
  final double amount;
  final String category;
  final DateTime date;
  final DateTime createdAt;

  Expense({
    required this.id,
    required this.cropId,
    required this.description,
    required this.amount,
    required this.category,
    required this.date,
    required this.createdAt,
  });
}

class AppUser {
  final String id;
  final String fullName;
  final String contact;
  final String password;

  AppUser({
    required this.id,
    required this.fullName,
    required this.contact,
    required this.password,
  });
}
