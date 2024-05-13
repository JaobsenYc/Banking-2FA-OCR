# Banking 2FA

This system manual guides you through the process of setting up your development environment for the Banking OCR project, from installing Flutter and Xcode to managing dependencies and building the app.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installing Flutter](#installing-flutter)
- [Setting up Xcode](#setting-up-xcode)
- [Managing Dependencies](#managing-dependencies)
- [Running the App](#running-the-app)
- [Building the App](#building-the-app)

## Prerequisites

Before you begin, make sure you have the following installed on your system:

- MacOS (required for Xcode)
- Xcode (required for iOS development)
- Android Studio or another IDE for Android development (optional)
- Git (for version control)

## Cloning the Repository from GitHub

### Step 1: Clone the Repository

1. Open a terminal window.
2. Use the following command to clone the `Banking-2FA-OCR` repository:

```shell
git clone https://github.com/JaobsenYc/Banking-2FA-OCR.git
```

3. Navigate into the cloned directory:

```shell
cd Banking-2FA-OCR
```

## Installing Flutter

### Step 1: Download Flutter SDK

1. Visit the Flutter SDK releases page: [Flutter SDK Releases](https://flutter.dev/docs/development/tools/sdk/releases).
2. Select the appropriate version for your operating system.
3. Download the installation bundle.

### Step 2: Extract the Flutter SDK

1. Extract the downloaded zip file to a preferred location, such as:

   ```shell
   ~/development/flutter
   ```

2. Add the `flutter/bin` directory to your PATH environment variable.

   For temporary PATH update (resets after terminal is closed):

   ```shell
   export PATH="$PATH:`pwd`/flutter/bin"
   ```

   For permanent PATH update, add the export line to your `.bashrc`, `.zshrc`, or `.bash_profile` file.

### Step 3: Run Flutter Doctor

Run the following command to check if there are any dependencies you need to install to complete the setup:

```shell
flutter doctor
```

Follow the prompts to install any missing dependencies.

## Setting up Xcode

### Step 1: Install Xcode

1. Open the Mac App Store.
2. Search for Xcode.
3. Click Install.

### Step 2: Configure Xcode

1. Launch Xcode and go through the initial setup process.
2. Accept the license agreement.
3. Install any additional required components.

### Step 3: Set up the Command Line Tools

1. Open Terminal.

2. Execute the following command:

   ```shell
   sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   sudo xcodebuild -runFirstLaunch
   ```

3. Install the iOS simulators and devices from within Xcode by navigating to:

   ```shell
   Xcode > Preferences > Components
   ```

## Managing Dependencies

### Step 1: Get Dependencies

Navigate to your Flutter project directory and run:

```shell
flutter pub get
```

This command retrieves all the packages your app depends on.

### Step 2: Update Dependencies

To update to the latest version of the dependencies, run:

```shell
flutter pub upgrade
```

## Running the App

### Step 1: Open Simulator or Connect Device

- For iOS, you can open the simulator by running:

  ```shell
  open -a Simulator
  ```

- Connect your Android device or use the Android emulator from Android Studio.

### Step 2: Run the App

Execute the following command from your project directory:

```shell
flutter run
```

This will build and run the app on the connected device or active simulator.

## Building the App

### For iOS:

1. Open your Flutter project in Xcode:

   ```shell
   open ios/Runner.xcworkspace
   ```

2. Select the target device or simulator.

3. Click the Build button or use the shortcut `Cmd + B`.

### For Android:

1. Open your Flutter project in Android Studio.
2. Select the target device or emulator.
3. Click the Run button or use the shortcut `Shift + F10`.

---

