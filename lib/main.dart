import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzData;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  tzData.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
  await NotificationService.init();
  await NotificationService.scheduleAutomaticReminders();
  runApp(const MyApp());
}

const String ADMIN_EMAIL = "yogarajyogaraj234@gmail.com";
bool isAdminUser(User? user) { if (user == null) return false; return user.email!.toLowerCase() == ADMIN_EMAIL.toLowerCase(); }
int calculatePoints(int energy, int stress, double sleep) { int score = energy * 20 - (stress - 1) * 12 - (sleep - 8).abs().round() * 6; if (score < 0) return 0; if (score > 100) return 100; return score; }
String getNameFromEmail(String? email) { if (email == null || email.isEmpty) return "User"; String n = email.split('@')[0]; if (n.isEmpty) return "User"; return n[0].toUpperCase() + n.substring(1); }
String safeInitial(String? txt) { if (txt == null || txt.trim().isEmpty) return "U"; return txt.trim()[0].toUpperCase(); }

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static Future<void> init() async { const android = AndroidInitializationSettings('@mipmap/ic_launcher'); await _plugin.initialize(const InitializationSettings(android: android)); }
  static Future<void> scheduleAutomaticReminders() async { await _plugin.cancelAll(); }
  static Future<void> stopAll() async { await _plugin.cancelAll(); }
  static Future<void> showNow(String t, String b) async { await _plugin.show(0, t, b, const NotificationDetails(android: AndroidNotificationDetails('mood_auto', 'Auto'))); }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData(useMaterial3: true, textTheme: GoogleFonts.poppinsTextTheme()),
        home: StreamBuilder<User?>(stream: FirebaseAuth.instance.authStateChanges(), builder: (c, s) { if (s.connectionState == ConnectionState.waiting) return const Scaffold(body: Center(child: CircularProgressIndicator())); if (s.hasData) return const MainNavPage(); return const OnboardingPage(); }));
  }
}

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});
  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0), extendBodyBehindAppBar: true,
        body: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)])), child: Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.psychology_alt_rounded, size: 80, color: Colors.white), const SizedBox(height: 20), Text("Mood Insight", style: GoogleFonts.poppins(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)), Text("Understand Your Mind, Better.", style: GoogleFonts.poppins(color: Colors.white70)), const SizedBox(height: 40), SizedBox(width: double.infinity, height: 56, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginPage())), child: Text("Get Started", style: GoogleFonts.poppins(color: const Color(0xFF6A11CB), fontWeight: FontWeight.bold, fontSize: 18))))])))));
  }
}

