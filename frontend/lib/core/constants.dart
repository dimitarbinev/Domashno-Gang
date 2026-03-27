class AppConstants {
  AppConstants._();

  static const String appName = 'АгроСтрийт Маркет';
  static const String tagline = 'Пресни продукти от фермата до улицата';

  // ─── Категории продукти ───
  static const List<String> productCategories = [
    'Зеленчуци',
    'Плодове',
    'Зърнени',
    'Млечни',
    'Билки',
    'Ядки',
    'Мед',
    'Месо',
    'Яйца',
    'Други',
  ];

  // ─── Български градове ───
  static const Map<String, ({double lat, double lng})> cityLocations = {
    'София': (lat: 42.6977, lng: 23.3219),
    'Пловдив': (lat: 42.1354, lng: 24.7453),
    'Варна': (lat: 43.2141, lng: 27.9147),
    'Бургас': (lat: 42.5048, lng: 27.4626),
    'Русе': (lat: 43.8356, lng: 25.9657),
    'Стара Загора': (lat: 42.4258, lng: 25.6345),
    'Плевен': (lat: 43.4170, lng: 24.6067),
    'Сливен': (lat: 42.6817, lng: 26.3229),
    'Добрич': (lat: 43.5725, lng: 27.8273),
    'Шумен': (lat: 43.2712, lng: 26.9361),
    'Перник': (lat: 42.6106, lng: 23.0292),
    'Хасково': (lat: 41.9344, lng: 25.5555),
    'Ямбол': (lat: 42.4842, lng: 26.5035),
    'Пазарджик': (lat: 42.1939, lng: 24.3333),
    'Благоевград': (lat: 42.0209, lng: 23.0943),
    'Велико Търново': (lat: 43.0757, lng: 25.6172),
    'Враца': (lat: 43.2102, lng: 23.5529),
    'Габрово': (lat: 42.8742, lng: 25.3186),
    'Асеновград': (lat: 42.0125, lng: 24.8772),
    'Видин': (lat: 43.9961, lng: 22.8679),
    'Казанлък': (lat: 42.6244, lng: 25.3929),
    'Кюстендил': (lat: 42.2839, lng: 22.6911),
    'Монтана': (lat: 43.4125, lng: 23.2250),
    'Димитровград': (lat: 42.0641, lng: 25.5721),
    'Ловеч': (lat: 43.1333, lng: 24.7167),
  };

  static List<String> get cities => cityLocations.keys.toList()..sort();

  static String normalizeCityName(String input) {
    if (input.isEmpty) return input;
    final lower = input.toLowerCase().trim();
    const mapping = {
      'shumen': 'Шумен',
      'pleven': 'Плевен',
      'vratsa': 'Враца',
      'sofia': 'София',
      'plovdiv': 'Пловдив',
      'varna': 'Варна',
      'burgas': 'Бургас',
      'ruse': 'Русе',
      'stara zagora': 'Стара Загора',
      'sliven': 'Сливен',
      'dobrich': 'Добрич',
      'pernik': 'Перник',
      'haskovo': 'Хасково',
      'yambol': 'Ямбол',
      'pazardzhik': 'Пазарджик',
      'blagoevgrad': 'Благоевград',
      'veliko tarnovo': 'Велико Търново',
      'gabrovo': 'Габрово',
      'asenovgrad': 'Асеновград',
      'vidin': 'Видин',
      'kazanlak': 'Казанлък',
      'kyustendil': 'Кюстендил',
      'montana': 'Монтана',
      'dimitrovgrad': 'Димитровград',
      'lovech': 'Ловеч',
    };
    if (mapping.containsKey(lower)) return mapping[lower]!;
    for (final city in cityLocations.keys) {
      if (city.toLowerCase() == lower) return city;
    }
    return input;
  }

  // ─── Сезони ───
  static const List<String> seasons = [
    'Пролет',
    'Лято',
    'Есен',
    'Зима',
    'Целогодишно',
  ];

  // ─── Статуси на обяви ───
  static const String statusDraft = 'draft';
  static const String statusActive = 'active';
  static const String statusThresholdReached = 'threshold_reached';
  static const String statusGoConfirmed = 'go_confirmed';
  static const String statusCancelled = 'cancelled';
  static const String statusCompleted = 'completed';

  // ─── Статуси на резервации ───
  static const String reservationPending = 'pending';
  static const String reservationConfirmed = 'confirmed';
  static const String reservationCancelled = 'cancelled';
  static const String reservationCompleted = 'completed';
}
