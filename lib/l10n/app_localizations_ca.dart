// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Catalan Valencian (`ca`).
class AppLocalizationsCa extends AppLocalizations {
  AppLocalizationsCa([String locale = 'ca']) : super(locale);

  @override
  String get usernameLabel => 'Nom d\'usuari o usuària';

  @override
  String get usernameHint => 'Nom d\'usuari o usuària';

  @override
  String get max20Characters => 'Màxim 20 caràcters';

  @override
  String get disclaimer =>
      'Els valors proporcionats per aquesta aplicació són estimacions orientatives i no s\'han d\'interpretar com a assessorament professional o tècnic, ni emprar-se com a única base per a decisions rellevants. Aquesta eina no substitueix instruments de mesura certificats ni el criteri d\'un professional qualificat.\n\nMalgrat haver estat desenvolupada amb la màxima cura, no es garanteix la precisió, exhaustivitat o idoneïtat dels resultats en totes les circumstàncies. La interpretació i l\'ús de la informació recollida són responsabilitat exclusiva de l\'usuari.\n\nL\'equip desenvolupador no assumirà, en cap cas, cap responsabilitat per danys directes o indirectes que puguin derivar-se de l\'ús, mal ús o interpretació de les dades generades per l\'aplicació.\n\nL\'ús d\'aquesta aplicació implica l\'acceptació expressa d\'aquests termes.';

  @override
  String get disclaimerMustBeAccepted =>
      'Has d\'acceptar l\'avís legal per continuar';

  @override
  String get disclaimerAcceptance => 'Accepto l\'avís legal';

  @override
  String get disclaimerScrollContinue => 'Continua scrollejant per continuar';

  @override
  String get disclaimerReadingText => 'Continua llegint per continuar';

  @override
  String get startProfile => 'Iniciar perfil';

  @override
  String get importProfile => 'Importar perfil';

  @override
  String get createProfile => 'Crear perfil';

  @override
  String get loginTitle => 'Iniciar\nSessió';

  @override
  String get registerTitle => 'Registre';

  @override
  String get userAlreadyRegistered =>
      'Usuari ja registrat amb aquest correu electrònic';

  @override
  String get userNotFound => 'Usuari no trobat';

  @override
  String get profileMenuItem => 'Perfil d\'usuari';

  @override
  String get creditsMenuItem => 'Crèdits';

  @override
  String get creditsMenuDescription =>
      'Aquesta aplicació ha estat desenvolupada amb l\'objectiu de facilitar la mesura del diàmetre de fruits mitjançant la presa de fotografies. Permet realitzar diferents tipus de mesuraments de manera ràpida i precisa, contribuïnt a millorar el control de qualitat i la presa de decisions en processos agrícoles, comercials o de recerca.';

  @override
  String get creditsDevelopedBy => 'Desenvolupat per';

  @override
  String get creditsProjectAcknowledgments =>
      'Agraïments al projecte: [Text a completar]';

  @override
  String get creditsFundingAcknowledgments =>
      'Agraïments a les entitats finançadores: [Text a completar]';

  @override
  String get creditsDevelopmentText =>
      'FruitMeasureApp ha estat desenvolupat per la Universitat de Lleida (UdL) i per l\'Institut de Recerca i Tecnologia Agroalimentàries (IRTA) en el marc de l\'activitat demostrativa \"FruitMeasureApp: Validació i prototipatge d\'una aplicació mòbil basada en IA per mesurar fruits en camp\" (Activitat cofinançada per la UE a través de la intervenció 7201 del Pla estratègic de la PAC 2023-2027).';

  @override
  String creditsWebsiteText(String url) {
    return 'Recursos complementaris vinculats amb FruitMeasureApp estan disponibles al lloc web $url.';
  }

  @override
  String get creditsWebsiteUrl => 'https://fruitmeasureapp.udl.cat/';

  @override
  String get logoutMenuItem => 'Tancar sessió';

  @override
  String get logoutDialogTitle => 'Confirmar';

  @override
  String get logoutDialogMessage => 'Estàs segur que vols tancar la sessió?';

  @override
  String get cancel => 'Cancel·lar';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get nameLabel => 'Nom';

  @override
  String get emailLabel => 'Correu electrònic';

  @override
  String get emailRecommended =>
      'El correu electrònic no és obligatori, però és recomanable per compartir dades';

  @override
  String get optionsLabel => 'Opcions';