class LoginPage extends StatefulWidget { const LoginPage({super.key}); @override State<LoginPage> createState() => _LoginPageState(); }
class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController(); // Username separate
  final emailController = TextEditingController(); // Email separate
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool obscurePassword = true;

  Future<void> login() async {
    if (passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter password")));
      return;
    }
    if (usernameController.text.trim().isEmpty && emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter Username or Email")));
      return;
    }
    setState(() => isLoading = true);
    try {
      String emailToLogin = emailController.text.trim();
      if (emailToLogin.isEmpty) {
        String uname = usernameController.text.trim();
        var q = await FirebaseFirestore.instance.collection("users").where("username", isEqualTo: uname).limit(1).get();
        if (q.docs.isEmpty) q = await FirebaseFirestore.instance.collection("users").where("name", isEqualTo: uname).limit(1).get();
        if (q.docs.isEmpty) throw FirebaseAuthException(code: 'user-not-found', message: 'Username not found');
        emailToLogin = q.docs.first.data()["email"];
      }
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailToLogin, password: passwordController.text.trim());
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainNavPage()), (r) => false);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Login failed"), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4F46E5), Color(0xFF0EA5E9)], // ✅ BLUE background like Signup
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 50),
                Container(padding: const EdgeInsets.all(16), decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.psychology_alt_rounded, size: 40, color: Color(0xFF4F46E5))),
                const SizedBox(height: 32),
                const Text("Mood Insight", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    children: [
                      // ✅ USERNAME SEPARATE
                      TextField(controller: usernameController, decoration: InputDecoration(labelText: "Username", prefixIcon: const Icon(Icons.person_outline), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                      const SizedBox(height: 12),
                      // ✅ EMAIL SEPARATE - NO OR
                      TextField(controller: emailController, decoration: InputDecoration(labelText: "Email", prefixIcon: const Icon(Icons.email_outlined), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                      const SizedBox(height: 12),
                      TextField(controller: passwordController, obscureText: obscurePassword, decoration: InputDecoration(labelText: "Password", prefixIcon: const Icon(Icons.lock_outline), suffixIcon: IconButton(icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => obscurePassword = !obscurePassword)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                      const SizedBox(height: 20),
                      SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: isLoading ? null : login, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Login", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)))),
                      const SizedBox(height: 12),
                      TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupPage())), child: const Text("Don't have account? Create Account", style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ✅ NEW - ADDED SIGNUP PAGE FOR ALL USERS
class SignupPage extends StatefulWidget { const SignupPage({super.key}); @override State<SignupPage> createState() => _SignupPageState(); }
class _SignupPageState extends State<SignupPage> {
  final emailC = TextEditingController();
  final passC = TextEditingController();
  final nameC = TextEditingController(); // ✅ NEW USERNAME
  bool isLoading = false;

  Future<void> signup() async {
    if (emailC.text.trim().isEmpty || passC.text.trim().isEmpty || nameC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Enter username, email & password"))); return;
    }
    setState(() => isLoading = true);
    try {
      var cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailC.text.trim(), password: passC.text.trim());
      // ✅ SAVE USERNAME NOT EMAIL NAME
      await cred.user!.updateDisplayName(nameC.text.trim());
      await FirebaseFirestore.instance.collection("users").doc(cred.user!.uid).set({
        "uid": cred.user!.uid,
        "email": cred.user!.email,
        "username": nameC.text.trim(), // ✅ This is real username
        "name": nameC.text.trim(),
        "createdAt": FieldValue.serverTimestamp()
      });
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainNavPage()), (r) => false);
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? "Signup failed"), backgroundColor: Colors.red));
    } finally { if (mounted) setState(() => isLoading = false); }
  }

  @override Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("Create Account")),
        body: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
          TextField(controller: nameC, decoration: InputDecoration(labelText: "Username", prefixIcon: const Icon(Icons.person), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))) ,
          const SizedBox(height: 12),
          TextField(controller: emailC, decoration: InputDecoration(labelText: "Email", prefixIcon: const Icon(Icons.email), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))) ,
          const SizedBox(height: 12),
          TextField(controller: passC, obscureText: true, decoration: InputDecoration(labelText: "Password (8+ chars)", prefixIcon: const Icon(Icons.lock), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)), onPressed: isLoading? null : signup, child: isLoading? const CircularProgressIndicator(color: Colors.white) : const Text("Create Account", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))])));
  }
}
class MainNavPage extends StatefulWidget { const MainNavPage({super.key}); @override State<MainNavPage> createState() => _MainNavPageState(); }
class _MainNavPageState extends State<MainNavPage> {
  int idx = 0;
  @override Widget build(BuildContext context) {
    bool isAdmin = isAdminUser(FirebaseAuth.instance.currentUser);
    User? user = FirebaseAuth.instance.currentUser; String dName = (user?.displayName!= null && user!.displayName!.trim().isNotEmpty)? user.displayName! : getNameFromEmail(user?.email);
    List<Widget> pages = [const DashboardPage(), const AddMoodPage(), const ReportsPage(), const InsightsPage(), const HistoryPage()];
    List<Color> colors = [const Color(0xFF38BDF8), const Color(0xFFE879F9), const Color(0xFFFB923C), const Color(0xFFA78BFA), const Color(0xFF4ADE80)];
    List<NavigationDestination> dest = [
      NavigationDestination(icon: const Icon(Icons.dashboard_outlined, color: Colors.grey), selectedIcon: Icon(Icons.dashboard, color: colors[0]), label: "Home"),
      NavigationDestination(icon: const Icon(Icons.add_circle_outline, color: Colors.grey), selectedIcon: Icon(Icons.add_circle, color: colors[1]), label: "Add"),
      NavigationDestination(icon: const Icon(Icons.assessment_outlined, color: Colors.grey), selectedIcon: Icon(Icons.assessment, color: colors[2]), label: "Reports"),
      NavigationDestination(icon: const Icon(Icons.insights_outlined, color: Colors.grey), selectedIcon: Icon(Icons.insights, color: colors[3]), label: "Insights"),
      NavigationDestination(icon: const Icon(Icons.history_outlined, color: Colors.grey), selectedIcon: Icon(Icons.history, color: colors[4]), label: "History"),
    ];
    if (isAdmin) { pages.add(const UsersPage()); dest.add(NavigationDestination(icon: const Icon(Icons.people_outline, color: Colors.grey), selectedIcon: Icon(Icons.people, color: Colors.redAccent), label: "Users")); colors.add(Colors.redAccent); }
    if (idx >= pages.length) idx = 0;
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, title: Text("Mood Insight", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.black)), actions: [GestureDetector(onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage())), child: Container(margin: const EdgeInsets.only(right: 16), padding: const EdgeInsets.all(2.5), decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [colors[idx], colors[idx].withOpacity(0.4)]), boxShadow: [BoxShadow(color: colors[idx].withOpacity(0.4), blurRadius: 10)]), child: CircleAvatar(radius: 18, backgroundColor: Colors.white, child: Text(safeInitial(dName), style: TextStyle(color: colors[idx], fontWeight: FontWeight.bold)))))]),
      body: pages[idx],
      bottomNavigationBar: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)), boxShadow: [BoxShadow(color: colors[idx].withOpacity(0.25), blurRadius: 20, offset: const Offset(0, -4))]), child: ClipRRect(borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)), child: NavigationBar(selectedIndex: idx, onDestinationSelected: (i) => setState(() => idx = i), height: 72, backgroundColor: Colors.white, indicatorColor: colors[idx].withOpacity(0.18), destinations: dest))),
    );
  }
}

