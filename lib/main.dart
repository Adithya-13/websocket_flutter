import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Remove the following comments to test background messages
    // This requires WebSocket connection (click 'CONNECT')
    // In order to see messages click on 'LISTEN MESSAGES'
//    Timer.periodic(const Duration(seconds: 1), (timer) {
//      try {
//        webSocket?.add('${DateTime.now().toIso8601String()}');
//      } catch (e) {
//        print('unable to send message, weboscket closed');
//      }
//    });
  }

  final TextEditingController _urlController =
      TextEditingController(text: 'wss://echo.websocket.org');
  final TextEditingController _messageController = TextEditingController();
  final String authToken = 'auth_token';
  WebSocket webSocket;
  String _message = '';
  bool _isClosed = true;
  StreamSubscription listenSubscription;

  @override
  void dispose() {
    super.dispose();

    listenSubscription?.cancel();
    webSocket?.close();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Websocket Manager Example'),
        ),
        body: Column(
          children: <Widget>[
            TextField(
              controller: _urlController,
            ),
            Wrap(
              children: <Widget>[
                RaisedButton(
                  child: Text('CONNECT'),
                  onPressed: () async {
                    webSocket = await WebSocket.connect(
                      '${_urlController.text}?authentication=$authToken',
                      headers: <String, String>{
                        'Authorization': authToken,
                      },
                    );
                    setState(() {
                      _isClosed = false;
                    });
                  },
                ),
                RaisedButton(
                  child: Text('CLOSE'),
                  onPressed: () {
                    if (webSocket != null) {
                      webSocket.close();
                    }
                  },
                ),
                RaisedButton(
                  child: Text('LISTEN MESSAGES'),
                  onPressed: () {
                    if (webSocket != null) {
                      listenSubscription = webSocket.listen(
                        (dynamic message) {
                          print('New message: $message');
                          setState(() {
                            _message = message.toString();
                          });
                        },
                        onDone: () {
                          print('Connection closed');
                          setState(() {
                            _isClosed = true;
                          });
                        },
                      );
                    }
                  },
                ),
              ],
            ),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    webSocket?.add(_messageController.text);
                  },
                ),
              ),
            ),
            Text('Received message:'),
            Text(_message),
            Text('Connection status: ${_isClosed ? 'Disconnected' : 'Connected'}'),
          ],
        ),
      ),
    );
  }
}
