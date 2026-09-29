# Android release build fixes

This version fixes the Android release configuration used by CROC-CITY FOOTBALL ACADEMY.

Changes:
- Moved `kotlinOptions` inside the `android {}` block in `android/app/build.gradle`.
- Updated the Gradle wrapper from 8.13 to 8.14.
- Added an R8 rule for the optional legacy SLF4J binding class `org.slf4j.impl.StaticLoggerBinder`.
- Registered the ProGuard/R8 rules file in the release build.

Build:
```powershell
flutter clean
flutter pub get
cd android
.\gradlew clean
cd ..
flutter build appbundle --release
```
