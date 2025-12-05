# Razorpay SDK rules
-keep class com.razorpay.** { *; }
-dontwarn com.razorpay.**

# Keep annotations (even if they don't exist)
-keep class proguard.annotation.Keep
-keep class proguard.annotation.KeepClassMembers

# Sometimes necessary for Kotlin
-keep class kotlin.Metadata { *; }

# Firebase Analytics
-keep class com.google.firebase.analytics.** { *; }
-dontwarn com.google.firebase.analytics.**

# Core Firebase SDKs
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

-keep class com.google.android.gms.** { *; }
