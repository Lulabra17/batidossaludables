# --- Flutter native methods ---
-keep class io.flutter.** { *; }
-dontwarn io.flutter.embedding.**

# --- Alarm plugin ---
-keep class com.gdelataillade.alarm.** { *; }
-dontwarn com.gdelataillade.alarm.**

# --- flutter_background_service ---
-keep class id.flutter.plugins.flutter_background_service.** { *; }
-dontwarn id.flutter.plugins.flutter_background_service.**

# --- Google Mobile Ads ---
-keep class com.google.android.gms.ads.** { *; }
-dontwarn com.google.android.gms.ads.**
-keep class com.google.ads.** { *; }
-dontwarn com.google.ads.**

# --- Hive ---
-keep class **.model.** { *; } # Solo si usas modelos anotados para Hive

# --- fluttertoast ---
-keep class io.github.ponnamkarthik.toast.fluttertoast.FlutterToastPlugin { *; }
-dontwarn io.github.ponnamkarthik.toast.fluttertoast.FlutterToastPlugin

# --- Prevent removing unused classes Flutter uses via reflection ---
-keep class * extends java.lang.annotation.Annotation
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}
-keepclassmembers class ** {
    public <init> (org.json.JSONObject);
}
-keepclassmembers class ** {
    public <init> (android.os.Parcel);
}
-keepclassmembers class ** {
    public static final int ic_notification;
}
