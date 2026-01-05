import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:health_ai/Screens/result_sheet.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../locale/locale_provider.dart';
import '../theme.dart';
import '../widgets/loader.dart';
import '../Provider/auth_provider.dart';
import 'package:health_ai/l10n/generated/app_localizations.dart';

enum ScanState { looking, stabilizing, capturing, captured }

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  final ImagePicker _picker = ImagePicker();

  CameraController? _controller;
  bool _cameraReady = false;
  bool _flashOn = false;
  bool _captured = false;
  String? _lang="";
  ScanState _scanState = ScanState.looking;
  XFile? _capturedImage;
  bool _sheetOpened = false;

  StreamSubscription? _accelSub;
  double _lastMagnitude = 0;
  int _stableCount = 0;

  static const int _requiredStableSamples = 15;
  static const double _motionThreshold = 0.3;

  // ---------------- LIFECYCLE ----------------
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    _sheetOpened = false;
    _accelSub?.cancel();
    _controller?.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null) return;

    if (state == AppLifecycleState.paused) {
      _controller!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  // ---------------- CAMERA INIT ----------------
  Future<void> _initCamera() async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) return;

      final cameras = await availableCameras();
      final backCamera =
      cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back);

      _controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();

      _captured = false;
      _stableCount = 0;

      setState(() {
        _cameraReady = true;
        _scanState = ScanState.looking;
      });

      Future.delayed(const Duration(milliseconds: 500), _startMotionDetection);
    } catch (e) {
      debugPrint('Camera init failed: $e');
    }
  }

  // ---------------- MOTION DETECTION ----------------
  void _startMotionDetection() {
    if (_captured) return;

    _accelSub?.cancel();
    setState(() => _scanState = ScanState.stabilizing);

    _accelSub = accelerometerEvents.listen((event) {
      if (_captured) return;

      final magnitude =
      math.sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
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

  // ---------------- CAPTURE ----------------
  Future<void> _captureImage() async {
    if (_captured || _controller == null) return;

    _captured = true;
    setState(() => _scanState = ScanState.capturing);

    final image = await _controller!.takePicture();
    _capturedImage = image;

    setState(() => _scanState = ScanState.captured);
    await _uploadCapturedImage();
  }

  // ---------------- UPLOAD ----------------
  Future<void> _uploadCapturedImage() async {
    final auth = context.read<AuthProvider>();
    if (_capturedImage == null) return;

    await auth.upload(image: File(_capturedImage!.path),language: _lang);

    if (!mounted) return;

    if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!)),
      );
      _resetScanner();
      return;
    }

    final result = auth.lastUpload;
    if (result == null) {
      throw StateError('Upload succeeded but lastUpload is null');
    }

    _showResultSheet(result.scanId, result.output);
  }

  void _resetScanner() {
    _captured = false;
    _stableCount = 0;
    setState(() => _scanState = ScanState.looking);
    _startMotionDetection();
  }

  // ---------------- GALLERY ----------------
  Future<void> _pickFromGallery() async {
    _accelSub?.cancel();

    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      _startMotionDetection();
      return;
    }

    _capturedImage = image;
    _captured = true;
    setState(() => _scanState = ScanState.captured);

    await _uploadCapturedImage();
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final t = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    _lang= localeProvider.locale?.languageCode ?? 'system';
    if (_controller == null || !_cameraReady) {
      return const AppLoader();
    }

    return Scaffold(
      body: Stack(
        children: [
          _cameraUI(colors, t),
          if (auth.loading)
            const Positioned.fill(child: AppLoader()),
        ],
      ),
    );
  }

  Widget _cameraUI(AppColors colors, AppLocalizations t) {
    return Stack(
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
        onPressed: _pickFromGallery,
        icon: Icon(Icons.image, color: colors.textPrimary),
        label: Text(
          t.uploadGallery,
          style: TextStyle(color: colors.textPrimary),
        ),
      ),
    );
  }

  String _statusText(AppLocalizations t) {
    switch (_scanState) {
      case ScanState.looking:
        return t.scanLooking;
      case ScanState.stabilizing:
        return t.scanHold;
      case ScanState.capturing:
        return t.scanCapturing;
      case ScanState.captured:
        return t.scanCaptured;
    }
  }

  void _showResultSheet(String scanId, Map<String, dynamic> output) {
    if (_sheetOpened) {
      // Sheet already open → just update provider data
      return;
    }

    _sheetOpened = true;

    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ResultSheet(
        scanId: scanId,
        output: output,
        onClosed: () {
          _sheetOpened = false;
          _resetScanner(); // allow next scan
        },
      ),
    );
  }

}
