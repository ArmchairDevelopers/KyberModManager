import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:kyber_mod_manager/widgets/unordered_list.dart';

class FrostySelector extends StatelessWidget {
  const FrostySelector({Key? key, required this.supportedVersions}) : super(key: key);

  final String prefix = 'walk_through.select_frosty_path';
  final List<String> supportedVersions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          translate('$prefix.description'),
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 25),
        Text(translate('$prefix.notice'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(
          translate('$prefix.notice_text'),
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 25),
        Text(translate('$prefix.important'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(
          translate('$prefix.important_text'),
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 15),
        Text(
          translate('$prefix.supported_versions'),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        UnorderedList(
          supportedVersions,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
        )
      ],
    );
  }
}
