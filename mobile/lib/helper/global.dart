import 'package:flutter/material.dart';

/// Application name constant
const String appName = 'AI Assistant';

/// Media query variable to store the device screen size
late Size mq;

/// TODO: API Key Configuration
///
/// ⚠️ **Important:** Never hardcode your API key directly in the source code.
/// Instead, use one of the following secure methods:
/// - Store the key in a secure backend (e.g., Appwrite, Firebase, or an environment variable).
/// - Use Flutter’s `.env` file (with `flutter_dotenv` package) to store API keys securely.
///
/// 🔹 **Google Gemini API Key:** Get your key from
///   👉 https://aistudio.google.com/app/apikey
///
/// 🔹 **ChatGPT API Key:** Get your key from
///   👉 https://platform.openai.com/account/api-keys
///
/// 📌 **How to Set Up Secure API Key Handling:**
/// - If using Appwrite, update your project settings to store the key securely.
/// - If using a local `.env` file, install `flutter_dotenv` and load the key from there.
/// - Otherwise, **remove hardcoded keys** and fetch them securely at runtime.

/// API Key for the AI service (Leave empty if fetching dynamically)
String apiKey = ''; // Ensure to retrieve this securely
