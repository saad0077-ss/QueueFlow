import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'specialty_style_options.dart';

const _fill = Color(0xFF1A2742);
const _border = Color(0xFF334155);
const _focus = Color(0xFF3B82F6);
const _radius = 12.0;

/// Parses `#RRGGBB` (with or without `#`); returns null when invalid.
Color? parseHexColor(String hex) {
  final clean = hex.trim().replaceFirst('#', '');
  if (!RegExp(r'^[0-9a-fA-F]{6}$').hasMatch(clean)) return null;
  return Color(int.parse('FF$clean', radix: 16));
}

class SpecialtyFieldLabel extends StatelessWidget {
  final String text;

  const SpecialtyFieldLabel(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: const Color(0xFFE2E8F0)),
      ),
    );
  }
}

/// Labelled wrapper used by every field in the specialty forms.
class SpecialtyLabeled extends StatelessWidget {
  final String label;
  final Widget child;
  final String? helper;

  const SpecialtyLabeled({super.key, required this.label, required this.child, this.helper});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SpecialtyFieldLabel(label),
        child,
        if (helper != null) ...[const SizedBox(height: 5), Text(helper!, style: GoogleFonts.inter(fontSize: 11.5, color: const Color(0xFF94A3B8)))],
      ],
    );
  }
}

class SpecialtyTextInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? hint;
  final int minLines;
  final int maxLines;
  final bool readOnly;
  final Widget? prefix;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;

  const SpecialtyTextInput({
    super.key,
    this.controller,
    this.hint,
    this.minLines = 1,
    this.maxLines = 1,
    this.readOnly = false,
    this.prefix,
    this.suffix,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      minLines: minLines,
      maxLines: maxLines,
      onChanged: onChanged,
      cursorColor: Colors.white,
      mouseCursor: readOnly ? SystemMouseCursors.forbidden : null,
      style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: readOnly ? const Color(0xFFCBD5E1) : Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF94A3B8)),
        isDense: true,
        filled: true,
        fillColor: _fill,
        prefixIcon: prefix,
        prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 0),
        suffixIcon: suffix,
        suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 0),
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
        border: _outline(_border),
        enabledBorder: _outline(_border),
        focusedBorder: readOnly ? _outline(_border) : _outline(_focus, 1.5),
      ),
    );
  }

  static OutlineInputBorder _outline(Color c, [double w = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(_radius),
      borderSide: BorderSide(color: c, width: w),
    );
  }
}

/// Bold select box styled like [SpecialtyTextInput].
class SpecialtyDropdown extends StatelessWidget {
  final String value;
  final Map<String, Widget> items;
  final ValueChanged<String> onChanged;
  final Widget? selectedOverride;

  const SpecialtyDropdown({super.key, required this.value, required this.items, required this.onChanged, this.selectedOverride});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 10),
      decoration: BoxDecoration(
        color: _fill,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: _border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.containsKey(value) ? value : items.keys.first,
          isExpanded: true,
          isDense: false,
          itemHeight: 48,
          borderRadius: BorderRadius.circular(_radius),
          dropdownColor: const Color(0xFF15213A),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 20),
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
          selectedItemBuilder: selectedOverride == null
              ? null
              : (_) => items.keys.map((k) => Align(alignment: Alignment.centerLeft, child: k == value ? selectedOverride! : items[k]!)).toList(),
          items: items.entries.map((e) => DropdownMenuItem(value: e.key, child: e.value)).toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

Widget _optionRow(Widget leading, String text) {
  return Row(
    children: [
      SizedBox(width: 20, child: Center(child: leading)),
      const SizedBox(width: 8),
      Flexible(child: Text(text, overflow: TextOverflow.ellipsis)),
    ],
  );
}

Widget _addCustomRow(String text) {
  return _optionRow(const Icon(Icons.add_circle_outline_rounded, size: 16, color: Color(0xFF38BDF8)), text);
}

/// Icon dropdown with presets plus an "Add custom icon" entry that reveals an emoji input.
class SpecialtyIconPicker extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const SpecialtyIconPicker({super.key, required this.value, required this.onChanged});

  @override
  State<SpecialtyIconPicker> createState() => _SpecialtyIconPickerState();
}

