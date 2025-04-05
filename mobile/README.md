# AI-Powered English Speaking Assistant  

## Overview  

This project aims to develop a mobile application that leverages Artificial Intelligence (AI) to help users enhance their English-speaking skills. The app provides a natural conversation environment, real-time feedback, and a personalized learning path based on the user's proficiency level.  

## Target Users  

The application is designed for individuals who:  
- Want to improve their English fluency.  
- Struggle with expressing their ideas in English.  
- Are preparing for TOEIC or IELTS Speaking exams.  
- Need better communication skills for an international working environment.  

## Key Features  

- **Role-playing in Real-World Situations**: Engage in interactive conversations to practice English in real-life contexts.  
- **Speech Recognition & Analysis**: AI-powered speech recognition to evaluate pronunciation and fluency.  
- **Pronunciation Scoring**: Provides a score based on pronunciation accuracy.  
- **Error Detection & Correction**: Identifies pronunciation mistakes and offers correction suggestions.  
- **Speaking Time Statistics**: Tracks and analyzes the user's speaking time for progress monitoring.  
- **Image Description Practice**: Helps users practice describing images, similar to TOEIC Speaking tasks.  

## Technology Stack  

- **Frontend**: Flutter  
- **Backend**: Python (FastAPI)  
- **Database**: PostgreSQL  
- **Cloud Services**: Azure, Firebase  

## Installation  

### Prerequisites  
- Flutter SDK installed  
- Python 3.8+  
- PostgreSQL database setup  

### Setup Instructions  

#### Backend  
1. Clone the repository:  
   ```sh
   git clone https://github.com/your-repo.git  
   cd your-repo/backend  
   ```  
2. Install dependencies:  
   ```sh
   pip install -r requirements.txt  
   ```  
3. Run the FastAPI server:  
   ```sh
   uvicorn main:app --host 0.0.0.0 --port 8000 --reload  
   ```  

#### Frontend  
1. Navigate to the frontend directory:  
   ```sh
   cd your-repo/frontend  
   ```  
2. Install dependencies:  
   ```sh
   flutter pub get  
   ```  
3. Run the application:  
   ```sh
   flutter run  
   ```  


### Project Structure

```
mobile/
├── lib/                      # Main source code directory
│   ├── apis/                # API service implementations
│   │   ├── auth_api.dart    # Authentication related API calls
│   │   ├── chat_api.dart    # Chat and conversation API calls
│   │   └── speech_api.dart  # Speech recognition and analysis API
│   │
│   ├── controller/          # Business logic and state management
│   │   ├── auth_controller.dart
│   │   ├── chat_controller.dart
│   │   └── speech_controller.dart
│   │
│   ├── model/              # Data models and entities
│   │   ├── user.dart
│   │   ├── conversation.dart
│   │   └── speech_result.dart
│   │
│   ├── screen/             # UI screens/pages
│   │   ├── auth/          # Authentication screens
│   │   ├── chat/          # Chat and conversation screens
│   │   └── practice/      # Practice mode screens
│   │
│   ├── widget/            # Reusable UI components
│   │   ├── common/        # Common widgets (buttons, inputs, etc.)
│   │   └── custom/        # Custom widgets specific to the app
│   │
│   ├── helper/            # Utility functions and helpers
│   │   ├── constants.dart
│   │   ├── theme.dart
│   │   └── validators.dart
│   │
│   └── main.dart          # Application entry point
│
├── assets/                # Static assets
│   ├── images/           # Image assets
│   ├── fonts/            # Custom fonts
│   └── sounds/           # Sound effects and audio files
│
├── test/                 # Test files
│   ├── unit/            # Unit tests
│   ├── widget/          # Widget tests
│   └── integration/     # Integration tests
│
└── pubspec.yaml          # Flutter dependencies and configurations
```

#### Key Directories Explained

1. **apis/**
   - Contains all API service implementations
   - Handles network requests and responses
   - Implements API endpoints for backend communication

2. **controller/**
   - Manages business logic and state
   - Implements BLoC pattern for state management
   - Handles data flow between UI and services

3. **model/**
   - Defines data structures and entities
   - Contains model classes for API responses
   - Implements data validation and transformation

4. **screen/**
   - Contains all app screens/pages
   - Organized by feature modules
   - Implements UI layouts and navigation

5. **widget/**
   - Reusable UI components
   - Common widgets used across multiple screens
   - Custom widgets specific to the app's features

6. **helper/**
   - Utility functions and helper classes
   - Constants and configuration
   - Theme definitions and styling

#### Development Guidelines

1. **Code Organization**
   - Follow the feature-first organization within each directory
   - Keep related files close to each other
   - Use clear, descriptive file names

2. **State Management**
   - Use BLoC pattern for complex state management
   - Keep state logic in controllers
   - Maintain unidirectional data flow

3. **API Integration**
   - Implement API calls in dedicated service classes
   - Use repository pattern for data access
   - Handle errors and loading states consistently

4. **UI Components**
   - Create reusable widgets for common UI elements
   - Follow Material Design guidelines
   - Maintain consistent styling across the app

5. **Testing**
   - Write unit tests for business logic
   - Implement widget tests for UI components
   - Add integration tests for critical user flows

## Contributi   flutter pub get  on  

Contributions are welcome! Feel free to submit issues or pull requests to enhance the application.  

## License  

This project is licensed under the MIT License.  

## Authors
- **Ha Van Dung**
- **Nguyen Minh Nhat**  
- **Nguyen Nguyen Huy**
- **Nguyen Viet Ai Nhi**  