  @override
  String get deletePhotosOption => 'Esborrar imatges del dispositiu';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get exportProfile => 'Exportar perfil';

  @override
  String get switchProfile => 'Canviar d\'usuari';

  @override
  String get deleteProfile => 'Eliminar perfil';

  @override
  String get confirmDeleteProfileTitle => 'Eliminar perfil';

  @override
  String get confirmDeleteProfileMessage =>
      'Estàs segur que vols eliminar aquest usuari? Es perdran totes les dades emmagatzemades.';

  @override
  String get confirm => 'Confirmar';

  @override
  String get confirmChangesTitle => 'Confirmar canvis';

  @override
  String get confirmChangesMessage =>
      'Estàs segur que vols confirmar els canvis realitzats?';

  @override
  String get saveChanges => 'Desar canvis';

  @override
  String get actionDone => 'Acció realitzada correctament';

  @override
  String get actionNotDone => 'No s’ha pogut completar l’acció';

  @override
  String get createPlot => 'Crear parcel·la';

  @override
  String get editPlot => 'Editar parcel·la';

  @override
  String get deletePlot => 'Eliminar parcel·la';

  @override
  String get confirmDeleteElementTitle => 'Eliminar element';

  @override
  String get confirmDeleteElementMessage =>
      'Estàs segur que vols eliminar aquest element permanentment?';

  @override
  String get mapTypeTooltip => 'Tipus de mapa';

  @override
  String get mapTypeNormal => 'Normal';

  @override
  String get mapTypeSatellite => 'Satèl·lit';

  @override
  String get mapTypeHybrid => 'Híbrid';

  @override
  String get mapTypeTerrain => 'Terreny';

  @override
  String get goToMyLocationTooltip => 'La meva ubicació';

  @override
  String get locationServicesDisabled =>
      'Els serveis de localització estan desactivats.';

  @override
  String get locationPermissionDenied =>
      'Els permisos de localització han estat denegats.';

  @override
  String get locationPermissionPermanentlyDenied =>
      'Els permisos de localització estan permanentment denegats. Si us plau, habilita’ls a la configuració de l’aplicació.';

  @override
  String get plotNameLabel => 'Nom de la parcel·la';

  @override
  String get plotNameHint => 'Nom de la parcel·la';

  @override
  String get farmerNameLabel => 'Nom de l\'agricultor/a';

  @override
  String get farmerNameHint => 'Nom de l\'agricultor/a';

  @override
  String get plantationDateLabel => 'Data de plantació';

  @override
  String get plantationDateHint => 'Data de plantació';

  @override
  String get varietyLabel => 'Espècie i Varietat';

  @override
  String get varietyHint => 'Espècie i Varietat';

  @override
  String get descriptionLabel => 'Descripció';

  @override
  String get descriptionHint => 'Descripció';

  @override
  String get plotLocationLabel => 'Ubicació de la parcel·la';

  @override
  String get locationDialogTitle => 'Ubicació (WGS84)';

  @override
  String get tapToEditMap => 'Toca per editar';

  @override
  String get tapToViewMap => 'Toca per veure el mapa';

  @override
  String get createMeasurement => 'Crear mesura';

  @override
  String get editMeasurement => 'Editar mesura';

  @override
  String get deleteMeasurement => 'Eliminar mesura';

  @override
  String get measurementModelLabel => 'Model';

  @override
  String get measurementModelHint => 'Model';

  @override
  String get measurementObservationsLabel => 'Observacions';

  @override
  String get measurementObservationsHint => 'Observacions';

  @override
  String get exitWithoutSave => 'Sortir sense desar';

  @override
  String get exitWithoutSaveQuestion =>
      'Estàs segur que vols sortir sense desar?';

  @override
  String get accept => 'Acceptar';

  @override
  String get supportDistance => 'Distància del suport de la càmera (mm)';

  @override
  String get users => 'Usuaris';

  @override
  String get plotView => 'Vista de parcel·la';

  @override
  String get plots => 'Parcel·les';

  @override
  String get searchPlots => 'Cercar parcel·la...';

  @override
  String get withoutPlots => 'Sense parcel·les';

  @override
  String get noPlotsRegistered => 'No hi ha parcel·les registrades';

  @override
  String get copy => 'Còpia';

  @override
  String get compareCurves => 'Comparar corbes';

  @override
  String get importPlots => 'Importar parcel·les';

  @override
  String get duplicatePlots => 'Duplicar parcel·la';

