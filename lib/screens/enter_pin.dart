import 'package:flutter/material.dart';
import '../utils/storage_helper.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EnterPinScreen extends StatefulWidget {
  @override
  _EnterPinScreenState createState() => _EnterPinScreenState();
}

class _EnterPinScreenState extends State<EnterPinScreen> {
  List<TextEditingController> _pinControllers =
      List.generate(4, (_) => TextEditingController());
  List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  String _errorMessage = '';
  int _attempts = 0;

  // Future<void> _checkPin() async {
  //   String enteredPin =
  //       _pinControllers.map((controller) => controller.text).join();
  //   String? storedPin = await StorageHelper.getPin();

  //   if (storedPin == null) {
  //     Fluttertoast.showToast(msg: 'No PIN found, please verify passkey again.');
  //     Navigator.pushReplacementNamed(context, '/verify-passkey');
  //   } else if (enteredPin == storedPin) {
  //     Navigator.pushReplacementNamed(context, '/dashboard');
  //   } else {
  //     _attempts++;
  //     if (_attempts >= 3) {
  //       Fluttertoast.showToast(
  //           msg: '3 incorrect attempts, please verify passkey again.');
  //       await StorageHelper.clearAll();
  //       Navigator.pushReplacementNamed(context, '/verify-passkey');
  //     } else {
  //       setState(() {
  //         _errorMessage = 'Incorrect PIN. Attempt ${_attempts}/3';
  //       });
  //     }
  //   }
  // }
  Future<void> _checkPin() async {
    String enteredPin =
        _pinControllers.map((controller) => controller.text).join();
    String? storedPin = await StorageHelper.getPin();

    if (storedPin == null) {
      Fluttertoast.showToast(msg: 'No PIN found, please verify passkey again.');
      Navigator.pushReplacementNamed(context, '/verify-passkey');
    } else if (enteredPin == storedPin) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      _attempts++;
      if (_attempts >= 3) {
        Fluttertoast.showToast(
            msg: '3 incorrect attempts, please verify passkey again.');
        await StorageHelper.delete(
            'pin'); // Clear only the PIN, not the passkey
        Navigator.pushReplacementNamed(context, '/verify-passkey');
      } else {
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
            image: AssetImage('assets/images/bg2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBackgroundBox(
                child: Column(
                  children: [
                    Text(
                      'Enter your 4-digit PIN:',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: 20),
                    _buildPinRow(),
                  ],
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  if (_pinControllers
                      .every((controller) => controller.text.isNotEmpty)) {
                    _checkPin();
                  } else {
                    setState(() {
                      _errorMessage = 'PIN must be 4 digits.';
                    });
                  }
                },
                child: Text(
                  'Login',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
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

  Widget _buildPinRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 5.0),
          child: SizedBox(
            width: 50,
            height: 60,
            child: RawKeyboardListener(
              focusNode: FocusNode(),
              onKey: (RawKeyEvent event) {
                if (event is RawKeyDownEvent &&
                    event.logicalKey == LogicalKeyboardKey.backspace &&
                    _pinControllers[index].text.isEmpty &&
                    index > 0) {
                  _focusNodes[index - 1].requestFocus();
                  _pinControllers[index - 1].clear();
                }
              },
              child: TextField(
                controller: _pinControllers[index],
                focusNode: _focusNodes[index],
                obscureText: true,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, color: Colors.white),
                maxLength: 1,
                decoration: InputDecoration(
                  counterText: '',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white, width: 2.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.green, width: 2.0),
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && index < 3) {
                    _focusNodes[index + 1].requestFocus();
                  }
                },
                onTap: () {
                  _unfocusAllExcept(_focusNodes[index]);
                },
              ),
            ),
          ),
        );
      }),
    );
  }

  void _unfocusAllExcept(FocusNode activeFocusNode) {
    for (var focusNode in _focusNodes) {
      if (focusNode != activeFocusNode) {
        focusNode.unfocus();
      }
    }
  }

  Widget _buildBackgroundBox({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8.0,
            spreadRadius: 2.0,
            offset: Offset(0, 4),
          ),
        ],
      ),
      margin: EdgeInsets.symmetric(horizontal: 24),
      padding: EdgeInsets.all(16),
      child: child,
    );
  }
}
