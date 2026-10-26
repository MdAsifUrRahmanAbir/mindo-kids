import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:mindo_kids/core/widgets/common_widgets.dart';
import 'package:mindo_kids/routes/route_names.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: MessageView(
          emoji: '🧭',
          title: 'Page not found',
          subtitle: 'Let\'s head back home.',
          actionLabel: 'Go home',
          onAction: () => context.go(RouteNames.home),
        ),
      ),
    );
  }
}