  @override
  String get downloadKML => 'Descarregar com a KML';

  @override
  String get exportPlots => 'Exportar parcel·les';

  @override
  String get dataMeasurement => 'Dades de mesura';

  @override
  String get caliber => 'Calibre';

  @override
  String get latitude => 'Latitud';

  @override
  String get longitude => 'Longitud';

  @override
  String get notAvalaible => 'No disponible';

  @override
  String get delete => 'Eliminar';

  @override
  String get camera => 'Càmera';

  @override
  String get gallery => 'Galeria';

  @override
  String get takeNewShot => 'Fer nova captura';

  @override
  String get editShot => 'Editar captura';

  @override
  String get detectionFruit => 'Fruit';

  @override
  String get statistics => 'Estadístiques';

  @override
  String get caliberSeasonText => 'Calibre - Època (aclarida/maduració)';

  @override
  String get withoutData => 'Sense dades';

  @override
  String get caliberMin => 'Calibre mínim';

  @override
  String get caliberAvg => 'Calibre mitjà';

  @override
  String get caliberMax => 'Calibre màxim';

  @override
  String get numberOfImages => 'Núm. d’imatges';

  @override
  String get avgFruitsPerImage => 'Fruits/imatge';

  @override
  String get shareChartImage => 'Compartir com a imatge';

  @override
  String get shareChartCsv => 'Compartir com a CSV';

  @override
  String get modelUpdateTo => 'Model actualitzat a';

  @override
  String get noImageCaptured => 'Sense captures';

  @override
  String get noCaptureForMeasurement =>
      'No s’han trobat captures per a aquesta mesura';

  @override
  String get makeCapture => 'Realitzar captura';

  @override
  String get selectImageFromGallery => 'Seleccionar imatge des de la galeria';

  @override
  String get loadingProcessingImage => 'Processant imatge...';

  @override
  String get selectingImages => 'Seleccionant imatges...';

  @override
  String get comparative => 'Comparativa';

  @override
  String get growthCurve => 'Corba de creixement';

  @override
  String get compareGrowthCurves => 'Comparar corbes de creixement';

  @override
  String get currentGrowthRate => 'Taxa de creixement actual';

  @override
  String get millimetersDay => 'mm/dia';

  @override
  String get temporalEvolutionPlot =>
      'Evolució temporal de la parcel·la (calibre)';

  @override
  String get tapPointsForDetails => 'Toca els punts per veure detalls';

  @override
  String get calendar => 'Calendari';

  @override
  String get withoutObservations => 'Sense observacions';

  @override
  String get measurementLabel => 'Mesura';

  @override
  String get selectModelLabel => 'Selecciona un model';

  @override
  String get creationDateLabel => 'Data de creació';

  @override
  String get measurementsLabel => 'Mesures';

  @override
  String get searchMeasurement => 'Cercar mesura...';

  @override
  String get withoutMeasurements => 'Sense mesures';

  @override
  String get noMeasurementsRegistered => 'No hi ha mesures registrades';

  @override
  String get exportMeasurements => 'Exportar mesures';

  @override
  String get importMeasurements => 'Importar mesures';

  @override
  String get calendarView => 'Vista de calendari';

  @override
  String get language => 'Idioma';

  @override
  String get languageEs => 'Espanyol';

  @override
  String get languageEn => 'Anglès';

  @override
  String get languageCa => 'Català';

  @override
  String get binWidthGrouping => 'Agrupació';

  @override
  String get yAxisMode => 'Eix Y:';

  @override
  String binWidthWarningFullscreen(
    int binWidth,
    int numGroups,
    int recommended,
  ) {
    return '💡 L\'agrupació actual de ${binWidth}mm genera $numGroups grups. Per a una millor visualització es recomana usar ${recommended}mm.';
  }

  @override
  String binWidthWarningExport(int binWidth, int numGroups, int recommended) {
    return '⚠️ L\'agrupació de ${binWidth}mm genera $numGroups grups. Per a compartir/exportar es recomana ${recommended}mm.';
  }

  @override
  String yAxisWarningFullscreen(int step) {
    return 'ℹ️ Eix Y simplificat en mode pantalla completa per millorar la lectura (salts de $step).';
  }

  @override
  String yAxisWarningNormal(int step) {
    return 'ℹ️ Eix Y autoajustat per mantenir la llegibilitat (salts de $step).';
  }

