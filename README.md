# Dialerpad App  

![1](https://github.com/user-attachments/assets/52c90041-5dde-423d-819c-c60af6990f7d)
## 🔹 Key Features  

### Dialpad & Calling  
- Custom numeric keypad with letter indicators  
- International dialing support & real-time formatting  
- Make & manage calls (Incoming/Outgoing/History)  

### Contact & Call History  
- Add, view, search, and sync contacts (Google Contacts)  
- Categorized call logs with quick actions (Call back, Add to contacts)  

### Additional Functionalities  
- Block/unblock numbers (Including unknown numbers)  
- Dark mode, animations, and responsive UI  
- Smooth permission handling & error management  

### Technical Highlights  
- **GetX state management** for efficiency  
- **Runtime permissions** with user-friendly handling  
- **Robust error handling** with platform-specific fallbacks

![2](https://github.com/user-attachments/assets/5284060b-26d5-4136-a88b-480150f7a80d)
![3](https://github.com/user-attachments/assets/e7857e94-6ebf-4253-b6a4-bbe2df6f548d)
![4](https://github.com/user-attachments/assets/21492a5e-716c-493b-ad42-6516365aa45e)


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

## Code Structure

- `lib/`: Contains the main codebase
  - `app/`: Core application code
    - `common/`: Shared components
      - `widgets/`: Reusable UI components
      - `values/`: App constants, colors, styles
    - `modules/`: Feature modules
      - `dialpad/`: Dialer functionality
      - `contacts/`: Contact management
      - `history/`: Call logs and history
      - `blocked/`: Number blocking feature
    - `services/`: Core services
      - Call handling
      - Contact management
      - Theme management
      - Google integration
    - `routes/`: App navigation
    - `config/`: App configuration
  - `models/`: Data models
  - `main.dart`: Application entry point

## Installation

1. **Clone the Repository:**
    ```bash
    git clone https://github.com/yazdanhaider/dialerpad
    ```

2. **Configure API Keys:**
    - Copy `lib/app/config/api_keys.template.dart` to `lib/app/config/api_keys.dart`
    - Add your Google API credentials

3. **Install Dependencies:**
    ```bash
    flutter pub get
    ```

4. **Run the App:**
    ```bash
    flutter run
    ```


## Permissions Required
- Phone State
- Call Log Access
- Contacts Access
- Phone Call Permission


Created with 💙 by Yazdan Haider
