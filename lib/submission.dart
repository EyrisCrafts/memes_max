import 'dart:convert';

import 'package:flutter/material.dart';

class Meme {
  String id;
  String url;
  GlobalKey? imageGlobal;
  String height;
  String width;

  set setImageGlobal(GlobalKey imageGlobal) => this.imageGlobal = imageGlobal;

  String get getHeight => height;

  set setHeight(String height) => this.height = height;

  String get getWidth => width;

  set setWidth(String width) => this.width = width;

  String get getId => id;

  set setId(String id) => this.id = id;

  String get getUrl => url;

  set setUrl(String url) => this.url = url;
  Meme({
    required this.id,
    required this.url,
    this.width = '0',
    this.height = '0',
    this.imageGlobal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
    };
  }

  factory Meme.fromMap(Map<String, dynamic> map) {
    return Meme(
      id: map['id'] ?? '',
      url: map['url'] ?? '',
    );
  }

  String toJson() => json.encode(toMap());

  factory Meme.fromJson(String source) => Meme.fromMap(json.decode(source));

  @override
  String toString() => 'Meme(id: $id, url: $url)';
}

class MemeFile {
  String path;
  GlobalKey key;

  String get getPath => path;

  set setPath(String path) => this.path = path;

  MemeFile({
    required this.path,
    required this.key,
  });

  @override
  String toString() => 'MemeFile(path: $path, key: $key)';
}
