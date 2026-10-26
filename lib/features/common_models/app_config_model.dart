import 'package:mindo_kids/core/utils/map_reader.dart';
import 'package:mindo_kids/features/common_models/media_ref.dart';

/// config/app — global settings managed from the admin panel.
class AppConfigModel {
  final String appName;
  final String tagline;
  final String supportEmail;
  final bool maintenanceMode;
  final String maintenanceMessage;
  final List<String> ageBands;
  final int defaultDailyLimitMinutes;
  final String correctSoundUrl;
  final String wrongSoundUrl;
  final String completeSoundUrl;
  final List<String> praiseMessages;
  final List<String> retryMessages;

  const AppConfigModel({
    this.appName = 'Mindo Kids',
    this.tagline = 'Little Minds. Infinite Worlds.',
    this.supportEmail = '',
    this.maintenanceMode = false,
    this.maintenanceMessage = '',
    this.ageBands = const ['1.5–3', '3–4', '4–5', '5–6'],
    this.defaultDailyLimitMinutes = 0,
    this.correctSoundUrl = '',
    this.wrongSoundUrl = '',
    this.completeSoundUrl = '',
    this.praiseMessages = const ['Great job!', 'Super!', 'You did it!', 'Awesome!'],
    this.retryMessages = const ['Almost! Try again.', 'Let\'s try once more.'],
  });

  factory AppConfigModel.fromMap(Map<String, dynamic> m) {
    const d = AppConfigModel();
    final bands = m.strings('ageBands');
    final praise = m.strings('praiseMessages');
    final retry = m.strings('retryMessages');
    return AppConfigModel(
      appName: m.str('appName', d.appName),
      tagline: m.str('tagline', d.tagline),
      supportEmail: m.str('supportEmail'),
      maintenanceMode: m.boolean('maintenanceMode'),
      maintenanceMessage: m.str('maintenanceMessage'),
      ageBands: bands.isEmpty ? d.ageBands : bands,
      defaultDailyLimitMinutes: m.integer('defaultDailyLimitMinutes'),
      correctSoundUrl: m.str('correctSoundUrl'),
      wrongSoundUrl: m.str('wrongSoundUrl'),
      completeSoundUrl: m.str('completeSoundUrl'),
      praiseMessages: praise.isEmpty ? d.praiseMessages : praise,
      retryMessages: retry.isEmpty ? d.retryMessages : retry,
    );
  }
}

/// config/paywall — copy shown on the subscription screen.
class PaywallConfig {
  final String title;
  final String subtitle;
  final List<String> benefits;
  final String ctaText;
  final String restoreText;
  final String footerNote;
  final MediaRef hero;

  const PaywallConfig({
    this.title = 'Unlock every world',
    this.subtitle = 'One subscription. All lessons, stories and games.',
    this.benefits = const [],
    this.ctaText = 'Subscribe',
    this.restoreText = 'Restore purchases',
    this.footerNote = '',
    this.hero = const MediaRef(emoji: '🚀'),
  });

  factory PaywallConfig.fromMap(Map<String, dynamic> m) {
    const d = PaywallConfig();
    final hero = MediaRef.fromMap(m);
    return PaywallConfig(
      title: m.str('title', d.title),
      subtitle: m.str('subtitle', d.subtitle),
      benefits: m.strings('benefits'),
      ctaText: m.str('ctaText', d.ctaText),
      restoreText: m.str('restoreText', d.restoreText),
      footerNote: m.str('footerNote'),
      hero: hero.isEmpty ? d.hero : hero,
    );
  }
}
