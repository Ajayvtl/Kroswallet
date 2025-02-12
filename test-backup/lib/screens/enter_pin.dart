import 'package:flutter/material.dart';
import '../utils/storage_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EnterPinScreen extends StatefulWidget {
  @override
  _EnterPinScreenState createState() => _EnterPinScreenState();
}

class _EnterPinScreenState extends State<EnterPinScreen> {
  TextEditingController _pinController = TextEditingController();
  String _errorMessage = '';
  int _attempts = 0;

  Future<void> _checkPin(String enteredPin) async {
    String? storedPin = await StorageHelper.getPin();

    if (storedPin == null) {
      // No stored PIN, force user to go back to passkey verification
      Fluttertoast.showToast(msg: 'No PIN found, please verify passkey again.');
      Navigator.pushReplacementNamed(context, '/verify-passkey');
    } else if (enteredPin == storedPin) {
      // Correct PIN, navigate to Dashboard
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      // Incorrect PIN, increment attempts
      _attempts++;
      if (_attempts >= 3) {
        // 3 failed attempts, go back to verify passkey
        Fluttertoast.showToast(
            msg: '3 incorrect attempts, please verify passkey again.');
        await StorageHelper.clearAll(); // Clear all data to reset
        Navigator.pushReplacementNamed(context, '/verify-passkey');
      } else {
        // Show error message for incorrect PIN
        setState(() {
          _errorMessage = 'Incorrect PIN. Attempt ${_attempts}/3';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter PIN'),
        backgroundColor: Colors.amber[700],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/bg2.png'), // Use the new background image
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Enter your 4-digit PIN:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.amberAccent, // Matching gradient theme
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: InputDecoration(
                  labelText: 'Enter PIN',
                  labelStyle: TextStyle(color: Colors.amber),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.amber, width: 2.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.grey[400]!, width: 1.0),
                  ),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  String enteredPin = _pinController.text.trim();
                  if (enteredPin.length == 4) {
                    _checkPin(enteredPin);
                  } else {
                    setState(() {
                      _errorMessage = 'PIN must be 4 digits.';
                    });
                  }
                },
                child: Text('Login'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.black,
                  backgroundColor: Colors.amber, // Text color on button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    _errorMessage,
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
