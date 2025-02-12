import 'package:flutter/material.dart';
import '../utils/storage_helper.dart';
import 'package:flutter/services.dart';

class SetPinScreen extends StatefulWidget {
  @override
  _SetPinScreenState createState() => _SetPinScreenState();
}

class _SetPinScreenState extends State<SetPinScreen> {
  List<TextEditingController> _pinControllers =
      List.generate(4, (_) => TextEditingController());
  List<TextEditingController> _confirmPinControllers =
      List.generate(4, (_) => TextEditingController());
  String _errorMessage = '';
  bool _isPinCompleted = false;

  Future<void> _savePin(String pin) async {
    await StorageHelper.savePin(pin); // Save the PIN securely
  }

  void _validatePin() {
    String pin = _pinControllers.map((controller) => controller.text).join();
    String confirmPin =
        _confirmPinControllers.map((controller) => controller.text).join();

    if (pin.length != 4 || confirmPin.length != 4) {
      setState(() {
        _errorMessage = 'PIN must be 4 digits!';
      });
      return;
    }

    if (pin == confirmPin) {
      _savePin(pin);
      Navigator.pushReplacementNamed(context, '/enter-pin');
    } else {
      setState(() {
        _errorMessage = 'PINs do not match!';
      });
    }
  }

  void _moveToNextField(TextEditingController currentController,
      FocusNode currentFocus, FocusNode nextFocus) {
    if (currentController.text.isNotEmpty) {
      currentFocus.unfocus();
      FocusScope.of(context).requestFocus(nextFocus);
    }
  }

  void _moveToPreviousField(TextEditingController currentController,
      FocusNode currentFocus, FocusNode previousFocus) {
    if (currentController.text.isEmpty) {
      currentFocus.unfocus();
      FocusScope.of(context).requestFocus(previousFocus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set PIN'),
        backgroundColor: Colors.amber[700],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/bg.png'), // Ensure bg.png is added in assets
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
                    _buildPinRow(_pinControllers, isConfirm: false),
                  ],
                ),
              ),
              SizedBox(height: 40),
              _buildBackgroundBox(
                child: Column(
                  children: [
                    Text(
                      'Confirm your PIN:',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                    SizedBox(height: 20),
                    _buildPinRow(_confirmPinControllers, isConfirm: true),
                  ],
                ),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                onPressed: _validatePin,
                child: Text('Set PIN'),
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
                      color: Colors.red,
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

  Widget _buildPinRow(List<TextEditingController> controllers,
      {required bool isConfirm}) {
    List<FocusNode> focusNodes = List.generate(4, (_) => FocusNode());

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
                    controllers[index].text.isEmpty &&
                    index > 0) {
                  FocusScope.of(context).requestFocus(focusNodes[index - 1]);
                  controllers[index - 1].clear();
                }
              },
              child: TextField(
                controller: controllers[index],
                focusNode: focusNodes[index],
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
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.red, width: 2.0),
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && index < 3) {
                    FocusScope.of(context).requestFocus(focusNodes[index + 1]);
                  }
                },
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildBackgroundBox({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: EdgeInsets.all(16),
      child: child,
    );
  }
}
