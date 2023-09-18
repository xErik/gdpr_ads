# Enable Ads in Android Project

Update AndroidManifest.xml and build.gradle

1. Admob requires updating `AndroidManifest.xml` with an Addmob App-Id.
2. In case of DEX compile errors, update `build.gradle`.

## AndroidManifest.xml

Add the Admob-App-ID to `android/app/src/AndroidManifest.xml`.

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">

	<uses-permission android:name="android.permission.INTERNET" />

  <!-- In case of DEX errors -->
	<application android:name="androidx.multidex.MultiDexApplication">	
		
        <meta-data 
            android:name="com.google.android.gms.ads.APPLICATION_ID" 
            android:value=" -- YOUR ADMOB APPLICATION ID HERE -- " /> 

   <!-- ... -->

</manifest>        
```
## build.gradle

In case of DEX compile errors, add these entries to `android/app/build.gradle` and the
MULTIDEX entry to the `AndroidManifest.xml` as given above.

```gradle
android {
    defaultConfig {
        multiDexEnabled true
    }
}

dependencies {
    implementation "androidx.multidex:multidex:2.0.1"
}
```