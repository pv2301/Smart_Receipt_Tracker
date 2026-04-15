import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme.dart';
import '../providers/receipt_providers.dart';

/// Banner de warm-up que aparece até o usuário ter 5 notas escaneadas.
/// Consome o endpoint GET /suggestions/count via [suggestionCountProvider].
/// 
/// Thresholds:
///   - 0..2 → Modo básico (precisa de 3 notas para sugestões básicas)
///   - 3..4 → Sugestões básicas ativas, faltam N para lista completa
///   - 5+   → Banner some, lista completa disponível
class SmartListWarmupBanner extends ConsumerWidget {
  const SmartListWarmupBanner({super.key});

  static const int _basicThreshold = 3;
  static const int _fullThreshold = 5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(suggestionCountProvider);

    return countAsync.when(
      // While loading, show a slim shimmer placeholder
      loading: () => const _BannerShimmer(),
      // On error, stay silent — don't disrupt the UX
      error: (_, __) => const SizedBox.shrink(),
      data: (count) {
        // Banner hides once the user has enough receipts
        if (count >= _fullThreshold) return const SizedBox.shrink();

        final isBasic = count >= _basicThreshold;
        final progress = count / _fullThreshold;
        final remaining = _fullThreshold - count;

        return _WarmupCard(
          receiptCount: count,
          progress: progress,
          remaining: remaining,
          isBasicMode: isBasic,
        );
      },
    );
  }
}

// ── Warmup Card ───────────────────────────────────────────────────────────────

class _WarmupCard extends StatelessWidget {
  final int receiptCount;
  final double progress;
  final int remaining;
  final bool isBasicMode;

  const _WarmupCard({
    required this.receiptCount,
    required this.progress,
    required this.remaining,
    required this.isBasicMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isBasicMode
              ? [
                  AppTheme.primaryAction.withOpacity(0.15),
                  AppTheme.primaryAction.withOpacity(0.05),
                ]
              : [
                  Colors.white.withOpacity(0.07),
                  Colors.white.withOpacity(0.03),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        border: Border.all(
          color: isBasicMode
              ? AppTheme.primaryAction.withOpacity(0.4)
              : Colors.white12,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + title row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isBasicMode
                      ? AppTheme.primaryAction.withOpacity(0.2)
                      : Colors.white10,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isBasicMode
                      ? Icons.auto_awesome_rounded
                      : Icons.receipt_long_rounded,
                  size: 20,
                  color: isBasicMode
                      ? AppTheme.primaryAction
                      : AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isBasicMode
                          ? 'Sugestões ativas! 🎉'
                          : 'Aprendendo seus hábitos…',
                      style: TextStyle(
                        fontSize: AppTheme.fontSM + 1,
                        fontWeight: FontWeight.bold,
                        color: isBasicMode
                            ? AppTheme.primaryAction
                            : Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isBasicMode
                          ? 'Escaneie mais $remaining nota${remaining == 1 ? '' : 's'} para desbloquear a lista completa'
                          : 'Escaneie $remaining nota${remaining == 1 ? '' : 's'} para começar a ver sugestões',
                      style: const TextStyle(
                        fontSize: AppTheme.fontSM,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(
                isBasicMode ? AppTheme.primaryAction : Colors.white30,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Step dots
          Row(
            children: List.generate(5, (i) {
              final filled = i < receiptCount;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: filled ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: filled
                        ? AppTheme.primaryAction
                        : Colors.white12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            }),
            mainAxisAlignment: MainAxisAlignment.start,
          ),
        ],
      ),
    );
  }
}

// ── Shimmer placeholder ───────────────────────────────────────────────────────

class _BannerShimmer extends StatefulWidget {
  const _BannerShimmer();

  @override
  State<_BannerShimmer> createState() => _BannerShimmerState();
}

class _BannerShimmerState extends State<_BannerShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.03, end: 0.10).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(_anim.value),
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
        ),
      ),
    );
  }
}
