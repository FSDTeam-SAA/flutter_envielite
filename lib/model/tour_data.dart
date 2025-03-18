// lib/models/tour_model.dart

class TourData {
  final Map<String, TourRoute> routes;

  TourData({required this.routes});

  factory TourData.fromJson(Map<String, dynamic> json) {
    final routes = <String, TourRoute>{};
    json.forEach((key, value) {
      routes[key] = TourRoute.fromJson(value);
    });
    return TourData(routes: routes);
  }

  Map<String, dynamic> toJson() {
    return routes.map((key, value) => MapEntry(key, value.toJson()));
  }
}

class TourRoute {
  final Map<String, TourLanguage> languages;

  TourRoute({required this.languages});

  factory TourRoute.fromJson(Map<String, dynamic> json) {
    final languages = <String, TourLanguage>{};
    json.forEach((key, value) {
      languages[key] = TourLanguage.fromJson(value);
    });
    return TourRoute(languages: languages);
  }

  Map<String, dynamic> toJson() {
    return languages.map((key, value) => MapEntry(key, value.toJson()));
  }
}

class TourLanguage {
  final String? intro;
  final List<TourPOI> pois;

  TourLanguage({this.intro, required this.pois});

  factory TourLanguage.fromJson(Map<String, dynamic> json) {
    return TourLanguage(
      intro: json['intro'],
      pois: (json['pois'] as List<dynamic>?)
          ?.map((poi) => TourPOI.fromJson(poi))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'intro': intro,
      'pois': pois.map((poi) => poi.toJson()).toList(),
    };
  }
}

class TourPOI {
  final double lat;
  final double lng;
  String audio;
  final String name;
  final bool played;

  TourPOI({
    required this.lat,
    required this.lng,
    required this.audio,
    required this.name,
    this.played = false,
  });

  factory TourPOI.fromJson(Map<String, dynamic> json) {
    return TourPOI(
      lat: json['lat'] as double,
      lng: json['lng'] as double,
      audio: json['audio'] as String,
      name: json['name'] as String,
      played: json['played'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'audio': audio,
      'name': name,
      'played': played,
    };
  }
}

