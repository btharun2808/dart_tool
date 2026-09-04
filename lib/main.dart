import 'package:flutter/material.dart';

void main() {
  runApp(const MeasureMateApp());
}

class MeasureMateApp extends StatelessWidget {
  const MeasureMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Measure Mate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A7C78),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7F5),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFD7E3DF)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF0A7C78), width: 2),
          ),
        ),
      ),
      home: const ConverterPage(),
    );
  }
}

enum MeasureType { length, weight }

class ConverterPage extends StatefulWidget {
  const ConverterPage({super.key});

  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  final _valueController = TextEditingController(text: '1');
  MeasureType _measureType = MeasureType.length;
  String _fromUnit = 'Miles';
  String _toUnit = 'Kilometers';
  double _result = 1.60934;

  static const _lengthUnits = ['Miles', 'Kilometers', 'Feet', 'Meters'];
  static const _weightUnits = ['Pounds', 'Kilograms', 'Ounces', 'Grams'];

  List<String> get _units =>
      _measureType == MeasureType.length ? _lengthUnits : _weightUnits;

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  void _changeMeasure(MeasureType type) {
    setState(() {
      _measureType = type;
      final units = type == MeasureType.length ? _lengthUnits : _weightUnits;
      _fromUnit = units.first;
      _toUnit = units[1];
      _convert();
    });
  }

  double _toBaseUnit(double value, String unit) {
    if (_measureType == MeasureType.length) {
      return switch (unit) {
        'Miles' => value * 1609.344,
        'Feet' => value * 0.3048,
        'Meters' => value,
        _ => value * 1000,
      };
    }
    return switch (unit) {
      'Pounds' => value * 0.45359237,
      'Ounces' => value * 0.0283495231,
      'Grams' => value / 1000,
      _ => value,
    };
  }

  double _fromBaseUnit(double value, String unit) {
    if (_measureType == MeasureType.length) {
      return switch (unit) {
        'Miles' => value / 1609.344,
        'Feet' => value / 0.3048,
        'Meters' => value,
        _ => value / 1000,
      };
    }
    return switch (unit) {
      'Pounds' => value / 0.45359237,
      'Ounces' => value / 0.0283495231,
      'Grams' => value * 1000,
      _ => value,
    };
  }

  void _convert() {
    final value = double.tryParse(_valueController.text) ?? 0;
    final baseValue = _toBaseUnit(value, _fromUnit);
    _result = _fromBaseUnit(baseValue, _toUnit);
  }

  void _swapUnits() {
    setState(() {
      final previousFrom = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = previousFrom;
      _convert();
    });
  }

  String _formatResult() => _result.abs() < 0.000001
      ? '0'
      : _result.toStringAsFixed(4).replaceFirst(RegExp(r'\.?0+$'), '');

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Measure Mate', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: 'About Measure Mate',
            onPressed: () => showAboutDialog(
              context: context,
              applicationName: 'Measure Mate',
              applicationVersion: '1.0.0',
              children: const [Text('A simple metric and imperial unit converter.')],
            ),
            icon: const Icon(Icons.info_outline),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            Text('Convert with confidence', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Quick, clear conversions for everyday measurements.', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16)),
            const SizedBox(height: 28),
            SegmentedButton<MeasureType>(
              segments: const [
                ButtonSegment(value: MeasureType.length, label: Text('Distance'), icon: Icon(Icons.route)),
                ButtonSegment(value: MeasureType.weight, label: Text('Weight'), icon: Icon(Icons.monitor_weight_outlined)),
              ],
              selected: {_measureType},
              onSelectionChanged: (selection) => _changeMeasure(selection.first),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('FROM', style: TextStyle(color: colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _valueController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => setState(_convert),
                    decoration: const InputDecoration(labelText: 'Enter a value', prefixIcon: Icon(Icons.edit_outlined)),
                  ),
                  const SizedBox(height: 14),
                  _unitDropdown(_fromUnit, (value) => setState(() { _fromUnit = value!; _convert(); })),
                  const SizedBox(height: 16),
                  Center(child: IconButton.filledTonal(onPressed: _swapUnits, tooltip: 'Swap units', icon: const Icon(Icons.swap_vert, size: 24))),
                  const SizedBox(height: 16),
                  Text('TO', style: TextStyle(color: colorScheme.primary, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                  const SizedBox(height: 10),
                  _unitDropdown(_toUnit, (value) => setState(() { _toUnit = value!; _convert(); })),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(20)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('RESULT', style: TextStyle(color: colorScheme.onPrimary.withValues(alpha: .75), fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                const SizedBox(height: 10),
                Text('${_formatResult()} $_toUnit', style: TextStyle(color: colorScheme.onPrimary, fontSize: 30, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text('Conversion updated instantly', style: TextStyle(color: colorScheme.onPrimary.withValues(alpha: .8))),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _unitDropdown(String value, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: const InputDecoration(labelText: 'Unit'),
      items: _units.map((unit) => DropdownMenuItem(value: unit, child: Text(unit))).toList(),
      onChanged: onChanged,
    );
  }
}