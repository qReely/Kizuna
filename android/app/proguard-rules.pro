# Flutter-specific rules
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**
-keep class androidx.** { *; }
-dontwarn androidx.**

# Keep your app's classes (adjust package name to match your app)
-keep class com.example.manga_reader_app.** { *; }
-dontwarn com.example.manga_reader_app.**

# flutter_local_notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }
-dontwarn com.dexterous.flutterlocalnotifications.**

# cached_network_image and flutter_cache_manager
-keep class com.baseflow.flutter_cache_manager.** { *; }
-dontwarn com.baseflow.flutter_cache_manager.**
-keep class io.flutter.plugins.image.** { *; }
-dontwarn io.flutter.plugins.image.**

# flutter_bloc
-keep class com.bloc.** { *; }
-dontwarn com.bloc.**


# Prevent R8 from removing unused classes and resources
-dontoptimize
-dontshrink
-dontwarn **