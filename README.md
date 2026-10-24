# DUOO — Do'kon egasi ilovasi (Flutter)

Do'kon egasi telefonidan zakaz beradigan mobil ilova. Backend API'ga ulanadi.

## Ekranlar

Splash (internet + majburiy yangilash) → Onboarding (1-marta) →
"Hisobingiz bormi?" → Kirish yoki Ro'yxatdan o'tish (sputnik xaritada joy
belgilash) → PIN o'rnatish → Bosh sahifa / Katalog / Savat / Buyurtmalar /
Profil.

## Ishga tushirish

```bash
flutter pub get
flutter run
```

Backend manzili `lib/core/config.dart` dagi `AppConfig.apiBaseUrl` da.

## Play Market'ga chiqarish

```bash
flutter build appbundle --release   # build/app/outputs/bundle/release/app-release.aab
```

- Har yuklashda `pubspec.yaml` dagi `version` ni oshiring (`1.0.2+2` →
  `1.0.3+3`). `+` dan keyingi raqam (versionCode) har safar kattaroq bo'lishi
  shart. Majburiy yangilash tekshiruvi ham shu versiyani ishlatadi.
- Imzo: `android/key.properties` + `.jks` (gitignore'da). Ular bo'lmasa
  release debug kaliti bilan imzolanadi va Play qabul qilmaydi.
- Ilova ikonkasi: `dart run flutter_launcher_icons` (sozlamasi pubspec'da).

## Loyiha tuzilishi

```
lib/
├── main.dart                 ← kirish nuqtasi, provider'lar
├── core/
│   ├── theme.dart            ← ranglar, shriftlar (DESIGN.md dan)
│   ├── config.dart           ← API manzili, versiya
│   └── format.dart           ← narx/sana formatlash
├── models/models.dart        ← ma'lumot modellari
├── services/api_service.dart ← API + token boshqaruvi
├── providers/                ← holat (auth, catalog, cart, orders)
├── widgets/                  ← qayta ishlatiladigan (product_card)
└── screens/                  ← barcha ekranlar
```

## Shrift

- **Plus Jakarta Sans:** `.ttf` fayllarni `assets/fonts/` ga qo'shib,
  `pubspec.yaml` dagi izohlangan `fonts:` blokini yoqing.

## Masshtablanish

- `cached_network_image` — rasmlar keshlanadi, lazy yuklanadi.
- Pagination — mahsulotlar 20 tadan, pastga scroll'da keyingi 20 ta.
- Kategoriya tanlanmaguncha brendlar/mahsulotlar yuklanmaydi.

## Hali qo'shilmaganlar (keyingi qadam)

- Splash reklama (Yandex uslubi) — `promo-screens` API tayyor.
- Push-bildirishnoma.
