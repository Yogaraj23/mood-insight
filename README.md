# 🧠 Mood Insight - Flutter Mood Tracking App

> Understand Your Mind, Better. A premium mood tracker with points gamification, Firebase backend, and admin panel.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

**Live Repo:** https://github.com/Yogaraj23/mood-insight

### ✨ What This App Does

- **Login with Username OR Email** - Custom Firestore lookup (not just Firebase Auth)
- **6 Mood Types** - Happy 😊, Calm 😌, Excited 🤩, Sad 😔, Anxious 😰, Angry 😠
- **Points System** - Auto calculates points: `Energy*20 - Stress*12 - Sleep factor`
- **6 Main Screens** - Onboarding, Dashboard, Add Mood (Wheel Picker), Reports (Daily/Weekly), Insights (Prediction), History
- **Admin Panel** - Admin can see all users and filter reports by user
- **Gamification** - Points preview, Success popup with earned points

### 📱 App Flow

### 🛠️ Built With

- Flutter 3.x, Dart
- Firebase Auth, Cloud Firestore, Firebase Core
- google_fonts (Poppins), intl (DateFormat), timezone (Asia/Kolkata), flutter_local_notifications

### 🔥 Key Code Highlight

**Points Logic:**
```dart
int calculatePoints(int energy, int stress, double sleep) {
  int score = energy * 20 - (stress - 1) * 12 - (sleep - 8).abs().round() * 6;
  return score.clamp(0, 100);
}
Onboarding -> Login (Username/Email separate) -> Dashboard (Total Logs, Points)
-> Add Reflection (Mood Chips + 3 Wheel Pickers + Trigger + Note)
-> Save -> Success Popup (X pts Earned) -> Reports / Insights / History
 ```

### 📂 Firestore DB

**users/{uid}** : uid, email, username, name, createdAt
**moods/{autoId}** : userId, mood, moodEmoji, energy, stress, sleep, points, note, trigger, timestamp, date

### 🚀 Run Locally
```bash
git clone https://github.com/Yogaraj23/mood-insight.git
flutter pub get
flutter run
```

Add your `google-services.json` in `android/app/`

### 👨‍💻 Developer

**YOGARAJ J** | B.Tech IT - KCE (7.83 CGPA)
Flutter Developer | Chennai | Open to Work
GitHub: @Yogaraj23

---
⭐ Star this repo if you like it!