  @override
  String get numberOfFruits => 'Núm. de fruits';

  @override
  String get percentageOfFruits => '% de fruits';

  @override
  String get fruit => 'fruit';

  @override
  String get fruits => 'fruits';

  @override
  String get tapToSeeDetails => 'Toca per veure detalls';

  @override
  String get exportFormat => 'Format d’exportació';

  @override
  String get exportFormatJson => 'JSON (.fma)';

  @override
  String get exportFormatJsonDescription => 'Format per importar';

  @override
  String get exportFormatCsv => 'CSV';

  @override
  String get exportFormatCsvDescription => 'Format de full de càlcul';

  @override
  String get exportFormatTxt => 'TXT';

  @override
  String get exportFormatTxtDescription => 'Informe llegible';

  @override
  String get errorNoImageSelected => 'ERROR! No s’ha seleccionat cap imatge';

  @override
  String get errorInvalidImageData => 'ERROR! Dades d’imatge invàlides';

  @override
  String get errorNoFruitsDetected => 'No s\'han detectat fruits';

  @override
  String get errorSupportNotFound => 'No s’ha trobat el suport de referència';

  @override
  String get errorNoValidDetections => 'No s’han trobat deteccions vàlides';

  @override
  String get errorNoValidPhotos => 'No s’han processat fotos vàlides';

  @override
  String get errorMissingParams => 'Falten paràmetres requerits';

  @override
  String get errorGallerySavePermissionDenied =>
      'No s’ha pogut desar a la galeria: Permisos denegats';

  @override
  String get errorGallerySaveFailed => 'No s’ha pogut desar a la galeria';

  @override
  String get photoProcessed => 'foto processada correctament';

  @override
  String get photosProcessed => 'fotos processades correctament';

  @override
  String get processingImages => 'Processant';

  @override
  String get ofTotal => 'de';

  @override
  String get noModel => 'Sense model';

  @override
  String get millimetersUnit => 'mm';

  @override
  String get errorImportWrongFileMeasurement =>
      'Arxiu incorrecte: Aquest és un arxiu de MESURES (.measurement.fma). Per importar parcel·les, utilitza un arxiu .plot.fma';

  @override
  String get errorImportWrongFilePlot =>
      'Arxiu incorrecte: Aquest és un arxiu de PARCEL·LES (.plot.fma). Per importar mesures, utilitza un arxiu .measurement.fma';

  @override
  String get errorImportWrongFileGeneric =>
      'Format d’arxiu incorrecte. Ha de ser un arxiu .plot.fma o .measurement.fma';

  @override
  String get errorImportWrongFileGenericMeasurements =>
      'Format d’arxiu incorrecte. Per importar mesures, l’arxiu ha de tenir l’extensió .measurement.fma';

  @override
  String get errorImportWrongFileGenericPlots =>
      'Format d’arxiu incorrecte. Per importar parcel·les, l’arxiu ha de tenir l’extensió .plot.fma';

  @override
  String get errorImportEmptyFile => 'L’arxiu està buit';

  @override
  String get errorImportNoPlots => 'No hi ha parcel·les a l’arxiu';

  @override
  String get errorImportNoMeasurements => 'No hi ha mesures a l’arxiu';

  @override
  String get errorImportParseError =>
      'Error en llegir l’arxiu. Verifica que el format sigui correcte';

  @override
  String get errorImportParseErrorMeasurements =>
      'Error en llegir l’arxiu. El format ha de ser un arxiu .measurement.fma vàlid (JSON). Verifica que l’arxiu no estigui corrupte o modificat';

  @override
  String get errorImportParseErrorPlots =>
      'Error en llegir l’arxiu. El format ha de ser un arxiu .plot.fma vàlid (JSON). Verifica que l’arxiu no estigui corrupte o modificat';

  @override
  String get errorImportDialogTitle => 'Error d’importació';

  @override
  String get allPlotsAlreadyImported =>
      'Totes les parcel·les ja han estat importades';

  @override
  String get allMeasurementsAlreadyImported =>
      'Totes les mesures ja han estat importades';

  @override
  String get importNoProcessedPlots => 'No s’ha processat cap parcel·la';

  @override
  String importSummaryOnlyNewPlots(Object measurements, num newPlots) {
    return 'Importades: $newPlots parcel·les\nMesures: $measurements';
  }

  @override
  String importSummaryOnlyExistingNoChanges(num existingPlots) {
    return 'Reimportada: $existingPlots parcel·la\nSense canvis en mesures';
  }

