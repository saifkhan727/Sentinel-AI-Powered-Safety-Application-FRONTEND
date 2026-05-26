# 🛡️ Sentinel — AI-Powered Women Safety App

> "Your Silent Guardian"

A comprehensive AI-powered women safety Android application built with
Flutter, featuring real-time SOS, live location sharing, on-device ML
voice detection, and an AI safety chatbot.

![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)
![Dart](https://img.shields.io/badge/Dart-3.x-blue)
![TensorFlow Lite](https://img.shields.io/badge/TFLite-CNN-orange)
![License](https://img.shields.io/badge/License-MIT-green)

---

## 📱 Features

| Feature | Description |
|---|---|
| 🆘 SOS System | One-tap, shake, and voice-triggered emergency alert |
| 🎙️ Voice SOS (AI/ML) | On-device CNN model detects distress keywords |
| 📍 Live Location | Real-time location sharing via WebSocket |
| 💬 AI Chatbot | 4-mode safety chatbot powered by Groq AI |
| 🗺️ Safe Places | Nearby police, hospitals via OpenStreetMap |
| 📲 Direct SMS | SOS SMS sent from user's own number |
| 👥 Guardian Circle | Up to 5 trusted contacts with priority levels |
| 📞 Fake Call | Realistic fake incoming call simulation |
| 🔔 Helplines | 16+ emergency helplines with one-tap calling |
| 📳 Shake Detection | Triple shake triggers SOS automatically |

---

## 🤖 AI/ML — Voice SOS Detection

- **Model:** Custom CNN trained on MFCC features
- **Keywords:** help, bachao, save me, chodo, madad karo
- **Input Shape:** (40, 128, 1) — 40 MFCC coefficients x 128 time frames
- **Deployment:** TensorFlow Lite (on-device, no internet needed)
- **Trigger:** Confidence > 75% → 3-second countdown → SOS

---

## 🛠️ Tech Stack

- **Framework:** Flutter (Dart)
- **State Management:** Flutter Riverpod
- **ML:** TensorFlow Lite (CNN)
- **AI Chatbot:** Groq AI — Llama 3.3 70B
- **Maps:** Google Maps Flutter SDK
- **Safe Places:** OpenStreetMap Overpass API
- **Auth:** Firebase Phone OTP
- **Notifications:** Firebase FCM
- **Real-time:** WebSocket

---

## 📁 Project Structure

```
lib/
├── core/
│   ├── constants/       # API constants (gitignored)
│   ├── theme/           # App theme
│   └── utils/           # Helper functions
├── data/
│   ├── models/          # Data models
│   └── services/        # API services
├── presentation/
│   ├── screens/         # All UI screens
│   └── widgets/         # Reusable widgets
├── providers/           # Riverpod providers
└── main.dart
```

---

## ⚙️ Setup & Installation

### Prerequisites
- Flutter SDK 3.x
- Android Studio / VS Code
- Android device or emulator (API 21+)
- Backend server running

### 1. Clone the repository
```
git clone https://github.com/saifkhan727/Sentinel-Flutter-App.git
cd Sentinel-Flutter-App
```

### 2. Create secrets file
Create lib/core/constants/api_constants.dart:
```
class ApiConstants {
  static const String serverUrl = 'YOUR_BACKEND_URL';
  static const String wsUrl = 'YOUR_WEBSOCKET_URL';
  static const String groqApiKey = 'YOUR_GROQ_API_KEY';
}
```

### 3. Add Firebase config
Place your google-services.json in android/app/

### 4. Install dependencies
```
flutter pub get
```

### 5. Run the app
```
flutter run
```

---

## ⚠️ Limitations

- Android only (iOS support not included)
- Voice model accuracy depends on dataset size
- AI Chatbot requires internet connectivity
- Live location requires GPS enabled

---

## 👨‍💻 Developer
**Saif Akhtar Khan**

🔗 Backend Repo: https://github.com/saifkhan727/Sentinel-AI-Powered-Women-Safety-Application

---

## 📄 License

This project is licensed under the MIT License.
