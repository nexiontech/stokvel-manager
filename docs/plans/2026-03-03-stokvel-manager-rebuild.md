# Stokvel Manager - Selective Rebuild Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Rebuild the Stokvel Manager Flutter app with tested screens/providers/services, keeping the existing models, theme, and architecture.

**Architecture:** Flutter + Firebase (Auth, Firestore, Storage) with Riverpod state management and GoRouter navigation. Feature-module structure: `core/` -> `shared/` -> `features/`. English-only UI. No payment processing - tracking and proof-of-payment management only.

**Tech Stack:** Flutter 3.11+, Dart 3.11+, Firebase (Auth, Firestore, Storage), Riverpod 2.6, GoRouter 14.8, Google Fonts, image_picker

---

## Phase 0: Foundation - Get the App Building and Running

### Task 0.1: Remove l10n and fix build errors

**Files:**
- Delete: `lib/l10n/app_en.arb`
- Delete: `lib/l10n/app_zu.arb`
- Delete: `lib/l10n/l10n.dart`
- Delete: `l10n.yaml`
- Modify: `pubspec.yaml` (remove generate: true under flutter)
- Modify: `lib/main.dart`

**Step 1: Remove l10n files and config**

Delete these files:
- `lib/l10n/app_en.arb`
- `lib/l10n/app_zu.arb`
- `lib/l10n/l10n.dart`
- `l10n.yaml`

**Step 2: Update pubspec.yaml**

Remove `generate: true` from the `flutter:` section. Keep `flutter_localizations` dependency for Material localizations (date pickers etc).

**Step 3: Rewrite lib/main.dart**

```dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/profile/providers/profile_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ProviderScope(child: StokvelManagerApp()));
}

class StokvelManagerApp extends ConsumerWidget {
  const StokvelManagerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final isDark = ref.watch(darkModeProvider);

    return MaterialApp.router(
      title: 'Stokvel Manager',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
    );
  }
}
```

**Step 4: Rewrite lib/core/routing/app_router.dart**

Remove the `AppLocalizations` import and replace all `l10n.xxx` references with hardcoded English strings. The `_ShellScaffold` labels become: 'Home', 'Groups', 'Money', 'Profile'. The `_MoneyTabScreen` tabs become: 'Contributions', 'Payouts', 'Meetings'.

**Step 5: Create stub screens for all features**

Create minimal stub screens for every route so the app compiles. Each stub is a `Scaffold` with an `AppBar` showing the screen name and a centered `Text` widget. Features will be rebuilt one by one in later phases.

Stubs needed:
- `lib/features/onboarding/screens/splash_screen.dart`
- `lib/features/onboarding/screens/onboarding_screen.dart`
- `lib/features/auth/screens/phone_auth_screen.dart`
- `lib/features/auth/screens/otp_screen.dart`
- `lib/features/auth/screens/profile_setup_screen.dart`
- `lib/features/dashboard/screens/dashboard_screen.dart`
- `lib/features/groups/screens/groups_list_screen.dart`
- `lib/features/groups/screens/group_detail_screen.dart`
- `lib/features/groups/screens/create_group_screen.dart`
- `lib/features/groups/screens/invite_screen.dart`
- `lib/features/contributions/screens/contributions_screen.dart`
- `lib/features/contributions/screens/record_contribution_screen.dart`
- `lib/features/contributions/screens/contribution_detail_screen.dart`
- `lib/features/payouts/screens/payouts_screen.dart`
- `lib/features/payouts/screens/payout_detail_screen.dart`
- `lib/features/meetings/screens/meetings_screen.dart`
- `lib/features/meetings/screens/schedule_meeting_screen.dart`
- `lib/features/meetings/screens/meeting_detail_screen.dart`
- `lib/features/profile/screens/profile_screen.dart`
- `lib/features/notifications/screens/notifications_screen.dart`

Each stub screen should accept the same constructor parameters that `app_router.dart` passes. For example:

```dart
// lib/features/groups/screens/group_detail_screen.dart
import 'package:flutter/material.dart';

class GroupDetailScreen extends StatelessWidget {
  final String groupId;
  const GroupDetailScreen({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Group Detail')),
      body: Center(child: Text('Group: $groupId')),
    );
  }
}
```

**Step 6: Verify providers compile**

Ensure these providers exist and compile:
- `lib/features/auth/providers/auth_provider.dart` (keep existing)
- `lib/features/profile/providers/profile_provider.dart` (keep existing)

**Step 7: Run flutter analyze**

Run: `flutter analyze`
Expected: 0 errors, 0 warnings (or only minor warnings)

**Step 8: Run on Android emulator or iOS simulator**

Run: `flutter run` on a connected device/emulator.
Expected: App launches, shows splash screen, navigates to onboarding stub.

**Step 9: Commit**

```bash
git add -A
git commit -m "chore: remove l10n, create stub screens, fix build errors"
```

---

## Phase 1: Authentication

### Task 1.1: Rebuild Splash Screen

**Files:**
- Modify: `lib/features/onboarding/screens/splash_screen.dart`

