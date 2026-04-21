import 'package:flutter/material.dart';

class StarSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const StarSelector({super.key, required this.value, required this.onChanged});

  (String, Color) _rarity(BuildContext c) => value >= 12
      ? ('Lendário', Colors.purple)
      : value >= 8
      ? ('Épico', const Color(0xFFEB02F7))
      : value >= 5
      ? ('Raro', Colors.blue)
      : value >= 2
      ? ('Incomum', Colors.green)
      : ('Comum', Theme.of(c).colorScheme.onSurfaceVariant);

  @override
  Widget build(BuildContext context) {
    final v = value.clamp(0, 14);
    final pink = v > 7 ? v - 7 : 0;
    final yellow = v > 7 ? 7 - pink : v;
    final (label, color) = _rarity(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Classificação',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                /// ⭐ estrelas
                Row(
                  children: List.generate(7, (i) {
                    final filledPink = i < pink;
                    final filledYellow = i < pink + yellow;

                    return InkWell(
                      onTap: () => onChanged(i + 1),
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          filledPink || filledYellow
                              ? Icons.star
                              : Icons.star_border,
                          size: 28,
                          color: filledPink
                              ? const Color(0xFFEB02F7)
                              : filledYellow
                              ? Colors.amber
                              : Colors.grey,
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 16),

                /// 🔘 controles (MAIORES)
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _BigButton(
                        icon: Icons.remove,
                        onTap: v > 1 ? () => onChanged(v - 1) : null,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          '$v',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),

                      _BigButton(
                        icon: Icons.add,
                        onTap: v < 14 ? () => onChanged(v + 1) : null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          /// 💎 raridade (topo direito)
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8),
                ],
              ),
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🔘 botão maior e mais confortável
class _BigButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _BigButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.all(12), // 👈 maior área de toque
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
        ),
        child: Icon(
          icon,
          size: 22, // 👈 ícone maior
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
