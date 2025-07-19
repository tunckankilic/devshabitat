# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Dart related
-keep class androidx.lifecycle.DefaultLifecycleObserver

# Firebase rules
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Firebase Firestore
-keep class com.google.firebase.firestore.** { *; }
-keep class com.google.firestore.v1.** { *; }
-dontwarn com.google.firestore.v1.**

# Firebase Auth
-keep class com.google.firebase.auth.** { *; }
-dontwarn com.google.firebase.auth.**

# Firebase Storage
-keep class com.google.firebase.storage.** { *; }
-dontwarn com.google.firebase.storage.**

# Firebase Messaging
-keep class com.google.firebase.messaging.** { *; }
-dontwarn com.google.firebase.messaging.**

# Google Play Services
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }
-dontwarn com.google.android.gms.**

# Google Sign In
-keep class com.google.android.gms.auth.api.signin.** { *; }
-keep class com.google.android.gms.auth.api.credentials.** { *; }
-keepattributes Signature
-keepattributes *Annotation*



# Image Picker & Cropper
-keep class io.flutter.plugins.imagepicker.** { *; }
-keep class com.yalantis.ucrop.** { *; }
-dontwarn com.yalantis.ucrop.**

# File Picker
-keep class com.mr.flutter.plugin.filepicker.** { *; }

# Network & HTTP
-keep class okhttp3.** { *; }
-keep class okio.** { *; }
-dontwarn okhttp3.**
-dontwarn okio.**

# Geolocator
-keep class com.baseflow.geolocator.** { *; }
-dontwarn com.baseflow.geolocator.**

# Device Info
-keep class io.flutter.plugins.deviceinfo.** { *; }

# Connectivity Plus
-keep class dev.fluttercommunity.plus.connectivity.** { *; }

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Flutter Secure Storage
-keep class io.flutter.plugins.flutter_secure_storage.** { *; }

# Shared Preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Path Provider
-keep class io.flutter.plugins.pathprovider.** { *; }

# URL Launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

# WebView Flutter
-keep class io.flutter.plugins.webviewflutter.** { *; }

# Photo View
-keep class photo_view.** { *; }

# Share Plus
-keep class dev.fluttercommunity.plus.share.** { *; }

# Cached Network Image
-keep class flutter_cached_network_image.** { *; }

# FL Chart
-keep class fl_chart.** { *; }

# Encrypt
-keep class encrypt.** { *; }

# Get (State Management)
-keep class get.** { *; }

# Get Storage
-keep class get_storage.** { *; }

# Logger
-keep class logger.** { *; }

# UUID
-keep class uuid.** { *; }

# Timeago
-keep class timeago.** { *; }

# Shimmer
-keep class shimmer.** { *; }

# Pull to Refresh
-keep class pull_to_refresh.** { *; }

# Custom app classes
-keep class site.tunckankilic.devshabitat.** { *; }

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

# Keep custom attributes
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes Signature
-keepattributes *JavascriptInterface*

# Keep enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Keep Parcelable classes
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Keep classes that might be accessed via reflection
-keepclassmembers class * {
    @androidx.annotation.Keep <methods>;
    @androidx.annotation.Keep <fields>;
    @androidx.annotation.Keep <init>(...);
}

# Remove debug logging in release builds
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}

# Optimization settings
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification
-dontpreverify

# Don't warn about missing classes that are not used
-dontwarn javax.annotation.**
-dontwarn javax.inject.**
-dontwarn sun.misc.Unsafe
-dontwarn com.google.common.util.concurrent.**

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlin.Metadata { *; }
-dontwarn kotlin.**
-keepclassmembers class **$WhenMappings {
    <fields>;
}
-keepclassmembers class kotlin.Metadata {
    public <methods>;
}

# Coroutines
-keepnames class kotlinx.coroutines.internal.MainDispatcherFactory {}
-keepnames class kotlinx.coroutines.CoroutineExceptionHandler {}

# Most of volatile fields are updated with AFU and should not be mangled
-keepclassmembernames class kotlinx.** {
    volatile <fields>;
}

# Same story for the standard library's SafeContinuation that also uses AtomicReferenceFieldUpdater
-keepclassmembernames class kotlin.coroutines.SafeContinuation {
    volatile <fields>;
}

# These classes are only required by kotlinx.coroutines.debug.AgentPremain, which is only loaded when
# kotlinx-coroutines-core is used as a Java agent, so these are not needed in contexts where ProGuard is used.
-dontwarn java.lang.instrument.ClassFileTransformer
-dontwarn sun.misc.SignalHandler
-dontwarn java.lang.instrument.Instrumentation
-dontwarn sun.misc.Signal
-dontwarn java.lang.management.ManagementFactory

# General
-keepattributes SourceFile,LineNumberTable        # Keep file names and line numbers.
-keep public class * extends java.lang.Exception  # Keep custom exceptions.

# Keep the R
-keep class **.R
-keep class **.R$* {
    <fields>;
}