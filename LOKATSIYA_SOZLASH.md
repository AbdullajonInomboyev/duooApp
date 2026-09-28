# Lokatsiya (GPS) sozlash

`geolocator` paketi ishlashi uchun platforma ruxsatlarini qo'shish kerak.
`flutter create .` dan keyin quyidagi fayllarni tahrirlang.

## 1. Android

**Fayl:** `android/app/src/main/AndroidManifest.xml`

`<application>` tegidan YUQORIDA (manifest ichida) qo'shing:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

**Fayl:** `android/app/build.gradle` — minSdkVersion 21 yoki undan yuqori:

```gradle
defaultConfig {
    minSdkVersion 21
    ...
}
```

## 2. iOS

**Fayl:** `ios/Runner/Info.plist`

`<dict>` ichiga qo'shing:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Do'kon manzilini aniqlash uchun joylashuv kerak</string>
```

## 3. Paketni yuklasha

```bash
flutter pub get
flutter run
```

Ro'yxatdan o'tish ekranida "Mening joylashuvim" tugmasi paydo bo'ladi.
Bosilganda GPS koordinata olinadi va ro'yxatdan o'tishda backend'ga yuboriladi
(`Shop.latitude`, `Shop.longitude`).

## Eslatma

- Web'da (Chrome) GPS brauzer ruxsati orqali ishlaydi, lekin aniqligi past.
- Real qurilmada aniq ishlaydi.
- Kelajakda xarita (Google Maps) qo'shilsa, bu koordinata boshlang'ich
  nuqta bo'ladi.
