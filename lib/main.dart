import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fruit_measure_app/components/colors.dart';
import 'package:fruit_measure_app/domains/detections/models/detection.dart';
import 'package:fruit_measure_app/domains/measurements/models/measurement.dart';
import 'package:fruit_measure_app/domains/measurements/views/measurement_list_view.dart';
import 'package:fruit_measure_app/domains/measurements/views/measurement_view.dart';
import 'package:fruit_measure_app/domains/measurements/views/measurements_calendar_view.dart';
import 'package:fruit_measure_app/domains/measurements/views/measurements_multi_growth_curve_stadistics_view.dart';
import 'package:fruit_measure_app/domains/measurements/views/measurements_stadistics_view.dart';
import 'package:fruit_measure_app/domains/photos/models/photo.dart';
import 'package:fruit_measure_app/domains/photos/views/photo_list_view.dart';
import 'package:fruit_measure_app/domains/photos/views/photo_view.dart';
import 'package:fruit_measure_app/domains/photos/views/photos_statistics_view.dart';
import 'package:fruit_measure_app/domains/plots/models/plot.dart';
import 'package:fruit_measure_app/domains/plots/views/plot_list_view.dart';
import 'package:fruit_measure_app/domains/plots/views/plot_view.dart';
import 'package:fruit_measure_app/domains/plots/views/plots_map_view.dart';
import 'package:fruit_measure_app/domains/users/models/language_manager.dart';
import 'package:fruit_measure_app/domains/users/models/user.dart';
import 'package:fruit_measure_app/domains/users/values/constants.dart';
import 'package:fruit_measure_app/domains/users/views/credits_view.dart';
import 'package:fruit_measure_app/domains/users/views/log_in_view.dart';
import 'package:fruit_measure_app/domains/users/views/profile_view.dart';
import 'package:fruit_measure_app/domains/users/views/switch_account_view.dart';
import 'package:fruit_measure_app/hive/hive_registrar.g.dart';
import 'package:fruit_measure_app/hive_boxes.dart';
import 'package:fruit_measure_app/l10n/app_localizations.dart';
import 'package:hive_ce_flutter/adapters.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> _clearCorruptedBox(String boxName) async {
  try {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box(boxName).close();
    }
    await Hive.deleteBoxFromDisk(boxName);
    if (kDebugMode) {
      print('Cleared corrupted box: $boxName');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error clearing box $boxName: $e');
    }
  }
}

Future<Box<T>> _openBoxSafely<T>(String boxName) async {
  try {
    return await Hive.openBox<T>(boxName);
  } catch (e) {
    if (kDebugMode) {
      print('Error opening box $boxName: $e');
      print('Attempting to clear corrupted box...');
    }
    await _clearCorruptedBox(boxName);
    return Hive.openBox<T>(boxName);
  }
}

