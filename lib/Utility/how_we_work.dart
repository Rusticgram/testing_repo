import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rusticgram/Public/app_assets.dart';
import 'package:rusticgram/Public/app_colors.dart';
import 'package:rusticgram/Route/route_manager.dart';
import 'package:video_player/video_player.dart';

class HowWeWorkView extends StatefulWidget {
  const HowWeWorkView({super.key});

  @override
  State<HowWeWorkView> createState() => _HowWeWorkViewState();
}

class _HowWeWorkViewState extends State<HowWeWorkView> {
  bool _visibility = false;
  bool _isPlaying = true;
  bool _isCompleted = false;
  Duration? currentPosition;
  final VideoPlayerController _videoPlayerController = VideoPlayerController.networkUrl(AppAssets.howWeWorkVideo);

  @override
  void initState() {
    _initialization();
    super.initState();
  }

  Future<void> _initialization() async {
    await _videoPlayerController.initialize();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    await _videoPlayerController.play();
    _videoPlayerController.addListener(() async {
      currentPosition = await _videoPlayerController.position;
      if (currentPosition != null) {
        if (currentPosition!.inSeconds >= 53) {
          _isCompleted = true;
          _isPlaying = false;
          _controllerVisibility();
        }
      }
    });
  }

  void _controllerVisibility() {
    if (!mounted) return;
    setState(() {
      if (!_isPlaying) {
        _visibility = true;
      } else {
        _visibility = !_visibility;
      }
    });

    if (_visibility && _isPlaying && !_isCompleted) {
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;
        setState(() {
          _visibility = false;
        });
      });
    }
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: true,
    onPopInvokedWithResult: (_, d) async {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    },
    child: SafeArea(child: Scaffold(body: _videoPlayer(context))),
  );

  Widget _videoPlayer(BuildContext context) => InkWell(
    splashColor: Colors.transparent,
    onTap: _controllerVisibility,
    child: SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [AspectRatio(aspectRatio: 16 / 8.8, child: VideoPlayer(_videoPlayerController)), Visibility(visible: _visibility, child: _videoController(context))],
      ),
    ),
  );

  Widget _videoController(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            children: [
              IconButton(
                onPressed: () async {
                  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
                  if (context.mounted) RouteManager(context).popBack();
                },
                style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(AppColors.primaryColor.withValues(alpha: 0.5))),
                icon: const Icon(Icons.arrow_back, color: AppColors.secondaryColor),
              ),
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 300.0,
                child: Row(
                  mainAxisAlignment: _isCompleted ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (!_isCompleted)
                      IconButton(
                        onPressed: () => _videoPlayerController.seekTo(Duration(seconds: currentPosition!.inSeconds - 5)),
                        style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(AppColors.primaryColor.withValues(alpha: 0.5))),
                        icon: const Icon(Icons.fast_rewind, color: AppColors.secondaryColor),
                      ),
                    IconButton(
                      onPressed: _currentButtonFunction,
                      style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(AppColors.primaryColor.withValues(alpha: 0.5))),
                      icon: Icon(_currentButtonState(), color: AppColors.secondaryColor),
                    ),
                    if (!_isCompleted)
                      IconButton(
                        onPressed: () => _videoPlayerController.seekTo(Duration(seconds: currentPosition!.inSeconds + 5)),
                        style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(AppColors.primaryColor.withValues(alpha: 0.5))),
                        icon: const Icon(Icons.fast_forward, color: AppColors.secondaryColor),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox.shrink(),
        ],
      ),
    );
  }

  IconData _currentButtonState() {
    if (_isCompleted) {
      return Icons.replay;
    } else if (_isPlaying) {
      return Icons.pause;
    } else {
      return Icons.play_arrow;
    }
  }

  void _currentButtonFunction() {
    if (_isPlaying) {
      _videoPlayerController.pause();
      _isPlaying = false;
    } else {
      _videoPlayerController.play();
      _isPlaying = true;
      if (_isCompleted) {
        _isCompleted = false;
      }
    }
    _controllerVisibility();
  }
}
