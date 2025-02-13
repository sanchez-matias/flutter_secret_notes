import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  List<CameraDescription> cameras = [];
  CameraController? controller;
  bool isInitialized = false;

  @override
  void initState() {
    super.initState();
    _setUpCameraController();
  }

  @override
  void dispose() {
    if (controller != null) {
      controller!.dispose();
    }
    super.dispose();
  }

  Future<void> _setUpCameraController() async {
    List<CameraDescription> getCameras = await availableCameras();

    if (getCameras.isNotEmpty) {
      setState(() {
        cameras = getCameras;
        controller = CameraController(cameras.first, ResolutionPreset.high);
      });

      controller?.initialize().then((_) {
        setState(() {
          isInitialized = true;
        });
      }).onError((error, stackTrace) {
        // print(error);
      });
    }
  }

  Future<void> takePicture() async {
    if (controller != null || !isInitialized) return;

    final XFile image = await controller!.takePicture();

    final directory = await getApplicationDocumentsDirectory();
    final customFolder = '${directory.path}${Platform.pathSeparator}images_storage';
    final imagePath = '$customFolder${Platform.pathSeparator}${DateTime.now()}.jpg';

    final savedImage = File(imagePath);
    await File(image.path).copy(savedImage.path);

    // TODO 1: guardar el link en base de datos a traves del provider y volver a obtener las notas.
    // TODO 2: Invalidar el provider getNote para que se vuelva a consultar y muestre la imagen tomada.
  } 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30),
              child: _CameraView(controller),
            ),
        
            const Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: 40),
                child: _TakePhotoButton(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TakePhotoButton extends StatelessWidget {
  // TODO: pasarle la funcion takePicture por parametro

  const _TakePhotoButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // TODO: Ejecutar funcion takePicture
      },
      child: Container(
        height: 80,
        width: 80,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
        ),
        child: Center(
          child: Container(
            height: 50,
            width: 50,
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                width: 2,
              )
            ),
          ),
        ),
      ),
    );
  }
}

class _CameraView extends StatelessWidget {
  final CameraController? controller;

  const _CameraView(this.controller);

@override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context).width - 10;
    final canShowCamera = controller != null && controller?.value.isInitialized == true;

    return Container(
      width: size,
      height: size * 1.7,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: canShowCamera
        ? CameraPreview(controller!)
        : const SizedBox(
            height: 50,
            width: 50,
            child: CircularProgressIndicator(),
          ),
    );
  }
}