class DashboardPage extends StatelessWidget { const DashboardPage({super.key}); @override Widget build(BuildContext context) { User? user = FirebaseAuth.instance.currentUser; if (user == null) return const Scaffold(body: Center(child: Text("No user"))); String dName = (user.displayName!= null && user.displayName!.trim().isNotEmpty)? user.displayName! : (user.email ?? "User"); bool isAdmin = isAdminUser(user); return SafeArea(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text("Hello,", style: GoogleFonts.poppins(color: Colors.grey)), Text(dName, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold))]), CircleAvatar(backgroundColor: const Color(0xFF6A11CB),
    child: Text(safeInitial(dName), style: const TextStyle(color: Colors.white)))]), const SizedBox(height: 16), Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]), borderRadius: BorderRadius.circular(16)), child: Row(children: [Expanded(child: Text("Track your mood daily - Points based on Energy, Sleep, Stress", style: GoogleFonts.poppins(color: Colors.white, fontSize: 12))), const Icon(Icons.star, color: Colors.yellow)])), const SizedBox(height: 16),
  StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection("moods").where("userId", isEqualTo: user.uid).snapshots(), builder: (c, snap) { int total = 0; int pts = 0; if (snap.hasData) { total = snap.data!.docs.length; for (var d in snap.data!.docs) { var m = d.data() as Map<String, dynamic>; pts += (m["points"]?? calculatePoints(m["energy"]?? 3, m["stress"]?? 2, (m["sleep"]?? 7).toDouble())) as int; } } return Row(children: [Expanded(child: _card("$total", "Logs", Icons.book)), const SizedBox(width: 10), Expanded(child: _card("$pts", "Points", Icons.star)), const SizedBox(width: 10), Expanded(child: _card(isAdmin? "Admin" : "User", "Role", Icons.person))]); }), const SizedBox(height: 20), Text("Recent", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)), const SizedBox(height: 8), Expanded(child: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection("moods").where("userId", isEqualTo: user.uid).orderBy("timestamp", descending: true).limit(5).snapshots(), builder: (c, snap) { if (snap.hasError) { return StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection("moods").where("userId", isEqualTo: user.uid).limit(5).snapshots(), builder: (c, s2) { if (s2.data == null) return const Center(child: CircularProgressIndicator()); return ListView(children: s2.data!.docs.map((d) { var m = d.data() as Map<String, dynamic>; return Card(child: ListTile(leading: Text(m["moodEmoji"]?? "😊", style: const TextStyle(fontSize: 24)), title: Text("${m["mood"]} - ${m["points"]?? 0} pts", style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)), subtitle: Text(m["note"]?? "", maxLines: 1))); }).toList()); }); } if (snap.data == null) return const Center(child: CircularProgressIndicator()); if (snap.data!.docs.isEmpty) return Center(child: Text("No moods yet", style: GoogleFonts.poppins())); return ListView(children: snap.data!.docs.map((d) { var m = d.data() as Map<String, dynamic>; int p = m["points"]?? calculatePoints(m["energy"]?? 3, m["stress"]?? 2, (m["sleep"]?? 7).toDouble()); return Card(child: ListTile(leading: Text(m["moodEmoji"]?? "😊", style: const TextStyle(fontSize: 24)), title: Text("${m["mood"]} - $p pts", style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600)), subtitle: Text(m["note"]?? "", maxLines: 1))); }).toList()); })), ]))); } Widget _card(String v, String t, IconData ic) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)]), child: Column(children: [Icon(ic, color: const Color(0xFF6A11CB)), Text(v, style: GoogleFonts.poppins(fontWeight: FontWeight.bold)), Text(t, style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey))])); }

