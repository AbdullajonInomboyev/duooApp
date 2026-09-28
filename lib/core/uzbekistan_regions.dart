/// O'zbekiston viloyatlari va tumanlari — statik (offline) ma'lumot.
/// Backend tayyor bo'lganda API'ga o'tkaziladi, hozircha ilova o'zidan oladi.
///
/// Ishlatish:
///   uzRegions.keys           -> viloyatlar ro'yxati
///   uzRegions['Andijon']     -> shu viloyat tumanlari
const Map<String, List<String>> uzRegions = {
  "Toshkent shahri": [
    "Bektemir", "Chilonzor", "Mirobod", "Mirzo Ulug'bek", "Sergeli",
    "Shayxontohur", "Olmazor", "Uchtepa", "Yakkasaroy", "Yashnobod",
    "Yunusobod", "Yangihayot",
  ],
  "Toshkent viloyati": [
    "Bekobod", "Bo'ka", "Bo'stonliq", "Chinoz", "Qibray", "Ohangaron",
    "Oqqo'rg'on", "Parkent", "Piskent", "Quyichirchiq", "Yangiyo'l",
    "Zangiota", "O'rtachirchiq", "Yuqorichirchiq",
  ],
  "Andijon": [
    "Andijon shahri", "Asaka", "Baliqchi", "Bo'z", "Buloqboshi", "Izboskan",
    "Jalaquduq", "Xo'jaobod", "Qo'rg'ontepa", "Marhamat", "Oltinko'l",
    "Paxtaobod", "Shahrixon", "Ulug'nor",
  ],
  "Buxoro": [
    "Buxoro shahri", "Kogon", "G'ijduvon", "Jondor", "Qorako'l",
    "Qorovulbozor", "Olot", "Peshku", "Romitan", "Shofirkon", "Vobkent",
  ],
  "Farg'ona": [
    "Farg'ona shahri", "Marg'ilon", "Qo'qon", "Quva", "Beshariq", "Bog'dod",
    "Buvayda", "Dang'ara", "Furqat", "Oltiariq", "Rishton", "So'x",
    "Toshloq", "Uchko'prik", "O'zbekiston", "Yozyovon",
  ],
  "Jizzax": [
    "Jizzax shahri", "Arnasoy", "Baxmal", "Do'stlik", "Forish", "G'allaorol",
    "Sharof Rashidov", "Mirzacho'l", "Paxtakor", "Yangiobod", "Zomin",
    "Zafarobod", "Zarbdor",
  ],
  "Xorazm": [
    "Urganch shahri", "Xiva", "Bog'ot", "Gurlan", "Hazorasp", "Xonqa",
    "Qo'shko'pir", "Shovot", "Urganch", "Yangiariq", "Yangibozor",
  ],
  "Namangan": [
    "Namangan shahri", "Chortoq", "Chust", "Kosonsoy", "Mingbuloq", "Norin",
    "Pop", "To'raqo'rg'on", "Uchqo'rg'on", "Uychi", "Yangiqo'rg'on",
  ],
  "Navoiy": [
    "Navoiy shahri", "Zarafshon", "Karmana", "Konimex", "Navbahor", "Nurota",
    "Qiziltepa", "Tomdi", "Uchquduq", "Xatirchi",
  ],
  "Qashqadaryo": [
    "Qarshi shahri", "Shahrisabz", "Chiroqchi", "Dehqonobod", "G'uzor",
    "Qamashi", "Qarshi", "Kasbi", "Kitob", "Ko'kdala", "Mirishkor",
    "Muborak", "Nishon", "Yakkabog'",
  ],
  "Samarqand": [
    "Samarqand shahri", "Kattaqo'rg'on", "Bulung'ur", "Ishtixon", "Jomboy",
    "Qo'shrabot", "Narpay", "Nurobod", "Oqdaryo", "Payariq", "Pastdarg'om",
    "Paxtachi", "Toyloq", "Urgut",
  ],
  "Sirdaryo": [
    "Guliston shahri", "Yangiyer", "Shirin", "Boyovut", "Guliston",
    "Mirzaobod", "Oqoltin", "Sardoba", "Sayxunobod", "Sirdaryo", "Xovos",
  ],
  "Surxondaryo": [
    "Termiz shahri", "Angor", "Bandixon", "Boysun", "Denov", "Jarqo'rg'on",
    "Qiziriq", "Qumqo'rg'on", "Muzrabot", "Oltinsoy", "Sariosiyo",
    "Sherobod", "Sho'rchi", "Termiz", "Uzun",
  ],
  "Qoraqalpog'iston": [
    "Nukus shahri", "Amudaryo", "Beruniy", "Chimboy", "Ellikqala", "Kegeyli",
    "Mo'ynoq", "Nukus", "Qanliko'l", "Qo'ng'irot", "Qorao'zak", "Shumanay",
    "Taxtako'pir", "To'rtko'l", "Xo'jayli",
  ],
};