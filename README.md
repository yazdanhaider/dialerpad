# Dialerpad App

A feature-rich phone dialer application built with Flutter, implementing modern UI/UX principles and comprehensive calling features.

## Features

### Core Features
- ✅ Modern Dialpad UI
  - Custom numeric keypad with letter indicators
  - International dialing code selector
  - Real-time number formatting
  - Haptic feedback
  - Auto-scrolling number display

- ✅ Call Management
  - Make phone calls
  - Call state detection (Incoming/Outgoing/Connected/Disconnected)
  - Active call display with duration
  - Call history with detailed logs
  - Platform-specific handling (Android/iOS)

- ✅ Contact Management
  - View and manage contacts
  - Add new contacts
  - Search contacts (name/number)
  - Contact details view
  - Add number to existing contact
  - Google Contacts sync

- ✅ Call History
  - Comprehensive call logs
  - Categorized by date (Today/Yesterday/Earlier)
  - Filter by call type (Missed/Incoming/Outgoing)
  - Detailed call information
  - Quick actions (Call back, Add to contacts)

### Additional Features
- ✅ Number Blocking
  - Block/unblock numbers
  - Blocked numbers list
  - Block from call logs/contacts
  - Block unknown numbers

- ✅ UI/UX Features
  - Dark mode support
  - Modern Material Design
  - Smooth animations
  - Loading states with shimmer effects
  - Responsive layout
  - Platform-specific adaptations

### Technical Features
- ✅ State Management
  - GetX implementation
  - Reactive programming
  - Efficient state updates

- ✅ Permission Handling
  - Runtime permissions
  - Graceful permission management
  - User-friendly permission requests

- ✅ Error Handling
  - Comprehensive error messages
  - Fallback behaviors
  - Platform-specific error handling

## Technical Details

### Architecture
- Clean folder structure following modular approach
- GetX pattern implementation
- Service-based architecture
- Platform-specific implementations

### Key Packages
- `get`: State management and routing
- `phone_state`: Call state detection
- `contacts_service`: Contact management
- `call_log`: Call history management
- `google_sign_in`: Google integration
- `permission_handler`: Permission management

### Platform Support
- Android: API 24+ (Android 7.0 and above)
- iOS: Basic support (limited features due to platform restrictions)

## Setup Instructions

1. Clone the repository
2. Copy `lib/app/config/api_keys.template.dart` to `lib/app/config/api_keys.dart`
3. Add your Google API credentials
4. Run `flutter pub get`
5. Run the app using `flutter run`

## Permissions Required
- Phone State
- Call Log Access
- Contacts Access
- Phone Call Permission

## Contributing
[Contributing guidelines]

## License
[License information]