// ADD PAGE - FIXED COLORS + SCROLL UP/DOWN + POPUP
class AddMoodPage extends StatefulWidget { const AddMoodPage({super.key}); @override State<AddMoodPage> createState() => _AddMoodPageState(); }
class _AddMoodPageState extends State<AddMoodPage> {
  String mood = "Happy"; String emoji = "😊"; int energy = 5; int stress = 2; double sleep = 2.5;
  final note = TextEditingController(); final trig = TextEditingController(); bool isSaving = false;
  late FixedExtentScrollController energyCtrl; late FixedExtentScrollController stressCtrl; late FixedExtentScrollController sleepCtrl;
  @override void initState() { super.initState(); energyCtrl = FixedExtentScrollController(initialItem: energy - 1); stressCtrl = FixedExtentScrollController(initialItem: stress - 1); sleepCtrl = FixedExtentScrollController(initialItem: (sleep * 2).round()); }
  @override void dispose() { energyCtrl.dispose(); stressCtrl.dispose(); sleepCtrl.dispose(); note.dispose(); trig.dispose(); super.dispose(); }
  List<Map<String, dynamic>> moodList = [{"name": "Happy", "emoji": "😊", "color": const Color(0xFFFBBF24)}, {"name": "Calm", "emoji": "😌", "color": const Color(0xFF38BDF8)}, {"name": "Excited", "emoji": "🤩", "color": const Color(0xFFE879F9)}, {"name": "Sad", "emoji": "😔", "color": const Color(0xFF94A3B8)}, {"name": "Anxious", "emoji": "😰", "color": const Color(0xFFFB923C)}, {"name": "Angry", "emoji": "😠", "color": const Color(0xFFFB7185)}];

