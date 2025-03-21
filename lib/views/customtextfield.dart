import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final String label;
  final String? initialValue;
  final FormFieldSetter<String>? onSaved;
  final String? Function(String?) validator;
  final bool obscureText;

  const CustomTextField({
    Key? key,
    required this.label,
    required this.onSaved,
    required this.validator,
    this.initialValue,
    this.obscureText = false,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _controller;
  bool _isValid = true;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final error = widget.validator(_controller.text);
    setState(() {
      _isValid = error == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      onSaved: widget.onSaved,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(color: Colors.grey),
        errorStyle: const TextStyle(color: Colors.red),
        suffixIcon: _controller.text.isEmpty
            ? null
            : _isValid
                ? Icon(Icons.check_circle,
                    color: Colors.lightBlue.withOpacity(0.7))
                : const Icon(Icons.error, color: Colors.red),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.lightBlue.withOpacity(0.7)),
        ),
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}

class CustomDropdown extends StatelessWidget {
  final String label;
  final List<String> data;
  final String? value;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  const CustomDropdown({
    Key? key,
    required this.label,
    required this.data,
    required this.onChanged,
    this.value,
    this.validator,
    required List<String> items,
    required Null Function(dynamic value) onSaved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        errorStyle: const TextStyle(color: Colors.red),
      ),
      items: data.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      validator: validator,
    );
  }
}
