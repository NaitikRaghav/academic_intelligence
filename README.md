# Academic Intelligence 🎓🤖

An advanced, end-to-end Flutter student management system that leverages generative artificial intelligence to revolutionize how coursework is created, submitted, and evaluated. 

## ⏱️ The Elevator Pitch
Academic Intelligence moves beyond standard attendance tracking to provide actionable, generative AI for education. Built with a sleek, custom iOS-inspired glassmorphism aesthetic, it offers dedicated environments for students and teachers. Instructors can generate structured assignments and multiple-choice quizzes instantly using the Gemini API, while the system automatically analyzes and grades student submissions. For students, it provides a unified dashboard, an interactive quiz engine, and a 24/7 AI tutor to assist with coursework. 

---

## ✨ Core Features & Capabilities

### 👨‍🏫 Teacher Environment (Content Generation & Grading)
*   **Generative AI Dashboard:** The `TeacherDashboard` acts as a command center, featuring premium action cards for instant content creation.
*   **AI Assignment Generator:** The `AIGeneratorModal` connects directly to the Gemini API to instantly draft structured essays, tasks, and rubrics based on a simple subject/topic prompt.
*   **Smart Quiz Builder:** The `QuizGeneratorModal` uses Gemini to build comprehensive multiple-choice tests—including correct answers and detailed explanations—hidden from the student view.
*   **Automated Grading (Submission Analyzer):** The `SubmissionAnalyzerScreen` evaluates student submissions against the original AI-generated rubrics, providing instant grading, summaries, strengths, and weaknesses.

### 🧑‍🎓 Student Environment (Learning & Submission)
*   **Smart Dashboard:** A unified `StudentDashboard` that tracks assignments, intelligently sorting them into 'Pending' and 'Completed' states using real-time database syncing.
*   **AI Quiz Engine:** A dynamic `QuizEngineScreen` that parses hidden AI-generated data into a clean, interactive multiple-choice test environment.
*   **Homework Submission:** A flexible `HomeworkSubmissionScreen` allowing students to either upload scanned documents (using simulated OCR) or type responses directly.

### 🧠 Shared AI Infrastructure
*   **Gemini Tutor Chat:** A fully integrated `AIChatScreen` that acts as a personal tutor for students and an assistant for teachers, saving conversation history directly to the database.

---

## 🛠️ Tech Stack & Collaborative Architecture

*   **Frontend:** Flutter & Dart
*   **State Management:** Riverpod (`ConsumerStatefulWidget`, Stream Providers)
*   **UI/UX:** Custom Glassmorphism, iOS-style widgets (`CupertinoPageScaffold`, `IOSGlassCard`, `PremiumIOSTextField`)
*   **AI Integration:** Google Gemini API 

### 🤝 Backend Collaboration Readiness
The application is intentionally architected to separate the UI layer from the data layer. The `services/` and `providers/` directories are strictly decoupled, making it frictionless to collaborate via GitHub. Backend developers can easily swap out dummy data or connect Supabase/Firebase endpoints without ever causing merge conflicts in the frontend UI code.

---

## 📂 Complete Directory Structure

The application follows a highly scalable, modular architecture designed for feature expansion:

```text
lib/
│
├── core/
│   ├── constants/
│   │   ├── api_keys.dart
│   │   ├── colors.dart
│   │   └── typography.dart
│   ├── routing/
│   │   └── app_router.dart
│   ├── theme/
│   └── utils/
│       ├── date_formatters.dart
│       └── validators.dart
│
├── models/
│   ├── assignment_model.dart
│   ├── submission_model.dart
│   └── user_model.dart
│
├── providers/
│   ├── ai_provider.dart
│   ├── auth_provider.dart
│   ├── chat_provider.dart
│   ├── database_provider.dart
│   └── submission_provider.dart
│
├── screens/
│   ├── auth/
│   │   ├── auth_wrapper.dart
│   │   └── login_screen.dart
│   ├── shared/
│   │   └── ai_chat_screen.dart
│   ├── student/
│   │   ├── homework_submission_screen.dart
│   │   ├── quiz_engine_screen.dart
│   │   └── student_dashboard.dart
│   └── teacher/
│       ├── ai_generator_modal.dart
│       ├── assignment_detail_screen.dart
│       ├── quiz_generator_modal.dart
│       ├── submission_analyzer_screen.dart
│       └── teacher_dashboard.dart
│
├── services/
│   ├── auth_service.dart
│   ├── database_service.dart
│   ├── gemini_service.dart
│   └── ocr_service.dart
│
├── widgets/
│   ├── cupertino_text_field.dart
│   ├── ios_glass_card.dart
│   └── primary_action_button.dart
│
└── main.dart
