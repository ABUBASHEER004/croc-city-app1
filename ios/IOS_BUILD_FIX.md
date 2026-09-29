# iOS release build fix

The Firebase Swift Package Manager plugins in this project require iOS 15.0.
The Runner target and generated Flutter Swift package are therefore configured for iOS 15.0.

Build with:

    flutter clean
    flutter pub get
    flutter build ios --release --no-codesign

If Xcode regenerates the Flutter ephemeral package, the Runner project deployment target remains the source-of-truth configuration.
