import 'dart:io' show Platform;

import 'package:flutter/material.dart';

import 'package:mindo_kids/core/utils/color_utils.dart';
import 'package:mindo_kids/core/utils/map_reader.dart';
import 'package:mindo_kids/features/common_models/media_ref.dart';

/// onboarding/{id}
class OnboardingSlide {
  final String id;
  final String title;
  final String subtitle;
  final MediaRef media;
  final String sideNote;
  final Color accent;
  final int order;
  final bool isActive;

  const OnboardingSlide({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.media = const MediaRef(),
    this.sideNote = '',
    this.accent = const Color(0xFFFFD6E4),
    this.order = 0,
    this.isActive = true,
  });

  factory OnboardingSlide.fromMap(String id, Map<String, dynamic> m) => OnboardingSlide(
    id: id,
    title: m.str('title'),
    subtitle: m.str('subtitle'),
    media: MediaRef.fromMap(m),
    sideNote: m.str('sideNote'),
    accent: hexToColor(m.str('accentColor'), fallback: const Color(0xFFFFD6E4)),
    order: m.integer('order'),
    isActive: m.boolean('isActive', true),
  );
}

/// worlds/{id} — a learning world (English World, Number World, …).
class WorldModel {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final MediaRef icon;
  final Color color;
  final String language;
  final String ttsLocale;
  final bool isRtl;
  final int order;
  final bool isActive;

  const WorldModel({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.description = '',
    this.icon = const MediaRef(),
    this.color = const Color(0xFF8E7CF8),
    this.language = 'en',
    this.ttsLocale = 'en-US',
    this.isRtl = false,
    this.order = 0,
    this.isActive = true,
  });

  factory WorldModel.fromMap(String id, Map<String, dynamic> m) => WorldModel(
    id: id,
    title: m.str('title'),
    subtitle: m.str('subtitle'),
    description: m.str('description'),
    icon: MediaRef.fromMap(m, imageKey: 'iconUrl'),
    color: hexToColor(m.str('color')),
    language: m.str('language', 'en'),
    ttsLocale: m.str('ttsLocale', 'en-US'),
    isRtl: m.boolean('isRtl'),
    order: m.integer('order'),
    isActive: m.boolean('isActive', true),
  );
}

/// lessons/{id}
class LessonModel {
  final String id;
  final String worldId;
  final String title;
  final String subtitle;
  final MediaRef thumbnail;
  final int order;
  final bool isActive;
  final bool isPremium;
  final bool isDailySpark;
  final int durationMinutes;
  final String ttsLocale;

  const LessonModel({
    required this.id,
    required this.worldId,
    required this.title,
    this.subtitle = '',
    this.thumbnail = const MediaRef(),
    this.order = 0,
    this.isActive = true,
    this.isPremium = false,
    this.isDailySpark = false,
    this.durationMinutes = 3,
    this.ttsLocale = '',
  });

  factory LessonModel.fromMap(String id, Map<String, dynamic> m) => LessonModel(
    id: id,
    worldId: m.str('worldId'),
    title: m.str('title'),
    subtitle: m.str('subtitle'),
    thumbnail: MediaRef.fromMap(m, imageKey: 'thumbnailUrl'),
    order: m.integer('order'),
    isActive: m.boolean('isActive', true),
    isPremium: m.boolean('isPremium'),
    isDailySpark: m.boolean('isDailySpark'),
    durationMinutes: m.integer('durationMinutes', 3),
    ttsLocale: m.str('ttsLocale'),
  );
}

/// badges/{id}. `rule` decides when a child earns it:
///   lessons_completed ≥ value | streak ≥ value | stars ≥ value |
///   world_lessons (lessons completed in rule.worldId) ≥ value
class BadgeModel {
  final String id;
  final String title;
  final String description;
  final MediaRef icon;
  final Color color;
  final String ruleType;
  final int ruleValue;
  final String ruleWorldId;
  final int order;
  final bool isActive;

  const BadgeModel({
    required this.id,
    required this.title,
    this.description = '',
    this.icon = const MediaRef(),
    this.color = const Color(0xFFFFE7B3),
    this.ruleType = 'lessons_completed',
    this.ruleValue = 1,
    this.ruleWorldId = '',
    this.order = 0,
    this.isActive = true,
  });

