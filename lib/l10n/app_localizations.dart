import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ca.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ca'),
    Locale('en'),
    Locale('es'),
  ];

  /// No description provided for @usernameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre de usuario o usuaria'**
  String get usernameLabel;

  /// No description provided for @usernameHint.
  ///
  /// In es, this message translates to:
  /// **'Nombre de usuario o usuaria'**
  String get usernameHint;

  /// No description provided for @max20Characters.
  ///
  /// In es, this message translates to:
  /// **'Máximo 20 caracteres'**
  String get max20Characters;

  /// No description provided for @disclaimer.
  ///
  /// In es, this message translates to:
  /// **'Los valores proporcionados por esta aplicación son estimaciones orientativas y no deben interpretarse como asesoramiento profesional o técnico, ni emplearse como única base para decisiones relevantes. Esta herramienta no sustituye instrumentos de medición certificados ni el criterio de un profesional cualificado.\n\nA pesar de haberse desarrollado con el máximo cuidado, no se garantiza la precisión, exhaustividad o adecuación de los resultados en todas las circunstancias. La interpretación y uso de la información recabada son responsabilidad exclusiva del usuario.\n\nEl equipo desarrollador no asumirá, en ningún caso, ninguna responsabilidad por daños directos o indirectos que puedan derivarse del uso, mal uso o interpretación de los datos generados por la aplicación.\n\nEl uso de esta app implica la aceptación expresa de estos términos.'**
  String get disclaimer;

  /// No description provided for @disclaimerMustBeAccepted.
  ///
  /// In es, this message translates to:
  /// **'Debes aceptar el aviso legal para continuar'**
  String get disclaimerMustBeAccepted;

  /// No description provided for @disclaimerAcceptance.
  ///
  /// In es, this message translates to:
  /// **'Acepto el aviso legal'**
  String get disclaimerAcceptance;

  /// No description provided for @disclaimerScrollContinue.
  ///
  /// In es, this message translates to:
  /// **'Sigue scrolleando para continuar'**
  String get disclaimerScrollContinue;

  /// No description provided for @disclaimerReadingText.
  ///
  /// In es, this message translates to:
  /// **'Sigue leyendo para continuar'**
  String get disclaimerReadingText;

  /// No description provided for @startProfile.
  ///
  /// In es, this message translates to:
  /// **'Iniciar perfil'**
  String get startProfile;

  /// No description provided for @importProfile.
  ///
  /// In es, this message translates to:
  /// **'Importar perfil'**
  String get importProfile;

  /// No description provided for @createProfile.
  ///
  /// In es, this message translates to:
  /// **'Crear perfil'**
  String get createProfile;

  /// No description provided for @loginTitle.
  ///
  /// In es, this message translates to:
  /// **'Iniciar\nSesión'**
  String get loginTitle;

  /// No description provided for @registerTitle.
  ///
  /// In es, this message translates to:
  /// **'Registro'**
  String get registerTitle;

  /// No description provided for @userAlreadyRegistered.
  ///
  /// In es, this message translates to:
  /// **'Usuario ya registrado con este correo electrónico'**
  String get userAlreadyRegistered;

  /// No description provided for @userNotFound.
  ///
  /// In es, this message translates to:
  /// **'Usuario no encontrado'**
  String get userNotFound;

  /// No description provided for @profileMenuItem.
  ///
  /// In es, this message translates to:
  /// **'Perfil de usuario'**
  String get profileMenuItem;

  /// No description provided for @creditsMenuItem.
  ///
  /// In es, this message translates to:
  /// **'Créditos'**
  String get creditsMenuItem;

  /// No description provided for @creditsMenuDescription.
  ///
  /// In es, this message translates to:
  /// **'Esta aplicación ha sido desarrollada con el objetivo de facilitar la medición del diámetro de frutas mediante la toma de fotografías. Permite realizar diferentes tipos de mediciones de forma rápida y precisa, contribuyendo a mejorar el control de calidad y la toma de decisiones en procesos agrícolas, comerciales o de investigación.'**
  String get creditsMenuDescription;

  /// No description provided for @creditsDevelopedBy.
  ///
  /// In es, this message translates to:
  /// **'Desarrollado por'**
  String get creditsDevelopedBy;

  /// No description provided for @creditsProjectAcknowledgments.
  ///
  /// In es, this message translates to:
  /// **'Agradecimientos al proyecto: [Texto a completar]'**
  String get creditsProjectAcknowledgments;

  /// No description provided for @creditsFundingAcknowledgments.
  ///
  /// In es, this message translates to:
  /// **'Agradecimientos a las entidades financiadoras: [Texto a completar]'**
  String get creditsFundingAcknowledgments;

  /// No description provided for @creditsDevelopmentText.
  ///
  /// In es, this message translates to:
  /// **'FruitMeasureApp ha sido desarrollado por la Universitat de Lleida (UdL) y por el Institut de Recerca i Tecnologia Agroalimentàries (IRTA) en el marco de la actividad demostrativa \"FruitMeasureApp: Validación y prototipado de una aplicación móvil basada en IA para medir frutos en campo\" (Actividad cofinanciada por la UE a través de la intervención 7201 del Plan estratégico de la PAC 2023-2027).'**
  String get creditsDevelopmentText;

  /// No description provided for @creditsWebsiteText.
  ///
  /// In es, this message translates to:
  /// **'Recursos complementarios vinculados con FruitMeasureApp están disponibles en el sitio web {url}.'**
  String creditsWebsiteText(String url);

  /// No description provided for @creditsWebsiteUrl.
  ///
  /// In es, this message translates to:
  /// **'https://fruitmeasureapp.udl.cat/'**
  String get creditsWebsiteUrl;

  /// No description provided for @logoutMenuItem.
  ///
  /// In es, this message translates to:
  /// **'Cerrar sesión'**
  String get logoutMenuItem;

  /// No description provided for @logoutDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get logoutDialogTitle;

  /// No description provided for @logoutDialogMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Estás seguro de que deseas cerrar sesión?'**
  String get logoutDialogMessage;

  /// No description provided for @cancel.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @profileTitle.
  ///
  /// In es, this message translates to:
  /// **'Perfil'**
  String get profileTitle;

  /// No description provided for @nameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre'**
  String get nameLabel;

  /// No description provided for @emailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get emailLabel;

  /// No description provided for @emailRecommended.
  ///
  /// In es, this message translates to:
  /// **'El correo electrónico no es obligatorio, pero es recomendable para compartir datos'**
  String get emailRecommended;

  /// No description provided for @optionsLabel.
  ///
  /// In es, this message translates to:
  /// **'Opciones'**
  String get optionsLabel;

  /// No description provided for @deletePhotosOption.
  ///
  /// In es, this message translates to:
  /// **'Borrar imágenes del dispositivo'**
  String get deletePhotosOption;

  /// No description provided for @editProfile.
  ///
  /// In es, this message translates to:
  /// **'Editar perfil'**
  String get editProfile;

  /// No description provided for @exportProfile.
  ///
  /// In es, this message translates to:
  /// **'Exportar perfil'**
  String get exportProfile;

  /// No description provided for @switchProfile.
  ///
  /// In es, this message translates to:
  /// **'Cambiar de usuario'**
  String get switchProfile;

  /// No description provided for @deleteProfile.
  ///
  /// In es, this message translates to:
  /// **'Eliminar perfil'**
  String get deleteProfile;

  /// No description provided for @confirmDeleteProfileTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar perfil'**
  String get confirmDeleteProfileTitle;

  /// No description provided for @confirmDeleteProfileMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Está seguro de que desea eliminar este usuario? Se perderán todos los datos almacenados.'**
  String get confirmDeleteProfileMessage;

  /// No description provided for @confirm.
  ///
  /// In es, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @confirmChangesTitle.
  ///
  /// In es, this message translates to:
  /// **'Confirmar cambios'**
  String get confirmChangesTitle;

  /// No description provided for @confirmChangesMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Está seguro de que desea confirmar los cambios realizados?'**
  String get confirmChangesMessage;

  /// No description provided for @saveChanges.
  ///
  /// In es, this message translates to:
  /// **'Guardar cambios'**
  String get saveChanges;

  /// No description provided for @actionDone.
  ///
  /// In es, this message translates to:
  /// **'Acción realizada correctamente'**
  String get actionDone;

  /// No description provided for @actionNotDone.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido completar la acción'**
  String get actionNotDone;

  /// No description provided for @createPlot.
  ///
  /// In es, this message translates to:
  /// **'Crear parcela'**
  String get createPlot;

  /// No description provided for @editPlot.
  ///
  /// In es, this message translates to:
  /// **'Editar parcela'**
  String get editPlot;

  /// No description provided for @deletePlot.
  ///
  /// In es, this message translates to:
  /// **'Eliminar parcela'**
  String get deletePlot;

  /// No description provided for @confirmDeleteElementTitle.
  ///
  /// In es, this message translates to:
  /// **'Eliminar elemento'**
  String get confirmDeleteElementTitle;

  /// No description provided for @confirmDeleteElementMessage.
  ///
  /// In es, this message translates to:
  /// **'¿Está seguro de que desea eliminar este elemento permanentemente?'**
  String get confirmDeleteElementMessage;

  /// No description provided for @mapTypeTooltip.
  ///
  /// In es, this message translates to:
  /// **'Tipo de mapa'**
  String get mapTypeTooltip;

  /// No description provided for @mapTypeNormal.
  ///
  /// In es, this message translates to:
  /// **'Normal'**
  String get mapTypeNormal;

  /// No description provided for @mapTypeSatellite.
  ///
  /// In es, this message translates to:
  /// **'Satélite'**
  String get mapTypeSatellite;

  /// No description provided for @mapTypeHybrid.
  ///
  /// In es, this message translates to:
  /// **'Híbrido'**
  String get mapTypeHybrid;

  /// No description provided for @mapTypeTerrain.
  ///
  /// In es, this message translates to:
  /// **'Terreno'**
  String get mapTypeTerrain;

  /// No description provided for @goToMyLocationTooltip.
  ///
  /// In es, this message translates to:
  /// **'Mi ubicación'**
  String get goToMyLocationTooltip;

  /// No description provided for @locationServicesDisabled.
  ///
  /// In es, this message translates to:
  /// **'Los servicios de ubicación están deshabilitados.'**
  String get locationServicesDisabled;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In es, this message translates to:
  /// **'Los permisos de ubicación han sido denegados.'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionPermanentlyDenied.
  ///
  /// In es, this message translates to:
  /// **'Los permisos de ubicación están permanentemente denegados. Por favor, habilítalos en la configuración de la aplicación.'**
  String get locationPermissionPermanentlyDenied;

  /// No description provided for @plotNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la parcela'**
  String get plotNameLabel;

  /// No description provided for @plotNameHint.
  ///
  /// In es, this message translates to:
  /// **'Nombre de la parcela'**
  String get plotNameHint;

  /// No description provided for @farmerNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre del agricultor/a'**
  String get farmerNameLabel;

  /// No description provided for @farmerNameHint.
  ///
  /// In es, this message translates to:
  /// **'Nombre del agricultor/a'**
  String get farmerNameHint;

  /// No description provided for @plantationDateLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha de plantación'**
  String get plantationDateLabel;

  /// No description provided for @plantationDateHint.
  ///
  /// In es, this message translates to:
  /// **'Fecha de plantación'**
  String get plantationDateHint;

  /// No description provided for @varietyLabel.
  ///
  /// In es, this message translates to:
  /// **'Especie y variedad'**
  String get varietyLabel;

  /// No description provided for @varietyHint.
  ///
  /// In es, this message translates to:
  /// **'Especie y variedad'**
  String get varietyHint;

  /// No description provided for @descriptionLabel.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get descriptionLabel;

  /// No description provided for @descriptionHint.
  ///
  /// In es, this message translates to:
  /// **'Descripción'**
  String get descriptionHint;

  /// No description provided for @plotLocationLabel.
  ///
  /// In es, this message translates to:
  /// **'Ubicación de la parcela'**
  String get plotLocationLabel;

  /// No description provided for @locationDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Ubicación (WGS84)'**
  String get locationDialogTitle;

  /// No description provided for @tapToEditMap.
  ///
  /// In es, this message translates to:
  /// **'Toca para editar'**
  String get tapToEditMap;

  /// No description provided for @tapToViewMap.
  ///
  /// In es, this message translates to:
  /// **'Toca para ver el mapa'**
  String get tapToViewMap;

  /// No description provided for @createMeasurement.
  ///
  /// In es, this message translates to:
  /// **'Crear medición'**
  String get createMeasurement;

  /// No description provided for @editMeasurement.
  ///
  /// In es, this message translates to:
  /// **'Editar medición'**
  String get editMeasurement;

  /// No description provided for @deleteMeasurement.
  ///
  /// In es, this message translates to:
  /// **'Eliminar medición'**
  String get deleteMeasurement;

  /// No description provided for @measurementModelLabel.
  ///
  /// In es, this message translates to:
  /// **'Modelo'**
  String get measurementModelLabel;

  /// No description provided for @measurementModelHint.
  ///
  /// In es, this message translates to:
  /// **'Modelo'**
  String get measurementModelHint;

  /// No description provided for @measurementObservationsLabel.
  ///
  /// In es, this message translates to:
  /// **'Observaciones'**
  String get measurementObservationsLabel;

  /// No description provided for @measurementObservationsHint.
  ///
  /// In es, this message translates to:
  /// **'Observaciones'**
  String get measurementObservationsHint;

  /// No description provided for @exitWithoutSave.
  ///
  /// In es, this message translates to:
  /// **'Salir sin guardar'**
  String get exitWithoutSave;

  /// No description provided for @exitWithoutSaveQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Está seguro de que desea salir sin guardar?'**
  String get exitWithoutSaveQuestion;

  /// No description provided for @accept.
  ///
  /// In es, this message translates to:
  /// **'Aceptar'**
  String get accept;

  /// No description provided for @supportDistance.
  ///
  /// In es, this message translates to:
  /// **'Distancia del soporte de la cámara (mm)'**
  String get supportDistance;

  /// No description provided for @users.
  ///
  /// In es, this message translates to:
  /// **'Usuarios'**
  String get users;

  /// No description provided for @plotView.
  ///
  /// In es, this message translates to:
  /// **'Vista de parcela'**
  String get plotView;

  /// No description provided for @plots.
  ///
  /// In es, this message translates to:
  /// **'Parcelas'**
  String get plots;

  /// No description provided for @searchPlots.
  ///
  /// In es, this message translates to:
  /// **'Buscar parcela...'**
  String get searchPlots;

  /// No description provided for @withoutPlots.
  ///
  /// In es, this message translates to:
  /// **'Sin parcelas'**
  String get withoutPlots;

  /// No description provided for @noPlotsRegistered.
  ///
  /// In es, this message translates to:
  /// **'No hay parcelas registradas'**
  String get noPlotsRegistered;

  /// No description provided for @copy.
  ///
  /// In es, this message translates to:
  /// **'Copia'**
  String get copy;

  /// No description provided for @compareCurves.
  ///
  /// In es, this message translates to:
  /// **'Comparar curvas'**
  String get compareCurves;

  /// No description provided for @importPlots.
  ///
  /// In es, this message translates to:
  /// **'Importar parcelas'**
  String get importPlots;

  /// No description provided for @duplicatePlots.
  ///
  /// In es, this message translates to:
  /// **'Duplicar parcela'**
  String get duplicatePlots;

  /// No description provided for @downloadKML.
  ///
  /// In es, this message translates to:
  /// **'Descargar como KML'**
  String get downloadKML;

  /// No description provided for @exportPlots.
  ///
  /// In es, this message translates to:
  /// **'Exportar parcelas'**
  String get exportPlots;

  /// No description provided for @dataMeasurement.
  ///
  /// In es, this message translates to:
  /// **'Datos de medición'**
  String get dataMeasurement;

  /// No description provided for @caliber.
  ///
  /// In es, this message translates to:
  /// **'Calibre'**
  String get caliber;

  /// No description provided for @latitude.
  ///
  /// In es, this message translates to:
  /// **'Latitud'**
  String get latitude;

  /// No description provided for @longitude.
  ///
  /// In es, this message translates to:
  /// **'Longitud'**
  String get longitude;

  /// No description provided for @notAvalaible.
  ///
  /// In es, this message translates to:
  /// **'No disponible'**
  String get notAvalaible;

  /// No description provided for @delete.
  ///
  /// In es, this message translates to:
  /// **'Eliminar'**
  String get delete;

  /// No description provided for @camera.
  ///
  /// In es, this message translates to:
  /// **'Cámara'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In es, this message translates to:
  /// **'Galería'**
  String get gallery;

  /// No description provided for @takeNewShot.
  ///
  /// In es, this message translates to:
  /// **'Tomar nueva captura'**
  String get takeNewShot;

  /// No description provided for @editShot.
  ///
  /// In es, this message translates to:
  /// **'Editar captura'**
  String get editShot;

  /// No description provided for @detectionFruit.
  ///
  /// In es, this message translates to:
  /// **'Fruto'**
  String get detectionFruit;

  /// No description provided for @statistics.
  ///
  /// In es, this message translates to:
  /// **'Estadísticas'**
  String get statistics;

  /// No description provided for @caliberSeasonText.
  ///
  /// In es, this message translates to:
  /// **'Calibre - Época (aclareo/maduración)'**
  String get caliberSeasonText;

  /// No description provided for @withoutData.
  ///
  /// In es, this message translates to:
  /// **'Sin datos'**
  String get withoutData;

  /// No description provided for @caliberMin.
  ///
  /// In es, this message translates to:
  /// **'Calibre mínimo'**
  String get caliberMin;

  /// No description provided for @caliberAvg.
  ///
  /// In es, this message translates to:
  /// **'Calibre medio'**
  String get caliberAvg;

  /// No description provided for @caliberMax.
  ///
  /// In es, this message translates to:
  /// **'Calibre máximo'**
  String get caliberMax;

  /// No description provided for @numberOfImages.
  ///
  /// In es, this message translates to:
  /// **'Nº de imágenes'**
  String get numberOfImages;

  /// No description provided for @avgFruitsPerImage.
  ///
  /// In es, this message translates to:
  /// **'Frutos/imagen'**
  String get avgFruitsPerImage;

  /// No description provided for @shareChartImage.
  ///
  /// In es, this message translates to:
  /// **'Compartir como imagen'**
  String get shareChartImage;

  /// No description provided for @shareChartCsv.
  ///
  /// In es, this message translates to:
  /// **'Compartir como CSV'**
  String get shareChartCsv;

  /// No description provided for @modelUpdateTo.
  ///
  /// In es, this message translates to:
  /// **'Modelo actualizado a'**
  String get modelUpdateTo;

  /// No description provided for @noImageCaptured.
  ///
  /// In es, this message translates to:
  /// **'Sin capturas'**
  String get noImageCaptured;

  /// No description provided for @noCaptureForMeasurement.
  ///
  /// In es, this message translates to:
  /// **'No se han encontrado capturas para esta medición'**
  String get noCaptureForMeasurement;

  /// No description provided for @makeCapture.
  ///
  /// In es, this message translates to:
  /// **'Realizar captura'**
  String get makeCapture;

  /// No description provided for @selectImageFromGallery.
  ///
  /// In es, this message translates to:
  /// **'Seleccionar imagen desde la galería'**
  String get selectImageFromGallery;

  /// No description provided for @loadingProcessingImage.
  ///
  /// In es, this message translates to:
  /// **'Procesando imagen...'**
  String get loadingProcessingImage;

  /// No description provided for @selectingImages.
  ///
  /// In es, this message translates to:
  /// **'Seleccionando imágenes...'**
  String get selectingImages;

  /// No description provided for @comparative.
  ///
  /// In es, this message translates to:
  /// **'Comparativa'**
  String get comparative;

  /// No description provided for @growthCurve.
  ///
  /// In es, this message translates to:
  /// **'Curva de crecimiento'**
  String get growthCurve;

  /// No description provided for @compareGrowthCurves.
  ///
  /// In es, this message translates to:
  /// **'Comparar curvas de crecimiento'**
  String get compareGrowthCurves;

  /// No description provided for @currentGrowthRate.
  ///
  /// In es, this message translates to:
  /// **'Tasa de crecimiento actual'**
  String get currentGrowthRate;

  /// No description provided for @millimetersDay.
  ///
  /// In es, this message translates to:
  /// **'mm/día'**
  String get millimetersDay;

  /// No description provided for @temporalEvolutionPlot.
  ///
  /// In es, this message translates to:
  /// **'Evolución temporal de la parcela (calibre)'**
  String get temporalEvolutionPlot;

  /// No description provided for @tapPointsForDetails.
  ///
  /// In es, this message translates to:
  /// **'Toca los puntos para ver detalles'**
  String get tapPointsForDetails;

  /// No description provided for @calendar.
  ///
  /// In es, this message translates to:
  /// **'Calendario'**
  String get calendar;

  /// No description provided for @withoutObservations.
  ///
  /// In es, this message translates to:
  /// **'Sin observaciones'**
  String get withoutObservations;

  /// No description provided for @measurementLabel.
  ///
  /// In es, this message translates to:
  /// **'Medición'**
  String get measurementLabel;

  /// No description provided for @selectModelLabel.
  ///
  /// In es, this message translates to:
  /// **'Selecciona un modelo'**
  String get selectModelLabel;

  /// No description provided for @creationDateLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha de creación'**
  String get creationDateLabel;

  /// No description provided for @measurementsLabel.
  ///
  /// In es, this message translates to:
  /// **'Mediciones'**
  String get measurementsLabel;

  /// No description provided for @searchMeasurement.
  ///
  /// In es, this message translates to:
  /// **'Buscar medición...'**
  String get searchMeasurement;

  /// No description provided for @withoutMeasurements.
  ///
  /// In es, this message translates to:
  /// **'Sin mediciones'**
  String get withoutMeasurements;

  /// No description provided for @noMeasurementsRegistered.
  ///
  /// In es, this message translates to:
  /// **'No hay mediciones registradas'**
  String get noMeasurementsRegistered;

  /// No description provided for @exportMeasurements.
  ///
  /// In es, this message translates to:
  /// **'Exportar mediciones'**
  String get exportMeasurements;

  /// No description provided for @importMeasurements.
  ///
  /// In es, this message translates to:
  /// **'Importar mediciones'**
  String get importMeasurements;

  /// No description provided for @calendarView.
  ///
  /// In es, this message translates to:
  /// **'Vista de calendario'**
  String get calendarView;

  /// No description provided for @language.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @languageEs.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get languageEs;

  /// No description provided for @languageEn.
  ///
  /// In es, this message translates to:
  /// **'Inglés'**
  String get languageEn;

  /// No description provided for @languageCa.
  ///
  /// In es, this message translates to:
  /// **'Catalán'**
  String get languageCa;

  /// No description provided for @binWidthGrouping.
  ///
  /// In es, this message translates to:
  /// **'Agrupación'**
  String get binWidthGrouping;

  /// No description provided for @yAxisMode.
  ///
  /// In es, this message translates to:
  /// **'Eje Y:'**
  String get yAxisMode;

  /// No description provided for @binWidthWarningFullscreen.
  ///
  /// In es, this message translates to:
  /// **'💡 La agrupación actual de {binWidth}mm genera {numGroups} grupos. Para una mejor visualización se recomienda usar {recommended}mm.'**
  String binWidthWarningFullscreen(
    int binWidth,
    int numGroups,
    int recommended,
  );

  /// No description provided for @binWidthWarningExport.
  ///
  /// In es, this message translates to:
  /// **'⚠️ La agrupación de {binWidth}mm genera {numGroups} grupos. Para compartir/exportar se recomienda {recommended}mm.'**
  String binWidthWarningExport(int binWidth, int numGroups, int recommended);

  /// No description provided for @yAxisWarningFullscreen.
  ///
  /// In es, this message translates to:
  /// **'ℹ️ Eje Y simplificado en modo pantalla completa para mejorar la lectura (saltos de {step}).'**
  String yAxisWarningFullscreen(int step);

  /// No description provided for @yAxisWarningNormal.
  ///
  /// In es, this message translates to:
  /// **'ℹ️ Eje Y autoajustado para mantener la legibilidad (saltos de {step}).'**
  String yAxisWarningNormal(int step);

  /// No description provided for @numberOfFruits.
  ///
  /// In es, this message translates to:
  /// **'Nº de frutos'**
  String get numberOfFruits;

  /// No description provided for @percentageOfFruits.
  ///
  /// In es, this message translates to:
  /// **'% de frutos'**
  String get percentageOfFruits;

  /// No description provided for @fruit.
  ///
  /// In es, this message translates to:
  /// **'fruta'**
  String get fruit;

  /// No description provided for @fruits.
  ///
  /// In es, this message translates to:
  /// **'frutas'**
  String get fruits;

  /// No description provided for @tapToSeeDetails.
  ///
  /// In es, this message translates to:
  /// **'Toca para ver detalles'**
  String get tapToSeeDetails;

  /// No description provided for @exportFormat.
  ///
  /// In es, this message translates to:
  /// **'Formato de exportación'**
  String get exportFormat;

  /// No description provided for @exportFormatJson.
  ///
  /// In es, this message translates to:
  /// **'JSON (.fma)'**
  String get exportFormatJson;

  /// No description provided for @exportFormatJsonDescription.
  ///
  /// In es, this message translates to:
  /// **'Formato para importar'**
  String get exportFormatJsonDescription;

  /// No description provided for @exportFormatCsv.
  ///
  /// In es, this message translates to:
  /// **'CSV'**
  String get exportFormatCsv;

  /// No description provided for @exportFormatCsvDescription.
  ///
  /// In es, this message translates to:
  /// **'Formato de hoja de cálculo'**
  String get exportFormatCsvDescription;

  /// No description provided for @exportFormatTxt.
  ///
  /// In es, this message translates to:
  /// **'TXT'**
  String get exportFormatTxt;

  /// No description provided for @exportFormatTxtDescription.
  ///
  /// In es, this message translates to:
  /// **'Informe legible'**
  String get exportFormatTxtDescription;

  /// No description provided for @errorNoImageSelected.
  ///
  /// In es, this message translates to:
  /// **'¡ERROR! No se seleccionó ninguna imagen'**
  String get errorNoImageSelected;

  /// No description provided for @errorInvalidImageData.
  ///
  /// In es, this message translates to:
  /// **'¡ERROR! Datos de imagen inválidos'**
  String get errorInvalidImageData;

  /// No description provided for @errorNoFruitsDetected.
  ///
  /// In es, this message translates to:
  /// **'No se detectaron frutas'**
  String get errorNoFruitsDetected;

  /// No description provided for @errorSupportNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontró el soporte de referencia'**
  String get errorSupportNotFound;

  /// No description provided for @errorNoValidDetections.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron detecciones válidas'**
  String get errorNoValidDetections;

  /// No description provided for @errorNoValidPhotos.
  ///
  /// In es, this message translates to:
  /// **'No se procesaron fotos válidas'**
  String get errorNoValidPhotos;

  /// No description provided for @errorMissingParams.
  ///
  /// In es, this message translates to:
  /// **'Faltan parámetros requeridos'**
  String get errorMissingParams;

  /// No description provided for @errorGallerySavePermissionDenied.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar en galería: Permisos denegados'**
  String get errorGallerySavePermissionDenied;

  /// No description provided for @errorGallerySaveFailed.
  ///
  /// In es, this message translates to:
  /// **'No se pudo guardar en galería'**
  String get errorGallerySaveFailed;

  /// No description provided for @photoProcessed.
  ///
  /// In es, this message translates to:
  /// **'foto procesada correctamente'**
  String get photoProcessed;

  /// No description provided for @photosProcessed.
  ///
  /// In es, this message translates to:
  /// **'fotos procesadas correctamente'**
  String get photosProcessed;

  /// No description provided for @processingImages.
  ///
  /// In es, this message translates to:
  /// **'Procesando'**
  String get processingImages;

  /// No description provided for @ofTotal.
  ///
  /// In es, this message translates to:
  /// **'de'**
  String get ofTotal;

  /// No description provided for @noModel.
  ///
  /// In es, this message translates to:
  /// **'Sin modelo'**
  String get noModel;

  /// No description provided for @millimetersUnit.
  ///
  /// In es, this message translates to:
  /// **'mm'**
  String get millimetersUnit;

  /// No description provided for @errorImportWrongFileMeasurement.
  ///
  /// In es, this message translates to:
  /// **'Archivo incorrecto: Este es un archivo de MEDICIONES (.measurement.fma). Para importar parcelas, usa un archivo .plot.fma'**
  String get errorImportWrongFileMeasurement;

  /// No description provided for @errorImportWrongFilePlot.
  ///
  /// In es, this message translates to:
  /// **'Archivo incorrecto: Este es un archivo de PARCELAS (.plot.fma). Para importar mediciones, usa un archivo .measurement.fma'**
  String get errorImportWrongFilePlot;

  /// No description provided for @errorImportWrongFileGeneric.
  ///
  /// In es, this message translates to:
  /// **'Formato de archivo incorrecto. Debe ser un archivo .plot.fma o .measurement.fma'**
  String get errorImportWrongFileGeneric;

  /// No description provided for @errorImportWrongFileGenericMeasurements.
  ///
  /// In es, this message translates to:
  /// **'Formato de archivo incorrecto. Para importar mediciones, el archivo debe tener la extensión .measurement.fma'**
  String get errorImportWrongFileGenericMeasurements;

  /// No description provided for @errorImportWrongFileGenericPlots.
  ///
  /// In es, this message translates to:
  /// **'Formato de archivo incorrecto. Para importar parcelas, el archivo debe tener la extensión .plot.fma'**
  String get errorImportWrongFileGenericPlots;

  /// No description provided for @errorImportEmptyFile.
  ///
  /// In es, this message translates to:
  /// **'El archivo está vacío'**
  String get errorImportEmptyFile;

  /// No description provided for @errorImportNoPlots.
  ///
  /// In es, this message translates to:
  /// **'No hay parcelas en el archivo'**
  String get errorImportNoPlots;

  /// No description provided for @errorImportNoMeasurements.
  ///
  /// In es, this message translates to:
  /// **'No hay mediciones en el archivo'**
  String get errorImportNoMeasurements;

  /// No description provided for @errorImportParseError.
  ///
  /// In es, this message translates to:
  /// **'Error al leer el archivo. Verifica que el formato sea correcto'**
  String get errorImportParseError;

  /// No description provided for @errorImportParseErrorMeasurements.
  ///
  /// In es, this message translates to:
  /// **'Error al leer el archivo. El formato debe ser un archivo .measurement.fma válido (JSON). Verifica que el archivo no esté corrupto o modificado'**
  String get errorImportParseErrorMeasurements;

  /// No description provided for @errorImportParseErrorPlots.
  ///
  /// In es, this message translates to:
  /// **'Error al leer el archivo. El formato debe ser un archivo .plot.fma válido (JSON). Verifica que el archivo no esté corrupto o modificado'**
  String get errorImportParseErrorPlots;

  /// No description provided for @errorImportDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Error de importación'**
  String get errorImportDialogTitle;

  /// No description provided for @allPlotsAlreadyImported.
  ///
  /// In es, this message translates to:
  /// **'Todas las parcelas ya fueron importadas'**
  String get allPlotsAlreadyImported;

  /// No description provided for @allMeasurementsAlreadyImported.
  ///
  /// In es, this message translates to:
  /// **'Todas las mediciones ya fueron importadas'**
  String get allMeasurementsAlreadyImported;

  /// No description provided for @importNoProcessedPlots.
  ///
  /// In es, this message translates to:
  /// **'No se procesó ninguna parcela'**
  String get importNoProcessedPlots;

  /// No description provided for @importSummaryOnlyNewPlots.
  ///
  /// In es, this message translates to:
  /// **'{newPlots, plural, =1{Importada} other{Importadas}}: {newPlots} {newPlots, plural, =1{parcela} other{parcelas}}\nMediciones: {measurements}'**
  String importSummaryOnlyNewPlots(Object measurements, num newPlots);

  /// No description provided for @importSummaryOnlyExistingNoChanges.
  ///
  /// In es, this message translates to:
  /// **'{existingPlots, plural, =1{Reimportada} other{Reimportadas}}: {existingPlots} {existingPlots, plural, =1{parcela} other{parcelas}}\nSin cambios en mediciones'**
  String importSummaryOnlyExistingNoChanges(num existingPlots);

  /// No description provided for @importSummaryOnlyExistingWithRestored.
  ///
  /// In es, this message translates to:
  /// **'{existingPlots, plural, =1{Reimportada} other{Reimportadas}}: {existingPlots} {existingPlots, plural, =1{parcela} other{parcelas}}\nRestauradas: {restored} mediciones'**
  String importSummaryOnlyExistingWithRestored(
    num existingPlots,
    Object restored,
  );

  /// No description provided for @importSummaryOnlyExistingWithRestoredAndSkipped.
  ///
  /// In es, this message translates to:
  /// **'{existingPlots, plural, =1{Reimportada} other{Reimportadas}}: {existingPlots} {existingPlots, plural, =1{parcela} other{parcelas}}\nRestauradas: {restored} | Omitidas: {skipped}'**
  String importSummaryOnlyExistingWithRestoredAndSkipped(
    num existingPlots,
    Object restored,
    Object skipped,
  );

  /// No description provided for @importSummaryMixedNoRestored.
  ///
  /// In es, this message translates to:
  /// **'{newPlots, plural, =1{Importada} other{Importadas}}: {newPlots} {newPlots, plural, =1{nueva} other{nuevas}} ({newMeasurements} med.)\n{existingPlots, plural, =1{Reimportada} other{Reimportadas}}: {existingPlots} {existingPlots, plural, =1{existente} other{existentes}}'**
  String importSummaryMixedNoRestored(
    num existingPlots,
    Object newMeasurements,
    num newPlots,
  );

  /// No description provided for @importSummaryMixedWithRestored.
  ///
  /// In es, this message translates to:
  /// **'{newPlots, plural, =1{Importada} other{Importadas}}: {newPlots} {newPlots, plural, =1{nueva} other{nuevas}} ({newMeasurements} med.)\n{existingPlots, plural, =1{Reimportada} other{Reimportadas}}: {existingPlots} | Restauradas: {restored} | Omitidas: {skipped}'**
  String importSummaryMixedWithRestored(
    num existingPlots,
    Object newMeasurements,
    num newPlots,
    Object restored,
    Object skipped,
  );

  /// No description provided for @importMeasurementsOnlyNew.
  ///
  /// In es, this message translates to:
  /// **'Importadas: {count} {count, plural, =1{medición} other{mediciones}}'**
  String importMeasurementsOnlyNew(num count);

  /// No description provided for @importMeasurementsOnlyUpdated.
  ///
  /// In es, this message translates to:
  /// **'Actualizadas: {count} {count, plural, =1{medición} other{mediciones}}'**
  String importMeasurementsOnlyUpdated(num count);

  /// No description provided for @importMeasurementsMixed.
  ///
  /// In es, this message translates to:
  /// **'Importadas: {imported}\nActualizadas: {updated}'**
  String importMeasurementsMixed(Object imported, Object updated);

  /// No description provided for @noMeasurementsForThisPlot.
  ///
  /// In es, this message translates to:
  /// **'No se encontraron mediciones para esta parcela'**
  String get noMeasurementsForThisPlot;

  /// No description provided for @viewAllPlotsOnMap.
  ///
  /// In es, this message translates to:
  /// **'Ver todas en mapa'**
  String get viewAllPlotsOnMap;

  /// No description provided for @noPlotsWithLocation.
  ///
  /// In es, this message translates to:
  /// **'No hay parcelas con ubicación'**
  String get noPlotsWithLocation;

  /// No description provided for @histogramWarning1mmTooMany.
  ///
  /// In es, this message translates to:
  /// **'Demasiados grupos ({count}). Usa agrupación de 3mm, 5mm o 10mm.'**
  String histogramWarning1mmTooMany(Object count);

  /// No description provided for @histogramWarning3mmTooMany.
  ///
  /// In es, this message translates to:
  /// **'Demasiados grupos ({count}) para 3mm. Usa 5mm o 10mm.'**
  String histogramWarning3mmTooMany(Object count);

  /// No description provided for @histogramWarning5mmTooMany.
  ///
  /// In es, this message translates to:
  /// **'Demasiados grupos ({count}) para 5mm. Usa 10mm.'**
  String histogramWarning5mmTooMany(Object count);

  /// No description provided for @histogramInfo10mmMaxReached.
  ///
  /// In es, this message translates to:
  /// **'Muchos grupos ({count}). Ya usas la agrupación máxima (10mm).'**
  String histogramInfo10mmMaxReached(Object count);

  /// No description provided for @deleteFromGalleryLabel.
  ///
  /// In es, this message translates to:
  /// **'Eliminar de la galería'**
  String get deleteFromGalleryLabel;

  /// No description provided for @deleteFromGalleryDescription.
  ///
  /// In es, this message translates to:
  /// **'Esto eliminará permanentemente las imágenes seleccionadas de tu dispositivo.'**
  String get deleteFromGalleryDescription;

  /// No description provided for @imageNotAvailable.
  ///
  /// In es, this message translates to:
  /// **'Imagen no disponible'**
  String get imageNotAvailable;

  /// No description provided for @imageNotAvailableDescription.
  ///
  /// In es, this message translates to:
  /// **'La imagen ya no está disponible en este dispositivo. Es posible que haya sido eliminada de la galería o haya sido procesada desde otro dispositivo.'**
  String get imageNotAvailableDescription;

  /// No description provided for @recoveringImageFromGallery.
  ///
  /// In es, this message translates to:
  /// **'Intentando recuperar imagen desde la galería...'**
  String get recoveringImageFromGallery;

  /// No description provided for @invertedAxesMessage.
  ///
  /// In es, this message translates to:
  /// **'Ejes invertidos para facilitar su visualización'**
  String get invertedAxesMessage;

  /// No description provided for @exportCalendar.
  ///
  /// In es, this message translates to:
  /// **'Exportar a Google Calendar'**
  String get exportCalendar;

  /// No description provided for @exportCalendarSuccess.
  ///
  /// In es, this message translates to:
  /// **'Calendario exportado correctamente'**
  String get exportCalendarSuccess;

  /// No description provided for @exportCalendarError.
  ///
  /// In es, this message translates to:
  /// **'Error al exportar el calendario'**
  String get exportCalendarError;

  /// No description provided for @exportCalendarNoMeasurements.
  ///
  /// In es, this message translates to:
  /// **'No hay mediciones para exportar'**
  String get exportCalendarNoMeasurements;

  /// No description provided for @exportToGoogleCalendar.
  ///
  /// In es, this message translates to:
  /// **'Exportar a Google Calendar'**
  String get exportToGoogleCalendar;

  /// No description provided for @shareWithOtherApps.
  ///
  /// In es, this message translates to:
  /// **'Compartir con otras aplicaciones'**
  String get shareWithOtherApps;

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'Fruit Measure App'**
  String get appTitle;

  /// No description provided for @errorUnknown.
  ///
  /// In es, this message translates to:
  /// **'Error desconocido'**
  String get errorUnknown;

  /// No description provided for @exportMeasurementsCsvHeader.
  ///
  /// In es, this message translates to:
  /// **'ID de Medición,Nombre de Medición,Modelo,Fecha de Creación de Medición,ID de Foto,Fecha de Creación de Foto,Fecha de Captura de Foto,Latitud,Longitud,ID de Detección,Calibre (mm),Confianza,Clase'**
  String get exportMeasurementsCsvHeader;

  /// No description provided for @exportReportTitle.
  ///
  /// In es, this message translates to:
  /// **'INFORME DE EXPORTACIÓN DE MEDICIONES'**
  String get exportReportTitle;

  /// No description provided for @exportReportSeparator.
  ///
  /// In es, this message translates to:
  /// **'========================================'**
  String get exportReportSeparator;

  /// No description provided for @exportDateLabel.
  ///
  /// In es, this message translates to:
  /// **'Fecha de exportación:'**
  String get exportDateLabel;

  /// No description provided for @exportTotalMeasurementsLabel.
  ///
  /// In es, this message translates to:
  /// **'Total de mediciones:'**
  String get exportTotalMeasurementsLabel;

  /// No description provided for @exportMeasurementLabel.
  ///
  /// In es, this message translates to:
  /// **'MEDICIÓN:'**
  String get exportMeasurementLabel;

  /// No description provided for @exportUnnamedLabel.
  ///
  /// In es, this message translates to:
  /// **'Sin nombre'**
  String get exportUnnamedLabel;

  /// No description provided for @exportIdLabel.
  ///
  /// In es, this message translates to:
  /// **'  ID:'**
  String get exportIdLabel;

  /// No description provided for @exportModelLabel.
  ///
  /// In es, this message translates to:
  /// **'  Modelo:'**
  String get exportModelLabel;

  /// No description provided for @exportNotAvailableLabel.
  ///
  /// In es, this message translates to:
  /// **'N/D'**
  String get exportNotAvailableLabel;

  /// No description provided for @exportCreationDateLabel.
  ///
  /// In es, this message translates to:
  /// **'  Fecha de creación:'**
  String get exportCreationDateLabel;

  /// No description provided for @exportObservationsLabel.
  ///
  /// In es, this message translates to:
  /// **'  Observaciones:'**
  String get exportObservationsLabel;

  /// No description provided for @exportNoneLabel.
  ///
  /// In es, this message translates to:
  /// **'Ninguna'**
  String get exportNoneLabel;

  /// No description provided for @exportTotalPhotosLabel.
  ///
  /// In es, this message translates to:
  /// **'  Total de fotos:'**
  String get exportTotalPhotosLabel;

  /// No description provided for @exportPhotoLabel.
  ///
  /// In es, this message translates to:
  /// **'  FOTO'**
  String get exportPhotoLabel;

  /// No description provided for @exportCaptureDataLabel.
  ///
  /// In es, this message translates to:
  /// **'    Fecha de captura:'**
  String get exportCaptureDataLabel;

  /// No description provided for @exportLocationLabel.
  ///
  /// In es, this message translates to:
  /// **'    Ubicación:'**
  String get exportLocationLabel;

  /// No description provided for @exportDetectionsLabel.
  ///
  /// In es, this message translates to:
  /// **'    Detecciones:'**
  String get exportDetectionsLabel;

  /// No description provided for @exportDetectionLabel.
  ///
  /// In es, this message translates to:
  /// **'      DETECCIÓN'**
  String get exportDetectionLabel;

  /// No description provided for @exportCaliberLabel.
  ///
  /// In es, this message translates to:
  /// **'        Calibre:'**
  String get exportCaliberLabel;

  /// No description provided for @exportConfidenceLabel.
  ///
  /// In es, this message translates to:
  /// **'        Confianza:'**
  String get exportConfidenceLabel;

  /// No description provided for @exportClassLabel.
  ///
  /// In es, this message translates to:
  /// **'        Clase:'**
  String get exportClassLabel;

  /// No description provided for @exportPlotsCsvHeader.
  ///
  /// In es, this message translates to:
  /// **'ID de Parcela,Nombre de Parcela,Variedad,Agricultor,ID de Medición,Nombre de Medición,Modelo,Fecha de Creación de Medición,ID de Foto,Fecha de Creación de Foto,Fecha de Captura de Foto,Latitud,Longitud,ID de Detección,Calibre (mm),Confianza,Clase'**
  String get exportPlotsCsvHeader;

  /// No description provided for @exportPlotsReportTitle.
  ///
  /// In es, this message translates to:
  /// **'INFORME DE EXPORTACIÓN DE PARCELAS'**
  String get exportPlotsReportTitle;

  /// No description provided for @exportTotalPlotsLabel.
  ///
  /// In es, this message translates to:
  /// **'Total de parcelas:'**
  String get exportTotalPlotsLabel;

  /// No description provided for @exportPlotLabel.
  ///
  /// In es, this message translates to:
  /// **'PARCELA:'**
  String get exportPlotLabel;

  /// No description provided for @exportVarietyLabel.
  ///
  /// In es, this message translates to:
  /// **'  Variedad:'**
  String get exportVarietyLabel;

  /// No description provided for @exportFarmerLabel.
  ///
  /// In es, this message translates to:
  /// **'  Agricultor:'**
  String get exportFarmerLabel;

  /// No description provided for @calendarEventMeasurementPrefix.
  ///
  /// In es, this message translates to:
  /// **'Medición -'**
  String get calendarEventMeasurementPrefix;

  /// No description provided for @calendarEventObservations.
  ///
  /// In es, this message translates to:
  /// **'Observaciones:'**
  String get calendarEventObservations;

  /// No description provided for @calendarEventModel.
  ///
  /// In es, this message translates to:
  /// **'Modelo:'**
  String get calendarEventModel;

  /// No description provided for @calendarEventPlot.
  ///
  /// In es, this message translates to:
  /// **'Parcela:'**
  String get calendarEventPlot;

  /// No description provided for @calendarEventVariety.
  ///
  /// In es, this message translates to:
  /// **'Variedad:'**
  String get calendarEventVariety;

  /// No description provided for @errorFileWriteFailed.
  ///
  /// In es, this message translates to:
  /// **'Error al escribir archivo'**
  String get errorFileWriteFailed;

  /// No description provided for @errorFileReadFailed.
  ///
  /// In es, this message translates to:
  /// **'Error al leer archivo'**
  String get errorFileReadFailed;

  /// No description provided for @errorExportFailed.
  ///
  /// In es, this message translates to:
  /// **'Error al exportar'**
  String get errorExportFailed;

  /// No description provided for @errorImportUserFailed.
  ///
  /// In es, this message translates to:
  /// **'Error al importar usuario'**
  String get errorImportUserFailed;

  /// No description provided for @errorDeletePhotoFailed.
  ///
  /// In es, this message translates to:
  /// **'Error al eliminar foto'**
  String get errorDeletePhotoFailed;

  /// No description provided for @errorYoloPredictionFailed.
  ///
  /// In es, this message translates to:
  /// **'Error en detección de frutas'**
  String get errorYoloPredictionFailed;

  /// No description provided for @errorUnexpected.
  ///
  /// In es, this message translates to:
  /// **'Error inesperado'**
  String get errorUnexpected;

  /// No description provided for @tooltipViewFullscreen.
  ///
  /// In es, this message translates to:
  /// **'Ver en grande'**
  String get tooltipViewFullscreen;

  /// No description provided for @tooltipScrollMode.
  ///
  /// In es, this message translates to:
  /// **'Modo con scroll'**
  String get tooltipScrollMode;

  /// No description provided for @tooltipFullView.
  ///
  /// In es, this message translates to:
  /// **'Vista completa'**
  String get tooltipFullView;

  /// No description provided for @tooltipViewPreviousValues.
  ///
  /// In es, this message translates to:
  /// **'Ver valores anteriores'**
  String get tooltipViewPreviousValues;

  /// No description provided for @tooltipViewNextValues.
  ///
  /// In es, this message translates to:
  /// **'Ver valores siguientes'**
  String get tooltipViewNextValues;

  /// No description provided for @tooltipRotateScreen.
  ///
  /// In es, this message translates to:
  /// **'Rotar pantalla'**
  String get tooltipRotateScreen;

  /// No description provided for @modelNameFruto.
  ///
  /// In es, this message translates to:
  /// **'Fruto'**
  String get modelNameFruto;

  /// No description provided for @modelNameCorimbo.
  ///
  /// In es, this message translates to:
  /// **'Corimbo'**
  String get modelNameCorimbo;

  /// No description provided for @modelNameCaixa.
  ///
  /// In es, this message translates to:
  /// **'Caja'**
  String get modelNameCaixa;

  /// No description provided for @noCalibersDetected.
  ///
  /// In es, this message translates to:
  /// **'No se detectaron calibres'**
  String get noCalibersDetected;

  /// No description provided for @unknown.
  ///
  /// In es, this message translates to:
  /// **'Desconocido'**
  String get unknown;

  /// No description provided for @confidenceThresholdLabel.
  ///
  /// In es, this message translates to:
  /// **'Nivel de confianza'**
  String get confidenceThresholdLabel;

  /// No description provided for @confidenceThresholdDescription.
  ///
  /// In es, this message translates to:
  /// **'Umbral mínimo para detecciones'**
  String get confidenceThresholdDescription;

  /// No description provided for @yoloLicenseTitle.
  ///
  /// In es, this message translates to:
  /// **'Licencia YOLO'**
  String get yoloLicenseTitle;

  /// No description provided for @yoloLicenseText.
  ///
  /// In es, this message translates to:
  /// **'Esta aplicación incorpora componentes de Ultralytics YOLOv11.\n\nYOLOv11 © Ultralytics y colaboradores.\nLicenciado bajo la GNU Affero General Public License v3.0 (AGPL-3.0).\n\nEsta aplicación se distribuye sin ninguna garantía.\n\nCódigo fuente disponible en:\nhttps://github.com/GRAP-UdL-AT/FruitMeasureApp'**
  String get yoloLicenseText;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ca', 'en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ca':
      return AppLocalizationsCa();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
