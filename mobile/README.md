# AI-Powered English Speaking Assistant  

## Overview  

This project aims to develop a mobile application that leverages Artificial Intelligence (AI) to help users enhance their English-speaking skills. The app provides a natural conversation environment, real-time feedback, and a personalized learning path based on the user’s proficiency level.  

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
### Clean Architecture

The project follows a clean architecture pattern to ensure maintainability, testability, and separation of concerns.

#### 📂 Directory Structure
mobile/
├── lib/                        # Main source code directory
│   ├── apis/                  # API integration layer
│   │   └── conversation_api.dart   # Add your API calls here
│   │
│   ├── controller/            # Business logic & state management
│   │   └── conversation_controller.dart   # Add controller here
│   │
│   ├── model/                # Data models
│   │   ├── message.dart      # Existing message model
│   │   └── conversation.dart  # Add your conversation model here
│   │
│   ├── screen/               # UI screens
│   │   ├── feature/          # Feature-specific screens
│   │   │   └── conversation/  # Add your screens here
│   │   │       ├── create_situation_screen.dart
│   │   │       └── chat_screen.dart
│   │   ├── home_screen.dart
│   │   └── [other screens]
│   │
│   ├── widget/               # Reusable UI components
│   │   └── conversation/     # Add conversation-specific widgets here
│   │
│   ├── helper/              # Utility functions and helpers
│   │
│   └── main.dart            # App entry point
│
├── assets/                   # Static assets (images, fonts, etc.)
├── test/                    # Test files
└── pubspec.yaml             # Dependencies and app configuration

#### 🏗️ Layer Details

##### 1. Models (`/model`)
- Purpose: Define data structures and business objects
- Contents:
  - Entity classes
  - Data transfer objects (DTOs)
  - Business object definitions
- Example: `conversation.dart`, `message.dart`, `user.dart`

##### 2. Screens (`/screen`)
- Purpose: Handle UI layouts and screen-specific logic
- Organization:
  - Main screens: Directly in `/screen`
  - Feature screens: In `/screen/feature/{feature_name}/`
- Naming Convention: `*_screen.dart`
- Example: `home_screen.dart`, `feature/chat/chat_screen.dart`

##### 3. Widgets (`/widget`)
- Purpose: House reusable UI components
- Characteristics:
  - Modular and reusable
  - Feature-specific widgets in subdirectories
  - Stateless when possible
- Example: `custom_button.dart`, `chat/message_bubble.dart`

##### 4. APIs (`/apis`)
- Purpose: Handle backend communication
- Responsibilities:
  - HTTP requests/responses
  - API endpoint integration
  - Response parsing
  - Error handling
- Example: `conversation_api.dart`, `auth_api.dart`

##### 5. Controllers (`/controller`)
- Purpose: Manage business logic and state
- Responsibilities:
  - State management
  - Business logic implementation
  - UI-Data coordination
  - Event handling
- Example: `conversation_controller.dart`

##### 6. Helpers (`/helper`)
- Purpose: Provide utility functions and common tools
- Contents:
  - Constants
  - Utility functions
  - Common validators
  - Shared formatters
- Example: `date_formatter.dart`, `string_utils.dart`

#### 🔄 Data Flow



## Contributi   flutter pub get  on  

Contributions are welcome! Feel free to submit issues or pull requests to enhance the application.  

## License  

This project is licensed under the MIT License.  

## Authors
- **Ha Van Dung**
- **Nguyen Minh Nhat**  
- **Nguyen Nguyen Huy**
- **Nguyen Viet Ai Nhi**  



