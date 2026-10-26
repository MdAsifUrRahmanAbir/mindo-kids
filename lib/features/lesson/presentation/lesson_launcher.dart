import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mindo_kids/core/widgets/parent_gate.dart';
import 'package:mindo_kids/features/common_models/content_models.dart';
import 'package:mindo_kids/features/subscription/data/repositories/subscription_repository.dart';
import 'package:mindo_kids/routes/route_names.dart';

/// Opens a lesson, or — for a premium lesson without a subscription — asks
/// a grown-up to pass the parent gate and shows the subscription screen.
Future<void> openLesson(BuildContext context, WidgetRef ref, LessonModel lesson) async {
  final locked = lesson.isPremium && !ref.read(isPremiumProvider);
  if (!locked) {
    context.push(RouteNames.lesson(lesson.id));
    return;
  }
  await openPaywall(context);
}

Future<void> openPaywall(BuildContext context) async {
  if (await showParentGate(context) && context.mounted) {
    context.push(RouteNames.paywall);
  }
}
