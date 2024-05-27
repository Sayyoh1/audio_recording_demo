// import 'package:flutter/material.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Transfer Animation',
//       home: TransferAnimationDemo(),
//     );
//   }
// }
//
// class TransferAnimationDemo extends StatefulWidget {
//   @override
//   _TransferAnimationDemoState createState() => _TransferAnimationDemoState();
// }
//
// class _TransferAnimationDemoState extends State<TransferAnimationDemo>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _widthAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(seconds: 3),
//       vsync: this,
//     );
//
//     _widthAnimation = Tween<double>(
//       begin: 100.0,
//       end: 0.0,
//     ).animate(CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeInOut,
//     ));
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Decreasing Width Transfer Animation'),
//       ),
//       body: Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           Container(width: 20,color: Colors.amber,),
//           Spacer(),
//           AnimatedBuilder(
//           animation: _controller,
//           builder: (context, child) {
//             return Container(
//               width: _widthAnimation.value,
//               height: 100,
//               color: Colors.blue,
//             );
//           },
//         ),]
//       ),
//       floatingActionButton: Row(
//         mainAxisAlignment: MainAxisAlignment.end,
//         children: [
//           FloatingActionButton(
//             onPressed: () {
//               if (_controller.isAnimating) {
//                 _controller.stop(canceled: false);
//               } else{
//                 if(_controller.isCompleted){
//                   _controller..reset()..forward();
//                 }else{
//                   _controller.forward();
//
//                 }
//               }
//             },
//             child: AnimatedBuilder(
//               animation: _controller,
//               builder: (context, child) {
//                 return Icon(
//                     _controller.isAnimating ? Icons.pause : Icons.play_arrow);
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:io';
import 'package:audio_recording/source/constants/app_colors.dart';
import 'package:audio_recording/source/others/audio_visualizer.dart';
import 'package:audio_recording/source/widgets/audio_message_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vibration/vibration.dart';

class AudioMessageScreen extends StatefulWidget {
  const AudioMessageScreen({super.key});

  @override
  _AudioMessageScreenState createState() => _AudioMessageScreenState();
}

class _AudioMessageScreenState extends State<AudioMessageScreen> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  final List<AudioMessage> _audioMessages = [];
  StreamSubscription? _recorderSubscription;
  StreamSubscription? _playerSubscription;
  List<double> _waveform = [];
  int _duration = 0;
  int? currentPlayingMessage;
  Timer? _timer;
  String _timerString = "00.0";

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    _player.openPlayer();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    _recorderSubscription?.cancel();
    _playerSubscription?.cancel();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initializeRecorder() async {
    await _recorder.openRecorder();
    await _recorder.setSubscriptionDuration(const Duration(milliseconds: 10));
  }

  Future<void> _startRecording() async {
    await Permission.microphone.request();
    if (await Permission.microphone.isGranted) {
      await _recorder.startRecorder(
        toFile: 'audio_${DateTime.now().millisecondsSinceEpoch}.aac',
      );
      _startTimer();
      _recorderSubscription = _recorder.onProgress!.listen((e) {
        if (e.decibels != null) {
          _duration += e.duration.inMicroseconds;
          setState(() {
            _waveform.add(e.decibels!);
          });
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Microphone permission is required to record audio.'),
      ));
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 1), (timer) {
      setState(() {
        _timerString =
            (Duration(milliseconds: timer.tick).inMilliseconds / 1000)
                .toStringAsFixed(1);
      });
    });
  }

  Future<void> _stopRecording() async {
    var result = await _recorder.stopRecorder();
    DateTime now = DateTime.now();
    String formattedTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    final fileSize = await File(result!).length();
    final audioSize = 1024 * 1024 < fileSize
        ? '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB'
        : '${(fileSize / 1024).toStringAsFixed(1)} KB';
    setState(() {
      if (result != null) {
        _audioMessages.insert(
            0,
            AudioMessage(
                path: result,
                waveform: _waveform,
                duration: _duration,
                timer: double.parse(_timerString).toInt(),
                audioSize: audioSize,
                recordedTime: formattedTime));
        _duration = 0;
        _waveform = [];
      }
    });
    _stopTimer();
    _recorderSubscription?.cancel();
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _timerString = '00.0';
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
    if(!_audioMessages[index].beforeListened){
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
        padding: EdgeInsets.symmetric(vertical: 10),
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
            padding: const EdgeInsets.only(left: 16, right: 13),
            child: Row(children: [
              DefaultTextStyle(
                  style: TextStyle(color: AppColors.bottomIcons, fontSize: 14),
                  child: Text(_timerString)),
              SizedBox(
                width: 15,
              ),
              Expanded(
                  child: Container(
                decoration: BoxDecoration(
                    border: Border.all(color: AppColors.bottomIcons, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                height: 40,
                child: CustomPaint(
                  painter: AudioVisualizer(_waveform),
                ),
              )),
              SizedBox(
                width: 15,
              ),
              Container(
                width: 30,
                height: 30,
                child: GestureDetector(
                  onLongPressStart: (_) async {
                    await Vibration.vibrate(duration: 50);
                    await _startRecording();
                  },
                  onLongPressEnd: (_) async {
                    _stopRecording();
                  },
                  child: Icon(
                    _recorder.isRecording
                        ? Icons.stop
                        : Icons.mic_none_outlined,
                    size: 30,
                    color: AppColors.bottomIcons,
                  ),
                ),
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

enum AudioState{
  start, pause, resume, stop
}
