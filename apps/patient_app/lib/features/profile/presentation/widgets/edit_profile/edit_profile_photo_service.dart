import 'dart:convert';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:queueflow_ui/queueflow_ui.dart';

import '../../../../../core/widgets/app_snack_bar.dart';
import 'edit_profile_bloc.dart';

class EditProfilePhotoService {
  const EditProfilePhotoService._();

  static bool get isMobile =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static Future<String> encode(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final src = frame.image;

    final side = src.width < src.height ? src.width : src.height;
    final srcRect = Rect.fromLTWH(
      (src.width - side) / 2,
      (src.height - side) / 2,
      side.toDouble(),
      side.toDouble(),
    );
    const out = 320.0;
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawImageRect(
      src,
      srcRect,
      const Rect.fromLTWH(0, 0, out, out),
      Paint()..filterQuality = FilterQuality.medium,
    );
    final squared = await recorder.endRecording().toImage(
      out.toInt(),
      out.toInt(),
    );
    final data = await squared.toByteData(format: ui.ImageByteFormat.png);
    src.dispose();
    squared.dispose();
    return base64Encode(data!.buffer.asUint8List());
  }

  static Future<void> pick({
    required BuildContext context,
    required EditProfileBloc cubit,
    required Future<Uint8List?> Function() reader,
  }) async {
    if (cubit.state.isPickingPhoto) return;
    cubit.setPickingPhoto(true);
    try {
      final bytes = await reader();
      if (bytes == null) return;
      String encoded;
      try {
        encoded = await encode(bytes);
      } catch (e) {
        if (bytes.length > 700 * 1024) rethrow;
        encoded = base64Encode(bytes);
      }
      cubit.updatePhoto(encoded);
    } catch (e) {
      if (context.mounted) {
        AppSnackBar.showError(
          context,
          title: 'Photo Upload Error',
          message: 'Could not load that image: $e',
        );
      }
    } finally {
      cubit.setPickingPhoto(false);
    }
  }

  static void showOptions(BuildContext context, EditProfileBloc cubit) {
    final colors = context.colors;
    if (!isMobile) {
      pick(
        context: context,
        cubit: cubit,
        reader: () async {
          final file = await FilePicker.pickFile(
            dialogTitle: 'Select a profile photo',
            type: FileType.image,
          );
          return file?.readAsBytes();
        },
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: colors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              ListTile(
                leading: Icon(
                  Icons.photo_library_outlined,
                  color: colors.textPrimary,
                ),
                title: Text(
                  'Choose from gallery',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  pick(
                    context: context,
                    cubit: cubit,
                    reader: () async => (await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    ))?.readAsBytes(),
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.photo_camera_outlined,
                  color: colors.textPrimary,
                ),
                title: Text(
                  'Take a photo',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  pick(
                    context: context,
                    cubit: cubit,
                    reader: () async => (await ImagePicker().pickImage(
                      source: ImageSource.camera,
                    ))?.readAsBytes(),
                  );
                },
              ),
              if (cubit.state.photoBase64 != null)
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                  ),
                  title: const Text(
                    'Remove photo',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    cubit.removePhoto();
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
