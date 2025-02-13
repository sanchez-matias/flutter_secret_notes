import 'package:camera/camera.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'cameras_provider.g.dart';

@riverpod
class Cameras extends _$Cameras {
  @override
  List<CameraDescription> build() {
    return [];
  }

  Future<void> getCameras() async {
    final cameras = await availableCameras();

    // for (final cam in cameras) {
    //   print('CAMERA: $cam');
    // }

    state = cameras;
  }
}