Future<Box> _openBoxSafelyUntyped(String boxName) async {
  try {
    return await Hive.openBox(boxName);
  } catch (e) {
    if (kDebugMode) {
      print('Error opening box $boxName: $e');
      print('Attempting to clear corrupted box...');
    }
    await _clearCorruptedBox(boxName);
    return Hive.openBox(boxName);
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  Hive.registerAdapters();

  await _openBoxSafely<User>(userBoxName);
  await _openBoxSafelyUntyped(sessionBoxName);
  await _openBoxSafely<Plot>(plotBoxName);
  await _openBoxSafely<Measurement>(measurementBoxName);
  await _openBoxSafely<Photo>(photoBoxName);
  await _openBoxSafely<Detection>(detectionsBoxName);

  await initializeDateFormatting();

  PaintingBinding.instance.imageCache.maximumSize = 50;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 50 * 1024 * 1024;

  runApp(const AppInitializer());
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  String? _initialRoute;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final sessionBox = Hive.box(sessionBoxName);
    final savedUserId = sessionBox.get('currentUserId');

    if (savedUserId != null) {
      final userBox = Hive.box<User>(userBoxName);
      final savedUser = userBox.get(savedUserId);

      if (savedUser != null) {
        currentUser = savedUser;
        LanguageManager.loadSavedLanguage();
        _initialRoute = '/';
      } else {
        _initialRoute = '/login';
      }
    } else {
      _initialRoute = '/login';
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MyApp(initialRoute: _initialRoute ?? '/login');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.initialRoute});

  final String initialRoute;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // 2) Cada vez que cambie el idioma, reconstruimos el MaterialApp
    LanguageManager.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    LanguageManager.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() => setState(() {});

  String get _localizedTitle {
    switch (LanguageManager.locale.languageCode) {
      case 'es':
        return 'Fruit Measure App';
      case 'ca':
        return 'Fruit Measure App';
      case 'en':
      default:
        return 'Fruit Measure App';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _localizedTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: fmaWhite,
          brightness: Brightness.light,
          primary: fmaBlack,
          secondary: fmaPricipal,
          tertiary: fmaWhiteComplementary,
          surface: fmaWhite,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          elevation: 3,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF1F3F4),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      locale: LanguageManager.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: widget.initialRoute,
      routes: {
        '/': (context) => const PlotListView(),
        '/login': (context) => const LogInView(),
        '/profile':
            (context) =>
                currentUser != null
                    ? ProfileView(user: currentUser!)
                    : const SizedBox(),
        '/switch-account': (context) => const SwitchAccountView(),
        '/credits': (context) => const CreditsView(),
        '/plot': (context) {
          final arguments =
              ModalRoute.of(context)!.settings.arguments as PlotViewArguments?;
          if (arguments == null) return const SizedBox();

          return PlotView(
            plot: arguments.plot,
            isCreatePlot: arguments.isCreatePlot,
          );
        },
        '/plots-map': (context) {
          final arguments =
              ModalRoute.of(context)!.settings.arguments
                  as PlotsMapViewArguments?;
          if (arguments == null) return const SizedBox();

          return PlotsMapView(plots: arguments.plots);
        },
        '/measurements': (context) {
          final arguments =
              ModalRoute.of(context)!.settings.arguments
                  as MeasurementListViewArguments?;
          if (arguments == null) return const SizedBox();

          return MeasurementListView(plot: arguments.plot);
        },
        '/measurements-calendar': (context) {
          final arguments =
              ModalRoute.of(context)!.settings.arguments
                  as MeasurementsCalendarViewArguments?;
          if (arguments == null) return const SizedBox();

          return MeasurementsCalendarView(plot: arguments.plot);
        },
        '/measurements-growth-curve-statistics': (context) {
          final arguments =
              ModalRoute.of(context)!.settings.arguments
                  as MeasurementsMultiGrowthCurveStatisticsViewArguments?;
          if (arguments == null) return const SizedBox();

          return MeasurementsMultiGrowthCurveStatisticsView(
            plots: arguments.plots,
          );
        },
        '/measurements-multi-growth-curve-statistics': (context) {
          final arguments =
              ModalRoute.of(context)!.settings.arguments
                  as MeasurementsMultiGrowthCurveStatisticsViewArguments?;
          if (arguments == null) return const SizedBox();

          return MeasurementsMultiGrowthCurveStatisticsView(
            plots: arguments.plots,
          );
        },
        '/measurements-stadistics-view': (context) {
          final arguments =
              ModalRoute.of(context)!.settings.arguments
                  as MeasurementsStatisticsViewArguments?;

          if (arguments == null) return const SizedBox();

          return MeasurementsStadisticsView(
            measurements: arguments.measurements,
          );
        },
        '/measurement': (context) {
          final arguments =
              ModalRoute.of(context)!.settings.arguments
                  as MeasurementViewArguments?;
          if (arguments == null) return const SizedBox();

          return MeasurementView(
            measurement: arguments.measurement,
            isCreateMeasurement: arguments.isCreateMeasurement,
          );
        },
        '/photos': (context) {
          final arguments =
              ModalRoute.of(context)!.settings.arguments
                  as PhotoListViewArguments?;
          if (arguments == null) return const SizedBox();

          return PhotoListView(
            plot: arguments.plot,
            measurement: arguments.measurement,
          );
        },
        '/photos-statistics': (context) {
          final arguments =
              ModalRoute.of(context)!.settings.arguments
                  as PhotosStatisticsViewArguments?;
          if (arguments == null) return const SizedBox();

          return PhotosStatisticsView(
            plot: arguments.plot,
            measurement: arguments.measurement,
          );
        },
        '/photo': (context) {
          final arguments =
              ModalRoute.of(context)!.settings.arguments as PhotoViewArguments?;
          if (arguments == null) return const SizedBox();

          return PhotoView(
            photo: arguments.photo,
            isCreatePhoto: arguments.isCreatePhoto,
            takenImage: arguments.takenImage,
          );
        },
      },
    );
  }
}