**Step 1: Implement splash screen**

```dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.accent,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.savings, size: 80, color: AppColors.primaryLight),
              const SizedBox(height: 16),
              Text(
                'Stokvel Manager',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Manage your stokvel with ease',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Step 2: Verify it renders**

Run: `flutter run` and confirm splash screen shows with animation.

**Step 3: Commit**

```bash
git add lib/features/onboarding/screens/splash_screen.dart
git commit -m "feat: implement splash screen with fade animation"
```

### Task 1.2: Rebuild Onboarding Screen

**Files:**
- Modify: `lib/features/onboarding/screens/onboarding_screen.dart`

**Step 1: Implement 3-page onboarding carousel**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      icon: Icons.savings,
      title: 'Track Contributions',
      description:
          'Record and track every member\'s contributions with proof of payment.',
    ),
    _OnboardingPage(
      icon: Icons.calendar_month,
      title: 'Manage Payouts & Meetings',
      description:
          'Automate rotation schedules and organise group meetings with RSVP.',
    ),
    _OnboardingPage(
      icon: Icons.groups,
      title: 'Stay Connected',
      description:
          'Keep your stokvel group organised, transparent, and accountable.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.goNamed(RouteNames.phoneAuth);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => context.goNamed(RouteNames.phoneAuth),
                  child: const Text('Skip'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _currentPage = i),
                  itemBuilder: (_, i) => _buildPage(_pages[i]),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _currentPage == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _currentPage == i
                          ? AppColors.primary
                          : AppColors.divider,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              AppButton(
                label: _currentPage == _pages.length - 1
                    ? 'Get Started'
                    : 'Next',
                onPressed: _next,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(page.icon, size: 120, color: AppColors.primary),
        const SizedBox(height: 32),
        Text(
          page.title,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          page.description,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondaryLight,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String description;
  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.description,
  });
}
```

**Step 2: Test navigation flow**

Run the app. Verify:
- 3 pages swipe correctly
- Dot indicators update
- Skip button goes to phone auth
- Get Started button goes to phone auth

**Step 3: Commit**

```bash
git add lib/features/onboarding/screens/onboarding_screen.dart
git commit -m "feat: implement onboarding carousel with 3 pages"
```

### Task 1.3: Rebuild Phone Auth Screen

**Files:**
- Modify: `lib/features/auth/screens/phone_auth_screen.dart`

**Step 1: Implement phone auth screen**

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../providers/auth_provider.dart';

