import 'package:flutter/material.dart';
import '../utils/storage_helper.dart';

class VerifyPasskeyScreen extends StatefulWidget {
  @override
  _VerifyPasskeyScreenState createState() => _VerifyPasskeyScreenState();
}

class _VerifyPasskeyScreenState extends State<VerifyPasskeyScreen> {
  List<String>? _passkeyWords;
  Map<int, String> _randomWords = {};
  Map<int, String> _userInputs = {};
  Map<int, String> _correctWords =
      {}; // To store the correct word for each index
  int _attempts = 0;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _loadPasskey();
  }

  // Load passkey from storage
  Future<void> _loadPasskey() async {
    String? passkey = await StorageHelper.getPasskey();
    if (passkey != null) {
      setState(() {
        _passkeyWords = passkey.split(' ');
        _generateRandomWords();
      });
    }
  }

  // Generate random words for validation
  void _generateRandomWords() {
    _randomWords.clear();
    _correctWords.clear(); // Clear previous correct words
    if (_passkeyWords != null) {
      // Randomly pick words from the passkey list
      for (int i = 0; i < 3; i++) {
        int index = (i + 1) % _passkeyWords!.length;
        _randomWords[index] = _passkeyWords![index];
        _correctWords[index] = _passkeyWords![index]; // Store the correct word
      }
    }
  }

  // Verify entered passkey words
  void _verifyPasskey() {
    bool allCorrect = true;
    for (int index in _randomWords.keys) {
      if (_userInputs[index] != _randomWords[index]) {
        allCorrect = false;
        break;
      }
    }

    if (allCorrect) {
      Navigator.pushReplacementNamed(context, '/set-pin');
    } else {
      setState(() {
        _attempts++;
        _message = 'Incorrect word(s)! Attempt ${_attempts} of 3.';
        if (_attempts >= 3) {
          StorageHelper.clearAll();
          Navigator.pushReplacementNamed(context, '/generate-passkey');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verify Passkey'),
        backgroundColor: Colors.amber[700],
      ),
      body: _passkeyWords == null
          ? Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/images/bg.png'), // Ensure bg.png is added in assets
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Verify your passkey:',
                      style: TextStyle(
                          color: const Color.fromARGB(255, 255, 255, 255),
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 20),
                    // Loop through random words for verification
                    for (int index in _randomWords.keys)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          children: [
                            TextField(
                              onChanged: (value) {
                                _userInputs[index] = value.trim();
                              },
                              style: TextStyle(
                                  color:
                                      const Color.fromARGB(255, 255, 255, 255),
                                  fontSize: 18),
                              decoration: InputDecoration(
                                labelText: 'Word ${index + 1}',
                                hintStyle: TextStyle(
                                  color: Colors
                                      .white70, // Softer white color for hint
                                  fontSize: 18.0, // Larger font size for hint
                                  fontWeight: FontWeight.bold,
                                ),
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.white, // Default white border
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: _userInputs[index] ==
                                            _randomWords[index]
                                        ? Colors.green
                                        : Colors.red,
                                    width: 2.0,
                                  ),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red, // Red border for errors
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(
                                    0.1), // Slightly transparent background
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                              ),
                            ),
                            // Show correct word below input if it's incorrect
                            if (_userInputs[index] != _randomWords[index])
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  'Correct word: ${_correctWords[index]}',
                                  style: TextStyle(
                                      color: const Color.fromARGB(
                                          255, 155, 244, 54),
                                      fontSize: 18),
                                ),
                              ),
                          ],
                        ),
                      ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _verifyPasskey,
                      child: Text('Verify'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[700],
                      ),
                    ),
                    if (_message.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Text(
                          _message,
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
}
