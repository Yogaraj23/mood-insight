# 🧠 Mood Insight - Flutter Mood Tracking App

> Understand Your Mind, Better. A premium mood tracker with points gamification, Firebase backend, and admin panel.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

**Live Repo:** https://github.com/Yogaraj23/mood-insight

## ✨ What This App Does
- **Login with Username OR Email** - Custom Firestore lookup
- **6 Mood Types** - Happy 😊, Calm 😌, Excited 🤩, Sad 😔, Anxious 😰, Angry 😠
- **Points System** - Based on energy, stress and sleep quality (max 100 per log)
- **6 Main Screens** - Onboarding, Dashboard, Add Mood, Reports, Insights, History
- **Admin Panel** - See all users + filter reports
- **Gamification** - Points preview + Success popup

## 📱 App Flow
```text
Splash -> Onboarding -> Login (Username/Email) -> Dashboard
-> Add Mood (6 Chips + 3 Wheel Pickers + Trigger + Note)
-> Save -> Success Popup (X pts Earned)
-> Reports | Insights | History | Profile | Admin
```

## 🛠️ Built With
- Flutter 3.x, Dart
- Firebase Auth, Cloud Firestore
- google_fonts, intl, timezone, flutter_local_notifications

## 🔥 Key Code Highlight
**Points Logic:**
```dart
int calculatePoints(int energy, int stress, double sleep) {
  int score = energy * 20 - (stress - 1) * 12 - (sleep - 8).abs().round() * 6;
  return score.clamp(0, 100).toInt();
}
```

## 📂 Firestore DB
- `users/{uid}` : uid, email, username, name, role, totalPoints, totalLogs, createdAt
- `moods/{autoId}` : userId, mood, moodEmoji, energy, stress, sleep, points, note, trigger, timestamp, date

## 🚀 Run Locally
```bash
git clone https://github.com/Yogaraj23/mood-insight.git
cd mood-insight
flutter pub get
flutter run
```
Add your `google-services.json` in `android/app/`

## 👨‍💻 Developer
**YOGARAJ J** | B.Tech IT - KCE (7.83 CGPA)
Flutter Developer | Chennai | Open to Work
GitHub: [@Yogaraj23](https://github.com/Yogaraj23)

---
⭐ Star this repo if you like it!