  factory BadgeModel.fromMap(String id, Map<String, dynamic> m) {
    final rule = m.obj('rule');
    return BadgeModel(
      id: id,
      title: m.str('title'),
      description: m.str('description'),
      icon: MediaRef.fromMap(m, imageKey: 'iconUrl'),
      color: hexToColor(m.str('color'), fallback: const Color(0xFFFFE7B3)),
      ruleType: rule.str('type', 'lessons_completed'),
      ruleValue: rule.integer('value', 1),
      ruleWorldId: rule.str('worldId'),
      order: m.integer('order'),
      isActive: m.boolean('isActive', true),
    );
  }
}

/// avatars/{id}
class AvatarModel {
  final String id;
  final MediaRef media;
  final Color background;
  final int order;
  final bool isActive;

  const AvatarModel({
    required this.id,
    this.media = const MediaRef(),
    this.background = const Color(0xFFFFE3EC),
    this.order = 0,
    this.isActive = true,
  });

  factory AvatarModel.fromMap(String id, Map<String, dynamic> m) => AvatarModel(
    id: id,
    media: MediaRef.fromMap(m),
    background: hexToColor(m.str('bgColor'), fallback: const Color(0xFFFFE3EC)),
    order: m.integer('order'),
    isActive: m.boolean('isActive', true),
  );
}

/// plans/{id} — subscription plans. Real prices come from the store; the
/// `priceLabel` is only a fallback shown while the store is loading.
class PlanModel {
  final String id;
  final String title;
  final String subtitle;
  final String productIdAndroid;
  final String productIdIos;
  final String priceLabel;
  final String periodLabel;
  final List<String> features;
  final String badgeText;
  final bool isHighlighted;
  final int order;
  final bool isActive;

  const PlanModel({
    required this.id,
    required this.title,
    this.subtitle = '',
    this.productIdAndroid = '',
    this.productIdIos = '',
    this.priceLabel = '',
    this.periodLabel = '',
    this.features = const [],
    this.badgeText = '',
    this.isHighlighted = false,
    this.order = 0,
    this.isActive = true,
  });

  String get productId => Platform.isIOS ? productIdIos : productIdAndroid;

  factory PlanModel.fromMap(String id, Map<String, dynamic> m) => PlanModel(
    id: id,
    title: m.str('title'),
    subtitle: m.str('subtitle'),
    productIdAndroid: m.str('productIdAndroid'),
    productIdIos: m.str('productIdIos'),
    priceLabel: m.str('priceLabel'),
    periodLabel: m.str('periodLabel'),
    features: m.strings('features'),
    badgeText: m.str('badgeText'),
    isHighlighted: m.boolean('isHighlighted'),
    order: m.integer('order'),
    isActive: m.boolean('isActive', true),
  );
}

/// pages/{id} — privacy policy, terms, help, about …
class ContentPage {
  final String id;
  final String title;
  final String body;
  final int order;
  final bool showInParentZone;

  const ContentPage({
    required this.id,
    required this.title,
    this.body = '',
    this.order = 0,
    this.showInParentZone = true,
  });

  factory ContentPage.fromMap(String id, Map<String, dynamic> m) => ContentPage(
    id: id,
    title: m.str('title'),
    body: m.str('body'),
    order: m.integer('order'),
    showInParentZone: m.boolean('showInParentZone', true),
  );
}

/// announcements/{id} — shown behind the bell icon on the dashboard.
class Announcement {
  final String id;
  final String title;
  final String body;
  final MediaRef media;
  final DateTime? createdAt;
  final bool isActive;

  const Announcement({
    required this.id,
    required this.title,
    this.body = '',
    this.media = const MediaRef(),
    this.createdAt,
    this.isActive = true,
  });

  factory Announcement.fromMap(String id, Map<String, dynamic> m) => Announcement(
    id: id,
    title: m.str('title'),
    body: m.str('body'),
    media: MediaRef.fromMap(m),
    createdAt: m.date('createdAt'),
    isActive: m.boolean('isActive', true),
  );
}
