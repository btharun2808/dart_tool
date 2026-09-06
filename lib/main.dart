import 'package:flutter/material.dart';

void main() {
  // Start the app.
  runApp(const MeasureMateApp());
}

class MeasureMateApp extends StatelessWidget {
  const MeasureMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Measures Converter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4285E5)),
        scaffoldBackgroundColor: Colors.white,
        inputDecorationTheme: InputDecorationTheme(
          border: const UnderlineInputBorder(),
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF4285E5), width: 2),
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
  // The controller keeps the number shown in the input field.
  final _valueController = TextEditingController(text: '1');
  MeasureType _measureType = MeasureType.length;
  String _fromUnit = 'Miles';
  String _toUnit = 'Kilometers';
  double _result = 1.60934;

  // Keep the choices together for each type of measurement.
  static const _lengthUnits = ['Miles', 'Kilometers', 'Feet', 'Meters'];
  static const _weightUnits = ['Pounds', 'Kilograms', 'Ounces', 'Grams'];

  List<String> get _units =>
      _measureType == MeasureType.length ? _lengthUnits : _weightUnits;

  @override
  void dispose() {
    // Controllers should be released when the screen is removed.
    _valueController.dispose();
    super.dispose();
  }

  void _changeMeasure(MeasureType type) {
    // Reset the units when the measurement type changes.
    setState(() {
      _measureType = type;
      final units = type == MeasureType.length ? _lengthUnits : _weightUnits;
      _fromUnit = units.first;
      _toUnit = units[1];
      _convert();
    });
  }

  double _toBaseUnit(double value, String unit) {
    // Convert through meters or kilograms so every unit pair uses one path.
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
    // Convert the shared value into the unit selected by the user.
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
    // Convert to a common unit before converting to the selected unit.
    final value = double.tryParse(_valueController.text) ?? 0;
    final baseValue = _toBaseUnit(value, _fromUnit);
    _result = _fromBaseUnit(baseValue, _toUnit);
  }

  String _formatResult() => _result.abs() < 0.000001
      ? '0'
      // Limit the result to four decimal places for easier reading.
      : _result.toStringAsFixed(4).replaceFirst(RegExp(r'\.?0+$'), '');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Measures Converter', style: TextStyle(fontSize: 16)),
        centerTitle: true,
        backgroundColor: const Color(0xFF4285E5),
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Row(
            children: [
              _tabButton('Distance', MeasureType.length),
              _tabButton('Weight', MeasureType.weight),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            // Keep the form readable on wider browser windows.
            constraints: const BoxConstraints(maxWidth: 420),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 32),
              shrinkWrap: true,
              children: [
                const Center(
                    child: Text('Value', style: TextStyle(color: Colors.grey))),
                TextField(
                  controller: _valueController,
                  textAlign: TextAlign.left,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  // Recalculate while the user types a new value.
                  onChanged: (_) => setState(_convert),
                  decoration: const InputDecoration(isDense: true),
                ),
                const SizedBox(height: 18),
                const Center(
                    child: Text('From', style: TextStyle(color: Colors.grey))),
                _unitDropdown(
                    _fromUnit,
                    (value) => setState(() {
                          _fromUnit = value!;
                          _convert();
                        })),
                const SizedBox(height: 18),
                const Center(
                    child: Text('To', style: TextStyle(color: Colors.grey))),
                _unitDropdown(
                    _toUnit,
                    (value) => setState(() {
                          _toUnit = value!;
                          _convert();
                        })),
                const SizedBox(height: 18),
                Center(
                  child: FilledButton(
                    onPressed: () => setState(_convert),
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFFE7E7E7),
                      foregroundColor: const Color(0xFF3568B5),
                      elevation: 0,
                      shape: const RoundedRectangleBorder(),
                    ),
                    child: const Text('Convert'),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Text(
                    '${_valueController.text} $_fromUnit are ${_formatResult()} $_toUnit',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _unitDropdown(String value, ValueChanged<String?> onChanged) {
    // Use the same dropdown layout for both unit fields.
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: const InputDecoration(isDense: true),
      items: _units
          .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
          .toList(),
      // The callback updates the selected source or destination unit.
      onChanged: onChanged,
    );
  }

  Widget _tabButton(String label, MeasureType type) {
    // Show which measurement type is currently selected.
    final isSelected = _measureType == type;
    return Expanded(
      child: InkWell(
        onTap: () => _changeMeasure(type),
        child: Container(
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: isSelected ? Colors.white : Colors.transparent,
                    width: 3)),
          ),
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
