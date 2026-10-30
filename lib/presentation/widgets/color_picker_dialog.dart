import 'package:flutter/material.dart';
import '../../core/constants/note_colors.dart';

/// Unrestricted Color Picker Sheet:
/// - 9 Classic ColorNote Swatches + User Saved Swatches
/// - 360-degree Rainbow Hue Slider (pick any color without restrictions)
/// - Paper Softness / Tint Slider (0.45..0.95)
class UnrestrictedColorPickerSheet extends StatefulWidget {
  final int currentColorIndex;
  final int? currentCustomColor;
  final double currentTintRatio;
  final List<NoteColorPalette> customPalettes;
  final void Function(int colorIndex, int? customColorValue, double tintRatio) onColorSelected;
  final void Function(NoteColorPalette newSavedPalette) onSaveCustomPalette;

  const UnrestrictedColorPickerSheet({
    super.key,
    required this.currentColorIndex,
    required this.currentCustomColor,
    required this.currentTintRatio,
    required this.customPalettes,
    required this.onColorSelected,
    required this.onSaveCustomPalette,
  });

  @override
  State<UnrestrictedColorPickerSheet> createState() => _UnrestrictedColorPickerSheetState();
}

class _UnrestrictedColorPickerSheetState extends State<UnrestrictedColorPickerSheet> {
  double _hue = 50.0;
  late double _tintRatio;
  int? _customArgb;

  @override
  void initState() {
    super.initState();
    _tintRatio = widget.currentTintRatio;
    _customArgb = widget.currentCustomColor;
    if (_customArgb != null) {
      _hue = HSVColor.fromColor(Color(_customArgb!)).hue;
    }
  }

  Color get _activeFreeColor => HSVColor.fromAHSV(1.0, _hue, 0.85, 0.92).toColor();

  @override
  Widget build(BuildContext context) {
    final allPalettes = [...NoteColors.defaultPalettes, ...widget.customPalettes];
    final previewPalette = NoteColorPalette.fromCustomColor(
      _activeFreeColor,
      paperWhiteRatio: _tintRatio,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '🌈 أداة اختيار أي لون حر (Unrestricted Color Picker)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Live Preview Box with Ruled Lines
            Container(
              height: 54,
              decoration: BoxDecoration(
                color: previewPalette.bodyColor,
                border: Border(
                  left: BorderSide(color: previewPalette.stripeColor, width: 10),
                  top: BorderSide(color: previewPalette.headerColor, width: 8),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: Text(
                'معاينة لون الورقة والشريط (${previewPalette.nameEn})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            const SizedBox(height: 12),

            // 360° Rainbow Hue Slider
            const Text('شريط الطيف اللوني الحر (360° Hue Spectrum):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            Slider(
              value: _hue,
              min: 0,
              max: 360,
              activeColor: _activeFreeColor,
              onChanged: (val) {
                setState(() {
                  _hue = val;
                  _customArgb = _activeFreeColor.value;
                });
                widget.onColorSelected(widget.currentColorIndex, _activeFreeColor.value, _tintRatio);
              },
            ),

            // Paper Tint Softness Slider
            const Text('درجة تفتيح ورقة الدفتر (Paper Tint Softness):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            Slider(
              value: _tintRatio,
              min: 0.45,
              max: 0.95,
              activeColor: Colors.teal,
              onChanged: (val) {
                setState(() => _tintRatio = val);
                widget.onColorSelected(
                  widget.currentColorIndex,
                  _customArgb ?? _activeFreeColor.value,
                  _tintRatio,
                );
              },
            ),

            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _activeFreeColor,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('تطبيق وحفظ هذا اللون في لوحة ألواني'),
              onPressed: () {
                final newIdx = 9 + widget.customPalettes.length;
                final newPal = NoteColorPalette.fromCustomColor(
                  _activeFreeColor,
                  paperWhiteRatio: _tintRatio,
                  index: newIdx,
                );
                widget.onSaveCustomPalette(newPal);
                Navigator.pop(context);
              },
            ),
            const Divider(height: 24),

            const Text('الألوان الكلاسيكية والمحفوظة:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: allPalettes.map((p) {
                final isSelected = _customArgb == null && widget.currentColorIndex == p.index;
                return InkWell(
                  onTap: () {
                    widget.onColorSelected(p.index, null, _tintRatio);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: p.stripeColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.white,
                        width: isSelected ? 3 : 1.5,
                      ),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 3)],
                    ),
                    child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