  Future<void> saveMood() async {
    if (isSaving) return;
    setState(() => isSaving = true);
    int pts = calculatePoints(energy, stress, sleep);
    try {
      await FirebaseFirestore.instance.collection("moods").add({"userId": FirebaseAuth.instance.currentUser!.uid, "mood": mood, "moodEmoji": emoji, "energy": energy, "stress": stress, "sleep": sleep, "points": pts, "note": note.text.trim(), "trigger": trig.text.trim(), "timestamp": FieldValue.serverTimestamp(), "date": DateFormat('yyyy-MM-dd').format(DateTime.now())});
      if (!mounted) return;
      setState(() => isSaving = false);
      showDialog(context: context, barrierDismissible: false, builder: (ctx) => Dialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), child: Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Column(mainAxisSize: MainAxisSize.min, children: [Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.green.shade100, shape: BoxShape.circle), child: const Icon(Icons.check_rounded, color: Colors.green, size: 50)), const SizedBox(height: 16), Text("Saved Successfully! 🎉", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20)), const SizedBox(height: 8), Text("$emoji $mood", style: GoogleFonts.poppins(fontSize: 16)), Container(margin: const EdgeInsets.only(top: 8), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFF6A11CB).withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text("$pts Points Earned!", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF6A11CB)))), const SizedBox(height: 20), SizedBox(width: double.infinity, height: 48, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A11CB), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), onPressed: () { Navigator.pop(ctx); note.clear(); trig.clear(); }, child: Text("Awesome!", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold))))]))));
    } catch (e) { if (mounted) { setState(() => isSaving = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red)); } }
  }

  @override Widget build(BuildContext context) {
    int preview = calculatePoints(energy, stress, sleep);
    return Scaffold(backgroundColor: const Color(0xFFF8FAFC), appBar: AppBar(title: Text("Add Reflection", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]), borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: const Color(0xFF6A11CB).withOpacity(0.3), blurRadius: 12, offset: const Offset(0,4))]), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [Text(emoji, style: const TextStyle(fontSize: 20)), const SizedBox(width: 8), Text("$mood Preview", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))]), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Text("$preview pts", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: const Color(0xFF6A11CB), fontSize: 13)))])),
        const SizedBox(height: 14), Text("Select Mood", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)), const SizedBox(height: 8), Wrap(spacing: 8, runSpacing: 8, children: moodList.map((m) => ChoiceChip(label: Text("${m["emoji"]} ${m["name"]}", style: GoogleFonts.poppins(fontSize: 12)), selected: mood == m["name"], selectedColor: (m["color"] as Color).withOpacity(0.3), onSelected: (_) => setState(() { mood = m["name"]; emoji = m["emoji"]; }))).toList()), const SizedBox(height: 18),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: _wheelCard("Energy", "$energy/5", energyCtrl, 5, (i) { setState(() => energy = i + 1); }, (i) { return "${i + 1}"; }, energy - 1, const Color(0xFF0EA5E9))), const SizedBox(width: 10), Expanded(child: _wheelCard("Stress", "$stress/5", stressCtrl, 5, (i) { setState(() => stress = i + 1); }, (i) { return "${i + 1}"; }, stress - 1, const Color(0xFFEF4444))), const SizedBox(width: 10), Expanded(child: _wheelCard("Sleep", "${sleep.toStringAsFixed(1)}h", sleepCtrl, 25, (i) { setState(() => sleep = i * 0.5); }, (i) { return "${(i * 0.5).toStringAsFixed(1)}h"; }, (sleep * 2).round(), const Color(0xFF8B5CF6))) ]),
        const SizedBox(height: 16), TextField(controller: trig, style: GoogleFonts.poppins(fontSize: 13), decoration: InputDecoration(labelText: "⚡ Trigger", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))), const SizedBox(height: 12), TextField(controller: note, maxLines: 2, style: GoogleFonts.poppins(fontSize: 13), decoration: InputDecoration(labelText: "📝 Note", filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))), const SizedBox(height: 20),
        SizedBox(width: double.infinity, height: 56, child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A11CB), foregroundColor: Colors.white, disabledBackgroundColor: const Color(0xFF6A11CB).withOpacity(0.6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 6), onPressed: isSaving? null : saveMood, child: isSaving? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)) : Text("Save - $preview pts 🚀", style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)))),
        const SizedBox(height: 120),
      ])),
    );
  }
  Widget _wheelCard(String title, String value, FixedExtentScrollController ctrl, int count, Function(int) onChanged, String Function(int) label, int selectedIndex, Color mainColor) {
    return Column(children: [Text(title, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87)), const SizedBox(height: 4), Text(value, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: mainColor)), const SizedBox(height: 6), Container(height: 130, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: mainColor.withOpacity(0.2)), boxShadow: [BoxShadow(color: mainColor.withOpacity(0.1), blurRadius: 8)]), child: ListWheelScrollView.useDelegate(controller: ctrl, itemExtent: 36, perspective: 0.008, diameterRatio: 1.1, overAndUnderCenterOpacity: 0.4, onSelectedItemChanged: onChanged, physics: const FixedExtentScrollPhysics(), childDelegate: ListWheelChildBuilderDelegate(builder: (c, i) { if (i < 0 || i >= count) return null; bool isSel = i == selectedIndex; return Container(margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: isSel? mainColor : Colors.transparent, borderRadius: BorderRadius.circular(10)), child: Center(child: Text(label(i), style: GoogleFonts.poppins(fontWeight: isSel? FontWeight.bold : FontWeight.w500, fontSize: isSel? 14 : 12, color: isSel? Colors.white : Colors.black54)))); }, childCount: count)))]);
  }
}

