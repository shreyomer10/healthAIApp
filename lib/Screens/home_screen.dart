import 'dart:async';
import 'dart:math' as Math;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme.dart';
import '../app_config.dart';
import '../Helper/user_settings.dart';
import '../Helper/logger.dart';
import 'package:sensors_plus/sensors_plus.dart';
enum ScanState {
  looking,
  stabilizing,
  stable,
  capturing,
  captured,
}


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver{
  CameraController? _controller;
  bool _cameraReady = false;
  bool _flashOn = false;
  bool _captured = false;
  ScanState _scanState = ScanState.looking;
  bool _isDisposed = false;

  StreamSubscription? _accelSub;
  double _lastMagnitude = 0.0;
  int _stableCount = 0;


  static const int _requiredStableSamples = 20;
  static const double _motionThreshold = 0.15; // tweakable

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _initCamera();
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (_controller == null) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      AppLogger.log('App paused, disposing camera');
      _isDisposed = true;
      _cameraReady = false;

      await _controller?.dispose();
      _controller = null;

      if (mounted) setState(() {});
    }

    if (state == AppLifecycleState.resumed) {
      AppLogger.log('App resumed, reinitializing camera');
      _isDisposed = false;
      _initCamera();
    }
  }


  /// ---------------- CAMERA INIT ----------------
  Future<void> _initCamera() async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        AppLogger.log('Camera permission denied');
        return;
      }

      final cameras = await availableCameras();
      final backCamera = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.medium, // IMPORTANT (see below)
        enableAudio: false,
      );

      await _controller!.initialize();

      AppLogger.log('Camera initialized, warming up');

      setState(() => _cameraReady = true);

      // ⏳ IMPORTANT: warm-up delay
      await Future.delayed(const Duration(milliseconds: 500));

      _startMotionDetection();
    } catch (e) {
      AppLogger.log('Camera init failed: $e');
    }
  }

  void _startMotionDetection() {
    AppLogger.log('Starting motion-based stability detection');
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
        AppLogger.log('Motion stable detected');
        _accelSub?.cancel();
        _captureImage();
      }
    });
  }


  /// ---------------- CAPTURE ----------------
  Future<void> _captureImage() async {
    if (_captured) return;
    if (_controller == null) return;
    if (!_controller!.value.isInitialized) return;
    if (_controller!.value.isTakingPicture) return;

    _captured = true;
    setState(() => _scanState = ScanState.capturing);
    AppLogger.log('Capturing image...');

    final image = await _controller!.takePicture();

    setState(() => _scanState = ScanState.captured);

    AppLogger.log('Image captured: ${image.path}');
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _controller?.dispose();
    super.dispose();
  }


  /// ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;

    if (_controller == null ||
        !_cameraReady ||
        _isDisposed) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }


    return Scaffold(
      body: Stack(
        children: [
          /// CAMERA BACKGROUND (FULL SCREEN)
          /// CAMERA BACKGROUND (FULL SCREEN)
          Positioned.fill(
            child: CameraPreview(_controller!),
          ),

          /// TRANSLUCENT OVERLAY
          Positioned.fill(
            child: Container(color: colors.overlay),
          ),

          /// UI OVERLAY
          SafeArea(
            child: Column(
              children: [
                _topBar(),
                const Spacer(),
                _scannerBox(colors),
                const Spacer(),
                _galleryButton(colors),
                const SizedBox(height: 12),
                Text(
                  _scanStatusText(),
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ---------------- TOP BAR ----------------
  Widget _topBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Icon(Icons.close, color: Colors.white),
          const Spacer(),
          IconButton(
            icon: Icon(
              _flashOn ? Icons.flash_on : Icons.flash_off,
              color: Colors.white,
            ),
            onPressed: () async {
              if (_controller == null) return;

              _flashOn = !_flashOn;

              await _controller!.setFlashMode(
                _flashOn ? FlashMode.torch : FlashMode.off,
              );

              setState(() {});
              AppLogger.log(
                _flashOn ? 'Manual Flash ON (auto disabled)'
                    : 'Manual Flash OFF (auto disabled)',
              );
            },

          ),
        ],
      ),
    );
  }
  String _scanStatusText() {
    switch (_scanState) {
      case ScanState.looking:
        return "Point the camera at ingredients";
      case ScanState.stabilizing:
        return "Hold steady…";
      case ScanState.stable:
        return "Stable frame detected";
      case ScanState.capturing:
        return "Capturing…";
      case ScanState.captured:
        return "Captured";
    }
  }

  /// ---------------- SCANNER ----------------
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
            top: a.y < 0
                ? BorderSide(color: c.scannerCorner, width: 4)
                : BorderSide.none,
            bottom: a.y > 0
                ? BorderSide(color: c.scannerCorner, width: 4)
                : BorderSide.none,
            left: a.x < 0
                ? BorderSide(color: c.scannerCorner, width: 4)
              : BorderSide.none,
          right: a.x > 0
              ? BorderSide(color: c.scannerCorner, width: 4)
                : BorderSide.none,
          ),
        ),
      ),
    );
  }

  /// ---------------- GALLERY BUTTON ----------------
  Widget _galleryButton(AppColors colors) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.35),
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextButton.icon(
        onPressed: () {
          AppLogger.log('Gallery upload pressed');
          // gallery logic later
        },
        icon: const Icon(Icons.image, color: Colors.white),
        label: Text(
          "Upload from gallery",
          style: TextStyle(color: colors.textPrimary),
        ),
      ),
    );
  }
}
extension on double {
  double sqrt() => Math.sqrt(this);
}