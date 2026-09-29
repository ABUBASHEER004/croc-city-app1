import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Public Paystack configuration.
///
/// The public key is safe to ship in the mobile application. The Paystack
/// secret key is intentionally NOT stored here; it lives in Firebase Secret
/// Manager and is only used by Cloud Functions.
class PaystackConfig {
  const PaystackConfig._();

  static String get publicKey {
    final fromDotEnv = dotenv.env['PAYSTACK_PUBLIC_KEY']?.trim() ?? '';
    if (fromDotEnv.isNotEmpty) return fromDotEnv;
    return const String.fromEnvironment('PAYSTACK_PUBLIC_KEY').trim();
  }

  static bool get isConfigured =>
      (publicKey.startsWith('pk_test_') ||
          publicKey.startsWith('pk_live_')) &&
      publicKey.length > 12;
}
