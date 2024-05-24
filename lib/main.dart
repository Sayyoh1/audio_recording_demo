import 'package:audio_recording/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transfer Animation',
      home: AudioMessageItem(
        waveform: [15, 15, 5, 4, 31, 21, 6, 5, 7],
        isPlaying: null,
        onClick: () {},
      ),
    );
  }
}

class AudioMessageItem extends StatelessWidget {
  Function() onClick;
  List<double>? _waveForm;
  bool? _isPlaying;

  AudioMessageItem(
      {super.key,
      required List<double> waveform,
      required bool? isPlaying,
      required this.onClick}) {
    _waveForm = waveform;
    _isPlaying = isPlaying;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.only(right: 5),
        alignment: Alignment.centerRight,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
                alignment: Alignment.topLeft,
                width: 240,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      topRight: Radius.circular(30)),
                  gradient: LinearGradient(colors: [
                    AppColors.audioMassageContainer0,
                    AppColors.audioMassageContainer1
                  ]),
                ),
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                            onTap: onClick,
                            child: Container(
                              width: 46,
                              height: 46,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(23),
                                  color: Colors.white),
                              child: Icon(
                                _isPlaying == true
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: AppColors.audioMassageContainer0,
                                size: 35,
                              ),
                            )),
                        Padding(
                            padding: EdgeInsets.only(left: 10, top: 2),
                            child: Column(
                              children: [
                                Container(
                                  color: Colors.green,
                                  width: 150,
                                  height: 26,
                                ),
                                // child: CustomPaint(
                                //   painter: AudioVisualizer(_waveForm!),
                                //   child: Container(
                                //     color: Colors.green,
                                //     width: double.infinity,
                                //     height: 40,
                                //   ),
                                // ),
                                Row(
                                  children: [
                                    Text("1.5 MB - 00:37", style: TextStyle(fontSize: 11),),
                                    Container(
                                      width: 2,
                                      height: 2,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(1)
                                      ),
                                    )
                                  ],
                                )
                              ],
                            ))
                      ],
                    ))),
            Container(
                width: 10,
                height: 98,
                decoration: BoxDecoration(
                    color: AppColors.secondaryColor,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                    )))
          ],
        ));
  }
}

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

