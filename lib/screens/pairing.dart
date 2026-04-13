import 'package:flutter/material.dart';
import 'package:gardians/constants/pairing_constants.dart';
import 'package:gardians/services/pairing_service.dart';

class PairingCodeScreen extends StatefulWidget {
  const PairingCodeScreen({super.key});

  @override
  State<PairingCodeScreen> createState() => _PairingCodeScreenState();
}

class _PairingCodeScreenState extends State<PairingCodeScreen> {
  final Color navyBlue = const Color(0xFF042459);
  final PairingService _pairingService = PairingService();
  String _pairCode = '';
  String _status = 'Generating parent code...';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _createCode();
  }

  Future<void> _createCode() async {
    try {
      final code = await _pairingService.createParentCode();
      if (!mounted) return;
      setState(() {
        _pairCode = code;
        _status = 'Share this code with child device';
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = 'Failed to generate code: $e';
        _loading = false;
      });
    }
  }

  Future<void> _checkLinkedChild() async {
    if (_pairCode.isEmpty) return;
    final childUid = await _pairingService.checkParentLinkedChild(_pairCode);
    if (!mounted) return;
    setState(() {
      _status = childUid == null
          ? 'Waiting for child to verify code'
          : 'Connected to child UID: $childUid';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, leading: CloseButton(color: navyBlue)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Pairing Code", style: TextStyle(color: navyBlue, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Text(
                "Enter this $pairingCodeLength-digit code on child device.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 40),
              
              
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F7FA),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF9ED7EB), width: 2),
                ),
                child: Text(
                  _pairCode.isEmpty ? ('-' * pairingCodeLength) : _pairCode,
                  style: TextStyle(color: navyBlue, fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: 5),
                ),
              ),
              
              const SizedBox(height: 50),
              Text(_status, style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loading ? null : _checkLinkedChild,
                child: const Text('Check Connection'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _loading ? null : _createCode,
                child: const Text('Generate New Code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}