class ReportsPage extends StatefulWidget { const ReportsPage({super.key}); @override State<ReportsPage> createState() => _ReportsPageState(); }
class _ReportsPageState extends State<ReportsPage> with SingleTickerProviderStateMixin {
  late TabController tab; String? selId;
  @override void initState() { super.initState(); tab = TabController(length: 2, vsync: this); selId = FirebaseAuth.instance.currentUser!.uid; }
  @override Widget build(BuildContext context) { bool isAdmin = isAdminUser(FirebaseAuth.instance.currentUser); String today = DateFormat('yyyy-MM-dd').format(DateTime.now()); return Scaffold(appBar: AppBar(title: Text("Reports", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)), bottom: TabBar(controller: tab, tabs: const [Tab(text: "Daily"), Tab(text: "Weekly")])), body: Column(children: [if (isAdmin) StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection("users").snapshots(), builder: (c, snap) { if (snap.data == null) return const LinearProgressIndicator(); return Padding(padding: const EdgeInsets.all(12), child: DropdownButtonFormField<String>(value: selId, decoration: InputDecoration(labelText: "Select User (Admin)", border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))), items: snap.data!.docs.map((d) { var u = d.data() as Map<String, dynamic>; return DropdownMenuItem<String>(value: u["uid"], child: Text(getNameFromEmail(u["email"]), style: GoogleFonts.poppins(fontSize: 12))); }).toList(), onChanged: (v) { setState(() { selId = v; }); })); }), Expanded(child: TabBarView(controller: tab, children: [StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection("moods").where("userId", isEqualTo: selId).where("date", isEqualTo: today).snapshots(), builder: (c, snap) { if (snap.data == null) return const Center(child: CircularProgressIndicator()); if (snap.data!.docs.isEmpty) return Center(child: Text("No logs today", style: GoogleFonts.poppins())); int total = 0; for (var d in snap.data!.docs) { var m = d.data() as Map<String, dynamic>; total += (m["points"]?? 0) as int; } return ListView(padding: const EdgeInsets.all(12), children: [Card(color: const Color(0xFF6A11CB), child: Padding(padding: const EdgeInsets.all(16), child: Text("Today $today\n${snap.data!.docs.length} logs | $total pts", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)))),...snap.data!.docs.map((d) { var m = d.data() as Map<String, dynamic>; return Card(child: ListTile(title: Text("${m["mood"]} - ${m["points"]} pts"), subtitle: Text(m["note"]?? ""))); }).toList()]); }), StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection("moods").where("userId", isEqualTo: selId).orderBy("timestamp", descending: true).limit(100).snapshots(), builder: (c, snap) { if (snap.hasError || snap.data == null) return Center(child: Text("No logs last 7 days", style: GoogleFonts.poppins())); var now = DateTime.now(); var week = snap.data!.docs.where((d) { var ts = (d.data() as Map<String, dynamic>)["timestamp"] as Timestamp?; if (ts == null) return false; return now.difference(ts.toDate()).inDays < 7; }).toList(); if (week.isEmpty) return Center(child: Text("No logs last 7 days", style: GoogleFonts.poppins())); Map<String, int> dayPts = {}; int total = 0; for (var d in week) { var m = d.data() as Map<String, dynamic>; int p = m["points"]?? 0; total += p; String day = DateFormat('yyyy-MM-dd').format((m["timestamp"] as Timestamp).toDate()); dayPts[day] = (dayPts[day]?? 0) + p; } String best = ""; int bestP = 0; dayPts.forEach((k, v) { if (v > bestP) { bestP = v; best = k; } }); return ListView(padding: const EdgeInsets.all(12), children: [Card(color: Colors.orange, child: Padding(padding: const EdgeInsets.all(16), child: Text("Weekly Total: $total pts\nBest Day: $best ($bestP pts)", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold)))),...dayPts.entries.map((e) => Card(color: e.key == best? Colors.amber.shade100 : null, child: ListTile(title: Text(e.key), trailing: Text("${e.value} pts", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)), leading: e.key == best? const Icon(Icons.star, color: Colors.amber) : null))).toList()]); })]))])); }
}

