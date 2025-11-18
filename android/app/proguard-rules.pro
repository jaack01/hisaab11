# Hisaab - ProGuard Rules for Release Build

## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

## Dart
-keep class io.flutter.embedding.** { *; }
-dontwarn io.flutter.embedding.**

## SQLite
-keep class org.sqlite.** { *; }
-keep class org.sqlite.database.** { *; }

## PDF Generation
-keep class com.lowagie.text.** { *; }
-dontwarn com.lowagie.text.**

## Riverpod (State Management)
-keep class * extends com.google.common.base.Function { *; }
-dontwarn com.google.common.base.**

## Shared Preferences
-keep class androidx.preference.** { *; }

## Path Provider
-keep class io.flutter.plugins.pathprovider.** { *; }

## JSON Serialization
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

## Keep entity classes for serialization
-keep class com.example.hisaab11.domain.entities.** { *; }

## Remove logging in production
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

## General Android
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider

## Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

## Optimization
-optimizationpasses 5
-dontusemixedcaseclassnames
-verbose

## Additional rules for release
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**
