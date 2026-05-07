# Stokvel Manager - Selective Rebuild Design

**Date:** 2026-03-03
**Approach:** Selective Rebuild - keep architecture/models, rebuild screens and providers with testing
**Target Platforms:** Android + iOS (web as bonus)
**Language:** English only (isiZulu deferred)
**Timeline:** ASAP

## Context

Stokvel Manager is a Flutter app for managing South African savings groups (stokvels). It tracks contributions, payouts, meetings, and member management. **No actual payment processing** - it's a coordination/tracking tool with proof-of-payment photo uploads.

The existing codebase has ~50 Dart files with solid architecture but has never been run or tested. The app currently fails to build due to a localization configuration issue. Rather than debugging untested AI-generated code, we'll rebuild screens and providers using the existing models and architecture as a foundation.

## What We Keep

- **Project structure:** `core/` -> `shared/` -> `features/`
- **State management:** Riverpod (StateNotifier + StreamProvider)
- **Navigation:** GoRouter with auth redirect
- **Backend:** Firebase (Auth, Firestore, Storage)
- **Data models:** Stokvel, StokvelMember, Contribution, Payout, Meeting, UserProfile
- **Theme:** AppColors + AppTheme (light/dark mode)
- **Shared widgets:** AppButton, AppCard, AppTextField, EmptyState, LoadingIndicator, StokvelAvatar, StokvelTypeChip
- **Firestore security rules and indexes**
- **Firebase configuration** (firebase_options.dart, google-services.json)

## What We Remove

- `l10n/` directory and all `AppLocalizations` references (English-only, hardcoded strings)
- `flutter_gen` dependency
- `l10n.yaml` configuration
- WhatsApp Cloud Functions (Phase 2 scope)
- All existing screens, providers, and services (rebuilt with tests)

## What We Rebuild

Every screen, provider, and service - tested as we go.

## Architecture

```
lib/
├── main.dart                     # Firebase init + ProviderScope + MaterialApp.router
├── core/
│   ├── theme/
│   │   ├── app_colors.dart       # Color constants
│   │   └── app_theme.dart        # Light/dark ThemeData
│   ├── routing/
│   │   ├── route_names.dart      # Route name constants
│   │   └── app_router.dart       # GoRouter config with auth guard
│   └── services/
│       ├── auth_service.dart     # Phone OTP + Google Sign-In
│       ├── firestore_service.dart # Generic Firestore CRUD
│       └── user_service.dart     # User profile operations
├── shared/
│   ├── models/                   # Kept as-is
│   │   ├── stokvel.dart
│   │   ├── member.dart
│   │   ├── contribution.dart
│   │   ├── payout.dart
│   │   ├── meeting.dart
│   │   └── user_profile.dart
│   └── widgets/                  # Rebuilt/verified
│       ├── app_button.dart
│       ├── app_card.dart
│       ├── app_text_field.dart
│       ├── empty_state.dart
│       ├── loading_indicator.dart
│       ├── stokvel_avatar.dart
│       └── stokvel_type_chip.dart
└── features/
    ├── onboarding/               # Splash + intro carousel
    ├── auth/                     # Phone, OTP, Google, profile setup
    ├── dashboard/                # Home summary
    ├── groups/                   # CRUD, members, invites
    ├── contributions/            # Record, track, proof upload
    ├── payouts/                  # Rotation schedule, tracking
    ├── meetings/                 # Schedule, RSVP
    ├── profile/                  # Settings, account
    └── notifications/            # In-app notifications (deferred)
```

## Firestore Schema

```
/users/{userId}
  - uid, displayName, phone, avatarUrl
  - fcmTokens[], stokvels[]
  - settings { darkMode, language, notificationsEnabled }
  - createdAt

/stokvels/{stokvelId}
  - name, type, description
  - contributionAmount, contributionFrequency, currency
  - memberCount, totalCollected
  - createdBy, createdAt
  - whatsappGroupId?, constitutionUrl?, nasasaRegistered

  /members/{memberId}
    - userId, displayName, phone
    - role (chairperson|treasurer|secretary|member)
    - rotationOrder?, joinedAt, status

  /contributions/{contributionId}
    - memberId, memberName, amount
    - dueDate, paidDate?, proofUrl?
    - status (pending|paid|late|excused)
    - recordedBy, createdAt, notes?

  /payouts/{payoutId}
    - recipientId, recipientName, amount
    - payoutDate, type, status
    - approvedBy[], createdAt, notes?

  /meetings/{meetingId}
    - title, date, locationName?, virtualLink?
    - agenda?, minutes?, rsvps {}
    - createdBy, createdAt

/invites/{inviteId}
  - stokvelId, stokvelName, createdBy
  - code, expiresAt, usedBy?
```

## Build Phases

### Phase 0: Foundation
- Fix build errors (remove l10n references, hardcode English)
- Verify Firebase config connects
- Get blank app running on Android + iOS simulator
- Verify theme renders correctly

### Phase 1: Auth
- Phone number input screen (+27 prefix)
- OTP verification screen (6-digit)
- Google Sign-In button
- Profile setup screen (name, avatar upload)
- Auth state provider with redirect logic
- Tests: auth flow, OTP validation, profile creation

### Phase 2: Groups
- Create stokvel wizard (name, type, contribution amount)
- Groups list screen (stream from Firestore)
- Group detail screen (overview, members tab)
- Invite system (generate code, QR, share link)
- Join group flow
- Tests: create group, list groups, invite/join

### Phase 3: Contributions
- Record contribution screen (member select, amount, proof photo)
- Contribution list per group (monthly grouping)
- Contribution detail with proof image
- Monthly contribution generation (batch create pending entries)
- Tests: record payment, upload proof, monthly generation

### Phase 4: Payouts
- Rotation schedule generation
- Payout list screen
- Payout detail with status
- Approval workflow (admin marks as paid)
- Tests: rotation order, approval flow

### Phase 5: Meetings
- Schedule meeting screen (date, location/virtual, agenda)
- Meetings list (upcoming)
- Meeting detail with RSVP
- Tests: create meeting, RSVP

### Phase 6: Dashboard
- Summary cards (total savings, next contribution, next payout, next meeting)
- Quick actions
- Tests: data aggregation from multiple providers

### Phase 7: Profile & Settings
- Profile display with edit
- Dark mode toggle
- Notifications toggle
- Sign out
- Tests: settings persistence

### Phase 8: Polish
- Loading states (shimmer)
- Empty states
- Error handling (snackbars)
- Edge cases (no network, expired invites, etc.)
- App icons and splash screen

## Key Decisions

1. **No payment processing** - app tracks contributions and proof, doesn't move money
2. **English only** - isiZulu added later via l10n system
3. **WhatsApp bot deferred** - Phase 2 after mobile app launches
4. **Notifications deferred** - FCM wiring happens after core features work
5. **No over-engineering** - simple screens, standard Riverpod patterns, no unnecessary abstractions
6. **Existing models preserved** - data layer schema is well-designed
7. **Firestore rules kept** - security model is correct

## Stokvel Types Supported

| Type | Purpose |
|------|---------|
| Rotational | Members take turns receiving the pot |
| Savings | Pool money for shared goal |
| Burial | Emergency fund for funeral costs |
| Grocery | Group buying for household goods |
| Investment | Pool for investment purposes |
| Hybrid | Combination of above |

## Member Roles

| Role | Permissions |
|------|------------|
| Chairperson | Full admin - manage group, members, payouts |
| Treasurer | Record contributions, manage finances |
| Secretary | Schedule meetings, take minutes |
| Member | View data, RSVP to meetings |
