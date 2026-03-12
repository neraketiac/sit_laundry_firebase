import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:web/web.dart' as web;

class CustomerGatePage extends StatefulWidget {
  const CustomerGatePage({super.key});

  @override
  State<CustomerGatePage> createState() => _CustomerGatePageState();
}

class _CustomerGatePageState extends State<CustomerGatePage> {
  static const String storageKey = 'customer_code';

  bool loading = true;
  bool loggedIn = false;
  bool rememberMe = true;

  String? error;
  final TextEditingController codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkSavedCode();
  }

  Future<void> _checkSavedCode() async {
    final savedCode = web.window.localStorage.getItem(storageKey);

    if (savedCode == null) {
      setState(() => loading = false);
      return;
    }

    final isValid = await _validateCode(savedCode);

    setState(() {
      loggedIn = isValid;
      loading = false;
    });
  }

  Future<bool> _validateCode(String code) async {
    final snap = await FirebaseFirestore.instance
        .collection('EmployeeSetup')
        .where('EmpId', isEqualTo: code)
        // .where('active', isEqualTo: true)
        .limit(1)
        .get();

    return snap.docs.isNotEmpty;
  }

  Future<void> _login() async {
    final code = codeController.text.trim();

    if (code.isEmpty) {
      setState(() => error = 'Please enter your unique number');
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    final isValid = await _validateCode(code);

    if (isValid) {
      if (rememberMe) {
        web.window.localStorage.setItem(storageKey, code);
      }

      setState(() {
        loggedIn = true;
        loading = false;
      });
    } else {
      setState(() {
        error = 'Invalid unique number';
        loading = false;
      });
    }
  }

  void _logout() {
    web.window.localStorage.removeItem(storageKey);
    setState(() {
      loggedIn = false;
      codeController.clear();
      rememberMe = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: loading
            ? const CircularProgressIndicator()
            : loggedIn
                ? _home()
                : _loginForm(),
      ),
    );
  }

  Widget _loginForm() {
    return SizedBox(
      width: 380,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Enter Your Unique Number',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: codeController,
            decoration: const InputDecoration(
              labelText: 'Unique Number',
              border: OutlineInputBorder(),
            ),
          ),
          CheckboxListTile(
            value: rememberMe,
            onChanged: (v) => setState(() => rememberMe = v ?? true),
            title: const Text('Remember this device'),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          ),
          if (error != null)
            Text(error!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _login,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _home() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.verified, size: 64, color: Colors.green),
        const Text(
          'Access Granted',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _logout,
          child: const Text('Logout'),
        ),
      ],
    );
  }
}
