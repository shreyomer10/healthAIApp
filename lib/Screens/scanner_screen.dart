import 'dart:async';
import 'dart:math' as Math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../theme.dart';
import '../Helper/logger.dart';
import 'package:health_ai/l10n/generated/app_localizations.dart';

enum ScanState {
  looking,
  stabilizing,
  stable,
  capturing,
  captured,
}

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  final ImagePicker _picker = ImagePicker();
  static const Duration _decisionDelay = Duration(seconds: 1);

  CameraController? _controller;
  bool _cameraReady = false;
  bool _flashOn = false;
  bool _captured = false;
  bool _isDisposed = false;
  ScanState _scanState = ScanState.looking;

  StreamSubscription? _accelSub;
  double _lastMagnitude = 0.0;
  int _stableCount = 0;

  static const int _requiredStableSamples = 20;
  static const double _motionThreshold = 0.15;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) return;

      final cameras = await availableCameras();
      final backCamera =
      cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back);

      _controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _controller!.initialize();
      setState(() => _cameraReady = true);

      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _scanState = ScanState.looking);

      Future.delayed(_decisionDelay, () {
        if (!mounted || _captured) return;
        _startMotionDetection();
      });
    } catch (e) {
      AppLogger.log('Camera init failed: $e');
    }
  }

  void _startMotionDetection() {
    setState(() => _scanState = ScanState.stabilizing);

    _accelSub = accelerometerEvents.listen((event) {
      if (_captured) return;

      final magnitude =
      (event.x * event.x + event.y * event.y + event.z * event.z).sqrt();
      final delta = (magnitude - _lastMagnitude).abs();
      _lastMagnitude = magnitude;

      if (delta < _motionThreshold) {
        _stableCount++;
      } else {
        _stableCount = 0;
      }

      if (_stableCount >= _requiredStableSamples) {
        _accelSub?.cancel();
        _captureImage();
      }
    });
  }

  Future<void> _captureImage() async {
    if (_captured || _controller == null) return;

    _captured = true;
    setState(() => _scanState = ScanState.capturing);
    await _controller!.takePicture();
    setState(() => _scanState = ScanState.captured);
  }

  Future<void> _pickFromGallery(AppLocalizations t) async {
    _accelSub?.cancel();
    final image = await _picker.pickImage(source: ImageSource.gallery);

    if (image == null) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.discarded)),
      );
      return;
    }

    setState(() => _scanState = ScanState.captured);
  }

  String _statusText(AppLocalizations t) {
    switch (_scanState) {
      case ScanState.looking:
        return t.scanLooking;
      case ScanState.stabilizing:
        return t.scanHold;
      case ScanState.stable:
        return t.scanStable;
      case ScanState.capturing:
        return t.scanCapturing;
      case ScanState.captured:
        return t.scanCaptured;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final t = AppLocalizations.of(context)!;

    if (_controller == null || !_cameraReady || _isDisposed) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: CameraPreview(_controller!)),
          Positioned.fill(child: Container(color: colors.overlay)),
          SafeArea(
            child: Column(
              children: [
                _topBar(),
                const Spacer(),
                _scannerBox(colors),
                const Spacer(),
                _galleryButton(colors, t),
                const SizedBox(height: 12),
                Text(
                  _statusText(t),
                  style: TextStyle(color: colors.textSecondary),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const BackButton(color: Colors.white),
          const Spacer(),
          IconButton(
            icon: Icon(
              _flashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: () async {
              if (_controller == null) return;
              _flashOn = !_flashOn;
              await _controller!
                  .setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget _scannerBox(AppColors colors) {
    final size = MediaQuery.of(context).size.width * 0.75;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          _corner(Alignment.topLeft, colors),
          _corner(Alignment.topRight, colors),
          _corner(Alignment.bottomLeft, colors),
          _corner(Alignment.bottomRight, colors),
        ],
      ),
    );
  }

  Widget _corner(Alignment a, AppColors c) {
    return Align(
      alignment: a,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          border: Border(
            top: a.y < 0 ? BorderSide(color: c.scannerCorner, width: 4) : BorderSide.none,
            bottom: a.y > 0 ? BorderSide(color: c.scannerCorner, width: 4) : BorderSide.none,
            left: a.x < 0 ? BorderSide(color: c.scannerCorner, width: 4) : BorderSide.none,
            right: a.x > 0 ? BorderSide(color: c.scannerCorner, width: 4) : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _galleryButton(AppColors colors, AppLocalizations t) {
    return Container(
      decoration: BoxDecoration(
        color: colors.overlay,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextButton.icon(
        onPressed: () => _pickFromGallery(t),
        icon: Icon(Icons.image, color: colors.textPrimary),
        label: Text(
          t.uploadGallery,
          style: TextStyle(color: colors.textPrimary),
        ),
      ),
    );
  }
}

extension on double {
  double sqrt() => Math.sqrt(this);
}
