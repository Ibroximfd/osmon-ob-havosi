import 'dart:math';
import '../../domain/entities/weather.dart';

class LocalAdviceService {
  final _rnd = Random();

  T _pick<T>(List<T> list) => list[_rnd.nextInt(list.length)];

  String getAIWeatherAdvice(Weather weather) {
    final intro = _intro(weather);
    final clothing = _clothing(weather);
    final activity = _activity(weather);
    final health = _health(weather);
    final tip = _funTip(weather);

    final parts = <String>[intro, clothing, activity, health, tip]
        .where((s) => s.isNotEmpty)
        .toList();

    return parts.join('\n\n');
  }

  String _intro(Weather w) {
    final t = w.temp;
    final c = w.condition.toLowerCase();
    final isDay = w.isDay;
    final city = w.city;

    if (c.contains('momaqaldiroq')) {
      return _pick([
        '⛈️ ${city}da momaqaldiroq! Bugun ehtiyot bo\'lish kuni — tabiat o\'z kuchini ko\'rsatmoqda.',
        '⚡ ${city}da chaqmoq va momaqaldiroq! Uyda qolish — eng aqlli qaror.',
        '🌩️ ${city}da osmon o\'kirayapti — chaqmoq xavfli, deraza yonidan uzoqroq turing.',
        '⛈️ Bugun ${city}da momaqaldiroq mehmoni — tabiatning kuchli kunlaridan biri.',
      ]);
    }
    if (c.contains('kuchli yomg')) {
      return _pick([
        '🌧️ ${city}da kuchli yomg\'ir yog\'moqda. Plashch va soyabon — bugungi eng yaxshi do\'stingiz.',
        '☔ ${city}ga jala quyilmoqda! Tashqariga chiqsangiz, suv o\'tkazmas kiyim shart.',
        '💧 ${city}da osmondan oqim quyilmoqda — yo\'l sirpanchiq, ehtiyot bo\'ling.',
        '🌊 ${city}da kuchli yog\'ingarchilik. Bunday kunda qulay uy — eng yaxshi joy.',
      ]);
    }
    if (c.contains('yomg')) {
      return _pick([
        '🌦️ ${city}da yomg\'irli kun. Toza havo, lekin nam — ehtiyot bo\'ling.',
        '☂️ ${city}da yengil yomg\'ir tomchilari tushmoqda. Soyaboningiz tayyormi?',
        '🌧️ ${city}da yomg\'ir tushyapti — havo toza, hidlar yangi.',
        '💦 ${city}da yomg\'irli ob-havo — ko\'chada xushmuomalalik bilan harakatlaning.',
      ]);
    }
    if (c.contains('qor')) {
      return _pick([
        '❄️ ${city}da qor yog\'moqda — ajoyib qish manzarasi! Lekin yo\'llar sirpanchiq.',
        '☃️ ${city}ni qor o\'rtoqlikka chaqirmoqda — ertak singari kun!',
        '🌨️ ${city}da oq qor parchalari raqs tushmoqda — qishning sehrli vaqti.',
        '❄️ ${city}da qorli kun — issiq kiyim va ehtiyot kerak.',
      ]);
    }
    if (c.contains('tuman')) {
      return _pick([
        '🌫️ ${city}da tuman tushgan. Sirli va sokin tong, ammo haydashda ehtiyotkor bo\'ling.',
        '🌁 $city tuman ostida yashirinmoqda — ko\'rinish chegaralangan.',
        '☁️ ${city}ni quyuq tuman o\'ragan — bu ertalabki ajoyib lavhalardan biri.',
      ]);
    }

    if (t >= 35) {
      return _pick([
        '🔥 ${city}da kuchli issiq — $t°C! Bu jaziramaga moslashish kerak.',
        '🌡️ ${city}da harorat osmon teshmoqda — $t°C. Soya va suvga yaqin bo\'ling.',
        '☀️ ${city}da o\'tkir quyosh — $t°C, jazirama. Quyoshdan saqlaning.',
        '🥵 $t°C — ${city}da bunday kunlar kam uchraydi! Issiqni hurmat qiling.',
      ]);
    }
    if (t >= 28 && isDay) {
      return _pick([
        '☀️ ${city}da iliq va yorqin kun — $t°C. Yoz nafasi sezilmoqda!',
        '🌞 ${city}ga quyosh oltin nurini sochmoqda — $t°C, mukammal yozgi kayfiyat.',
        '🌻 ${city}da $t°C — yorqin va iliq kun, sayrga chiqsa bo\'ladi.',
        '🏖️ $t°C va quyoshli — ${city}da yozgi kayfiyat boshlanmoqda!',
      ]);
    }
    if (t >= 18 && t < 28 && isDay) {
      return _pick([
        '🌤️ ${city}da ajoyib ob-havo — $t°C. Tashqi faoliyat uchun ideal vaqt.',
        '🍃 ${city}da $t°C — ne issiq, ne sovuq, eng yaxshi tabiat haroratidan biri.',
        '☁️ ${city}da yumshoq va qulay $t°C. Bunday kunlar uchun yaratilgansiz!',
        '🌸 ${city}da $t°C — kun davomida tashqarida yurgingiz keladi.',
      ]);
    }
    if (t >= 8 && t < 18) {
      return _pick([
        '🍂 ${city}da salqin havo — $t°C. Engil sovuqcha, lekin sayrga zo\'r.',
        '🧥 ${city}da $t°C — kuzgi salqinlik, kurtka kerak bo\'ladi.',
        '🌬️ ${city}da $t°C — havo yangi, lekin issiq emas.',
      ]);
    }
    if (t >= 0 && t < 8) {
      return _pick([
        '🥶 ${city}da sovuq tongda — $t°C. Issiq kiyim shart.',
        '🧣 ${city}da $t°C — sovuq sezilarli, qalin kiyining.',
        '☕ ${city}da $t°C — issiq choy va issiq kiyim — eng to\'g\'ri kombinatsiya.',
      ]);
    }
    if (t < 0) {
      return _pick([
        '🧊 ${city}da ayoz — $t°C. Sovuq lekin chiroyli — qish o\'z hukmida.',
        '❄️ ${city}da haqiqiy qish — $t°C, qor va muz mavsumi.',
        '🥶 $t°C — ${city}da haqiqiy ayoz. Tashqarida uzoq qolmang.',
      ]);
    }

    if (!isDay) {
      return _pick([
        '🌙 ${city}da kechki vaqt — $t°C, havo tinch va sokin.',
        '✨ ${city}da kechki osmon — $t°C, yulduzlar uchrashuvi vaqti.',
        '🌃 ${city}da tun — $t°C, shahar uyquga ketmoqda.',
      ]);
    }

    return '🌍 ${city}da ob-havo $t°C, ${w.condition.toLowerCase()}.';
  }

