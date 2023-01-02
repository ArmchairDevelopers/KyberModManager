// To parse this JSON data, do
//
//     final discordEvent = discordEventFromJson(jsonString);

import 'package:freezed_annotation/freezed_annotation.dart';
import 'dart:convert';

part 'discord_event.freezed.dart';
part 'discord_event.g.dart';

@freezed
class DiscordEvent with _$DiscordEvent {
  const factory DiscordEvent({
    String? id,
    @JsonKey(name: 'guild_id')
    String? guildId,
    @JsonKey(name: 'channel_id')
    dynamic? channelId,
    @JsonKey(name: 'creator_id')
    String? creatorId,
    String? name,
    String? description,
    dynamic? image,
    @JsonKey(name: 'scheduled_start_time')
    DateTime? scheduledStartTime,
    @JsonKey(name: 'scheduled_end_time')
    DateTime? scheduledEndTime,
    @JsonKey(name: 'privacy_level')
    int? privacyLevel,
    int? status,
    @JsonKey(name: 'entity_type')
    int? entityType,
    @JsonKey(name: 'entity_id')
    dynamic? entityId,
    @JsonKey(name: 'pentity_metadata')
    EntityMetadata? entityMetadata,
    @JsonKey(name: 'sku_ids')
    List<dynamic>? skuIds,
    Creator? creator,
    @JsonKey(name: 'user_count')
    int? userCount,
  }) = _DiscordEvent;

  factory DiscordEvent.fromJson(Map<String, dynamic> json) => _$DiscordEventFromJson(json);
}

@freezed
class Creator with _$Creator {
  const factory Creator({
    String? id,
    String? username,
    String? avatar,
    @JsonKey(name: 'avatar_decoration')
    dynamic? avatarDecoration,
    String? discriminator,
    @JsonKey(name: 'public_flags')
    int? publicFlags,
  }) = _Creator;

  factory Creator.fromJson(Map<String, dynamic> json) => _$CreatorFromJson(json);
}

@freezed
class EntityMetadata with _$EntityMetadata {
  const factory EntityMetadata({
    String? location,
  }) = _EntityMetadata;

  factory EntityMetadata.fromJson(Map<String, dynamic> json) => _$EntityMetadataFromJson(json);
}
