import 'dart:async';

import 'package:flutter/material.dart';
import 'package:record/record.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MicPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MicPage extends StatefulWidget {
  const MicPage({super.key});

  @override
  State<MicPage> createState() => _MicPageState();
}

class _MicPageState extends State<MicPage> {
  Record recording = Record();
  Timer? timer;

  double vol = 0.0;
  double minVol = -45.0;

  startTimer() async {
    timer ??= Timer.periodic(
        const Duration(milliseconds: 50), (timer) => updateVolume());
  }

  updateVolume() async {
    Amplitude ampl = await recording.getAmplitude();
    if (ampl.current > minVol) {
      setState(() {
        vol = (ampl.current - minVol) / minVol;
      });
    }
  }

  int volume0to(int maxVol) {
    return (vol * maxVol).round().abs();
  }

  Future<bool> startRecording() async {
    if (await recording.hasPermission()) {
      if (!await recording.isRecording()) {
        await recording.start();
      }
      startTimer();
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Future<bool> recordFutureBuilder =
        Future<bool>.delayed(const Duration(seconds: 3), (() async {
      return startRecording();
    }));

    return FutureBuilder(
      future: recordFutureBuilder,
      builder: (context, AsyncSnapshot<bool> snapshot) {
        return Scaffold(
          body: Center(
            child: snapshot.hasData
                ? Text(
                    "VOLUME\n${volume0to(100)}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 42, fontWeight: FontWeight.bold),
                  )
                : const CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
