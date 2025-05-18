import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class WorkoutTimerScreen extends StatefulWidget {
  final List<String> exerciseNames;
  const WorkoutTimerScreen({Key? key, required this.exerciseNames})
      : super(key: key);

  @override
  State<WorkoutTimerScreen> createState() => _WorkoutTimerScreenState();
}

class _WorkoutTimerScreenState extends State<WorkoutTimerScreen> {
  int _timer = 10;
  int _exerciseIndex = 0;
  Timer? _countdownTimer;
  String _phase = 'ready'; // 'ready', 'exercise', 'rest'
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _speakPhaseIntro();
    startTimer();
  }

  Future<void> _speak(String text) async {
    await _flutterTts.stop();
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.speak(text);
  }

  Future<void> _speakPhaseIntro() async {
    String message = "";
    if (_phase == 'ready') {
      message = "Ready to go! ${widget.exerciseNames[_exerciseIndex]} for 30 seconds.";
    } else if (_phase == 'exercise') {
      message = "Start ${widget.exerciseNames[_exerciseIndex]} for 30 seconds.";
    } else if (_phase == 'rest') {
      if (_exerciseIndex < widget.exerciseNames.length - 1) {
        message = "Rest for 10 seconds. Next: ${widget.exerciseNames[_exerciseIndex + 1]}";
      } else {
        message = "Rest for 10 seconds.";
      }
    }
    await _speak(message);
  }

  void startTimer() {
    int duration = _phase == 'ready' || _phase == 'rest' ? 10 : 30;
    _timer = duration;

    _speakPhaseIntro();

    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      setState(() {
        _timer--;
      });

      // Countdown voice for last 3 seconds
      if (_timer <= 3 && _timer > 0) {
        await _speak("$_timer");
      }

      if (_timer == 0) {
        _countdownTimer?.cancel();
        nextPhase();
      }
    });
  }

  void nextPhase() {
    if (_phase == 'ready') {
      _phase = 'exercise';
    } else if (_phase == 'exercise') {
      _phase = 'rest';
    } else if (_phase == 'rest') {
      if (_exerciseIndex < widget.exerciseNames.length - 1) {
        _exerciseIndex++;
        _phase = 'exercise';
      } else {
        _speak("Workout complete! Great job.");
        Navigator.pop(context);
        return;
      }
    }
    startTimer();
  }

  void goToNextExercise() {
    if (_exerciseIndex < widget.exerciseNames.length - 1) {
      _exerciseIndex++;
      _phase = 'exercise';
      startTimer();
      setState(() {});
    }
  }

  void goToPreviousExercise() {
    if (_exerciseIndex > 0) {
      _exerciseIndex--;
      _phase = 'exercise';
      startTimer();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String mainText = _phase == 'ready'
        ? 'READY TO GO!'
        : _phase == 'exercise'
        ? widget.exerciseNames[_exerciseIndex]
        : 'REST';

    String? nextExerciseText;
    if (_phase == 'rest' &&
        _exerciseIndex < widget.exerciseNames.length - 1) {
      nextExerciseText = "Next: ${widget.exerciseNames[_exerciseIndex + 1]}";
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(),
            Text(
              mainText,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (nextExerciseText != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  nextExerciseText,
                  style: const TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            const SizedBox(height: 40),
            Text(
              _timer.toString().padLeft(2, '0'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 60,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _exerciseIndex > 0 ? goToPreviousExercise : null,
                    icon: const Icon(Icons.arrow_back_ios),
                    color: Colors.white,
                    iconSize: 32,
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Quit"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: _exerciseIndex < widget.exerciseNames.length - 1
                        ? goToNextExercise
                        : null,
                    icon: const Icon(Icons.arrow_forward_ios),
                    color: Colors.white,
                    iconSize: 32,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
