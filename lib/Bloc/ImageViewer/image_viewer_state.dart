part of 'image_viewer_cubit.dart';

class ImageViewerState {
  final DataState dataState;
  final List<DownloadLinks> imageList;
  final int currentImageIndex;
  final String errorMessage;

  const ImageViewerState({required this.dataState, required this.imageList, required this.currentImageIndex, required this.errorMessage});

  factory ImageViewerState.initial() => ImageViewerState(dataState: DataState.initial, imageList: [], currentImageIndex: 0, errorMessage: "");

  ImageViewerState copyWith({DataState? dataState, List<DownloadLinks>? imageList, int? currentImageIndex, String? errorMessage}) => ImageViewerState(
    dataState: dataState ?? this.dataState,
    imageList: imageList ?? this.imageList,
    currentImageIndex: currentImageIndex ?? this.currentImageIndex,
    errorMessage: errorMessage ?? this.errorMessage,
  );
}
