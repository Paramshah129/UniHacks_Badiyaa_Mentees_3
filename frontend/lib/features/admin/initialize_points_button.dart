import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';

class InitializePointsButton extends StatefulWidget {
  const InitializePointsButton({super.key});

  @override
  State<InitializePointsButton> createState() => _InitializePointsButtonState();
}

class _InitializePointsButtonState extends State<InitializePointsButton> {
  bool _isLoading = false;
  String? _result;

  Future<void> _initializePoints() async {
    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final callable = FirebaseFunctions.instance.httpsCallable('initialize_all_user_points');
      final result = await callable.call();
      
      setState(() {
        _result = result.data['message'] ?? 'Success!';
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_result!),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: _isLoading ? null : _initializePoints,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purple,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : const Text('Initialize All User Points'),
        ),
        if (_result != null) ...[
          const SizedBox(height: 16),
          Text(
            _result!,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
