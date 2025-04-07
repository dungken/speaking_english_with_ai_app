# Speaking English with AI

A Flutter application that helps users practice and improve their English speaking skills using AI technology. The app features chat conversations with AI, text translation, and AI image generation capabilities.

## Features

- **AI Chat**: Practice English conversation with an AI chatbot
- **Translation**: Translate text between multiple languages
- **Image Generation**: Generate images using AI based on text descriptions
- **Clean Architecture**: Well-organized codebase following clean architecture principles
- **State Management**: Uses BLoC pattern for state management
- **Navigation**: GetX for efficient navigation and dependency injection

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- OpenAI API Key

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/speaking_english_with_ai.git
   ```

2. Navigate to the project directory:
   ```bash
   cd speaking_english_with_ai
   ```

3. Install dependencies:
   ```bash
   flutter pub get
   ```

4. Update the OpenAI API key:
   - Open `lib/main.dart`
   - Replace `YOUR_OPENAI_API_KEY` with your actual OpenAI API key

5. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── application/        # BLoC (Business Logic Component)
│   ├── auth/          # Authentication BLoC
│   └── chat/          # Chat BLoC
├── core/              # Core functionality
│   ├── routes/        # App routes
│   └── utils/         # Utility functions
├── data/              # Data layer
│   ├── datasources/   # Remote data sources
│   └── repositories/  # Repository implementations
├── domain/            # Domain layer
│   ├── entities/      # Business objects
│   └── repositories/  # Repository interfaces
└── presentation/      # UI layer
    ├── screens/       # App screens
    └── widgets/       # Reusable widgets
```

## Dependencies

- `flutter_bloc`: State management
- `get`: Navigation and dependency injection
- `http`: API calls
- `google_generative_ai`: AI integration
- `translator_plus`: Text translation
- `flutter_animate`: UI animations

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- OpenAI for providing the AI capabilities
- Flutter team for the amazing framework
- All contributors who help improve this project
