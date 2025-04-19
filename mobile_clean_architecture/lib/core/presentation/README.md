# SpeakBetter UI Component Library

This directory contains the shared UI components and utilities for maintaining consistency across the SpeakBetter application.

## Architecture

The component library follows these organizational principles:

```
/core/presentation/
  ├── /widgets/              # All shared UI components
  │   ├── /animations/       # Animation utilities
  │   ├── /buttons/          # Button components
  │   ├── /cards/            # Card components
  │   ├── /feedback/         # Feedback and error components
  │   ├── /inputs/           # Input field components
  │   ├── /templates/        # Page layout templates
  │   └── index.dart         # Export all components for easy importing
```

## Using the Component Library

Import all components with a single import:

```dart
import 'package:mobile_clean_architecture/core/presentation/widgets/index.dart';
```

Or import specific components as needed:

```dart
import 'package:mobile_clean_architecture/core/presentation/widgets/buttons/primary_button.dart';
```

## Utility Classes

The component library is supported by these utility classes:

- `AppColors`: All color definitions and theme-aware getters
- `TextStyles`: Typography scale implementation
- `ResponsiveLayout`: Screen adaptation utilities
- `UIConfig`: Shared UI constants and configurations
- `AppAnimations`: Standard animation patterns
- `AppPageTransitions`: Navigation transitions

## Screen Templates

To ensure consistent layouts, use these templates for different screen types:

1. **FeatureHomeTemplate**: Entry points for major features
   ```dart
   FeatureHomeTemplate(
     title: 'Conversation Practice',
     heroContent: YourHeroWidget(),
     actionCards: [YourActionCard(), AnotherActionCard()],
     contentSection: YourContentWidget(),
   )
   ```

2. **PracticeActivityTemplate**: For active learning screens
   ```dart
   PracticeActivityTemplate(
     title: 'Image Description',
     instructionPanel: YourInstructionWidget(),
     contentDisplay: YourContentWidget(),
     interactionArea: YourInteractionWidget(),
   )
   ```

3. **FeedbackResultsTemplate**: For feedback and results screens
   ```dart
   FeedbackResultsTemplate(
     title: 'Practice Results',
     summarySection: YourSummaryWidget(),
     detailedFeedbackSection: YourFeedbackWidget(),
     primaryActionLabel: 'Continue',
     onPrimaryActionPressed: () => navigateToNextScreen(),
     secondaryActionLabel: 'Try Again',
     onSecondaryActionPressed: () => restartActivity(),
   )
   ```

## Common Components

### Buttons

1. **PrimaryButton**: Main call-to-action buttons
   ```dart
   PrimaryButton(
     text: 'Start Practice',
     icon: Icons.play_arrow,
     onPressed: () => startPractice(),
     isFullWidth: true,
   )
   ```

2. **SecondaryButton**: Alternative or secondary actions
   ```dart
   SecondaryButton(
     text: 'Cancel',
     onPressed: () => Navigator.of(context).pop(),
   )
   ```

3. **MicButton**: Voice recording interaction
   ```dart
   MicButton(
     isRecording: _isRecording,
     onRecordingStarted: _startRecording,
     onRecordingStopped: _stopRecording,
   )
   ```

### Cards

**AppCard**: Standard card component for navigation and information display
```dart
AppCard(
  icon: Icon(Icons.chat_bubble_outline, color: AppColors.primary),
  title: 'Conversation Practice',
  subtitle: 'Role-play real scenarios',
  onTap: () => Navigator.of(context).push('/conversations'),
)
```

### Feedback

**FeedbackCard**: Display feedback, errors, warnings, or informational messages
```dart
FeedbackCard(
  title: 'Great Pronunciation',
  content: 'Your pronunciation of "th" sounds has improved significantly.',
  type: FeedbackType.success,
  actionLabel: 'View Details',
  onActionPressed: () => showPronunciationDetails(),
)
```

### Inputs

1. **AppTextInput**: Standardized text input field
   ```dart
   AppTextInput(
     label: 'Your Name',
     hintText: 'Enter your full name',
     controller: _nameController,
     onChanged: (value) => updateName(value),
   )
   ```

2. **VoiceInput**: Voice recording with transcription
   ```dart
   VoiceInput(
     isRecording: _isRecording,
     onRecordingStarted: _startRecording,
     onRecordingStopped: _stopRecording,
     recordedText: _transcribedText,
     placeholder: 'Tap the microphone to describe the image',
   )
   ```

## Animations

Use the `AppAnimations` class for consistent animation patterns:

```dart
// Create animation controller in your widget's State
_animationController = AnimationController(
  vsync: this,
  duration: UIConfig.mediumAnimation,
);

// Create animations
final fadeAnimation = AppAnimations.fadeIn(_animationController);
final slideAnimation = AppAnimations.slideIn(_animationController);

// Use with AnimatedBuilder
AnimatedBuilder(
  animation: _animationController,
  builder: (context, child) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: child,
      ),
    );
  },
  child: yourWidget,
)
```

Or use the simplified `AnimatedBuilder` component:

```dart
core.presentation.widgets.animations.AnimatedBuilder(
  child: yourWidget,
  animationType: AnimationType.combined,
  duration: UIConfig.mediumAnimation,
)
```

## Responsive Design

Use the `ResponsiveLayout` utilities to ensure consistent adaptation across screen sizes:

```dart
// Check if device is in landscape mode on a large screen
if (ResponsiveLayout.isLargeScreen(context)) {
  return _buildLandscapeLayout(context);
} else {
  return _buildPortraitLayout(context);
}

// Get appropriate text size based on screen size
final titleFontSize = ResponsiveLayout.getTitleTextSize(context);

// Get appropriate spacing based on screen size
final padding = ResponsiveLayout.getCardPadding(context);
final spacing = ResponsiveLayout.getSectionSpacing(context);
```

## Theme-Aware Colors

Use the `AppColors` utilities to ensure correct colors in both light and dark modes:

```dart
final isDarkMode = Theme.of(context).brightness == Brightness.dark;

// Get theme-appropriate colors
final backgroundColor = AppColors.getBackgroundColor(isDarkMode);
final textColor = AppColors.getTextColor(isDarkMode);
final surfaceColor = AppColors.getSurfaceColor(isDarkMode);

// Use in widgets
Container(
  color: backgroundColor,
  child: Text(
    'Hello World',
    style: TextStyle(color: textColor),
  ),
)
```

## Typography

Use the `TextStyles` class for consistent text styling:

```dart
Text(
  'Screen Title',
  style: TextStyles.h1(context, isDarkMode: isDarkMode),
)

Text(
  'Section Header',
  style: TextStyles.h2(context, isDarkMode: isDarkMode),
)

Text(
  'Card Title',
  style: TextStyles.h3(context, isDarkMode: isDarkMode),
)

Text(
  'Main content text',
  style: TextStyles.body(context, isDarkMode: isDarkMode),
)

Text(
  'Supporting information',
  style: TextStyles.secondary(context, isDarkMode: isDarkMode),
)

Text(
  'Small caption',
  style: TextStyles.caption(context, isDarkMode: isDarkMode),
)
```

## UI Consistency Checklist

When implementing new features, refer to the UI Consistency Checklist:
`/lib/core/utils/ui_consistency_checklist.md`

## Design System Documentation

For complete details about design principles, colors, typography, and component specifications, refer to:
`/rule/design_system.md`
