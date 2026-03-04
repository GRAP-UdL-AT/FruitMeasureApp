// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get usernameLabel => 'Nombre de usuario o usuaria';

  @override
  String get usernameHint => 'Nombre de usuario o usuaria';

  @override
  String get max20Characters => 'Máximo 20 caracteres';

  @override
  String get disclaimer =>
      'Los valores proporcionados por esta aplicación son estimaciones orientativas y no deben interpretarse como asesoramiento profesional o técnico, ni emplearse como única base para decisiones relevantes. Esta herramienta no sustituye instrumentos de medición certificados ni el criterio de un profesional cualificado.\n\nA pesar de haberse desarrollado con el máximo cuidado, no se garantiza la precisión, exhaustividad o adecuación de los resultados en todas las circunstancias. La interpretación y uso de la información recabada son responsabilidad exclusiva del usuario.\n\nEl equipo desarrollador no asumirá, en ningún caso, ninguna responsabilidad por daños directos o indirectos que puedan derivarse del uso, mal uso o interpretación de los datos generados por la aplicación.\n\nEl uso de esta app implica la aceptación expresa de estos términos.';

  @override
  String get disclaimerMustBeAccepted =>
      'Debes aceptar el aviso legal para continuar';

  @override
  String get disclaimerAcceptance => 'Acepto el aviso legal';

  @override
  String get disclaimerScrollContinue => 'Sigue scrolleando para continuar';

  @override
  String get disclaimerReadingText => 'Sigue leyendo para continuar';

  @override
  String get startProfile => 'Iniciar perfil';

  @override
  String get importProfile => 'Importar perfil';

  @override
  String get createProfile => 'Crear perfil';

  @override
  String get loginTitle => 'Iniciar\nSesión';

  @override
  String get registerTitle => 'Registro';

  @override
  String get userAlreadyRegistered =>
      'Usuario ya registrado con este correo electrónico';

  @override
  String get userNotFound => 'Usuario no encontrado';

  @override
  String get profileMenuItem => 'Perfil de usuario';

  @override
  String get creditsMenuItem => 'Créditos';

  @override
  String get creditsMenuDescription =>
      'Esta aplicación ha sido desarrollada con el objetivo de facilitar la medición del diámetro de frutas mediante la toma de fotografías. Permite realizar diferentes tipos de mediciones de forma rápida y precisa, contribuyendo a mejorar el control de calidad y la toma de decisiones en procesos agrícolas, comerciales o de investigación.';

  @override
  String get creditsDevelopedBy => 'Desarrollado por';

  @override
  String get creditsProjectAcknowledgments =>
      'Agradecimientos al proyecto: [Texto a completar]';

  @override
  String get creditsFundingAcknowledgments =>
      'Agradecimientos a las entidades financiadoras: [Texto a completar]';

  @override
  String get creditsDevelopmentText =>
      'FruitMeasureApp ha sido desarrollado por la Universitat de Lleida (UdL) y por el Institut de Recerca i Tecnologia Agroalimentàries (IRTA) en el marco de la actividad demostrativa \"FruitMeasureApp: Validación y prototipado de una aplicación móvil basada en IA para medir frutos en campo\" (Actividad cofinanciada por la UE a través de la intervención 7201 del Plan estratégico de la PAC 2023-2027).';

  @override
  String creditsWebsiteText(String url) {
    return 'Recursos complementarios vinculados con FruitMeasureApp están disponibles en el sitio web $url.';
  }

  @override
  String get creditsWebsiteUrl => 'https://fruitmeasureapp.udl.cat/';

  @override
  String get logoutMenuItem => 'Cerrar sesión';

  @override
  String get logoutDialogTitle => 'Confirmar';

  @override
  String get logoutDialogMessage =>
      '¿Estás seguro de que deseas cerrar sesión?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get nameLabel => 'Nombre';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get emailRecommended =>
      'El correo electrónico no es obligatorio, pero es recomendable para compartir datos';

  @override
  String get optionsLabel => 'Opciones';

  @override
  String get deletePhotosOption => 'Borrar imágenes del dispositivo';

  @override
  String get editProfile => 'Editar perfil';

  @override
  String get exportProfile => 'Exportar perfil';

  @override
  String get switchProfile => 'Cambiar de usuario';

  @override
  String get deleteProfile => 'Eliminar perfil';

  @override
  String get confirmDeleteProfileTitle => 'Eliminar perfil';

  @override
  String get confirmDeleteProfileMessage =>
      '¿Está seguro de que desea eliminar este usuario? Se perderán todos los datos almacenados.';

  @override
  String get confirm => 'Confirmar';

  @override
  String get confirmChangesTitle => 'Confirmar cambios';

  @override
  String get confirmChangesMessage =>
      '¿Está seguro de que desea confirmar los cambios realizados?';

  @override
  String get saveChanges => 'Guardar cambios';

  @override
  String get actionDone => 'Acción realizada correctamente';

  @override
  String get actionNotDone => 'No se ha podido completar la acción';

  @override
  String get createPlot => 'Crear parcela';

  @override
  String get editPlot => 'Editar parcela';

  @override
  String get deletePlot => 'Eliminar parcela';

  @override
  String get confirmDeleteElementTitle => 'Eliminar elemento';

  @override
  String get confirmDeleteElementMessage =>
      '¿Está seguro de que desea eliminar este elemento permanentemente?';

  @override
  String get mapTypeTooltip => 'Tipo de mapa';

  @override
  String get mapTypeNormal => 'Normal';

  @override
  String get mapTypeSatellite => 'Satélite';

  @override
  String get mapTypeHybrid => 'Híbrido';

  @override
  String get mapTypeTerrain => 'Terreno';

  @override
  String get goToMyLocationTooltip => 'Mi ubicación';

  @override
  String get locationServicesDisabled =>
      'Los servicios de ubicación están deshabilitados.';

  @override
  String get locationPermissionDenied =>
      'Los permisos de ubicación han sido denegados.';

  @override
  String get locationPermissionPermanentlyDenied =>
      'Los permisos de ubicación están permanentemente denegados. Por favor, habilítalos en la configuración de la aplicación.';

  @override
  String get plotNameLabel => 'Nombre de la parcela';

  @override
  String get plotNameHint => 'Nombre de la parcela';

  @override
  String get farmerNameLabel => 'Nombre del agricultor/a';

  @override
  String get farmerNameHint => 'Nombre del agricultor/a';

  @override
  String get plantationDateLabel => 'Fecha de plantación';

  @override
  String get plantationDateHint => 'Fecha de plantación';

  @override
  String get varietyLabel => 'Especie y variedad';

  @override
  String get varietyHint => 'Especie y variedad';

  @override
  String get descriptionLabel => 'Descripción';

  @override
  String get descriptionHint => 'Descripción';

  @override
  String get plotLocationLabel => 'Ubicación de la parcela';

  @override
  String get locationDialogTitle => 'Ubicación (WGS84)';

  @override
  String get tapToEditMap => 'Toca para editar';

  @override
  String get tapToViewMap => 'Toca para ver el mapa';

  @override
  String get createMeasurement => 'Crear medición';

  @override
  String get editMeasurement => 'Editar medición';

  @override
  String get deleteMeasurement => 'Eliminar medición';

  @override
  String get measurementModelLabel => 'Modelo';

  @override
  String get measurementModelHint => 'Modelo';

  @override
  String get measurementObservationsLabel => 'Observaciones';

  @override
  String get measurementObservationsHint => 'Observaciones';

  @override
  String get exitWithoutSave => 'Salir sin guardar';

  @override
  String get exitWithoutSaveQuestion =>
      '¿Está seguro de que desea salir sin guardar?';

  @override
  String get accept => 'Aceptar';

  @override
  String get supportDistance => 'Distancia del soporte de la cámara (mm)';

  @override
  String get users => 'Usuarios';

  @override
  String get plotView => 'Vista de parcela';

  @override
  String get plots => 'Parcelas';

  @override
  String get searchPlots => 'Buscar parcela...';

  @override
  String get withoutPlots => 'Sin parcelas';

  @override
  String get noPlotsRegistered => 'No hay parcelas registradas';

  @override
  String get copy => 'Copia';

  @override
  String get compareCurves => 'Comparar curvas';

  @override
  String get importPlots => 'Importar parcelas';

  @override
  String get duplicatePlots => 'Duplicar parcela';

  @override
  String get downloadKML => 'Descargar como KML';

  @override
  String get exportPlots => 'Exportar parcelas';

  @override
  String get dataMeasurement => 'Datos de medición';

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
  String get camera => 'Cámara';

  @override
  String get gallery => 'Galería';

  @override
  String get takeNewShot => 'Tomar nueva captura';

  @override
  String get editShot => 'Editar captura';

  @override
  String get detectionFruit => 'Fruto';

  @override
  String get statistics => 'Estadísticas';

  @override
  String get caliberSeasonText => 'Calibre - Época (aclareo/maduración)';

  @override
  String get withoutData => 'Sin datos';

  @override
  String get caliberMin => 'Calibre mínimo';

  @override
  String get caliberAvg => 'Calibre medio';

  @override
  String get caliberMax => 'Calibre máximo';

  @override
  String get numberOfImages => 'Nº de imágenes';

  @override
  String get avgFruitsPerImage => 'Frutos/imagen';

  @override
  String get shareChartImage => 'Compartir como imagen';

  @override
  String get shareChartCsv => 'Compartir como CSV';

  @override
  String get modelUpdateTo => 'Modelo actualizado a';

  @override
  String get noImageCaptured => 'Sin capturas';

  @override
  String get noCaptureForMeasurement =>
      'No se han encontrado capturas para esta medición';

  @override
  String get makeCapture => 'Realizar captura';

  @override
  String get selectImageFromGallery => 'Seleccionar imagen desde la galería';

  @override
  String get loadingProcessingImage => 'Procesando imagen...';

  @override
  String get selectingImages => 'Seleccionando imágenes...';

  @override
  String get comparative => 'Comparativa';

  @override
  String get growthCurve => 'Curva de crecimiento';

  @override
  String get compareGrowthCurves => 'Comparar curvas de crecimiento';

  @override
  String get currentGrowthRate => 'Tasa de crecimiento actual';

  @override
  String get millimetersDay => 'mm/día';

  @override
  String get temporalEvolutionPlot =>
      'Evolución temporal de la parcela (calibre)';

  @override
  String get tapPointsForDetails => 'Toca los puntos para ver detalles';

  @override
  String get calendar => 'Calendario';

  @override
  String get withoutObservations => 'Sin observaciones';

  @override
  String get measurementLabel => 'Medición';

  @override
  String get selectModelLabel => 'Selecciona un modelo';

  @override
  String get creationDateLabel => 'Fecha de creación';

  @override
  String get measurementsLabel => 'Mediciones';

  @override
  String get searchMeasurement => 'Buscar medición...';

  @override
  String get withoutMeasurements => 'Sin mediciones';

  @override
  String get noMeasurementsRegistered => 'No hay mediciones registradas';

  @override
  String get exportMeasurements => 'Exportar mediciones';

  @override
  String get importMeasurements => 'Importar mediciones';

  @override
  String get calendarView => 'Vista de calendario';

  @override
  String get language => 'Idioma';

  @override
  String get languageEs => 'Español';

  @override
  String get languageEn => 'Inglés';

  @override
  String get languageCa => 'Catalán';

  @override
  String get binWidthGrouping => 'Agrupación';

  @override
  String get yAxisMode => 'Eje Y:';

  @override
  String binWidthWarningFullscreen(
    int binWidth,
    int numGroups,
    int recommended,
  ) {
    return '💡 La agrupación actual de ${binWidth}mm genera $numGroups grupos. Para una mejor visualización se recomienda usar ${recommended}mm.';
  }

  @override
  String binWidthWarningExport(int binWidth, int numGroups, int recommended) {
    return '⚠️ La agrupación de ${binWidth}mm genera $numGroups grupos. Para compartir/exportar se recomienda ${recommended}mm.';
  }

  @override
  String yAxisWarningFullscreen(int step) {
    return 'ℹ️ Eje Y simplificado en modo pantalla completa para mejorar la lectura (saltos de $step).';
  }

  @override
  String yAxisWarningNormal(int step) {
    return 'ℹ️ Eje Y autoajustado para mantener la legibilidad (saltos de $step).';
  }

  @override
  String get numberOfFruits => 'Nº de frutos';

  @override
  String get percentageOfFruits => '% de frutos';

  @override
  String get fruit => 'fruta';

  @override
  String get fruits => 'frutas';

  @override
  String get tapToSeeDetails => 'Toca para ver detalles';

  @override
  String get exportFormat => 'Formato de exportación';

  @override
  String get exportFormatJson => 'JSON (.fma)';

  @override
  String get exportFormatJsonDescription => 'Formato para importar';

  @override
  String get exportFormatCsv => 'CSV';

  @override
  String get exportFormatCsvDescription => 'Formato de hoja de cálculo';

  @override
  String get exportFormatTxt => 'TXT';

  @override
  String get exportFormatTxtDescription => 'Informe legible';

  @override
  String get errorNoImageSelected => '¡ERROR! No se seleccionó ninguna imagen';

  @override
  String get errorInvalidImageData => '¡ERROR! Datos de imagen inválidos';

  @override
  String get errorNoFruitsDetected => 'No se detectaron frutas';

  @override
  String get errorSupportNotFound => 'No se encontró el soporte de referencia';

  @override
  String get errorNoValidDetections => 'No se encontraron detecciones válidas';

  @override
  String get errorNoValidPhotos => 'No se procesaron fotos válidas';

  @override
  String get errorMissingParams => 'Faltan parámetros requeridos';

  @override
  String get errorGallerySavePermissionDenied =>
      'No se pudo guardar en galería: Permisos denegados';

  @override
  String get errorGallerySaveFailed => 'No se pudo guardar en galería';

  @override
  String get photoProcessed => 'foto procesada correctamente';

  @override
  String get photosProcessed => 'fotos procesadas correctamente';

  @override
  String get processingImages => 'Procesando';

  @override
  String get ofTotal => 'de';

  @override
  String get noModel => 'Sin modelo';

  @override
  String get millimetersUnit => 'mm';

  @override
  String get errorImportWrongFileMeasurement =>
      'Archivo incorrecto: Este es un archivo de MEDICIONES (.measurement.fma). Para importar parcelas, usa un archivo .plot.fma';

  @override
  String get errorImportWrongFilePlot =>
      'Archivo incorrecto: Este es un archivo de PARCELAS (.plot.fma). Para importar mediciones, usa un archivo .measurement.fma';

  @override
  String get errorImportWrongFileGeneric =>
      'Formato de archivo incorrecto. Debe ser un archivo .plot.fma o .measurement.fma';

  @override
  String get errorImportWrongFileGenericMeasurements =>
      'Formato de archivo incorrecto. Para importar mediciones, el archivo debe tener la extensión .measurement.fma';

  @override
  String get errorImportWrongFileGenericPlots =>
      'Formato de archivo incorrecto. Para importar parcelas, el archivo debe tener la extensión .plot.fma';

  @override
  String get errorImportEmptyFile => 'El archivo está vacío';

  @override
  String get errorImportNoPlots => 'No hay parcelas en el archivo';

  @override
  String get errorImportNoMeasurements => 'No hay mediciones en el archivo';

  @override
  String get errorImportParseError =>
      'Error al leer el archivo. Verifica que el formato sea correcto';

  @override
  String get errorImportParseErrorMeasurements =>
      'Error al leer el archivo. El formato debe ser un archivo .measurement.fma válido (JSON). Verifica que el archivo no esté corrupto o modificado';

  @override
  String get errorImportParseErrorPlots =>
      'Error al leer el archivo. El formato debe ser un archivo .plot.fma válido (JSON). Verifica que el archivo no esté corrupto o modificado';

  @override
  String get errorImportDialogTitle => 'Error de importación';

  @override
  String get allPlotsAlreadyImported =>
      'Todas las parcelas ya fueron importadas';

  @override
  String get allMeasurementsAlreadyImported =>
      'Todas las mediciones ya fueron importadas';

  @override
  String get importNoProcessedPlots => 'No se procesó ninguna parcela';

  @override
  String importSummaryOnlyNewPlots(Object measurements, num newPlots) {
    String _temp0 = intl.Intl.pluralLogic(
      newPlots,
      locale: localeName,
      other: 'Importadas',
      one: 'Importada',
    );
    String _temp1 = intl.Intl.pluralLogic(
      newPlots,
      locale: localeName,
      other: 'parcelas',
      one: 'parcela',
    );
    return '$_temp0: $newPlots $_temp1\nMediciones: $measurements';
  }

  @override
  String importSummaryOnlyExistingNoChanges(num existingPlots) {
    String _temp0 = intl.Intl.pluralLogic(
      existingPlots,
      locale: localeName,
      other: 'Reimportadas',
      one: 'Reimportada',
    );
    String _temp1 = intl.Intl.pluralLogic(
      existingPlots,
      locale: localeName,
      other: 'parcelas',
      one: 'parcela',
    );
    return '$_temp0: $existingPlots $_temp1\nSin cambios en mediciones';
  }

  @override
  String importSummaryOnlyExistingWithRestored(
    num existingPlots,
    Object restored,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      existingPlots,
      locale: localeName,
      other: 'Reimportadas',
      one: 'Reimportada',
    );
    String _temp1 = intl.Intl.pluralLogic(
      existingPlots,
      locale: localeName,
      other: 'parcelas',
      one: 'parcela',
    );
    return '$_temp0: $existingPlots $_temp1\nRestauradas: $restored mediciones';
  }

  @override
  String importSummaryOnlyExistingWithRestoredAndSkipped(
    num existingPlots,
    Object restored,
    Object skipped,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      existingPlots,
      locale: localeName,
      other: 'Reimportadas',
      one: 'Reimportada',
    );
    String _temp1 = intl.Intl.pluralLogic(
      existingPlots,
      locale: localeName,
      other: 'parcelas',
      one: 'parcela',
    );
    return '$_temp0: $existingPlots $_temp1\nRestauradas: $restored | Omitidas: $skipped';
  }

  @override
  String importSummaryMixedNoRestored(
    num existingPlots,
    Object newMeasurements,
    num newPlots,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      newPlots,
      locale: localeName,
      other: 'Importadas',
      one: 'Importada',
    );
    String _temp1 = intl.Intl.pluralLogic(
      newPlots,
      locale: localeName,
      other: 'nuevas',
      one: 'nueva',
    );
    String _temp2 = intl.Intl.pluralLogic(
      existingPlots,
      locale: localeName,
      other: 'Reimportadas',
      one: 'Reimportada',
    );
    String _temp3 = intl.Intl.pluralLogic(
      existingPlots,
      locale: localeName,
      other: 'existentes',
      one: 'existente',
    );
    return '$_temp0: $newPlots $_temp1 ($newMeasurements med.)\n$_temp2: $existingPlots $_temp3';
  }

  @override
  String importSummaryMixedWithRestored(
    num existingPlots,
    Object newMeasurements,
    num newPlots,
    Object restored,
    Object skipped,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      newPlots,
      locale: localeName,
      other: 'Importadas',
      one: 'Importada',
    );
    String _temp1 = intl.Intl.pluralLogic(
      newPlots,
      locale: localeName,
      other: 'nuevas',
      one: 'nueva',
    );
    String _temp2 = intl.Intl.pluralLogic(
      existingPlots,
      locale: localeName,
      other: 'Reimportadas',
      one: 'Reimportada',
    );
    return '$_temp0: $newPlots $_temp1 ($newMeasurements med.)\n$_temp2: $existingPlots | Restauradas: $restored | Omitidas: $skipped';
  }

  @override
  String importMeasurementsOnlyNew(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'mediciones',
      one: 'medición',
    );
    return 'Importadas: $count $_temp0';
  }

  @override
  String importMeasurementsOnlyUpdated(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'mediciones',
      one: 'medición',
    );
    return 'Actualizadas: $count $_temp0';
  }

  @override
  String importMeasurementsMixed(Object imported, Object updated) {
    return 'Importadas: $imported\nActualizadas: $updated';
  }

  @override
  String get noMeasurementsForThisPlot =>
      'No se encontraron mediciones para esta parcela';

  @override
  String get viewAllPlotsOnMap => 'Ver todas en mapa';

  @override
  String get noPlotsWithLocation => 'No hay parcelas con ubicación';

  @override
  String histogramWarning1mmTooMany(Object count) {
    return 'Demasiados grupos ($count). Usa agrupación de 3mm, 5mm o 10mm.';
  }

  @override
  String histogramWarning3mmTooMany(Object count) {
    return 'Demasiados grupos ($count) para 3mm. Usa 5mm o 10mm.';
  }

  @override
  String histogramWarning5mmTooMany(Object count) {
    return 'Demasiados grupos ($count) para 5mm. Usa 10mm.';
  }

  @override
  String histogramInfo10mmMaxReached(Object count) {
    return 'Muchos grupos ($count). Ya usas la agrupación máxima (10mm).';
  }

  @override
  String get deleteFromGalleryLabel => 'Eliminar de la galería';

  @override
  String get deleteFromGalleryDescription =>
      'Esto eliminará permanentemente las imágenes seleccionadas de tu dispositivo.';

  @override
  String get imageNotAvailable => 'Imagen no disponible';

  @override
  String get imageNotAvailableDescription =>
      'La imagen ya no está disponible en este dispositivo. Es posible que haya sido eliminada de la galería o haya sido procesada desde otro dispositivo.';

  @override
  String get recoveringImageFromGallery =>
      'Intentando recuperar imagen desde la galería...';

  @override
  String get invertedAxesMessage =>
      'Ejes invertidos para facilitar su visualización';

  @override
  String get exportCalendar => 'Exportar a Google Calendar';

  @override
  String get exportCalendarSuccess => 'Calendario exportado correctamente';

  @override
  String get exportCalendarError => 'Error al exportar el calendario';

  @override
  String get exportCalendarNoMeasurements => 'No hay mediciones para exportar';

  @override
  String get exportToGoogleCalendar => 'Exportar a Google Calendar';

  @override
  String get shareWithOtherApps => 'Compartir con otras aplicaciones';

  @override
  String get appTitle => 'Fruit Measure App';

  @override
  String get errorUnknown => 'Error desconocido';

  @override
  String get exportMeasurementsCsvHeader =>
      'ID de Medición,Nombre de Medición,Modelo,Fecha de Creación de Medición,ID de Foto,Fecha de Creación de Foto,Fecha de Captura de Foto,Latitud,Longitud,ID de Detección,Calibre (mm),Confianza,Clase';

  @override
  String get exportReportTitle => 'INFORME DE EXPORTACIÓN DE MEDICIONES';

  @override
  String get exportReportSeparator =>
      '========================================';

  @override
  String get exportDateLabel => 'Fecha de exportación:';

  @override
  String get exportTotalMeasurementsLabel => 'Total de mediciones:';

  @override
  String get exportMeasurementLabel => 'MEDICIÓN:';

  @override
  String get exportUnnamedLabel => 'Sin nombre';

  @override
  String get exportIdLabel => '  ID:';

  @override
  String get exportModelLabel => '  Modelo:';

  @override
  String get exportNotAvailableLabel => 'N/D';

  @override
  String get exportCreationDateLabel => '  Fecha de creación:';

  @override
  String get exportObservationsLabel => '  Observaciones:';

  @override
  String get exportNoneLabel => 'Ninguna';

  @override
  String get exportTotalPhotosLabel => '  Total de fotos:';

  @override
  String get exportPhotoLabel => '  FOTO';

  @override
  String get exportCaptureDataLabel => '    Fecha de captura:';

  @override
  String get exportLocationLabel => '    Ubicación:';

  @override
  String get exportDetectionsLabel => '    Detecciones:';

  @override
  String get exportDetectionLabel => '      DETECCIÓN';

  @override
  String get exportCaliberLabel => '        Calibre:';

  @override
  String get exportConfidenceLabel => '        Confianza:';

  @override
  String get exportClassLabel => '        Clase:';

  @override
  String get exportPlotsCsvHeader =>
      'ID de Parcela,Nombre de Parcela,Variedad,Agricultor,ID de Medición,Nombre de Medición,Modelo,Fecha de Creación de Medición,ID de Foto,Fecha de Creación de Foto,Fecha de Captura de Foto,Latitud,Longitud,ID de Detección,Calibre (mm),Confianza,Clase';

  @override
  String get exportPlotsReportTitle => 'INFORME DE EXPORTACIÓN DE PARCELAS';

  @override
  String get exportTotalPlotsLabel => 'Total de parcelas:';

  @override
  String get exportPlotLabel => 'PARCELA:';

  @override
  String get exportVarietyLabel => '  Variedad:';

  @override
  String get exportFarmerLabel => '  Agricultor:';

  @override
  String get calendarEventMeasurementPrefix => 'Medición -';

  @override
  String get calendarEventObservations => 'Observaciones:';

  @override
  String get calendarEventModel => 'Modelo:';

  @override
  String get calendarEventPlot => 'Parcela:';

  @override
  String get calendarEventVariety => 'Variedad:';

  @override
  String get errorFileWriteFailed => 'Error al escribir archivo';

  @override
  String get errorFileReadFailed => 'Error al leer archivo';

  @override
  String get errorExportFailed => 'Error al exportar';

  @override
  String get errorImportUserFailed => 'Error al importar usuario';

  @override
  String get errorDeletePhotoFailed => 'Error al eliminar foto';

  @override
  String get errorYoloPredictionFailed => 'Error en detección de frutas';

  @override
  String get errorUnexpected => 'Error inesperado';

  @override
  String get tooltipViewFullscreen => 'Ver en grande';

  @override
  String get tooltipScrollMode => 'Modo con scroll';

  @override
  String get tooltipFullView => 'Vista completa';

  @override
  String get tooltipViewPreviousValues => 'Ver valores anteriores';

  @override
  String get tooltipViewNextValues => 'Ver valores siguientes';

  @override
  String get tooltipRotateScreen => 'Rotar pantalla';

  @override
  String get modelNameFruto => 'Fruto';

  @override
  String get modelNameCorimbo => 'Corimbo';

  @override
  String get modelNameCaixa => 'Caja';

  @override
  String get noCalibersDetected => 'No se detectaron calibres';

  @override
  String get unknown => 'Desconocido';

  @override
  String get confidenceThresholdLabel => 'Nivel de confianza';

  @override
  String get confidenceThresholdDescription => 'Umbral mínimo para detecciones';

  @override
  String get yoloLicenseTitle => 'Licencia YOLO';

  @override
  String get yoloLicenseText =>
      'Esta aplicación incorpora componentes de Ultralytics YOLOv11.\n\nYOLOv11 © Ultralytics y colaboradores.\nLicenciado bajo la GNU Affero General Public License v3.0 (AGPL-3.0).\n\nEsta aplicación se distribuye sin ninguna garantía.\n\nCódigo fuente disponible en:\nhttps://github.com/GRAP-UdL-AT/FruitMeasureApp';
}
