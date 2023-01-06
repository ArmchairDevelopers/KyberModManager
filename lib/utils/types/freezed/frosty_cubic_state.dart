import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:kyber_mod_manager/utils/types/freezed/frosty_version.dart';
import 'package:kyber_mod_manager/utils/types/freezed/github_asset.dart';


part 'frosty_cubic_state.freezed.dart';

@freezed
class FrostyCubicState with _$FrostyCubicState {
  const factory FrostyCubicState({
    required bool isOutdated,
    FrostyVersion? currentVersion,
    GitHubAsset? latestVersion,
  }) = _FrostyCubicState;
}