import 'package:material_ui/material_ui.dart';

import '../../app/theme.dart';

/// Кнопка «Название: значение ▾» со всплывающим списком снизу.
class SelectButton<T> extends StatelessWidget {
  const SelectButton({
    super.key,
    required this.label,
    required this.sheetTitle,
    required this.value,
    required this.options,
    required this.optionLabel,
    required this.onChanged,
  });

  final String label;
  final String sheetTitle;
  final T value;
  final List<T> options;
  final String Function(T) optionLabel;
  final ValueChanged<T> onChanged;

  Future<void> _open(BuildContext context) async {
    final picked = await showSelectSheet<T>(
      context,
      title: sheetTitle,
      value: value,
      options: options,
      optionLabel: optionLabel,
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = Theme.of(context).textTheme;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: c.line),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _open(context),
        child: SizedBox(
          height: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Text('$label ', style: t.bodyMedium?.copyWith(color: c.muted)),
                Expanded(
                  child: Text(
                    optionLabel(value),
                    style: t.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.expand_more, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Всплывающий список выбора одного значения.
Future<T?> showSelectSheet<T>(
  BuildContext context, {
  required String title,
  required T value,
  required List<T> options,
  required String Function(T) optionLabel,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      final c = ctx.colors;
      final t = Theme.of(ctx).textTheme;
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.7,
          ),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(title, style: t.bodySmall),
              ),
              for (final o in options)
                ListTile(
                  minTileHeight: 48,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  selected: o == value,
                  selectedTileColor: c.accentSoft,
                  selectedColor: c.accentText,
                  title: Text(
                    optionLabel(o),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: o == value
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  onTap: () => Navigator.pop(ctx, o),
                ),
            ],
          ),
        ),
      );
    },
  );
}
