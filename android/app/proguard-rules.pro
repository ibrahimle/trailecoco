# =============================================================================
# EcoTrail - ProGuard Rules for Release Builds
# =============================================================================
# These rules configure R8 (Android's code shrinker) for the release build.
# They prevent errors from missing Play Core classes that Flutter may reference
# for deferred components (dynamic feature modules) even when not used.
# =============================================================================

# -----------------------------------------------------------------------------
# Flutter-specific rules
# -----------------------------------------------------------------------------
# Keep Flutter engine classes
-keep class io.flutter.** { *; }
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }

# -----------------------------------------------------------------------------
# Google Play Core - Deferred Components
# -----------------------------------------------------------------------------
# Flutter's Android build may reference Google Play Core classes for deferred
# components (dynamic feature modules). If the app doesn't use this feature
# and doesn't include the Play Core library, R8 will fail during release build.
#
# These dontwarn rules tell R8 to ignore the missing classes, which is safe
# because the deferred components functionality will not be used at runtime.
# -----------------------------------------------------------------------------

# Play Core base classes
-dontwarn com.google.android.play.core.**

# Split Install API (for dynamic feature modules)
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.splitinstall.model.**
-dontwarn com.google.android.play.core.splitinstall.testing.**

# Split Compat (for backward compatibility with dynamic features)
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication

# App Update API
-dontwarn com.google.android.play.core.appupdate.**
-dontwarn com.google.android.play.core.appupdate.testing.**

# In-App Review API
-dontwarn com.google.android.play.core.review.**
-dontwarn com.google.android.play.core.review.testing.**

# Asset Delivery API
-dontwarn com.google.android.play.core.assetpacks.**
-dontwarn com.google.android.play.core.assetpacks.model.**

# Tasks API (used by Play Core)
-dontwarn com.google.android.play.core.tasks.**

# Common Play Core classes
-dontwarn com.google.android.play.core.common.**
-dontwarn com.google.android.play.core.listener.**
-dontwarn com.google.android.play.core.install.**

# Kotlin coroutines extensions for Play Core
-dontwarn com.google.android.play.core.ktx.**

# -----------------------------------------------------------------------------
# General Android rules
# -----------------------------------------------------------------------------
# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelable implementations
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

# Keep Serializable implementations
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# -----------------------------------------------------------------------------
# Debugging - Keep line numbers for stack traces
# -----------------------------------------------------------------------------
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile

# -----------------------------------------------------------------------------
# Optimization settings
# -----------------------------------------------------------------------------
# Don't optimize too aggressively
-optimizationpasses 5
-dontusemixedcaseclassnames
-verbose

# =============================================================================
# End of ProGuard Rules
# =============================================================================
