import 'package:fruit_measure_app/l10n/app_localizations.dart';
import 'package:hive_ce/hive.dart';

part 'model_enum.g.dart';

@HiveType(typeId: 67)
enum Model {
  @HiveField(0)
  fruto,

  @HiveField(1)
  corimbo,

  @HiveField(2)
  caixa;

  String getModelName([AppLocalizations? loc]) {
    switch (this) {
      case Model.fruto:
        return loc?.modelNameFruto ?? 'Fruto';
      case Model.corimbo:
        return loc?.modelNameCorimbo ?? 'Corimbo';
      case Model.caixa:
        return loc?.modelNameCaixa ?? 'Caixa';
    }
  }
}