class InsightsPage extends StatelessWidget { const InsightsPage({super.key}); @override Widget build(BuildContext context) { String uid = FirebaseAuth.instance.currentUser!.uid; return Scaffold(appBar: AppBar(title: Text("Insights", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0), body: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection("moods").where("userId", isEqualTo: uid).orderBy("timestamp", descending: true).snapshots(), builder: (c, snap) { if (snap.hasError) { return StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection("moods").where("userId", isEqualTo: uid).snapshots(), builder: (c, s2) { if (s2.data == null) return const Center(child: CircularProgressIndicator()); return _buildContent(s2.data!.docs); }); } if (snap.data == null) return const Center(child: CircularProgressIndicator()); if (snap.data!.docs.isEmpty) return Center(child: Text("Log more", style: GoogleFonts.poppins())); return _buildContent(snap.data!.docs); })); } Widget _buildContent(List<DocumentSnapshot> docs) { String today = DateFormat('yyyy-MM-dd').format(DateTime.now()); String yest = DateFormat('yyyy-MM-dd').format(DateTime.now().subtract(const Duration(days: 1))); int todayP = 0, yestP = 0, totalP = 0; Map<String, int> daily = {}; for (var d in docs) { var m = d.data() as Map<String, dynamic>; int p = m["points"]?? 0; totalP += p; String dt = m["date"]?? ""; daily[dt] = (daily[dt]?? 0) + p; if (dt == today) todayP += p; if (dt == yest) yestP += p; } String best = ""; int bestP = 0; daily.forEach((k, v) { if (v > bestP) { bestP = v; best = k; } }); int tomorrow = daily.isNotEmpty? (totalP / daily.length).round() : 50; return SingleChildScrollView(physics: const BouncingScrollPhysics(), padding: const EdgeInsets.all(16), child: Column(children: [SizedBox(height: 145, child: PageView(physics: const BouncingScrollPhysics(), children: [_b("Today", "$todayP pts", today, Colors.blue), _b("Yesterday", "$yestP pts", yest, Colors.grey), _b("Tomorrow", "~$tomorrow pts", "Predicted", Colors.orange)])), const SizedBox(height: 12), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), decoration: BoxDecoration(gradient: LinearGradient(colors: todayP >= yestP? [Colors.green, Colors.teal] : [Colors.red, Colors.orange]), borderRadius: BorderRadius.circular(12)), child: Row(children: [Icon(todayP >= yestP? Icons.trending_up : Icons.trending_down, color: Colors.white, size: 18), const SizedBox(width: 8), Expanded(child: Text("Today $todayP vs Yesterday $yestP - ${todayP >= yestP? "Improving 🚀" : "Decreasing"}", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)))])), const SizedBox(height: 12), Row(children: [Expanded(child: _b("Total", "$totalP pts", "${docs.length} logs", Colors.amber)), const SizedBox(width: 10), Expanded(child: _b("Best Day", best.isEmpty? "N/A" : best, "$bestP pts", Colors.purple))]), const SizedBox(height: 100)])); } Widget _b(String t, String v, String sub, Color c) => Container(margin: const EdgeInsets.all(6), padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: c.withOpacity(0.15), blurRadius: 8)], border: Border.all(color: c.withOpacity(0.15))), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.star, color: c, size: 18), const SizedBox(height: 4), Flexible(child: Text(v, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis)), Text(t, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600)), const SizedBox(height: 2), Flexible(child: Text(sub, style: GoogleFonts.poppins(fontSize: 9, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis))])); }

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});
  @override State<HistoryPage> createState() => _HistoryPageState();
}
class _HistoryPageState extends State<HistoryPage> {
  bool isClearing = false;

  Future<void> clearAll() async {
    bool? ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Clear History?", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text("Delete all your mood logs? This cannot be undone.", style: GoogleFonts.poppins(fontSize: 13)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text("Cancel", style: GoogleFonts.poppins())),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), onPressed: () => Navigator.pop(ctx, true), child: Text("Clear", style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold))),
        ],
      ),
    );
    if (ok != true) return;

    setState(() => isClearing = true);

    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      // FIXED: No orderBy - gets all docs even if timestamp is null
      var snap = await FirebaseFirestore.instance.collection("moods").where("userId", isEqualTo: uid).get();

      if (snap.docs.isEmpty) {
        if (mounted) {
          setState(() => isClearing = false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No history to clear", style: GoogleFonts.poppins()), backgroundColor: Colors.orange));
        }
        return;
      }

      // Use batch for fast delete
      WriteBatch batch = FirebaseFirestore.instance.batch();
      for (var d in snap.docs) {
        batch.delete(d.reference);
      }
      await batch.commit();

      if (mounted) {
        setState(() => isClearing = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("History cleared! ${snap.docs.length} logs deleted", style: GoogleFonts.poppins(color: Colors.white)), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
      }
    } catch (e) {
      print("CLEAR ERROR: $e");
      if (mounted) {
        setState(() => isClearing = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to clear: $e"), backgroundColor: Colors.red));
      }
    }
  }

  @override Widget build(BuildContext context) {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
          title: Text("History", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.white, elevation: 0,
          actions: [
            isClearing
                ? const Padding(padding: EdgeInsets.all(16), child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)))
                : IconButton(icon: const Icon(Icons.delete_forever, color: Colors.red), onPressed: clearAll)
          ]
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection("moods").where("userId", isEqualTo: uid).orderBy("timestamp", descending: true).snapshots(),
          builder: (c, snap) {
            // FIXED: If orderBy fails due to null timestamp, fallback to no orderBy query
            if (snap.hasError) {
              return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection("moods").where("userId", isEqualTo: uid).snapshots(),
                  builder: (c, s2) {
                    if (s2.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                    if (s2.data == null || s2.data!.docs.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.history, size: 60, color: Colors.grey.shade300), const SizedBox(height: 12), Text("No history", style: GoogleFonts.poppins(color: Colors.grey))]));
                    // Sort manually by timestamp
                    var docs = s2.data!.docs.toList();
                    docs.sort((a,b){
                      var ta = (a.data() as Map<String,dynamic>)["timestamp"] as Timestamp?;
                      var tb = (b.data() as Map<String,dynamic>)["timestamp"] as Timestamp?;
                      if(ta==null && tb==null) return 0;
                      if(ta==null) return 1;
                      if(tb==null) return -1;
                      return tb.compareTo(ta);
                    });
                    return ListView.builder(padding: const EdgeInsets.all(12), itemCount: docs.length, itemBuilder: (c, i) { var m = docs[i].data() as Map<String, dynamic>; var ts = m["timestamp"] as Timestamp?; return Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), child: ListTile(leading: Text(m["moodEmoji"]?? "😊", style: const TextStyle(fontSize: 24)), title: Text("${m["mood"]} - ${m["points"]} pts", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)), subtitle: Text(m["note"]?? "", maxLines: 1, style: GoogleFonts.poppins(fontSize: 11)), trailing: Text(ts!=null? DateFormat('MMM dd, hh:mm a').format(ts.toDate()) : "Now", style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)))); });
                  }
              );
            }
            if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snap.data == null || snap.data!.docs.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.history, size: 60, color: Colors.grey.shade300), const SizedBox(height: 12), Text("No history", style: GoogleFonts.poppins(color: Colors.grey))]));
            return ListView.builder(padding: const EdgeInsets.all(12), itemCount: snap.data!.docs.length, itemBuilder: (c, i) { var m = snap.data!.docs[i].data() as Map<String, dynamic>; var ts = m["timestamp"] as Timestamp?; return Card(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 1, child: ListTile(leading: Text(m["moodEmoji"]?? "😊", style: const TextStyle(fontSize: 24)), title: Text("${m["mood"]} - ${m["points"]} pts", style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)), subtitle: Text(m["note"]?? "", maxLines: 1, style: GoogleFonts.poppins(fontSize: 11)), trailing: Text(ts!=null? DateFormat('MMM dd, hh:mm a').format(ts.toDate()) : "Now", style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey)))); });
          }
      ),
    );
  }
}