class PhoneAuthScreen extends ConsumerStatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  ConsumerState<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends ConsumerState<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your phone number';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 9) {
      return 'Enter a valid 9-digit SA phone number';
    }
    return null;
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    final phoneNumber = '+27$digits';
    ref.read(authStateProvider.notifier).verifyPhoneNumber(phoneNumber);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    ref.listen<AuthState>(authStateProvider, (prev, next) {
      if (next.status == AuthStatus.codeSent) {
        context.goNamed(RouteNames.otp);
      }
      if (next.status == AuthStatus.error && next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  'Stokvel Manager',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppColors.primary,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter your phone number to get started',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                ),
                const SizedBox(height: 32),
                AppTextField(
                  label: 'Phone Number',
                  hint: '81 234 5678',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                  prefix: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '\u{1F1FF}\u{1F1E6}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '+27',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(width: 8),
                        Container(width: 1, height: 24, color: AppColors.divider),
                      ],
                    ),
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'We\'ll send you an SMS with a verification code.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 32),
                AppButton(
                  label: 'Continue',
                  onPressed: isLoading ? null : _continue,
                  isLoading: isLoading,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text('or',
                          style: Theme.of(context).textTheme.bodySmall),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: isLoading
                      ? null
                      : () => ref
                          .read(authStateProvider.notifier)
                          .signInWithGoogle(),
                  icon: const Icon(Icons.g_mobiledata, size: 24),
                  label: const Text('Continue with Google'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: AppColors.divider),
                  ),
                ),
                const Spacer(),
                Center(
                  child: Text.rich(
                    TextSpan(
                      text: 'By continuing, you agree to our ',
                      style: Theme.of(context).textTheme.bodySmall,
                      children: [
                        TextSpan(
                          text: 'Terms',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
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
```

**Step 2: Run and verify**

Run the app, navigate to phone auth. Verify:
- +27 prefix renders
- Phone validation works (9 digits)
- Google sign-in button is present
- Loading state shows on submit

**Step 3: Commit**

```bash
git add lib/features/auth/screens/phone_auth_screen.dart
git commit -m "feat: implement phone auth screen with validation"
```

### Task 1.4: Rebuild OTP Screen

**Files:**
- Modify: `lib/features/auth/screens/otp_screen.dart`

**Step 1: Implement OTP screen**

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  Timer? _resendTimer;
  int _resendSeconds = 60;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendSeconds = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() => _resendSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    if (_otp.length == 6) {
      _verify();
    }
  }

  void _verify() {
    if (_otp.length != 6) return;
    ref.read(authStateProvider.notifier).verifyOtp(_otp);
  }

  void _resend() {
    ref.read(authStateProvider.notifier).resendCode();
    _startResendTimer();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.status == AuthStatus.loading;

    ref.listen<AuthState>(authStateProvider, (prev, next) {
      if (next.status == AuthStatus.error && next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verification Code',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Enter the 6-digit code sent to ${authState.phoneNumber ?? "your phone"}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (i) {
                  return SizedBox(
                    width: 48,
                    child: TextField(
                      controller: _controllers[i],
                      focusNode: _focusNodes[i],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: Theme.of(context).textTheme.headlineSmall,
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (v) => _onDigitChanged(i, v),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              AppButton(
                label: 'Verify',
                onPressed: isLoading ? null : _verify,
                isLoading: isLoading,
              ),
              const SizedBox(height: 24),
              Center(
                child: _resendSeconds > 0
                    ? Text(
                        'Resend code in ${_resendSeconds}s',
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    : TextButton(
                        onPressed: _resend,
                        child: const Text('Resend Code'),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Step 2: Run and verify**

Run the app, reach OTP screen. Verify:
- 6 digit fields render
- Focus moves between fields
- Resend timer counts down
- Auto-submits on 6th digit

**Step 3: Commit**

```bash
git add lib/features/auth/screens/otp_screen.dart
git commit -m "feat: implement OTP verification screen with resend timer"
```

### Task 1.5: Rebuild Profile Setup Screen

**Files:**
- Modify: `lib/features/auth/screens/profile_setup_screen.dart`

**Step 1: Implement profile setup**

```dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/user_profile.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../../core/services/user_service.dart';
import '../providers/auth_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _avatarPath;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (image != null) {
      setState(() => _avatarPath = image.path);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authStateProvider).user!;
      String? avatarUrl;

      if (_avatarPath != null) {
        final ref = FirebaseStorage.instance
            .ref('avatars/${user.uid}.jpg');
        await ref.putFile(File(_avatarPath!));
        avatarUrl = await ref.getDownloadURL();
      }

      final profile = UserProfile(
        uid: user.uid,
        displayName: _nameController.text.trim(),
        phone: user.phoneNumber ?? '',
        avatarUrl: avatarUrl,
        fcmTokens: [],
        stokvels: [],
        createdAt: DateTime.now(),
        settings: const UserSettings(),
      );

      await UserService().createProfile(profile);

      if (mounted) {
        context.goNamed(RouteNames.dashboard);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set Up Profile')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage: _avatarPath != null
                        ? FileImage(File(_avatarPath!))
                        : null,
                    child: _avatarPath == null
                        ? Icon(Icons.camera_alt,
                            size: 32, color: AppColors.primary)
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _pickImage,
                  child: const Text('Add Photo'),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: 'Display Name',
                  hint: 'Enter your name',
                  controller: _nameController,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Name is required'
                      : null,
                ),
                const Spacer(),
                AppButton(
                  label: 'Continue',
                  onPressed: _isLoading ? null : _save,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

**Step 2: Run and verify**

Run the app, complete auth flow to reach profile setup. Verify:
- Avatar picker works
- Name validation works
- Profile saves to Firestore
- Redirects to dashboard on success

**Step 3: Commit**

```bash
git add lib/features/auth/screens/profile_setup_screen.dart
git commit -m "feat: implement profile setup with avatar upload"
```

---

## Phase 2: Groups

### Task 2.1: Rebuild Group Service

**Files:**
- Create: `lib/features/groups/services/group_service.dart`

**Step 1: Implement group service**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/firestore_service.dart';
import '../../../shared/models/member.dart';
import '../../../shared/models/stokvel.dart';

class GroupService {
  final FirestoreService _db = FirestoreService();

  Future<String> createStokvel(Stokvel stokvel, String userId) async {
    final doc = await _db.create('stokvels', stokvel.toJson());

    // Add creator as chairperson
    final member = StokvelMember(
      id: userId,
      userId: userId,
      displayName: stokvel.name,
      phone: '',
      role: MemberRole.chairperson,
      rotationOrder: 1,
      joinedAt: DateTime.now(),
      status: MemberStatus.active,
    );
    await _db.set(
      'stokvels/${doc.id}/members/$userId',
      member.toJson(),
    );

    // Add stokvel to user's list
    await _db.update('users/$userId', {
      'stokvels': FieldValue.arrayUnion([doc.id]),
    });

    return doc.id;
  }

  Stream<List<Stokvel>> streamUserStokvels(List<String> stokvelIds) {
    if (stokvelIds.isEmpty) return Stream.value([]);
    return FirebaseFirestore.instance
        .collection('stokvels')
        .where(FieldPath.documentId, whereIn: stokvelIds)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Stokvel.fromJson(d.data(), d.id)).toList());
  }

  Stream<Stokvel?> streamStokvel(String stokvelId) {
    return _db.streamDocument('stokvels/$stokvelId').map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return Stokvel.fromJson(snap.data()!, snap.id);
    });
  }

  Stream<List<StokvelMember>> streamMembers(String stokvelId) {
    return FirebaseFirestore.instance
        .collection('stokvels/$stokvelId/members')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => StokvelMember.fromJson(d.data(), d.id))
            .toList());
  }

  Future<void> updateStokvel(String stokvelId, Map<String, dynamic> data) {
    return _db.update('stokvels/$stokvelId', data);
  }

  Future<void> addMember(String stokvelId, StokvelMember member) async {
    await _db.set(
      'stokvels/$stokvelId/members/${member.userId}',
      member.toJson(),
    );
    await _db.update('stokvels/$stokvelId', {
      'memberCount': FieldValue.increment(1),
    });
    await _db.update('users/${member.userId}', {
      'stokvels': FieldValue.arrayUnion([stokvelId]),
    });
  }
}
```

**Step 2: Commit**

```bash
git add lib/features/groups/services/group_service.dart
git commit -m "feat: implement group service with Firestore CRUD"
```

### Task 2.2: Rebuild Groups Provider

**Files:**
- Create: `lib/features/groups/providers/groups_provider.dart`

**Step 1: Implement groups provider**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/models/stokvel.dart';
import '../../../shared/models/member.dart';
import '../services/group_service.dart';

final groupServiceProvider = Provider<GroupService>((ref) => GroupService());

final userStokvelsProvider = StreamProvider<List<Stokvel>>((ref) {
  final profile = ref.watch(userProfileProvider).valueOrNull;
  if (profile == null || profile.stokvels.isEmpty) {
    return Stream.value([]);
  }
  return ref.watch(groupServiceProvider).streamUserStokvels(profile.stokvels);
});

final stokvelProvider =
    StreamProvider.family<Stokvel?, String>((ref, stokvelId) {
  return ref.watch(groupServiceProvider).streamStokvel(stokvelId);
});

final membersProvider =
    StreamProvider.family<List<StokvelMember>, String>((ref, stokvelId) {
  return ref.watch(groupServiceProvider).streamMembers(stokvelId);
});
```

