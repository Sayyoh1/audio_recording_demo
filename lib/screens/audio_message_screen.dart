import 'dart:async';
import 'dart:io';
import 'package:audio_recording/source/constants/app_colors.dart';
import 'package:audio_recording/source/others/audio_visualizer.dart';
import 'package:audio_recording/source/others/recording_audio_visualizer.dart';
import 'package:audio_recording/source/widgets/audio_message_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';

class AudioMessageScreen extends StatefulWidget {
  const AudioMessageScreen({super.key});

  @override
  AudioMessageScreenState createState() => AudioMessageScreenState();
}

class AudioMessageScreenState extends State<AudioMessageScreen>
    with SingleTickerProviderStateMixin {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  final List<AudioMessage> _audioMessages = [];
  StreamSubscription? _recorderSubscription;
  StreamSubscription? _playerSubscription;
  List<double> _waveform = [];
  int _duration = 0;
  int? currentPlayingMessage;
  Timer? _timer;
  bool _isRecordable = false;
  String _timerString = "00:00,0";
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _player.openPlayer();
    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    _animation = Tween<double>(begin: 0.7, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    _recorderSubscription?.cancel();
    _playerSubscription?.cancel();
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _initializeRecorder() async {
    await _recorder.openRecorder();
    await _recorder.setSubscriptionDuration(const Duration(milliseconds: 10));
  }

  Future<void> _startRecording() async {
    if (await Permission.microphone.isGranted) {
      await _recorder.startRecorder(
        toFile: 'audio_${DateTime.now().millisecondsSinceEpoch}.aac',
      );
      _startTimer();
      _controller.repeat(reverse: true);
      _recorderSubscription = _recorder.onProgress!.listen((e) {
        if (e.decibels != null) {
          _duration += e.duration.inMicroseconds;
          setState(() {
            _waveform.add(e.decibels!);
          });
        }
      });
    } else if(await Permission.microphone.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Microphone permission is required to record audio.'),
      ));
    } else{
      Permission.microphone.request();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 1), (timer) {
      if(Duration(milliseconds: timer.tick).inSeconds >= 1){
        setState(() {
          _isRecordable = true;
        });
      }
      setState(() {
        _timerString =
            '${(Duration(milliseconds: timer.tick).inMinutes % 60).toString().padLeft(2, '0')}:${(Duration(milliseconds: timer.tick).inSeconds % 60).toString().padLeft(2, '0')},${(Duration(milliseconds: timer.tick).inMilliseconds % 1000) ~/ 100}';
      });
    });
  }

  Future<void> _stopRecording() async {
    var result = await _recorder.stopRecorder();
    if(_isRecordable){
      DateTime now = DateTime.now();
      String formattedTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
      final fileSize = await File(result!).length();
      final audioSize = 1024 * 1024 < fileSize
          ? '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB'
          : '${(fileSize / 1024).toStringAsFixed(1)} KB';
      List<String> divider = _timerString.split(",");
      List<String> divider1 = divider.first.split(":");
      int timer = int.parse(divider1.first) * 60 + int.parse(divider1.last);
      setState(() {
        _audioMessages.insert(
            0,
            AudioMessage(
                path: result,
                waveform: _waveform,
                duration: _duration,
                timer: timer,
                audioSize: audioSize,
                recordedTime: formattedTime));
      });
    }else{
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Hold for at least 1 s to record audio.'),
      ));
    }
    _duration = 0;
    _waveform = [];
    _isRecordable = false;
    _stopTimer();
    _controller.stop();
    _recorderSubscription?.cancel();
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _timerString = '00:00,0';
    });
  }

  void _playCurrentRecording() async {
    if (_player.isPlaying) {
      await _player.pausePlayer();
      setState(() {
        _audioMessages[currentPlayingMessage!].audioState = AudioState.pause;
      });
    } else {
      await _player.resumePlayer();
      setState(() {
        _audioMessages[currentPlayingMessage!].audioState = AudioState.resume;
      });
    }
  }

  void _playOtherRecording(int index) async {
    await _player.stopPlayer();
    if (currentPlayingMessage != null) {
      setState(() {
        _audioMessages[currentPlayingMessage!].audioState = AudioState.stop;
      });
    }
    currentPlayingMessage = index;
    setState(() {
      _audioMessages[index].audioState = AudioState.start;
    });
    await _player.startPlayer(
        fromURI: _audioMessages[index].path,
        codec: Codec.aacADTS,
        whenFinished: () {
          setState(() {
            _audioMessages[index].audioState = AudioState.stop;
          });
          currentPlayingMessage = null;
        });
    if (!_audioMessages[index].beforeListened) {
      setState(() {
        _audioMessages[index].beforeListened = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Audio message chat',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        backgroundColor: AppColors.mainColor,
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        color: AppColors.secondaryColor,
        child: ListView.separated(
            reverse: true,
            itemBuilder: (context, index) => AudioMessageItem(
                  key: ValueKey(_audioMessages[index].path),
                  audioMessage: _audioMessages[index],
                  onClick: () async {
                    if (currentPlayingMessage != null) {
                      if (index == currentPlayingMessage) {
                        _playCurrentRecording();
                      } else {
                        _playOtherRecording(index);
                      }
                    } else {
                      _playOtherRecording(index);
                    }
                  },
                ),
            separatorBuilder: (context, index) => const SizedBox(
                  height: 7,
                ),
            itemCount: _audioMessages.length),
      ),
      bottomNavigationBar: Container(
        color: AppColors.mainColor,
        width: double.infinity,
        height: 55,
        alignment: Alignment.centerRight,
        child: Padding(
            padding: const EdgeInsets.only(left: 20, right: 13),
            child: Row(children: [
              DefaultTextStyle(
                  style: const TextStyle(color: AppColors.bottomIcons, fontSize: 14),
                  child: Text(_timerString)),
              const SizedBox(
                width: 20,
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: AppColors.bottomIcons, width: 2),
                    borderRadius: const BorderRadius.all(Radius.circular(5))),
                height: 40,
                width: 235,
                child: CustomPaint(
                  painter: AudioVisualizer(_waveform),
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(
                    width: 55,
                    height: 55,
                  ),
                  CustomPaint(
                    painter: CircularVisualizerPainter(_animation.value),
                    child: SizedBox(
                      width: _recorder.isRecording ? 55 : 0,
                      height: _recorder.isRecording ? 55 : 0,
                    ),
                  ),
                  SizedBox(
                    width: 30,
                    height: 30,
                    child: GestureDetector(
                      onLongPressStart: (_) async {
                        await Vibration.vibrate(duration: 50);
                        await _startRecording();
                      },
                      onLongPressEnd: (_) async {
                        if(await Permission.microphone.isGranted){
                          await _stopRecording();
                        }
                      },
                      child: Icon(
                        _recorder.isRecording
                            ? Icons.stop
                            : Icons.mic_none_outlined,
                        size: 30,
                        color: _recorder.isRecording ? Colors.white : AppColors.bottomIcons,
                      ),
                    ),
                  )
                ],
              )
            ])),
      ),
    );
  }
}

class AudioMessage {
  String? path;
  List<double>? waveform;
  AudioState audioState;
  int? duration;
  int? timer;
  String? audioSize;
  String? recordedTime;
  bool beforeListened;

  AudioMessage(
      {required this.path,
      required this.waveform,
      required this.duration,
      required this.timer,
      required this.audioSize,
      required this.recordedTime,
      this.beforeListened = false,
      this.audioState = AudioState.stop});
}

enum AudioState { start, pause, resume, stop }
