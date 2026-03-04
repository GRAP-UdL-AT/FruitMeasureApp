# FruitMeasureApp

FruitMeasureApp is a mobile application developed by the Universitat de Lleida (UdL) and the Institut de Recerca i Tecnologia Agroalimentàries (IRTA) for measuring fruit diameter using AI-based image processing.

## Features

- Measure fruit diameter using your device's camera
- Multiple measurement models (Fruit, Cluster, Box)
- Georeferenced plot management
- Statistics and growth curve visualization
- Data export in multiple formats (JSON, CSV, TXT, KML)
- Multi-language support (Catalan, Spanish, English)

## Technology Stack

- **Framework**: Flutter
- **AI/ML**: Ultralytics YOLOv11 for object detection
- **Database**: Hive (local NoSQL)
- **Maps**: Google Maps

## Requirements

- Flutter SDK ^3.7.2
- iOS 16.0+ or Android 5.0+

## Getting Started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter run
```

## License

This project is licensed under the GNU Affero General Public License v3.0 (AGPL-3.0).

### Third-Party Licenses

This application incorporates components of **Ultralytics YOLOv11**, which is licensed under the GNU Affero General Public License v3.0 (AGPL-3.0).

- YOLOv11 © Ultralytics and contributors
- https://github.com/ultralytics/ultralytics

## Credits

Developed by:
- **Universitat de Lleida (UdL)**
- **Institut de Recerca i Tecnologia Agroalimentàries (IRTA)**

FruitMeasureApp has been developed within the framework of the demonstration activity "FruitMeasureApp: Validation and prototyping of an AI-based mobile application for measuring fruits in the field" (Activity co-financed by the EU through intervention 7201 of the CAP Strategic Plan 2023-2027).

## Resources

- Website: https://fruitmeasureapp.udl.cat/
- Repository: https://github.com/GRAP-UdL-AT/FruitMeasureApp
