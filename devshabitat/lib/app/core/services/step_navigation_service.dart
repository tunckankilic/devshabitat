import 'package:get/get.dart';

enum StepState { pending, inProgress, completed, skipped, error }

class StepConfiguration {
  final String id;
  final String title;
  final String description;
  final bool isRequired;
  final bool canSkip;
  final List<String> requiredFields;
  final List<String> optionalFields;
  final List<String> dependencies;

  const StepConfiguration({
    required this.id,
    required this.title,
    required this.description,
    this.isRequired = true,
    this.canSkip = false,
    this.requiredFields = const [],
    this.optionalFields = const [],
    this.dependencies = const [],
  });
}

class StepNavigationService extends GetxService {
  // Current step index
  final RxInt _currentStepIndex = 0.obs;

  // Step configurations
  final List<StepConfiguration> _steps;

  // Step states
  final RxMap<String, StepState> _stepStates = <String, StepState>{}.obs;

  // Unsaved changes flag
  final RxBool _hasUnsavedChanges = false.obs;

  // Navigation history
  final RxList<int> _navigationHistory = <int>[].obs;

  StepNavigationService(this._steps) {
    // Initialize step states
    for (var step in _steps) {
      _stepStates[step.id] = StepState.pending;
    }

    // Set first step as in progress
    if (_steps.isNotEmpty) {
      _stepStates[_steps[0].id] = StepState.inProgress;
    }
  }

  // Getters
  int get currentStepIndex => _currentStepIndex.value;
  StepConfiguration get currentStep => _steps[currentStepIndex];
  bool get isFirstStep => currentStepIndex == 0;
  bool get isLastStep => currentStepIndex == _steps.length - 1;
  bool get hasUnsavedChanges => _hasUnsavedChanges.value;
  List<int> get navigationHistory => _navigationHistory;

  // Step state getters
  StepState getStepState(String stepId) =>
      _stepStates[stepId] ?? StepState.pending;
  bool isStepCompleted(String stepId) =>
      _stepStates[stepId] == StepState.completed;
  bool isStepSkipped(String stepId) => _stepStates[stepId] == StepState.skipped;
  bool isStepInProgress(String stepId) =>
      _stepStates[stepId] == StepState.inProgress;
  bool isStepPending(String stepId) => _stepStates[stepId] == StepState.pending;
  bool isStepError(String stepId) => _stepStates[stepId] == StepState.error;

  // Navigation validation
  bool canMoveNext() {
    final currentStepConfig = _steps[currentStepIndex];

    // Check if current step is required and not completed
    if (currentStepConfig.isRequired &&
        !isStepCompleted(currentStepConfig.id)) {
      return false;
    }

    // Check if next step's dependencies are met
    if (currentStepIndex < _steps.length - 1) {
      final nextStep = _steps[currentStepIndex + 1];
      for (var depId in nextStep.dependencies) {
        if (!isStepCompleted(depId)) {
          return false;
        }
      }
    }

    return true;
  }

  bool canMovePrevious() {
    return !isFirstStep && !hasUnsavedChanges;
  }

  bool canSkipStep() {
    final currentStepConfig = _steps[currentStepIndex];
    return currentStepConfig.canSkip && !isLastStep;
  }

  // Navigation methods
  Future<bool> moveNext() async {
    if (!canMoveNext()) return false;

    // Save current step index to history
    _navigationHistory.add(currentStepIndex);

    // Move to next step
    if (!isLastStep) {
      _currentStepIndex.value++;
      _stepStates[currentStep.id] = StepState.inProgress;
      return true;
    }

    return false;
  }

  Future<bool> movePrevious() async {
    if (!canMovePrevious()) return false;

    // Move to previous step
    if (!isFirstStep) {
      _currentStepIndex.value--;
      _stepStates[currentStep.id] = StepState.inProgress;
      return true;
    }

    return false;
  }

  Future<bool> skipStep() async {
    if (!canSkipStep()) return false;

    // Mark current step as skipped
    _stepStates[currentStep.id] = StepState.skipped;

    // Move to next step
    return moveNext();
  }

  // Step state management
  void markStepAsCompleted(String stepId) {
    _stepStates[stepId] = StepState.completed;
  }

  void markStepAsError(String stepId) {
    _stepStates[stepId] = StepState.error;
  }

  void markStepAsPending(String stepId) {
    _stepStates[stepId] = StepState.pending;
  }

  void setUnsavedChanges(bool value) {
    _hasUnsavedChanges.value = value;
  }

  // Navigation history management
  void clearNavigationHistory() {
    _navigationHistory.clear();
  }

  bool canGoBack() {
    return _navigationHistory.isNotEmpty;
  }

  Future<bool> goBack() async {
    if (!canGoBack()) return false;

    final previousIndex = _navigationHistory.removeLast();
    _currentStepIndex.value = previousIndex;
    _stepStates[currentStep.id] = StepState.inProgress;

    return true;
  }

  // Reset
  void reset() {
    _currentStepIndex.value = 0;
    _navigationHistory.clear();
    _hasUnsavedChanges.value = false;

    // Reset step states
    for (var step in _steps) {
      _stepStates[step.id] = StepState.pending;
    }

    // Set first step as in progress
    if (_steps.isNotEmpty) {
      _stepStates[_steps[0].id] = StepState.inProgress;
    }
  }
}
