import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key});

  @override
  State<CameraView> createState() => _CameraViewState();
}


// TODO: terminar la inicializacion de las camaras y poder usarlas
class _CameraViewState extends State<CameraView> {
  List<CameraDescription> cameras = [];
  late CameraController controller;

  @override
  void initState() {
    super.initState();
    _setUpCameraController();
  }

  Future<void> _setUpCameraController() async {
    final getCameras = await availableCameras();

    if (getCameras.isNotEmpty) {
      setState(() {
        cameras = getCameras;
        controller = CameraController(getCameras.first, ResolutionPreset.high);
      });
    }

    controller
        .initialize()
        .then((_) => setState(() {}))
        .onError((error, stackTrace) {
          print(error);
        });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Container(
      width: double.infinity,
      height: size.width,
      decoration: const BoxDecoration(
        color: Colors.grey,
      ),
      child: controller.value.isInitialized == false
        ? const Center(child: CircularProgressIndicator())
        : SafeArea(child: Text('Loaded')),
    );
  }
}
