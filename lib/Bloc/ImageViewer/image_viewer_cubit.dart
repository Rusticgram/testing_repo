import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:no_screenshot/no_screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rusticgram/Bloc/OrderDetails/order_details_cubit.dart';
import 'package:rusticgram/Config/content_state.dart';
import 'package:rusticgram/Model/local_data_model.dart';
import 'package:rusticgram/Model/order_details_model.dart';
import 'package:rusticgram/Public/common_function.dart';
import 'package:rusticgram/Public/constant.dart';
import 'package:share_plus/share_plus.dart';

part 'image_viewer_state.dart';

class ImageViewerCubit extends Cubit<ImageViewerState> {
  final PageController pageController = PageController(initialPage: initialImageIndex);
  final _downloadImageChannel = MethodChannel('download_image');

  final NoScreenshot _noScreenShot = NoScreenshot.instance;

  final OrderDetailsCubit orderDetailsCubit;
  ImageViewerCubit(this.orderDetailsCubit) : super(ImageViewerState.initial()) {
    _noScreenShot.screenshotOff();
    List<DownloadLinks> imageList = orderDetailsCubit.state.orderDetails.imageLinks.downloadLinks;
    if (!orderDetailsCubit.state.orderDetails.paymentDetails.paymentStatus) {
      if (imageList.length > 5) {
        imageList = imageList.getRange(0, 5).toList();
      }
    }
    emit(state.copyWith(imageList: imageList, currentImageIndex: initialImageIndex));
  }

  void checkingCurrentIndex(int index) => emit(state.copyWith(currentImageIndex: index));

  Future<void> processImagesWithWatermark(bool share) async {
    try {
      String imageUrl = state.imageList[state.currentImageIndex].downloadLink;
      String imageName = state.imageList[state.currentImageIndex].fileName;
      final Uint8List imageFile = (await NetworkAssetBundle(Uri.parse(imageUrl)).load(imageUrl)).buffer.asUint8List();
      final ByteData data = await rootBundle.load('assets/watermark.png');
      final Directory tempDir = await getTemporaryDirectory();
      final String watermarkPath = '${tempDir.path}/watermark.png';
      final File watermarkFile = File(watermarkPath);
      await watermarkFile.writeAsBytes(data.buffer.asUint8List());
      final Uint8List? processedBytes = await _downloadImageChannel.invokeMethod<Uint8List>('download_image', {'imageBytes': imageFile, 'watermarkPath': watermarkPath});
      if (processedBytes != null && processedBytes.isNotEmpty) {
        if (share) {
          _shareImage(imageFile: processedBytes, imageName: imageName);
        } else {
          Directory dir = await getApplicationDocumentsDirectory();
          File finalImage = await File("${dir.path}/$imageName").writeAsBytes(processedBytes);
          await appDatabase.insertRecordImageTable(
            imageDBModel: ImageDBModel(imageName: imageName, imagePath: finalImage.path),
          );
          emit(state.copyWith(dataState: DataState.success));
        }
        emit(state.copyWith(dataState: DataState.loaded));
      } else {
        emit(state.copyWith(errorMessage: "Something went wrong. Please try again.", dataState: DataState.failure));
        _resettingStatus();
      }
    } on PlatformException catch (exception, stack) {
      CommonFunction.recordingError(
        exception: exception,
        stack: stack,
        functionName: "_processImagesWithWatermark()",
        error: "Something went wrong while adding watermark to the image",
        input: "",
      );
      emit(state.copyWith(errorMessage: "Something went wrong. Please try again.", dataState: DataState.failure));
      _resettingStatus();
    }
  }

  Future<void> _shareImage({required Uint8List imageFile, required String imageName}) async {
    XFile finalFile = XFile.fromData(imageFile, mimeType: "image/jpeg", name: imageName);
    await Share.shareXFiles(
      [finalFile],
      text:
          "Hey sharing my nostalgia from the Rusticgram app. Check it out!\nGive life to your old photos with rusticgram with my referral, it's free!\n\nhttps://efm6q.test-app.link/KdbvCjjTFUb",
    );
  }

  void _resettingStatus() => Future.delayed(const Duration(seconds: 2), () => emit(state.copyWith(errorMessage: "", dataState: DataState.loaded)));

  @override
  Future<void> close() {
    _noScreenShot.screenshotOn();
    return super.close();
  }
}