  String _clothing(Weather w) {
    final t = w.temp;
    final feels = w.feelsLike;
    final wind = w.windSpeed;

    final feelsExtra = feels < t - 4
        ? ' Sezilayotgan harorat $feels°C — aslidan sovuqroq.'
        : (feels > t + 4 ? ' Sezilayotgan harorat $feels°C — aslidan issiqroq.' : '');
    final windExtra = wind > 25 ? ' Shamolga qarshi qatlam qo\'shing.' : '';

    if (t >= 35) {
      return '👕 ${_pick([
        "**Kiyim:** Eng yengil paxta kiyim, panama yoki shapka, quyosh ko'zoynak shart. Sintetik kiyimdan saqlaning.",
        "**Kiyim:** Yengil oq yoki och rangli paxta — issiqni qaytaradi. Shapka va ko'zoynak — majburiy.",
        "**Kiyim:** Engil shifondan yoki paxtadan tikilgan kiyim. Quyosh kremi va shapkangiz tayyor bo'lsin.",
      ])}';
    }
    if (t >= 28) {
      return '👕 ${_pick([
        "**Kiyim:** Yengil futbolka, shorti yoki yengil ko'ylak. Quyosh ko'zoynagi qo'l keladi.",
        "**Kiyim:** Yozgi kiyim — futbolka, short, sandal. Yorqin ranglar yarashadi.",
        "**Kiyim:** Yengil paxta kiyim, shapka va quyosh ko'zoynak.",
      ])}$windExtra';
    }
    if (t >= 20) {
      return '👔 ${_pick([
        "**Kiyim:** Oddiy kiyim — ko'ylak, yengil shim. Kechqurun yengil kofta zarar qilmaydi.",
        "**Kiyim:** Yengil ko'ylak yoki polo, oddiy shim. Yopiq oyoq kiyim qulay.",
        "**Kiyim:** Erkin uslub — ko'ylak, jinsi shim, krossovka.",
      ])}$feelsExtra$windExtra';
    }
    if (t >= 12) {
      return '🧥 ${_pick([
        "**Kiyim:** Yengil kurtka yoki sviter, uzun shim. Kechqurun sovuqroq bo'ladi.",
        "**Kiyim:** Kuzgi uslub — sviter, jinsi, yengil etik.",
        "**Kiyim:** Bomber yoki vetrovka, ichidan futbolka — qatlamli kiyim qulay.",
      ])}$feelsExtra$windExtra';
    }
    if (t >= 5) {
      return '🧥 ${_pick([
        "**Kiyim:** Issiq kurtka, sviter, yopiq oyoq kiyim. Sharf qo'shsangiz yaxshi bo'ladi.",
        "**Kiyim:** Kurtka, sviter, qalin shim, sharf — sovuqdan saqlaydi.",
        "**Kiyim:** Issiq kuz/qish kiyimi — palto, sviter, etik.",
      ])}$feelsExtra$windExtra';
    }
    if (t >= 0) {
      return '🧣 ${_pick([
        "**Kiyim:** Qalin kurtka, sharf, qalin paypoq. Qishki etik yaxshiroq.",
        "**Kiyim:** Qish kiyimi — palto, sharf, qalpoq, qo'lqop.",
        "**Kiyim:** Termal ostki kiyim, qalin palto, qishki etik — sovuqqa qarshi.",
      ])}$feelsExtra';
    }
    return '🥶 ${_pick([
      "**Kiyim:** Eng qalin kiyim — palto, qo'lqop, sharf, qalpoq. Qatlamlash isitadi.",
      "**Kiyim:** Termal kiyim, ikki qatlam jemper, qalin palto, qishki etik.",
      "**Kiyim:** Qalin junli kiyim, qo'lqop, sharf, qalpoq — barcha tana qismlarini yoping.",
    ])}$feelsExtra';
  }

  String _activity(Weather w) {
    final t = w.temp;
    final c = w.condition.toLowerCase();
    final isDay = w.isDay;

    if (c.contains('momaqaldiroq')) {
      return '🏠 ${_pick([
        "**Faoliyat:** Bugun uyda qoling. Film tomosha qiling, kitob o'qing yoki oilangiz bilan vaqt o'tkazing.",
        "**Faoliyat:** Uyda mazali ovqat tayyorlang, sevimli serialingizni ko'ring.",
        "**Faoliyat:** Bunday kunlar — uy ishlarini bajarish, tartibga solish uchun ideal.",
      ])}';
    }
    if (c.contains('kuchli yomg') || c.contains('jala')) {
      return '☂️ ${_pick([
        "**Faoliyat:** Tashqi rejalar bekor — kafe, muzey yoki savdo markaziga boring.",
        "**Faoliyat:** Yopiq joydagi sport zali, kino yoki teatr — bugungi eng yaxshi tanlov.",
        "**Faoliyat:** Issiq qahva bilan kafeda kitob o'qish — ajoyib kunni o'tkazish usuli.",
      ])}';
    }
    if (c.contains('yomg')) {
      return '🌧️ ${_pick([
        "**Faoliyat:** Yengil sayrga chiqsangiz, soyabon olishni unutmang. Yoga yoki sport zali — yaxshi tanlov.",
        "**Faoliyat:** Yopiq joyda sport, muzey yoki kafe — bugun bunday joylar yaxshi.",
        "**Faoliyat:** Yomg'ir tomonichlari ostida sayr — agar romantik kayfiyatda bo'lsangiz!",
      ])}';
    }
    if (c.contains('qor')) {
      return '⛄ ${_pick([
        "**Faoliyat:** Qor o'yini, qordan odam yasash, fotosurat — qishki kunlarning eng yaxshi xotiralari.",
        "**Faoliyat:** Chana, konki, qor o'yinlari — bolaligingizni eslang!",
        "**Faoliyat:** Tabiatda qishki sayr — ajoyib fotolar, yangi taassurotlar.",
      ])}';
    }

    if (t >= 35) {
      return '🏊 ${_pick([
        "**Faoliyat:** Suzish, dengiz, hovuz — eng yaxshi tanlov. 12:00–16:00 oralig'ida tashqarida bo'lmaslikka harakat qiling.",
        "**Faoliyat:** Salqin joy — kondisionerli kafe, hovuz, daryo. Issiqni hurmat qiling.",
        "**Faoliyat:** Erta tongda yoki kechqurun chiqing. Kunduzi salqin joyda qoling.",
      ])}';
    }
    if (t >= 25 && isDay) {
      return '🚴 ${_pick([
        "**Faoliyat:** Velosiped, futbol, sayr, piknik — barcha tashqi faoliyatlar uchun ajoyib kun!",
        "**Faoliyat:** Park, tabiat, do'stlar bilan piknik — bugun tashqarida bo'ling!",
        "**Faoliyat:** Sport, sayr, suzish — har qanday faol mashg'ulot uchun ideal.",
      ])}';
    }
    if (t >= 15 && isDay) {
      return '🚶 ${_pick([
        "**Faoliyat:** Yurish, yugurish, sport — ideal harorat. Ko'cha kafelarida o'tirish uchun mukammal.",
        "**Faoliyat:** Park bo'ylab sayr, yengil sport — tana uchun foydali.",
        "**Faoliyat:** Tabiat, fotosurat, qishloq sayri — bunday haroratda barchasi mumkin.",
      ])}';
    }
    if (t >= 5) {
      return '☕ ${_pick([
        "**Faoliyat:** Issiq choy, kafe, kitob o'qish. Tashqarida bo'lsangiz, qisqa sayr bilan cheklaning.",
        "**Faoliyat:** Issiq kafe, kitob, do'stlar bilan suhbat — kuzgi kayfiyat.",
        "**Faoliyat:** Sport zal yoki yopiq mashqlar — sovuqdan saqlanib, faollikni yo'qotmang.",
      ])}';
    }
    if (t >= 0) {
      return '🍵 ${_pick([
        "**Faoliyat:** Issiq mashg'ulotlar — basseyn, sport zal, hammom.",
        "**Faoliyat:** Issiq ovqat tayyorlang, oila bilan qoling, issiq choy iching.",
        "**Faoliyat:** Tashqarida 30 daqiqadan ortiq qolmang. Iliq joy — eng yaxshi tanlov.",
      ])}';
    }
    return '🏠 ${_pick([
      "**Faoliyat:** Iliq joyda qoling. Tashqi yumushlarni ertaga qoldiring.",
      "**Faoliyat:** Issiq ovqat va issiq ichimlik vaqti. Tashqarida uzoq qolmang.",
      "**Faoliyat:** Uy ishlari, kitob, film — bunday kunlarni mukammal o'tkazish usuli.",
    ])}';
  }

  String _health(Weather w) {
    final t = w.temp;
    final h = w.humidity;
    final wind = w.windSpeed;
    final aqi = w.aqi;
    final tips = <String>[];

    if (t >= 32) {
      tips.add(_pick([
        "💧 Har 30 daqiqada bir stakan suv iching",
        "💧 Tana suvsizlanmasin — kunda 2.5L suv kerak",
        "💧 Suv, mineral suv, yangi sharbat — ko'p iching",
      ]));
    } else if (t < 5) {
      tips.add(_pick([
        "☕ Issiq ichimlik tananizni qizdiradi",
        "🍵 Issiq choy, sho'rva — sovuqqa qarshi",
        "☕ Imbir bilan choy — issiqni saqlaydi",
      ]));
    }

    if (h > 75 && t > 25) {
      tips.add('Namlik yuqori — ko\'p terlash, mineral suv yaxshi');
    } else if (h < 25) {
      tips.add('Havo quruq — lab balzami va krem foydali');
    }

    if (aqi > 100) {
      tips.add('😷 Havo sifati past (AQI: $aqi) — N95 niqob kiying');
    } else if (aqi > 50) {
      tips.add('🌫️ Havo o\'rtacha (AQI: $aqi) — astma bor bo\'lsa ehtiyot bo\'ling');
    }

    if (wind > 35) {
      tips.add(_pick([
        '💨 Kuchli shamol — ko\'zoynak qo\'l keladi',
        '💨 Shamolda chang ko\'p — ko\'z va burunni himoya qiling',
      ]));
    }

    if (tips.isEmpty) return '';
    return '${tips.join('. ')}.';
  }

  String _funTip(Weather w) {
    final t = w.temp;
    final c = w.condition.toLowerCase();

    if (c.contains('ochiq') && w.isDay && t >= 20 && t <= 28) {
      return _pick([
        '✨ **Maslahat:** Bugungi kun shaharning eng yaxshi joylarida fotosurat olish uchun ideal!',
        '✨ **Maslahat:** Bunday kunlar — yangi joylarni kashf qilish vaqti.',
        '✨ **Maslahat:** Bog\'da piknik, do\'stlar bilan futbol — bugun ko\'p narsa qila olasiz.',
        '✨ **Maslahat:** Quyoshli kunlarda D vitamini olish uchun 15-20 daqiqa tashqarida bo\'ling.',
      ]);
    }
    if (c.contains('yomg') || c.contains('jala')) {
      return _pick([
        '✨ **Maslahat:** Yomg\'irda eng mazali qahva — issiq choy bilan deraza yonida o\'tirib, sevimli kitobingizni o\'qing.',
        '✨ **Maslahat:** Yomg\'irli kunlarda eski filmlar tomosha qilish — alohida kayfiyat.',
        '✨ **Maslahat:** Qulay svitr, issiq kakao va kitob — bunday kunlar uchun mukammal kombinatsiya.',
      ]);
    }
    if (c.contains('qor')) {
      return _pick([
        '✨ **Maslahat:** Qor yog\'gan kunlarda issiq somsa va choy — eng yaxshi kombinatsiya!',
        '✨ **Maslahat:** Qor lavhalarini fotosurat oling — qishning sehrli paytlari.',
        '✨ **Maslahat:** Issiq sho\'rva yoki lag\'mon — qor kunining mukammal taomi.',
      ]);
    }
    if (t >= 32) {
      return _pick([
        '✨ **Maslahat:** Tarvuz, qovun yoki yangi sharbat — issiqni yenggan eng zo\'r ozuqalar.',
        '✨ **Maslahat:** Muzqaymoq, tarvuz, salqin sharbat — bunday kunlar uchun yaratilgan.',
        '✨ **Maslahat:** Ayron, qatiq, mineral suv — issiqda eng foydali ichimliklar.',
      ]);
    }
    if (t < 5) {
      return _pick([
        '✨ **Maslahat:** Issiq sho\'rva yoki lag\'mon — sovuqda eng to\'g\'ri tanlov.',
        '✨ **Maslahat:** Imbir, asal va limon bilan choy — sovuqdan saqlaydi.',
        '✨ **Maslahat:** Plov, sho\'rva, somsa — sovuq kunlarning eng yaxshi taomlari.',
      ]);
    }
    if (!w.isDay) {
      return _pick([
        '✨ **Maslahat:** Kechki sayr — kun bo\'yi to\'plangan zo\'riqishni yo\'qotishning eng yaxshi usuli.',
        '✨ **Maslahat:** Kechki yulduzlarni kuzating — bu meditatsiya o\'rnini bosadi.',
        '✨ **Maslahat:** Issiq sut yoki choy — yaxshi uyqu uchun ajoyib variant.',
      ]);
    }
    return '';
  }

  String getAgricultureAdvice(Weather weather) {
    final t = weather.temp;
    final h = weather.humidity;
    final c = weather.condition.toLowerCase();
    final wind = weather.windSpeed;

    if (c.contains('momaqaldiroq') || c.contains('kuchli yomg')) {
      return _pick([
        '⚠️ Bugun dala ishlarini to\'xtating — kuchli yomg\'ir va shamol ekinlarga zarar yetkazishi mumkin.',
        '⚠️ Mol-qorani panaga qo\'ying, dala ishlari xavfli.',
        '⚠️ Issiqxonalarning derazalarini yoping, ko\'chatlarni himoya qiling.',
      ]);
    }
    if (c.contains('yomg')) {
      return _pick([
        '🌧️ Yomg\'ir tufayli sug\'orish kerak emas — tabiat o\'z ishini qildi.',
        '🌧️ Bugun zararkunandalar nazoratini kechiktiring — preparatlar yuviladi.',
        '🌧️ Tuproq nam — sug\'orish o\'rniga yumshatish bilan band bo\'ling.',
      ]);
    }
    if (t > 35 && h < 30) {
      return _pick([
        '🔥 Issiq va quruq ob-havo — ekinlarni erta tongda sug\'oring.',
        '🔥 Mulchadan foydalaning — tuproq namligini saqlaydi.',
        '🔥 Sug\'orishni 5:00-7:00 oralig\'ida bajaring, kunduzi ekinlar zaiflashadi.',
      ]);
    }
    if (t > 30) {
      return _pick([
        '☀️ Sug\'orishni 5:00–8:00 yoki 19:00 dan keyin bajaring.',
        '☀️ Kunduzi ishlamang — soya yoki yopiq joyda dam oling.',
        '☀️ Issiqxonalarni shamollating — issiqlik haddan oshmasin.',
      ]);
    }
    if (t < 5) {
      return _pick([
        '❄️ Ko\'chatlarni ayozdan himoya qiling — agro-mato yoki plyonka yoping.',
        '❄️ Tunda ayoz tushishi mumkin — issiqxonalar yopilsin.',
        '❄️ Mol-qoraga qo\'shimcha ozuqa va iliq panapod kerak.',
      ]);
    }
    if (wind > 30) {
      return _pick([
        '💨 Kuchli shamol — kimyoviy ishlov berishdan saqlaning.',
        '💨 Shamol kuchli — preparatlar tarqalib ketadi, ishni keyinroq bajaring.',
      ]);
    }
    if (h > 75) {
      return _pick([
        '💧 Namlik yuqori — zamburug\' kasalliklari xavfi bor, profilaktika kerak.',
        '💧 Issiqxonalarni yaxshi shamollating — namlik kasalliklarni keltirib chiqaradi.',
      ]);
    }
    if (t >= 18 && t <= 28 && h >= 40 && h <= 65) {
      return _pick([
        '✅ Bugun dala ishlari uchun ideal sharoit — ekin parvarish, o\'g\'itlash mumkin!',
        '✅ Mukammal ob-havo — ekish, sug\'orish, begona o\'tlarni yulish vaqti.',
        '✅ Bugun barcha dala ishlari uchun ajoyib kun — vaqtdan unumli foydalaning.',
      ]);
    }
    return _pick([
      '🌱 Havo sharoitiga qarab sug\'orish va ekin rejimini moslashtiring.',
      '🌱 Tuproq namligini doimo nazorat qiling.',
      '🌱 Mavsumga qarab agronomik tadbirlarni rejalashtiring.',
    ]);
  }
}
