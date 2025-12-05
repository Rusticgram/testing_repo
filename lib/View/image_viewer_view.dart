import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:rusticgram/Bloc/ImageViewer/image_viewer_cubit.dart';
import 'package:rusticgram/Config/content_state.dart';
import 'package:rusticgram/Public/app_colors.dart';
import 'package:rusticgram/Route/route_manager.dart';
import 'package:rusticgram/Utility/common_alert_dialog.dart';

class ImageViewerView extends StatelessWidget {
  const ImageViewerView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ImageViewerCubit, ImageViewerState>(
      listener: (context, state) => _downloadStatusAlert(context, state: state),
      builder: (context, state) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) => RouteManager(context).popBack(),
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              onPressed: () {
                if (state.dataState != DataState.loading) {
                  RouteManager(context).popBack();
                }
              },
              icon: const Icon(Icons.arrow_back, color: AppColors.body3Color),
            ),
            title: Text("Memory ${state.currentImageIndex + 1}", style: Theme.of(context).textTheme.titleSmall),
            actions: [
              IconButton(
                onPressed: () => BlocProvider.of<ImageViewerCubit>(context).processImagesWithWatermark(false),
                icon: state.dataState == DataState.loading ? const SizedBox(width: 24.0, height: 24.0, child: CircularProgressIndicator()) : const Icon(Icons.download, size: 24.0),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: IconButton(onPressed: () => BlocProvider.of<ImageViewerCubit>(context).processImagesWithWatermark(true), icon: const Icon(Icons.share_outlined, size: 24.0)),
              ),
            ],
          ),
          body: _buildPageView(context, state: state),
        ),
      ),
    );
  }

  Widget _buildPageView(BuildContext context, {required ImageViewerState state}) {
    return PhotoViewGallery.builder(
      pageController: BlocProvider.of<ImageViewerCubit>(context).pageController,
      backgroundDecoration: BoxDecoration(color: AppColors.secondaryColor),
      itemCount: state.imageList.length,
      onPageChanged: BlocProvider.of<ImageViewerCubit>(context).checkingCurrentIndex,
      builder: (BuildContext context, int index) {
        return PhotoViewGalleryPageOptions(
          minScale: PhotoViewComputedScale.contained * 0.95,
          maxScale: PhotoViewComputedScale.contained * 5,
          imageProvider: ExtendedNetworkImageProvider(state.imageList[index].downloadLink, cache: true),
          initialScale: PhotoViewComputedScale.contained * 0.95,
          heroAttributes: PhotoViewHeroAttributes(tag: state.imageList[index].fileName),
        );
      },
    );
  }

  void _downloadStatusAlert(BuildContext context, {required ImageViewerState state}) {
    if (state.dataState == DataState.success || state.dataState == DataState.failure) {
      String title = "Download Successful";
      String content = "Downloading Image Successful";
      if (state.dataState == DataState.failure) {
        title = "Download Failed";
        content = "Downloading Image Failed. Please Try Again.";
      }
      showDialog(
        context: context,
        builder: (_) => DownloadStatus(title: title, content: content),
      );
      Future.delayed(const Duration(seconds: 3), () {
        if (context.mounted) RouteManager(context).popBack();
      });
    }
  }
}
