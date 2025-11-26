import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:window_manager/window_manager.dart';
import 'package:path/path.dart' as path;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ИНИЦИАЛИЗАЦИЯ MEDIA KIT — обязательно!
  MediaKit.ensureInitialized();

  // Настройка окна Windows
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = WindowOptions(
    size: const Size(1920, 1080),
    center: true,
    backgroundColor: Colors.black,
    skipTaskbar: false,
    title: 'Random Video Player',
  );
  await windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setFullScreen(true);
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VideoPlayerScreen(),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late final Player _player;
  late final VideoController _videoController;
  bool _isInitialized = false;

  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadRandomVideo();
  }

  Future<void> _loadRandomVideo() async {
    try {
      final exePath = Platform.resolvedExecutable;
      final exeDir = Directory(path.dirname(exePath));

      final files = exeDir.listSync().where((file) {
        final ext = path.extension(file.path).toLowerCase();
        return ['.mp4', '.avi', '.mov', '.mkv'].contains(ext);
      }).toList();

      if (files.isEmpty) {
        throw Exception('Видео не найдены в папке: ${exeDir.path}');
      }

      final randomFile = files[Random().nextInt(files.length)];

      _player = Player();
      _videoController = VideoController(_player);

      await _player.open(Media(randomFile.path), play: true);

      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print(e.toString());
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(_errorMessage, style: const TextStyle(color: Colors.red)),
      );
    }

    if (!_isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Scaffold(
      body: Container(
        color: Colors.black,
        width: double.infinity,
        height: double.infinity,
        child: Video(controller: _videoController, fit: BoxFit.contain),
      ),
    );
  }
}
