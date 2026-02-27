import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class OradeaVideoWidget extends StatefulWidget {
  /// dacă e true, utilizatorul poate apăsa oriunde pe video pentru a activa/dezactiva sunetul
  final bool enableTapToToggleSound;

  const OradeaVideoWidget({
    Key? key,
    this.enableTapToToggleSound = false,
  }) : super(key: key);

  @override
  State<OradeaVideoWidget> createState() => _OradeaVideoWidgetState();
}

class _OradeaVideoWidgetState extends State<OradeaVideoWidget> {
  late VideoPlayerController _controller;
  bool _isMuted = true;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/images/oradea_video.mp4')
      ..initialize().then((_) {
        _controller
          ..setLooping(true)
          ..setVolume(0)
          ..play();

        setState(() {}); // reîmprospătează UI-ul după inițializare
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0 : 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return GestureDetector(
      onTap: widget.enableTapToToggleSound ? _toggleMute : null,
      child: Stack(
        children: [
          // 🔹 Video — se scalează frumos
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller.value.size.width,
                  height: _controller.value.size.height,
                  child: VideoPlayer(_controller),
                ),
              ),
            ),
          ),

          // 🔹 Iconiță volum
          Positioned(
            bottom: 10,
            right: 10,
            child: GestureDetector(
              onTap: _toggleMute,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(8),
                child: Icon(
                  _isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
