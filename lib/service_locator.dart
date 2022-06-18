import 'package:get_it/get_it.dart';
import 'package:memes_max/models/themeMeme.dart';

GetIt sl = GetIt.instance;

void setupServiceLocator() {
  sl.registerSingleton<ThemeMeme>(ThemeMeme());
}