  @override
  String importSummaryOnlyExistingWithRestored(
    num existingPlots,
    Object restored,
  ) {
    return 'Reimportada: $existingPlots parcel·la\nRestaurades: $restored mesures';
  }

  @override
  String importSummaryOnlyExistingWithRestoredAndSkipped(
    num existingPlots,
    Object restored,
    Object skipped,
  ) {
    return 'Reimportada: $existingPlots parcel·la\nRestaurades: $restored | Omeses: $skipped';
  }

  @override
  String importSummaryMixedNoRestored(
    num existingPlots,
    Object newMeasurements,
    num newPlots,
  ) {
    return 'Importades: $newPlots noves ($newMeasurements mes.)\nReimportada: $existingPlots existent';
  }

  @override
  String importSummaryMixedWithRestored(
    num existingPlots,
    Object newMeasurements,
    num newPlots,
    Object restored,
    Object skipped,
  ) {
    return 'Importades: $newPlots noves ($newMeasurements mes.)\nReimportada: $existingPlots | Restaurades: $restored | Omeses: $skipped';
  }

  @override
  String importMeasurementsOnlyNew(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'mesures',
      one: 'mesura',
    );
    return 'Importades: $count $_temp0';
  }

  @override
  String importMeasurementsOnlyUpdated(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'mesures',
      one: 'mesura',
    );
    return 'Actualitzades: $count $_temp0';
  }

  @override
  String importMeasurementsMixed(Object imported, Object updated) {
    return 'Importades: $imported\nActualitzades: $updated';
  }

  @override
  String get noMeasurementsForThisPlot =>
      'No s’han trobat mesures per a aquesta parcel·la';

  @override
  String get viewAllPlotsOnMap => 'Veure totes al mapa';

  @override
  String get noPlotsWithLocation => 'No hi ha parcel·les amb ubicació';

  @override
  String histogramWarning1mmTooMany(Object count) {
    return 'Massa grups ($count). Utilitza agrupació de 3mm, 5mm o 10mm.';
  }

  @override
  String histogramWarning3mmTooMany(Object count) {
    return 'Massa grups ($count) per 3mm. Utilitza 5mm o 10mm.';
  }

  @override
  String histogramWarning5mmTooMany(Object count) {
    return 'Massa grups ($count) per 5mm. Utilitza 10mm.';
  }

  @override
  String histogramInfo10mmMaxReached(Object count) {
    return 'Molts grups ($count). Ja utilitzes l’agrupació màxima (10mm).';
  }

  @override
  String get deleteFromGalleryLabel => 'Eliminar de la galeria';

  @override
  String get deleteFromGalleryDescription =>
      'Això eliminarà permanentment les imatges seleccionades del teu dispositiu.';

  @override
  String get imageNotAvailable => 'Imatge no disponible';

  @override
  String get imageNotAvailableDescription =>
      'La imatge ja no està disponible en aquest dispositiu. És possible que hagi estat eliminada de la galeria o hagi estat processada des d’un altre dispositiu.';

  @override
  String get recoveringImageFromGallery =>
      'Intentant recuperar imatge des de la galeria...';

  @override
  String get invertedAxesMessage =>
      'Eixos invertits per facilitar la seva visualització';

  @override
  String get exportCalendar => 'Exportar a Google Calendar';

  @override
  String get exportCalendarSuccess => 'Calendari exportat correctament';

  @override
  String get exportCalendarError => 'Error en exportar el calendari';

  @override
  String get exportCalendarNoMeasurements => 'No hi ha mesures per exportar';

  @override
  String get exportToGoogleCalendar => 'Exportar a Google Calendar';

  @override
  String get shareWithOtherApps => 'Compartir amb altres aplicacions';

  @override
  String get appTitle => 'Fruit Measure App';

  @override
  String get errorUnknown => 'Error desconegut';

  @override
  String get exportMeasurementsCsvHeader =>
      'ID de Mesura,Nom de Mesura,Model,Data de Creació de Mesura,ID de Foto,Data de Creació de Foto,Data de Captura de Foto,Latitud,Longitud,ID de Detecció,Calibre (mm),Confiança,Classe';

  @override
  String get exportReportTitle => 'INFORME D\'EXPORTACIÓ DE MESURES';

  @override
  String get exportReportSeparator =>
      '========================================';

  @override
  String get exportDateLabel => 'Data d\'exportació:';

  @override
  String get exportTotalMeasurementsLabel => 'Total de mesures:';

  @override
  String get exportMeasurementLabel => 'MESURA:';

  @override
  String get exportUnnamedLabel => 'Sense nom';

  @override
  String get exportIdLabel => '  ID:';

  @override
  String get exportModelLabel => '  Model:';

  @override
  String get exportNotAvailableLabel => 'N/D';

  @override
  String get exportCreationDateLabel => '  Data de creació:';

  @override
  String get exportObservationsLabel => '  Observacions:';

  @override
  String get exportNoneLabel => 'Cap';

  @override
  String get exportTotalPhotosLabel => '  Total de fotos:';

  @override
  String get exportPhotoLabel => '  FOTO';

  @override
  String get exportCaptureDataLabel => '    Data de captura:';

  @override
  String get exportLocationLabel => '    Ubicació:';

  @override
  String get exportDetectionsLabel => '    Deteccions:';

  @override
  String get exportDetectionLabel => '      DETECCIÓ';

  @override
  String get exportCaliberLabel => '        Calibre:';

  @override
  String get exportConfidenceLabel => '        Confiança:';

  @override
  String get exportClassLabel => '        Classe:';

  @override
  String get exportPlotsCsvHeader =>
      'ID de Parcel·la,Nom de Parcel·la,Varietat,Agricultor/a,ID de Mesura,Nom de Mesura,Model,Data de Creació de Mesura,ID de Foto,Data de Creació de Foto,Data de Captura de Foto,Latitud,Longitud,ID de Detecció,Calibre (mm),Confiança,Classe';

  @override
  String get exportPlotsReportTitle => 'INFORME D\'EXPORTACIÓ DE PARCEL·LES';

  @override
  String get exportTotalPlotsLabel => 'Total de parcel·les:';

  @override
  String get exportPlotLabel => 'PARCEL·LA:';

  @override
  String get exportVarietyLabel => '  Varietat:';

  @override
  String get exportFarmerLabel => '  Agricultor/a:';

  @override
  String get calendarEventMeasurementPrefix => 'Mesura -';

  @override
  String get calendarEventObservations => 'Observacions:';

  @override
  String get calendarEventModel => 'Model:';

  @override
  String get calendarEventPlot => 'Parcel·la:';

  @override
  String get calendarEventVariety => 'Varietat:';

  @override
  String get errorFileWriteFailed => 'Error en escriure l\'arxiu';

  @override
  String get errorFileReadFailed => 'Error en llegir l\'arxiu';

  @override
  String get errorExportFailed => 'Error en exportar';

  @override
  String get errorImportUserFailed => 'Error en importar usuari';

  @override
  String get errorDeletePhotoFailed => 'Error en eliminar foto';

  @override
  String get errorYoloPredictionFailed => 'Error en detecció de fruits';

  @override
  String get errorUnexpected => 'Error inesperat';

  @override
  String get tooltipViewFullscreen => 'Veure en gran';

  @override
  String get tooltipScrollMode => 'Mode amb desplaçament';

  @override
  String get tooltipFullView => 'Vista completa';

  @override
  String get tooltipViewPreviousValues => 'Veure valors anteriors';

  @override
  String get tooltipViewNextValues => 'Veure valors següents';

  @override
  String get tooltipRotateScreen => 'Rotar pantalla';

  @override
  String get modelNameFruto => 'Fruit';

  @override
  String get modelNameCorimbo => 'Corimbe';

  @override
  String get modelNameCaixa => 'Caixa';

  @override
  String get noCalibersDetected => 'No s\'han detectat calibres';

  @override
  String get unknown => 'Desconegut';

  @override
  String get confidenceThresholdLabel => 'Nivell de confiança';

  @override
  String get confidenceThresholdDescription => 'Llindar mínim per a deteccions';

  @override
  String get yoloLicenseTitle => 'Llicència YOLO';

  @override
  String get yoloLicenseText =>
      'Aquesta aplicació incorpora components d\'Ultralytics YOLOv11.\n\nYOLOv11 © Ultralytics i col·laboradors.\nLlicenciat sota la GNU Affero General Public License v3.0 (AGPL-3.0).\n\nAquesta aplicació es distribueix sense cap garantia.\n\nCodi font disponible a:\nhttps://github.com/GRAP-UdL-AT/FruitMeasureApp';
}
