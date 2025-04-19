import 'package:flutter/material.dart';

import '../../domain/models/practice_item_model.dart';

/// Defines all possible stages in the practice flow
enum PracticeStage {
  prompt,
  recording,
  feedback,
  practice,
  complete,
}

/// Defines the states of the voice recording
enum RecordingState {
  ready,
  recording,
  recorded,
}

/// Provider class to manage state for the Practice Mistakes screen
class PracticeMistakesProvider extends ChangeNotifier {
  /// Current stage in the practice flow
  PracticeStage _currentStage = PracticeStage.prompt;
  
  /// Current state of the recording process
  RecordingState _recordingState = RecordingState.ready;
  
  /// Current practice item being worked on
  PracticeItemModel _currentItem = PracticeItemModel.mockItem();
  
  /// Index of the current practice item in the sequence
  int _currentItemIndex = 2; // For UI display (3/8)
  
  /// Total number of practice items in the sequence
  int _totalItems = 8;

  /// Getters for the state variables
  PracticeStage get currentStage => _currentStage;
  RecordingState get recordingState => _recordingState;
  PracticeItemModel get currentItem => _currentItem;
  int get currentItemIndex => _currentItemIndex;
  int get totalItems => _totalItems;
  
  /// String representation of the recording state
  String get recordingStateString {
    switch (_recordingState) {
      case RecordingState.ready:
        return 'ready';
      case RecordingState.recording:
        return 'recording';
      case RecordingState.recorded:
        return 'recorded';
    }
  }
  
  /// String representation of the current stage
  String get stageString {
    switch (_currentStage) {
      case PracticeStage.prompt:
        return 'prompt';
      case PracticeStage.recording:
        return 'recording';
      case PracticeStage.feedback:
        return 'feedback';
      case PracticeStage.practice:
        return 'practice';
      case PracticeStage.complete:
        return 'complete';
    }
  }

  /// Handle the record button press
  void handleRecord() {
    if (_currentStage == PracticeStage.prompt) {
      _currentStage = PracticeStage.recording;
      _recordingState = RecordingState.recording;
      notifyListeners();
      return;
    }
    
    if (_recordingState == RecordingState.ready) {
      _recordingState = RecordingState.recording;
      notifyListeners();
      return;
    }
    
    if (_recordingState == RecordingState.recording) {
      _recordingState = RecordingState.recorded;
      notifyListeners();
      return;
    }
  }
  
  /// Reset recording to ready state
  void resetRecording() {
    _recordingState = RecordingState.ready;
    notifyListeners();
  }
  
  /// Show feedback after recording
  void showFeedback() {
    _currentStage = PracticeStage.feedback;
    notifyListeners();
  }
  
  /// Move to practice stage
  void practiceCorrect() {
    _currentStage = PracticeStage.practice;
    _recordingState = RecordingState.ready;
    notifyListeners();
  }
  
  /// Complete the current practice item
  void complete() {
    _currentStage = PracticeStage.complete;
    notifyListeners();
  }
  
  /// Move to the next practice item
  void next() {
    // In a real app, this would load the next practice item
    _currentStage = PracticeStage.prompt;
    _recordingState = RecordingState.ready;
    notifyListeners();
  }
}