// import 'dart:async';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_sound/flutter_sound.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:vibration/vibration.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Audio recorder demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const AudioRecorderPlayer(),
//     );
//   }
// }
//
// class AudioRecorderPlayer extends StatefulWidget {
//   const AudioRecorderPlayer({super.key});
//
//   @override
//   _AudioRecorderPlayerState createState() => _AudioRecorderPlayerState();
// }
//
// class _AudioRecorderPlayerState extends State<AudioRecorderPlayer> {
//   final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
//   final FlutterSoundPlayer _player = FlutterSoundPlayer();
//   final AudioPlayer _audioPlayer = AudioPlayer();
//   bool _isRecording = false;
//   List<AudioMessage> audioMessages = [];
//   StreamSubscription? _recorderSubscription;
//   StreamSubscription? _playerSubscription;
//   List<double> _waveform = [];
//   int? currentPlayingMessage;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeRecorder();
//     _player.openPlayer();
//   }
//
//   @override
//   void dispose() {
//     _recorder.closeRecorder();
//     _player.closePlayer();
//     _recorderSubscription?.cancel();
//     _playerSubscription?.cancel();
//     super.dispose();
//   }
//
//   Future<void> _initializeRecorder() async {
//     await _recorder.openRecorder();
//     await _recorder.setSubscriptionDuration(const Duration(milliseconds: 10));
//   }
//
//   Future<void> _startRecording() async {
//     await Permission.microphone.request();
//     if (await Permission.microphone.isGranted) {
//       await _recorder.startRecorder(
//         toFile: 'audio_${DateTime
//             .now()
//             .millisecondsSinceEpoch}.aac',
//       );
//       _recorderSubscription = _recorder.onProgress!.listen((e) {
//         if (e.decibels != null) {
//           setState(() {
//             _waveform.add(e.decibels!);
//           });
//         }
//       });
//       setState(() {
//         _isRecording = true;
//       });
//     } else {
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//         content: Text('Microphone permission is required to record audio.'),
//       ));
//     }
//   }
//
//   Future<void> _stopRecording() async {
//     var result = await _recorder.stopRecorder();
//     setState(() {
//       _isRecording = false;
//       if (result != null) {
//         audioMessages.insert(
//             0, AudioMessage(path: result, waveform: _waveform));
//         _waveform = [];
//       }
//     });
//     _recorderSubscription?.cancel();
//   }
//
//   void _playCurrentRecording() async {
//     if (_player.isPlaying) {
//       await _player.pausePlayer();
//       setState(() {
//         audioMessages[currentPlayingMessage!]._isPlaying = false;
//       });
//     } else {
//       await _player.resumePlayer();
//       setState(() {
//         audioMessages[currentPlayingMessage!]._isPlaying = true;
//       });
//     }
//     // await _player.startPlayer(
//     //   fromURI: audioMessages[index]._path,
//     //   codec: Codec.aacADTS,
//     // );
//     // _playerSubscription = _player.onProgress!.listen(onDone: (){
//     //   setState(() {
//     //     audioMessages[currentPlayingMessage!]._isPlaying = false;
//     //   });
//     // },(_) {});
//   }
//
//   void _playOtherRecording(int index) async {
//     await _player.stopPlayer();
//     if (currentPlayingMessage != null) {
//       setState(() {
//         audioMessages[currentPlayingMessage!]._isPlaying = false;
//       });
//     }
//     currentPlayingMessage = index;
//     setState(() {
//       audioMessages[index]._isPlaying = true;
//     });
//     await _player.startPlayer(
//         fromURI: audioMessages[index]._path,
//         codec: Codec.aacADTS,
//         whenFinished: () {
//           setState(() {
//             audioMessages[index]._isPlaying = false;
//           });
//           currentPlayingMessage = null;
//         });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Audio message chat'),
//         backgroundColor: Colors.blue,
//       ),
//       body: Container(
//         color: Colors.blueGrey,
//         child: ListView.separated(
//             reverse: true,
//             itemBuilder: (context, index) =>
//                 AudioMessageItem(
//                   waveform: audioMessages[index]._waveform!,
//                   isPlaying: audioMessages[index]._isPlaying!,
//                   onClick: () async {
//                     if (currentPlayingMessage != null) {
//                       if (index == currentPlayingMessage) {
//                         _playCurrentRecording();
//                       } else {
//                         _playOtherRecording(index);
//                       }
//                     } else {
//                       _playOtherRecording(index);
//                     }
//                   },
//                 ),
//             separatorBuilder: (context, index) =>
//             const SizedBox(
//               height: 5,
//             ),
//             itemCount: audioMessages.length),
//       ),
//       bottomNavigationBar: Container(
//         color: Colors.blue,
//         width: double.infinity,
//         height: 70,
//         alignment: Alignment.centerRight,
//         child: Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16),
//             child: Row(children: [
//               Container(color: Colors.green, width: 60, height: 40, child: Text("00.0"),),
//               Expanded(child:  Container(color: Colors.amberAccent, height: 40,
//               child: CustomPaint(painter: AudioVisualizer(_waveform),),
//               )),
//               Container(width: 30,
//                   height: 30,
//                   color: Colors.purple,
//                   child: GestureDetector(
//                     onLongPressStart: (_) async {
//                       await Vibration.vibrate(duration: 50);
//                       await _startRecording();
//                     },
//                     onLongPressEnd: (_) async {
//                       _stopRecording();
//                     },
//                     child: Icon(_recorder.isRecording ? Icons.stop : Icons.mic),
//                   ), )
//             ])
//         ),
//       ),
//     );
//   }
// }
//

//
//
//
//
// class AudioMessage {
//   String? _path;
//   List<double>? _waveform;
//   bool? _isPlaying;
//
//   AudioMessage({required String path,
//     required List<double> waveform,
//     bool isPlaying = false}) {
//     _path = path;
//     _waveform = waveform;
//     _isPlaying = isPlaying;
//   }
// }

class AudioVisualizer extends CustomPainter {
  final List<double> waveform;

  AudioVisualizer(this.waveform);

  @override
  void paint(Canvas canvas, Size size) {
    double width = size.width;
    double height = size.height;
    double centerY = height / 2;
    double barWidth = width / waveform.length;

    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < waveform.length; i++) {
      double amplitude = waveform[i] / 80 * height;
      double x = width - (i * barWidth); // Start from the right and move left
      double y1 = centerY - amplitude / 2;
      double y2 = centerY + amplitude / 2;

      canvas.drawLine(Offset(x, y1), Offset(x, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