class UsersPage extends StatelessWidget { const UsersPage({super.key}); @override Widget build(BuildContext context) { if (!isAdminUser(FirebaseAuth.instance.currentUser)) return Scaffold(appBar: AppBar(title: const Text("Access Denied")), body: const Center(child: Text("Admin Only"))); return Scaffold(appBar: AppBar(title: Text("Users - Admin", style: GoogleFonts.poppins(fontWeight: FontWeight.bold))), body: StreamBuilder<QuerySnapshot>(stream: FirebaseFirestore.instance.collection("users").snapshots(), builder: (c, snap) { if (snap.data == null) return const Center(child: CircularProgressIndicator()); return ListView.builder(padding: const EdgeInsets.all(12), itemCount: snap.data!.docs.length, itemBuilder: (c, i) { var u = snap.data!.docs[i].data() as Map<String, dynamic>; return Card(child: ListTile(leading: CircleAvatar(child: Text(safeInitial(u["name"]?? u["email"]))),title: Text(u["username"]?? u["name"]?? getNameFromEmail(u["email"])), subtitle: Text(u["email"]?? ""))); }); })); } }

class ProfilePage extends StatelessWidget { const ProfilePage({super.key}); @override Widget build(BuildContext context) {
  User? user = FirebaseAuth.instance.currentUser;
  if (user == null) return const Scaffold(body: Center(child: Text("No user")));
  return Scaffold(appBar: AppBar(title: Text("Profile", style: GoogleFonts.poppins(fontWeight: FontWeight.bold))),
      body: StreamBuilder<DocumentSnapshot>(stream: FirebaseFirestore.instance.collection("users").doc(user.uid).snapshots(), builder: (c, snap){
        String username = user.displayName ?? "User";
        if(snap.hasData && snap.data!.exists){
          var data = snap.data!.data() as Map<String, dynamic>;
          username = data["username"] ?? data["name"] ?? user.displayName ?? "User";
        }
        return Padding(padding: const EdgeInsets.all(20), child: Column(children: [
          CircleAvatar(radius: 50, backgroundColor: const Color(0xFF6A11CB), child: Text(safeInitial(username), style: const TextStyle(fontSize: 40, color: Colors.white))),
          const SizedBox(height: 12),
          Text(username, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold)), // ✅ NOW SHOWS USERNAME NOT EMAIL
          Text(user.email?? "", style: GoogleFonts.poppins(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 20),
          Card(child: ListTile(leading: const Icon(Icons.logout, color: Colors.red), title: Text("Logout", style: GoogleFonts.poppins(color: Colors.red)), onTap: () async { await FirebaseAuth.instance.signOut(); if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const OnboardingPage()), (r) => false); }))]));
      })); } }