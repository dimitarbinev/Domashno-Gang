import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme.dart';
import '../../shared/providers/providers.dart';
import '../../shared/widgets/nature_scaffold.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = (ref.watch(themeModeProvider).value ?? ThemeMode.dark) == ThemeMode.dark;
    final notificationsOn = ref.watch(notificationsEnabledProvider).value ?? true;
    
    return NatureScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Настройки'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ─── Appearance ───
          _SectionHeader(title: 'Външен вид'),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            iconColor: isDark ? const Color(0xFF9575CD) : const Color(0xFFFFA726),
            title: 'Тъмен режим',
            subtitle: isDark ? 'Превключи към светла тема' : 'Превключи към тъмна тема',
            trailing: Switch.adaptive(
              value: isDark,
              onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
              activeThumbColor: AppTheme.accentGreen,
              activeTrackColor: AppTheme.primaryGreen.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),

          // ─── Notifications ───
          _SectionHeader(title: 'Уведомления'),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: notificationsOn ? Icons.notifications_active_rounded : Icons.notifications_off_rounded,
            iconColor: notificationsOn ? AppTheme.accentGreen : Colors.white.withValues(alpha: 0.3),
            title: 'Push уведомления',
            subtitle: notificationsOn ? 'Ще получавате уведомления' : 'Уведомленията са изключени',
            trailing: Switch.adaptive(
              value: notificationsOn,
              onChanged: (_) => ref.read(notificationsEnabledProvider.notifier).toggle(),
              activeThumbColor: AppTheme.primaryGreen,
              activeTrackColor: AppTheme.primaryGreen.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),

          // ─── About ───
          _SectionHeader(title: 'Информация'),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.privacy_tip_rounded,
            iconColor: const Color(0xFF42A5F5),
            title: 'Политика за поверителност',
            subtitle: 'Как боравим с вашите данни',
            trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white54),
            onTap: () => _showPolicyDialog(context, _PolicyType.privacy),
          ),
          const SizedBox(height: 12),
          _SettingsTile(
            icon: Icons.gavel_rounded,
            iconColor: const Color(0xFF26A69A),
            title: 'Условията за ползване',
            subtitle: 'Правила и споразумения',
            trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white54),
            onTap: () => _showPolicyDialog(context, _PolicyType.terms),
          ),
          const SizedBox(height: 48),

          // ─── App Info ───
          Center(
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGreen.withValues(alpha: 0.3),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.eco, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 16),
                const Text(
                  'AgriSell',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Версия 1.0.0',
                  style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.5)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showPolicyDialog(BuildContext context, _PolicyType type) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          type == _PolicyType.privacy ? 'Политика за поверителност' : 'Условия за ползване',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Text(
            type == _PolicyType.privacy ? _privacyPolicyText : _termsOfServiceText,
            style: TextStyle(fontSize: 14, height: 1.6, color: Colors.white.withValues(alpha: 0.8)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: const Text('Затвори', style: TextStyle(color: AppTheme.accentGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

enum _PolicyType { privacy, terms }

// ─── Privacy Policy Content ───
const _privacyPolicyText = '''
Последно актуализирано: март 2026

В AgriSell отнасяме сериозно към вашата поверителност. Тази политика обяснява как събираме, използваме и защитаваме вашата лична информация.

1. Информация, която събираме
Събираме информация, която предоставяте директно, като име, имейл, телефонен номер и данни за продукти.

2. Как използваме вашата информация
Вашата информация се използва за:
• Работа и подобряване на платформата
• Свързване на купувачи и продавачи
• Изпращане на уведомления

3. Защита на данните
Използваме индустриални стандарти за криптиране и защита.
''';

// ─── Terms of Service Content ───
const _termsOfServiceText = '''
Последно актуализирано: март 2026

Добре дошли в AgriSell. Използвайки нашата платформа, вие приемате тези условия.

1. Приемане на условията
При достъп или използване на AgriSell, вие се съгласявате с тези условия.

2. Допустимост
Трябва да сте навършили 18 години.

3. Отговорности
Продавачите отговарят за точността на обявите. Купувачите спазват резервациите.
''';

// ─── Helper Widgets ───
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.white.withValues(alpha: 0.4),
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: glassDecoration().copyWith(
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: iconColor.withValues(alpha: 0.2)),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
