# CROC-CITY FOOTBALL ACADEMY — PDF & Storage Fix

## What was fixed

### 1. Admin publishing to parents
Firebase Storage now permits authorized administrators to publish PDFs under both:
- `student_results/{studentId}/{resultId}.pdf`
- `player_results/{playerId}/{resultId}.pdf`

Admin authorization accepts the existing custom admin claim and the administrator role stored in the user's Firestore document.

### 2. Parent PDF action
The parent dashboard now shows **Open PDF**, matching the student portal behavior. It opens the published official PDF URL. It no longer tries to regenerate/download a second local copy for an already-published result.

### 3. Profile photo in PDFs
Student and player PDF generation now resolves Firebase Storage `gs://` URLs and Storage object paths to download URLs before embedding the image. Normal HTTPS download URLs continue to work.

## Required Firebase deployment
After extracting this project, deploy the Storage rules from the project root:

```powershell
firebase deploy --only storage
```

If your Firebase CLI asks you to select a project, select the CROC-CITY FOOTBALL ACADEMY Firebase project.

## Rebuild

```powershell
flutter clean
flutter pub get
flutter build appbundle --release
```

For iOS:

```bash
flutter clean
flutter pub get
flutter build ios --release --no-codesign
```

The iOS deployment target remains 15.0 because the current Firebase Swift Package dependencies require iOS 15.