class _SpecialtyIconPickerState extends State<SpecialtyIconPicker> {
  late bool _custom = !kSpecialtyIconOptions.containsKey(widget.value);
  late final _ctrl = TextEditingController(text: _custom ? widget.value : '');

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final custom = _ctrl.text.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SpecialtyDropdown(
          value: _custom ? kCustomOptionValue : widget.value,
          items: {
            for (final e in kSpecialtyIconOptions.entries) e.key: _optionRow(Text(e.key, style: const TextStyle(fontSize: 15)), e.value),
            kCustomOptionValue: _addCustomRow('Add custom icon…'),
          },
          selectedOverride: _custom ? _optionRow(Text(custom.isEmpty ? '❔' : custom, style: const TextStyle(fontSize: 15)), 'Custom Icon') : null,
          onChanged: (v) {
            setState(() => _custom = v == kCustomOptionValue);
            if (!_custom) {
              widget.onChanged(v);
            } else if (custom.isNotEmpty) {
              widget.onChanged(custom);
            }
          },
        ),
        if (_custom) ...[
          const SizedBox(height: 8),
          SpecialtyTextInput(
            controller: _ctrl,
            hint: 'Paste or type an emoji, e.g. 🫀',
            prefix: const Icon(Icons.emoji_emotions_outlined, size: 18, color: Color(0xFF94A3B8)),
            onChanged: (v) {
              setState(() {});
              if (v.trim().isNotEmpty) widget.onChanged(v.trim());
            },
          ),
        ],
      ],
    );
  }
}

/// Accent color dropdown with presets plus a "Custom color" entry that reveals a hex input.
class SpecialtyColorPicker extends StatefulWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const SpecialtyColorPicker({super.key, required this.value, required this.onChanged});

  @override
  State<SpecialtyColorPicker> createState() => _SpecialtyColorPickerState();
}

class _SpecialtyColorPickerState extends State<SpecialtyColorPicker> {
  late bool _custom = !kSpecialtyColorOptions.containsKey(widget.value.toUpperCase());
  late final _ctrl = TextEditingController(text: _custom ? widget.value : '');

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customColor = parseHexColor(_ctrl.text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SpecialtyDropdown(
          value: _custom ? kCustomOptionValue : widget.value.toUpperCase(),
          items: {
            for (final e in kSpecialtyColorOptions.entries) e.key: _optionRow(_swatch(parseHexColor(e.key)!), '${e.value} (${e.key})'),
            kCustomOptionValue: _addCustomRow('Custom color…'),
          },
          selectedOverride: _custom
              ? _optionRow(_swatch(customColor ?? Colors.transparent), customColor == null ? 'Custom' : 'Custom (${_normalized(_ctrl.text)})')
              : null,
          onChanged: (v) {
            setState(() => _custom = v == kCustomOptionValue);
            if (!_custom) {
              widget.onChanged(v);
            } else if (customColor != null) {
              widget.onChanged(_normalized(_ctrl.text));
            }
          },
        ),
        if (_custom) ...[
          const SizedBox(height: 8),
          SpecialtyTextInput(
            controller: _ctrl,
            hint: 'Hex code, e.g. #14B8A6',
            prefix: Center(widthFactor: 1, child: _swatch(customColor ?? Colors.transparent)),
            suffix: _ctrl.text.isEmpty || customColor != null ? null : const Icon(Icons.error_outline_rounded, size: 18, color: Color(0xFFEF4444)),
            onChanged: (v) {
              setState(() {});
              if (parseHexColor(v) != null) widget.onChanged(_normalized(v));
            },
          ),
        ],
      ],
    );
  }

  String _normalized(String v) => '#${v.trim().replaceFirst('#', '').toUpperCase()}';

  Widget _swatch(Color c) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: c,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
      ),
    );
  }
}

/// Blue→teal gradient pill used for primary actions.
class GradientPillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool glow;
  final EdgeInsetsGeometry padding;

  const GradientPillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.glow = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF14B8A6)]),
        shadows: glow ? [BoxShadow(color: const Color(0xFF2563EB).withValues(alpha: 0.35), blurRadius: 18, offset: const Offset(0, 6))] : null,
      ),
      child: Material(
        color: Colors.transparent,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: loading ? null : onPressed,
          child: Padding(
            padding: padding,
            child: loading
                ? const Center(
                    widthFactor: 1,
                    child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                  )
                : Text(
                    label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(fontSize: 13.5, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Dark outlined pill used for secondary actions like Cancel.
class OutlinePillButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const OutlinePillButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF1E293B),
      shape: const StadiumBorder(side: BorderSide(color: _border)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
