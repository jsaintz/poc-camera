import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:poc_camera/pages/video_page.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  bool _isLoading = true;
  bool _isRecord = false;
  late CameraController? _cameraController;

  @override
  void initState() {
    _initCamera();
    super.initState();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  _initCamera() async {
    final cameras = await availableCameras();
    final front = cameras.firstWhere((cam) => cam.lensDirection == CameraLensDirection.front);
    _cameraController = CameraController(front, ResolutionPreset.ultraHigh);
    await _cameraController?.initialize();
    setState(() => _isLoading = false);
  }

  _recordVideo(BuildContext context) async {
    if (_isRecord) {
      final file = await _cameraController?.stopVideoRecording();
      setState(() => _isRecord = false);

      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => VideoPage(
            filePath: file!.path,
          ),
        ),
      );
    } else {
      await _cameraController?.prepareForVideoRecording();
      await _cameraController?.startVideoRecording();

      setState(() => _isRecord = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.white,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Center(
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CameraPreview(_cameraController!),
            Padding(
              padding: const EdgeInsets.all(25),
              child: FloatingActionButton(
                backgroundColor: Colors.red,
                child: Icon(_isRecord ? Icons.stop : Icons.circle),
                onPressed: () => _recordVideo(context),
              ),
            ),
          ],
        ),
      );
    }
  }
}