**Step 2: Commit**

```bash
git add lib/features/groups/providers/groups_provider.dart
git commit -m "feat: implement groups provider with stream-based state"
```

### Task 2.3: Rebuild Groups List Screen

**Files:**
- Modify: `lib/features/groups/screens/groups_list_screen.dart`

**Step 1: Implement groups list**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/stokvel_avatar.dart';
import '../../../shared/widgets/stokvel_type_chip.dart';
import '../providers/groups_provider.dart';

class GroupsListScreen extends ConsumerWidget {
  const GroupsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stokvelsAsync = ref.watch(userStokvelsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Groups'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.pushNamed(RouteNames.notifications),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(RouteNames.createGroup),
        child: const Icon(Icons.add),
      ),
      body: stokvelsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (stokvels) {
          if (stokvels.isEmpty) {
            return EmptyState(
              icon: Icons.groups,
              title: 'No Groups Yet',
              message: 'Create or join a stokvel to get started.',
              actionLabel: 'Create Group',
              onAction: () => context.pushNamed(RouteNames.createGroup),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: stokvels.length,
            itemBuilder: (context, index) {
              final s = stokvels[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AppCard(
                  onTap: () => context.pushNamed(
                    RouteNames.groupDetail,
                    pathParameters: {'id': s.id},
                  ),
                  child: Row(
                    children: [
                      StokvelAvatar(name: s.name, type: s.type),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.name,
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 4),
                            StokvelTypeChip(type: s.type),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'R${s.totalCollected.toStringAsFixed(0)}',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: AppColors.accent),
                          ),
                          Text(
                            '${s.memberCount} members',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

**Step 2: Run and verify**

Run the app. After auth, navigate to Groups tab. Verify empty state shows with Create Group button.

**Step 3: Commit**

```bash
git add lib/features/groups/screens/groups_list_screen.dart
git commit -m "feat: implement groups list screen with empty state"
```

### Task 2.4: Rebuild Create Group Screen

**Files:**
- Modify: `lib/features/groups/screens/create_group_screen.dart`

**Step 1: Implement create group wizard**

A multi-step form: Step 1 (name, type, description), Step 2 (contribution amount, frequency). Creates the stokvel in Firestore on submit.

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_names.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/models/stokvel.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/groups_provider.dart';

class CreateGroupScreen extends ConsumerStatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  ConsumerState<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends ConsumerState<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  StokvelType _type = StokvelType.rotational;
  String _frequency = 'monthly';
  int _currentStep = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = ref.read(authStateProvider).user!;
      final profile = ref.read(userProfileProvider).valueOrNull;

      final stokvel = Stokvel(
        id: '',
        name: _nameController.text.trim(),
        type: _type,
        description: _descController.text.trim(),
        contributionAmount: double.parse(_amountController.text),
        contributionFrequency: _frequency,
        currency: 'ZAR',
        createdBy: user.uid,
        createdAt: DateTime.now(),
        memberCount: 1,
        totalCollected: 0,
        nasasaRegistered: false,
      );

      final groupId =
          await ref.read(groupServiceProvider).createStokvel(stokvel, user.uid);

      if (mounted) {
        context.pushReplacementNamed(
          RouteNames.groupDetail,
          pathParameters: {'id': groupId},
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Stokvel')),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep == 0) {
              if (_nameController.text.trim().isEmpty) return;
              setState(() => _currentStep = 1);
            } else {
              _create();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              context.pop();
            }
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: _currentStep == 1 ? 'Create' : 'Next',
                      onPressed: _isLoading ? null : details.onStepContinue,
                      isLoading: _isLoading,
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (_currentStep > 0)
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text('Back'),
                    ),
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('Group Info'),
              isActive: _currentStep >= 0,
              content: Column(
                children: [
                  AppTextField(
                    label: 'Group Name',
                    hint: 'e.g. Family Savings Club',
                    controller: _nameController,
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Name is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<StokvelType>(
                    value: _type,
                    decoration: const InputDecoration(
                      labelText: 'Stokvel Type',
                      border: OutlineInputBorder(),
                    ),
                    items: StokvelType.values.map((t) {
                      return DropdownMenuItem(
                        value: t,
                        child: Text(t.displayName),
                      );
                    }).toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _type = v);
                    },
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Description (optional)',
                    hint: 'What is this group about?',
                    controller: _descController,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Contributions'),
              isActive: _currentStep >= 1,
              content: Column(
                children: [
                  AppTextField(
                    label: 'Contribution Amount (ZAR)',
                    hint: 'e.g. 500',
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Amount is required';
                      if (double.tryParse(v) == null) return 'Enter a valid number';
                      return null;
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _frequency,
                    decoration: const InputDecoration(
                      labelText: 'Frequency',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                      DropdownMenuItem(
                          value: 'bi-weekly', child: Text('Bi-weekly')),
                      DropdownMenuItem(
                          value: 'monthly', child: Text('Monthly')),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _frequency = v);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Step 2: Run and verify**

Create a stokvel. Verify it appears in the groups list.

**Step 3: Commit**

```bash
git add lib/features/groups/screens/create_group_screen.dart
git commit -m "feat: implement create group wizard with 2-step form"
```

### Task 2.5: Rebuild Group Detail Screen

**Files:**
- Modify: `lib/features/groups/screens/group_detail_screen.dart`

**Step 1: Implement group detail with tabs**

Build a tabbed detail screen: Overview, Members, Contributions, Payouts. Each tab shows relevant data streamed from Firestore. This is a larger screen - implement Overview and Members tabs, leave Contributions and Payouts tabs as placeholders that will be populated in Phase 3/4.

The screen should show:
- Overview tab: group name, type, contribution amount, frequency, total collected, member count
- Members tab: list of members with roles and status
- Contributions tab: placeholder linking to contributions screen
- Payouts tab: placeholder linking to payouts screen

**Step 2: Run and verify**

Navigate to a group detail. Verify tabs render with data from Firestore.

**Step 3: Commit**

```bash
git add lib/features/groups/screens/group_detail_screen.dart
git commit -m "feat: implement group detail screen with tabbed view"
```

### Task 2.6: Rebuild Invite Service and Screen

**Files:**
- Create: `lib/features/groups/services/invite_service.dart`
- Modify: `lib/features/groups/screens/invite_screen.dart`

**Step 1: Implement invite service**

```dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/firestore_service.dart';

class InviteService {
  final FirestoreService _db = FirestoreService();

  String _generateCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random.secure();
    return List.generate(8, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  Future<Map<String, String>> createInvite({
    required String stokvelId,
    required String stokvelName,
    required String createdBy,
  }) async {
    final code = _generateCode();
    final expiresAt = DateTime.now().add(const Duration(days: 7));

    await _db.set('invites/$code', {
      'stokvelId': stokvelId,
      'stokvelName': stokvelName,
      'createdBy': createdBy,
      'code': code,
      'expiresAt': Timestamp.fromDate(expiresAt),
    });

    return {'code': code};
  }

  Future<Map<String, dynamic>?> validateInvite(String code) async {
    final snap = await _db.read('invites/$code');
    if (!snap.exists || snap.data() == null) return null;

    final data = snap.data()!;
    final expiresAt = (data['expiresAt'] as Timestamp).toDate();
    if (expiresAt.isBefore(DateTime.now())) return null;

    return data;
  }
}
```

**Step 2: Implement invite screen with QR code and share**

The invite screen shows the invite code, a QR code, and share button.

**Step 3: Commit**

```bash
git add lib/features/groups/services/invite_service.dart lib/features/groups/screens/invite_screen.dart
git commit -m "feat: implement invite system with QR code and share"
```

---

## Phase 3: Contributions

### Task 3.1: Rebuild Contribution Service

**Files:**
- Create: `lib/features/contributions/services/contribution_service.dart`

**Step 1: Implement contribution service**

```dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/firestore_service.dart';
import '../../../shared/models/contribution.dart';

class ContributionService {
  final FirestoreService _db = FirestoreService();

  Stream<List<Contribution>> streamGroupContributions(String stokvelId) {
    return FirebaseFirestore.instance
        .collection('stokvels/$stokvelId/contributions')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => Contribution.fromJson(d.data(), d.id))
            .toList());
  }

  Future<String?> uploadProof(String stokvelId, String contribId, XFile image) async {
    final ref = FirebaseStorage.instance
        .ref('stokvels/$stokvelId/proofs/$contribId.jpg');
    await ref.putFile(File(image.path));
    return ref.getDownloadURL();
  }

  Future<void> recordContribution({
    required String stokvelId,
    required Contribution contribution,
    XFile? proofImage,
  }) async {
    final doc = await _db.create(
      'stokvels/$stokvelId/contributions',
      contribution.toJson(),
    );

    if (proofImage != null) {
      final proofUrl = await uploadProof(stokvelId, doc.id, proofImage);
      await _db.update(
        'stokvels/$stokvelId/contributions/${doc.id}',
        {'proofUrl': proofUrl},
      );
    }

    if (contribution.status == ContributionStatus.paid) {
      await _db.update('stokvels/$stokvelId', {
        'totalCollected': FieldValue.increment(contribution.amount),
      });
    }
  }

  Future<void> updateContributionStatus(
    String stokvelId,
    String contribId,
    ContributionStatus status,
  ) {
    return _db.update('stokvels/$stokvelId/contributions/$contribId', {
      'status': status.firestoreValue,
    });
  }
}
```

**Step 2: Commit**

```bash
git add lib/features/contributions/services/contribution_service.dart
git commit -m "feat: implement contribution service with proof upload"
```

### Task 3.2: Rebuild Contribution Provider

**Files:**
- Create: `lib/features/contributions/providers/contribution_provider.dart`

**Step 1: Implement contribution provider**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/contribution.dart';
import '../services/contribution_service.dart';

final contributionServiceProvider =
    Provider<ContributionService>((ref) => ContributionService());

final groupContributionsProvider =
    StreamProvider.family<List<Contribution>, String>((ref, stokvelId) {
  return ref
      .watch(contributionServiceProvider)
      .streamGroupContributions(stokvelId);
});
```

**Step 2: Commit**

```bash
git add lib/features/contributions/providers/contribution_provider.dart
git commit -m "feat: implement contribution provider"
```

### Task 3.3: Rebuild Record Contribution Screen

**Files:**
- Modify: `lib/features/contributions/screens/record_contribution_screen.dart`

**Step 1: Implement record contribution screen**

Form with: member dropdown, amount field (pre-filled from group), date picker, proof photo button, notes field. On submit, calls `contributionService.recordContribution()`.

**Step 2: Run and verify**

Navigate to a group, record a contribution. Verify it appears in the contributions list.

**Step 3: Commit**

```bash
git add lib/features/contributions/screens/record_contribution_screen.dart
git commit -m "feat: implement record contribution with proof upload"
```

### Task 3.4: Rebuild Contributions List and Detail Screens

**Files:**
- Modify: `lib/features/contributions/screens/contributions_screen.dart`
- Modify: `lib/features/contributions/screens/contribution_detail_screen.dart`

**Step 1: Implement contributions list**

Streams contributions for the group, displays them grouped by month with status indicators (paid/pending/late).

**Step 2: Implement contribution detail**

Shows full contribution details including proof-of-payment image (if uploaded), status, amount, date, and notes.

**Step 3: Commit**

```bash
git add lib/features/contributions/screens/contributions_screen.dart lib/features/contributions/screens/contribution_detail_screen.dart
git commit -m "feat: implement contributions list and detail screens"
```

---

## Phase 4: Payouts

### Task 4.1: Rebuild Payout Service

**Files:**
- Create: `lib/features/payouts/services/payout_service.dart`

**Step 1: Implement payout service**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/firestore_service.dart';
import '../../../shared/models/member.dart';
import '../../../shared/models/payout.dart';

class PayoutService {
  final FirestoreService _db = FirestoreService();

  Stream<List<Payout>> streamGroupPayouts(String stokvelId) {
    return FirebaseFirestore.instance
        .collection('stokvels/$stokvelId/payouts')
        .orderBy('payoutDate')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Payout.fromJson(d.data(), d.id)).toList());
  }

  Future<void> generateRotationSchedule({
    required String stokvelId,
    required List<StokvelMember> members,
    required double contributionAmount,
  }) async {
    final batch = _db.batch();
    final col = FirebaseFirestore.instance
        .collection('stokvels/$stokvelId/payouts');

    // Sort by rotation order
    final sorted = [...members]
      ..sort((a, b) => (a.rotationOrder ?? 0).compareTo(b.rotationOrder ?? 0));

    final payoutAmount = contributionAmount * members.length;
    final now = DateTime.now();

    for (var i = 0; i < sorted.length; i++) {
      final member = sorted[i];
      final payoutDate = DateTime(now.year, now.month + i + 1, 1);
      final payout = Payout(
        id: '',
        recipientId: member.userId,
        recipientName: member.displayName,
        amount: payoutAmount,
        payoutDate: payoutDate,
        type: PayoutType.rotation,
        status: PayoutStatus.scheduled,
        approvedBy: [],
        createdAt: now,
      );
      batch.set(col.doc(), payout.toJson());
    }

    await batch.commit();
  }

  Future<void> updatePayoutStatus(
    String stokvelId,
    String payoutId,
    PayoutStatus status, {
    String? approverId,
  }) async {
    final data = <String, dynamic>{'status': status.firestoreValue};
    if (approverId != null) {
      data['approvedBy'] = FieldValue.arrayUnion([approverId]);
    }
    if (status == PayoutStatus.paid) {
      data['paidDate'] = Timestamp.now();
    }
    await _db.update('stokvels/$stokvelId/payouts/$payoutId', data);
  }
}
```

**Step 2: Commit**

```bash
git add lib/features/payouts/services/payout_service.dart
git commit -m "feat: implement payout service with rotation schedule"
```

### Task 4.2: Rebuild Payout Provider and Screens

**Files:**
- Create: `lib/features/payouts/providers/payout_provider.dart`
- Modify: `lib/features/payouts/screens/payouts_screen.dart`
- Modify: `lib/features/payouts/screens/payout_detail_screen.dart`

**Step 1: Implement payout provider**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/payout.dart';
import '../services/payout_service.dart';

final payoutServiceProvider =
    Provider<PayoutService>((ref) => PayoutService());

final groupPayoutsProvider =
    StreamProvider.family<List<Payout>, String>((ref, stokvelId) {
  return ref.watch(payoutServiceProvider).streamGroupPayouts(stokvelId);
});
```

**Step 2: Implement payouts list screen**

Shows payout schedule with recipient names, amounts, dates, and status badges.

**Step 3: Implement payout detail screen**

Shows full payout details with approve/mark-as-paid actions for admins.

**Step 4: Commit**

```bash
git add lib/features/payouts/providers/payout_provider.dart lib/features/payouts/screens/payouts_screen.dart lib/features/payouts/screens/payout_detail_screen.dart
git commit -m "feat: implement payout screens with rotation schedule"
```

---

## Phase 5: Meetings

### Task 5.1: Rebuild Meeting Service

**Files:**
- Create: `lib/features/meetings/services/meeting_service.dart`

**Step 1: Implement meeting service**

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/services/firestore_service.dart';
import '../../../shared/models/meeting.dart';

class MeetingService {
  final FirestoreService _db = FirestoreService();

  Stream<List<Meeting>> streamGroupMeetings(String stokvelId) {
    return FirebaseFirestore.instance
        .collection('stokvels/$stokvelId/meetings')
        .orderBy('date')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Meeting.fromJson(d.data(), d.id)).toList());
  }

  Future<void> createMeeting(String stokvelId, Meeting meeting) {
    return _db.create('stokvels/$stokvelId/meetings', meeting.toJson());
  }

  Future<void> updateRsvp(
      String stokvelId, String meetingId, String userId, String response) {
    return _db.update('stokvels/$stokvelId/meetings/$meetingId', {
      'rsvps.$userId': response,
    });
  }
}
```

**Step 2: Commit**

```bash
git add lib/features/meetings/services/meeting_service.dart
git commit -m "feat: implement meeting service"
```

### Task 5.2: Rebuild Meeting Provider and Screens

**Files:**
- Create: `lib/features/meetings/providers/meeting_provider.dart`
- Modify: `lib/features/meetings/screens/meetings_screen.dart`
- Modify: `lib/features/meetings/screens/schedule_meeting_screen.dart`
- Modify: `lib/features/meetings/screens/meeting_detail_screen.dart`

**Step 1: Implement meeting provider**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/models/meeting.dart';
import '../services/meeting_service.dart';

final meetingServiceProvider =
    Provider<MeetingService>((ref) => MeetingService());

final groupMeetingsProvider =
    StreamProvider.family<List<Meeting>, String>((ref, stokvelId) {
  return ref.watch(meetingServiceProvider).streamGroupMeetings(stokvelId);
});
```

**Step 2: Implement schedule meeting screen**

Form with: title, date picker, time picker, location/virtual toggle, agenda text field. On submit creates meeting in Firestore.

**Step 3: Implement meetings list screen**

Shows upcoming meetings with date, title, location, and RSVP count.

**Step 4: Implement meeting detail screen**

Shows full meeting details with RSVP buttons (Yes/No/Maybe) for current user.

**Step 5: Commit**

```bash
git add lib/features/meetings/
git commit -m "feat: implement meeting screens with scheduling and RSVP"
```

---

## Phase 6: Dashboard

### Task 6.1: Rebuild Dashboard Provider

**Files:**
- Create: `lib/features/dashboard/providers/dashboard_provider.dart`

**Step 1: Implement dashboard provider**

Aggregates data from user's stokvels: total savings, next contribution due, next payout, next meeting.

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../groups/providers/groups_provider.dart';

final totalSavingsProvider = Provider<double>((ref) {
  final stokvels = ref.watch(userStokvelsProvider).valueOrNull ?? [];
  return stokvels.fold(0.0, (sum, s) => sum + s.totalCollected);
});
```

**Step 2: Commit**

```bash
git add lib/features/dashboard/providers/dashboard_provider.dart
git commit -m "feat: implement dashboard data provider"
```

### Task 6.2: Rebuild Dashboard Screen

**Files:**
- Modify: `lib/features/dashboard/screens/dashboard_screen.dart`

**Step 1: Implement dashboard**

Shows:
- Greeting (Good morning/afternoon/evening)
- Total savings card
- Next contribution card
- Next payout card
- Next meeting card
- Quick action buttons (Create Group, Record Payment)

**Step 2: Run and verify**

Run the app with some test data. Verify dashboard cards show correct data.

**Step 3: Commit**

```bash
git add lib/features/dashboard/screens/dashboard_screen.dart
git commit -m "feat: implement dashboard with summary cards"
```

---

## Phase 7: Profile & Settings

### Task 7.1: Rebuild Profile Screen

**Files:**
- Modify: `lib/features/profile/screens/profile_screen.dart`
- Keep: `lib/features/profile/providers/profile_provider.dart`

**Step 1: Implement profile screen**

Shows:
- Avatar and name
- Phone number
- Settings section: dark mode toggle, notifications toggle
- Sign out button
- App version

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);
    final isDark = ref.watch(darkModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: profileAsync.when(
        loading: () => const LoadingIndicator(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('No profile found'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: profile.avatarUrl != null
                      ? NetworkImage(profile.avatarUrl!)
                      : null,
                  child: profile.avatarUrl == null
                      ? Text(
                          profile.displayName.isNotEmpty
                              ? profile.displayName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(fontSize: 32),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  profile.displayName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Center(
                child: Text(
                  profile.phone,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondaryLight,
                      ),
                ),
              ),
              const SizedBox(height: 32),
              const Divider(),
              SwitchListTile(
                title: const Text('Dark Mode'),
                value: isDark,
                onChanged: (v) =>
                    ref.read(darkModeProvider.notifier).state = v,
              ),
              const Divider(),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () =>
                    ref.read(authStateProvider.notifier).signOut(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(color: AppColors.error),
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: const Text('Sign Out'),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'v1.0.1',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
```

**Step 2: Run and verify**

Verify profile shows user data, dark mode toggle works, sign out works.

**Step 3: Commit**

```bash
git add lib/features/profile/screens/profile_screen.dart
git commit -m "feat: implement profile screen with settings"
```

---

## Phase 8: Polish

### Task 8.1: Wire up the Money tab

**Files:**
- Modify: `lib/core/routing/app_router.dart` (the `_MoneyTabScreen`)

**Step 1:** Ensure the Money tab's three sub-tabs (Contributions, Payouts, Meetings) show cross-group data. Each tab should stream all contributions/payouts/meetings across the user's stokvels.

**Step 2: Commit**

```bash
git commit -m "feat: wire up money tab with cross-group data"
```

### Task 8.2: Notifications stub

**Files:**
- Modify: `lib/features/notifications/screens/notifications_screen.dart`

**Step 1:** Implement a simple notifications screen that shows "No notifications yet" empty state. Real FCM integration is deferred.

**Step 2: Commit**

```bash
git commit -m "feat: implement notifications placeholder screen"
```

### Task 8.3: Error handling and loading states

**Step 1:** Review all screens and ensure:
- Every `AsyncValue.when()` has proper loading and error states
- Network errors show user-friendly snackbars
- Loading indicators use shimmer where appropriate
- Empty states have helpful messages and actions

**Step 2: Commit**

```bash
git commit -m "fix: improve error handling and loading states"
```

### Task 8.4: App icons and splash screen

**Step 1:** Verify app icons and splash screen are configured correctly:

```bash
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create
```

**Step 2: Commit**

```bash
git commit -m "chore: regenerate app icons and splash screen"
```

### Task 8.5: Final build verification

**Step 1:** Run full analysis and build:

```bash
flutter analyze
flutter build apk --release
flutter build ios --release --no-codesign
```

Expected: 0 errors, successful builds for both platforms.

**Step 2: Commit any final fixes**

```bash
git commit -m "chore: fix final build issues"
```

---

## Summary

| Phase | Tasks | Focus |
|-------|-------|-------|
| 0 | 1 task | Fix build, create stubs, get app running |
| 1 | 5 tasks | Auth: splash, onboarding, phone, OTP, profile setup |
| 2 | 6 tasks | Groups: service, provider, list, create, detail, invite |
| 3 | 4 tasks | Contributions: service, provider, record, list/detail |
| 4 | 2 tasks | Payouts: service + provider, screens |
| 5 | 2 tasks | Meetings: service, provider + screens |
| 6 | 2 tasks | Dashboard: provider, screen |
| 7 | 1 task | Profile: screen with settings |
| 8 | 5 tasks | Polish: money tab, notifications, errors, icons, build |

**Total: 28 tasks across 9 phases**

Each phase builds on the previous one. After Phase 0, the app compiles and runs. After Phase 1, users can authenticate. After Phase 2, they can create and manage groups. Each subsequent phase adds a complete feature vertical.
