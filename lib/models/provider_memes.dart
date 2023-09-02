import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get_it/get_it.dart';
import 'package:memes_max/models/theme_meme.dart';
import 'package:memes_max/submission.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' as ui;

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;

import 'package:share_plus/share_plus.dart';

class ProviderMemes extends ChangeNotifier {
  // Reddit? reddit;
  bool isLoading = false;
  String subreddit = "memes";
  List<Meme> memes = [];
  String? lastMeme;

  Future<void> setupReddit() async {
    // reddit = await Reddit.createReadOnlyInstance(clientId: "Y82I2nvR-d4CNg", clientSecret: "mTPPwrOque6TX2WuEAqiMp1b6SU", userAgent: "whatever");
    notifyListeners();
  }

  void updateMemeCategory(String subreddit) {
    memes.clear();
    this.subreddit = subreddit;
    lastMeme = null;
    requestNextPage();
  }

  void saveImage(int index) async {
    if (await Permission.storage.isDenied) {
      PermissionStatus status = await Permission.storage.request();
      if (status.isDenied) return;
    }
    RenderRepaintBoundary? boundary = GetIt.I<ProviderMemes>().memes[index].imageGlobal?.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();
    // String bs64 = base64Encode(pngBytes);

    getExternalStorageDirectory().then((directory) {
      File imageFile = File("${directory!.path}/${GetIt.I<ProviderMemes>().memes[index].getId}.png");
      imageFile.writeAsBytesSync(pngBytes);
      GetIt.I<ThemeMeme>().showToast(Icons.thumb_up, "Saved Image");
    });
  }

  void shareMeme(int index) async {
    if (await Permission.storage.isDenied) {
      PermissionStatus status = await Permission.storage.request();
      if (status.isDenied) return;
    }
    RenderRepaintBoundary? boundary = GetIt.I<ProviderMemes>().memes[index].imageGlobal?.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return;

    ui.Image image = await boundary.toImage(pixelRatio: 3.0);

    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    Uint8List pngBytes = byteData!.buffer.asUint8List();

    getApplicationDocumentsDirectory().then((directory) {
      File imageFile = File("${directory.path}/temp.png");
      imageFile.writeAsBytesSync(pngBytes);
      Share.shareFiles(
        ['${directory.path}/temp.png'],
        text: 'Checkout this meme',
      );
    });
  }


  void requestNextPage() async {
    if (isLoading) return;
    isLoading = true;
    notifyListeners();
    // if (reddit == null) await setupReddit();
    try {
      List<Map<String, String>> content = await getRedditMemes(count: 25 + memes.length, after: lastMeme);

      memes.addAll(content.map((e) => Meme(imageGlobal: GlobalKey(), id: e['title'] ?? "", url: e['imageUrl'] ?? "", height: '200', width: '200')).toList());

      isLoading = false;
      notifyListeners();

      //Save last id
      if (memes.isNotEmpty) {
        lastMeme = memes.last.id;
      }
    } catch (e) {
      //Show toast
      log("Error occurred ");
      log("Error occurred $e");
      GetIt.I<ThemeMeme>().showToast(Icons.error, "Error Loading memes");
    }
  }

  Future<List<Map<String, String>>> getImagesFromReddit(int page) async {
    final url = 'https://old.reddit.com/r/memes/hot.json?limit=20&page=$page';
    log("getting url $url");
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      var items = <Map<String, String>>[];
      final posts = json['data']['children'].map((post) {
        final imageUrl = post['data']['url'];
        final postId = post['data']['id'];
        if (imageUrl.toString().startsWith("https://i.redd.it")) {
          items.add({'title': postId, 'imageUrl': imageUrl});
        }
        // return ImagePost(imageUrl, postId);
      }).toList();

      return items;
    } else {
      throw Exception('Failed to get images from Reddit');
    }
  }

  Future<List<Map<String, String>>> getRedditMemes({String? after, int? count}) async {
    String url = 'https://old.reddit.com/r/memes/';
    try {
      if (after != null && count != null) {
        url += '?count=$count&after=$after';
      }
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var document = parse(response.body);
        var items = <Map<String, String>>[];
        List<dom.Element> links = document.querySelectorAll('a.title');
        List<dom.Element> posts = document.querySelectorAll('div.thing');
        for (var i = 0; i < links.length; i++) {
          final link = links[i];
          final post = posts[i];  // Corresponding post element
          
          final href = link.attributes['href'];
          final title = link.text;
          final id = post.attributes['data-fullname'];  // Extracting the unique ID

          if (href != null && (href.endsWith('.jpg') || href.endsWith('.png'))) {
            items.add({
              'id': id ?? "",   // Adding the id field here
              'title': id ?? "", 
              'imageUrl': href.startsWith('http') ? href : 'https://old.reddit.com$href'
            });
          }
        }

        return items;
      } else {
        log("Exception loading memes");
        throw Exception('Failed to load memes');
      }
    } catch (e) {
      log("Exception loading memes $e");
      return [];
    }
  }

  bool imageFilter(dynamic element) {
    bool hasCrappyInternet = GetIt.I<ThemeMeme>().hasCrappyInternet;
    return element['url'].toString().contains("i.redd") &&
        !element['url'].toString().contains(".gif") &&
        ((hasCrappyInternet && (element['preview']['images'][0]['source']['height'] * element['preview']['images'][0]['source']['width'] < 2250000)) || !hasCrappyInternet);
  }
}
