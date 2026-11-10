import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'fcm_service.dart';
import 'firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  debugPrint('onBackgroundMessage: ${message.messageId}');

  // Background processing belongs here.
  // Do not call setState or access widgets here.
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  runApp(const DeliveryApp());
}

class DeliveryApp extends StatelessWidget {
  const DeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Delivery Updates',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
        ),
        useMaterial3: true,
      ),
      home: const DeliveryScreen(),
    );
  }
}

class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key});

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  final FCMService _fcm = FCMService();

  static const Map<String, String> _images = {
    'default': 'assets/images/default.png',
    'promo': 'assets/images/promo.png',
  };

  String _title = 'Order received';
  String _imagePath = 'assets/images/default.png';
  String _setupStatus = 'Starting messaging...';
  String _diagnostic = 'Waiting for a delivery update.';
  String _lastHandler = 'None';
  String _messageId = 'None';
  int _receiptCount = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_startMessaging());
      }
    });
  }

  Future<void> _startMessaging() async {
    try {
      await _fcm.initialize(
        onData: _handleMessage,
        onStatus: (status) {
          if (!mounted) return;

          setState(() {
            _setupStatus = status;
          });
        },
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _setupStatus = 'Messaging setup error: $error';
      });
    }
  }

  void _handleMessage(RemoteMessage message, String handler) {
    if (!mounted) return;

    final action = message.data['action'];
    final asset = message.data['asset'];

    String? rejection;

    if (action != 'update_ui') {
      rejection = 'Rejected: action must be update_ui.';
    } else if (asset is! String || asset.isEmpty) {
      rejection = 'Rejected: missing or invalid asset.';
    } else if (!_images.containsKey(asset)) {
      rejection = 'Rejected: unsupported asset "$asset".';
    }

    setState(() {
      // Every received event updates the evidence panel.
      _lastHandler = handler;
      _messageId = message.messageId ?? 'Unavailable';
      _receiptCount += 1;

      if (rejection != null) {
        // Keep the previous title and image.
        _diagnostic = rejection;
      } else {
        _imagePath = _images[asset]!;
        _title = asset == 'promo'
            ? 'Out for delivery'
            : 'Order received';
        _diagnostic = 'Valid delivery update applied.';
      }
    });
  }

  @override
  void dispose() {
    unawaited(_fcm.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Updates'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Demo order #1001',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            Text(
              _title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Image.asset(
              _imagePath,
              height: 220,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_setupStatus),
                    const Divider(),
                    Text('Last handler: $_lastHandler'),
                    Text('Receipt count: $_receiptCount'),
                    Text('Message ID: $_messageId'),
                    const SizedBox(height: 12),
                    Text(
                      _diagnostic,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}