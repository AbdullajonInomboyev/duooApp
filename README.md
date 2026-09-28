# GoDostavka — Do'kon egasi ilovasi (Flutter)

Do'kon egasi telefonidan zakaz beradigan mobil ilova. Backend API'ga ulanadi.

## Ekranlar (dizayn oqimiga mos)

Splash (versiya tekshiruvi) → Onboarding → Kirish / Ro'yxatdan o'tish →
Bosh sahifa (brendlar) → Kategoriya → Brend mahsulotlari → Mahsulot tafsiloti →
Savat → Buyurtmani tasdiqlash → Muvaffaqiyat → Chek → Buyurtmalar tarixi → Profil.

## Ishga tushirish

```bash
cd mobile/store_app
flutter pub get
flutter run
```

**Muhim:** backend ishlab turishi kerak. `lib/core/config.dart` da manzilni
tekshiring:
- Android emulyator: `http://10.0.2.2:8000/api`
- iOS simulyator: `http://127.0.0.1:8000/api`
- Haqiqiy qurilma: kompyuter IP yoki server domeni

Test uchun backend'dagi namuna login: telefon `+998901234567`, parol `1234`.

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

## Logo va shrift

- **Logo:** `assets/logo/logo.png` ga qo'ying. Splash va kirish ekranida
  hozir "Go" matn turibdi — logo qo'yilganda `Image.asset('assets/logo/logo.png')`
  bilan almashtiriladi.
- **Shrift (Plus Jakarta Sans):** `.ttf` fayllarni `assets/fonts/` ga qo'shib,
  `pubspec.yaml` dagi izohlangan `fonts:` blokini yoqing.

## Masshtablanish

- `cached_network_image` — rasmlar keshlanadi, lazy yuklanadi.
- Pagination — mahsulotlar 20 tadan, pastga scroll'da keyingi 20 ta.
- Kategoriya tanlanmaguncha brendlar/mahsulotlar yuklanmaydi.

## Hali qo'shilmaganlar (keyingi qadam)

- Rasm yuklash (`image_picker`) — do'kon rasmi, ro'yxatdan o'tishda.
- Xarita (`google_maps_flutter`) — lokatsiya tanlash.
- Splash reklama (Yandex uslubi) — `promo-screens` API tayyor.
- Push-bildirishnoma.
- PIN kodli kirish (dizaynda bor).
