import 'dart:ui';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:rusticgram/Public/app_assets.dart';
import 'package:rusticgram/Public/app_colors.dart';

class GridImageItem extends StatefulWidget {
  final String imageUrl;
  final bool blurStatus;

  const GridImageItem({super.key, required this.imageUrl, required this.blurStatus});

  @override
  State<GridImageItem> createState() => _GridImageItemState();
}

class _GridImageItemState extends State<GridImageItem> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Stack(
      fit: StackFit.expand,
      alignment: AlignmentDirectional.bottomEnd,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          clipBehavior: Clip.hardEdge,
          child: ImageFiltered(
            enabled: widget.blurStatus,
            imageFilter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
            child: SizedBox(
              width: 100,
              height: 100,
              child: ExtendedImage.network(
                widget.imageUrl,
                cacheWidth: 200,
                cacheHeight: 200,
                fit: BoxFit.cover,
                loadStateChanged: (progress) {
                  if (progress.extendedImageLoadState == LoadState.loading) {
                    return Center(child: Image.asset(AppAssets.cameraIcon, width: 26.0, height: 26.0));
                  } else if (progress.extendedImageLoadState == LoadState.failed) {
                    return const Icon(Icons.broken_image_rounded, color: AppColors.grey);
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
        Visibility(visible: widget.blurStatus, child: Align(alignment: Alignment.bottomRight, child: Image.asset(AppAssets.premiumIcon, width: 50.0, height: 50.0))),
      ],
    );
  }
}
