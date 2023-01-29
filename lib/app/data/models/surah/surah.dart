import 'dart:convert';

import 'package:equatable/equatable.dart';

class Surah extends Equatable {
  final int? id;
  final String? name;
  final String? transliteration;
  final String? translation;
  final String? type;
  final int? totalVerses;
  final String? link;

  const Surah({
    this.id,
    this.name,
    this.transliteration,
    this.translation,
    this.type,
    this.totalVerses,
    this.link,
  });

  factory Surah.fromMap(Map<String, dynamic> data) => Surah(
        id: data['id'] as int?,
        name: data['name'] as String?,
        transliteration: data['transliteration'] as String?,
        translation: data['translation'] as String?,
        type: data['type'] as String?,
        totalVerses: data['total_verses'] as int?,
        link: data['link'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'transliteration': transliteration,
        'translation': translation,
        'type': type,
        'total_verses': totalVerses,
        'link': link,
      };

  /// `dart:convert`
  ///
  /// Parses the string and returns the resulting Json object as [Surah].
  factory Surah.fromJson(String data) {
    return Surah.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  /// `dart:convert`
  ///
  /// Converts [Surah] to a JSON string.
  String toJson() => json.encode(toMap());

  Surah copyWith({
    int? id,
    String? name,
    String? transliteration,
    String? translation,
    String? type,
    int? totalVerses,
    String? link,
  }) {
    return Surah(
      id: id ?? this.id,
      name: name ?? this.name,
      transliteration: transliteration ?? this.transliteration,
      translation: translation ?? this.translation,
      type: type ?? this.type,
      totalVerses: totalVerses ?? this.totalVerses,
      link: link ?? this.link,
    );
  }

  @override
  bool get stringify => true;

  @override
  List<Object?> get props {
    return [
      id,
      name,
      transliteration,
      translation,
      type,
      totalVerses,
      link,
    ];
  }
}
