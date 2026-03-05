# Flutter Stripe SDK keep rules
-keep class com.stripe.** { *; }
-keep class com.reactnativestripesdk.** { *; }

# Keep push provisioning classes (even if not used)
-keep class com.stripe.android.pushProvisioning.** { *; }

# Firebase (si utilisé)
-keep class com.google.firebase.** { *; }

# Keep classes with native methods
-keepclasseswithmembers class * {
    native <methods>;
}

# Prevent obfuscation of Flutter plugins
-keep class io.flutter.plugins.** { *; }

# Stripe SDK - Keep Push Provisioning
-keep class com.stripe.** { *; }
-dontwarn com.stripe.**