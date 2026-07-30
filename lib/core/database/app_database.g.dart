// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FavoriteTracksTable extends FavoriteTracks
    with TableInfo<$FavoriteTracksTable, FavoriteTrack> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FavoriteTracksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trackSnapshotMeta = const VerificationMeta(
    'trackSnapshot',
  );
  @override
  late final GeneratedColumn<String> trackSnapshot = GeneratedColumn<String>(
    'track_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [trackId, trackSnapshot, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'favorite_tracks';
  @override
  VerificationContext validateIntegrity(
    Insertable<FavoriteTrack> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('track_snapshot')) {
      context.handle(
        _trackSnapshotMeta,
        trackSnapshot.isAcceptableOrUnknown(
          data['track_snapshot']!,
          _trackSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_trackSnapshotMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {trackId};
  @override
  FavoriteTrack map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FavoriteTrack(
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      trackSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_snapshot'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $FavoriteTracksTable createAlias(String alias) {
    return $FavoriteTracksTable(attachedDatabase, alias);
  }
}

class FavoriteTrack extends DataClass implements Insertable<FavoriteTrack> {
  final String trackId;
  final String trackSnapshot;
  final DateTime createdAt;
  const FavoriteTrack({
    required this.trackId,
    required this.trackSnapshot,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track_id'] = Variable<String>(trackId);
    map['track_snapshot'] = Variable<String>(trackSnapshot);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  FavoriteTracksCompanion toCompanion(bool nullToAbsent) {
    return FavoriteTracksCompanion(
      trackId: Value(trackId),
      trackSnapshot: Value(trackSnapshot),
      createdAt: Value(createdAt),
    );
  }

  factory FavoriteTrack.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FavoriteTrack(
      trackId: serializer.fromJson<String>(json['trackId']),
      trackSnapshot: serializer.fromJson<String>(json['trackSnapshot']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trackId': serializer.toJson<String>(trackId),
      'trackSnapshot': serializer.toJson<String>(trackSnapshot),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  FavoriteTrack copyWith({
    String? trackId,
    String? trackSnapshot,
    DateTime? createdAt,
  }) => FavoriteTrack(
    trackId: trackId ?? this.trackId,
    trackSnapshot: trackSnapshot ?? this.trackSnapshot,
    createdAt: createdAt ?? this.createdAt,
  );
  FavoriteTrack copyWithCompanion(FavoriteTracksCompanion data) {
    return FavoriteTrack(
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      trackSnapshot: data.trackSnapshot.present
          ? data.trackSnapshot.value
          : this.trackSnapshot,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteTrack(')
          ..write('trackId: $trackId, ')
          ..write('trackSnapshot: $trackSnapshot, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(trackId, trackSnapshot, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FavoriteTrack &&
          other.trackId == this.trackId &&
          other.trackSnapshot == this.trackSnapshot &&
          other.createdAt == this.createdAt);
}

class FavoriteTracksCompanion extends UpdateCompanion<FavoriteTrack> {
  final Value<String> trackId;
  final Value<String> trackSnapshot;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const FavoriteTracksCompanion({
    this.trackId = const Value.absent(),
    this.trackSnapshot = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FavoriteTracksCompanion.insert({
    required String trackId,
    required String trackSnapshot,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : trackId = Value(trackId),
       trackSnapshot = Value(trackSnapshot),
       createdAt = Value(createdAt);
  static Insertable<FavoriteTrack> custom({
    Expression<String>? trackId,
    Expression<String>? trackSnapshot,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (trackSnapshot != null) 'track_snapshot': trackSnapshot,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FavoriteTracksCompanion copyWith({
    Value<String>? trackId,
    Value<String>? trackSnapshot,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return FavoriteTracksCompanion(
      trackId: trackId ?? this.trackId,
      trackSnapshot: trackSnapshot ?? this.trackSnapshot,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (trackSnapshot.present) {
      map['track_snapshot'] = Variable<String>(trackSnapshot.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FavoriteTracksCompanion(')
          ..write('trackId: $trackId, ')
          ..write('trackSnapshot: $trackSnapshot, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserPlaylistsTable extends UserPlaylists
    with TableInfo<$UserPlaylistsTable, UserPlaylist> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPlaylistsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _coverAssetMeta = const VerificationMeta(
    'coverAsset',
  );
  @override
  late final GeneratedColumn<String> coverAsset = GeneratedColumn<String>(
    'cover_asset',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    coverAsset,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_playlists';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserPlaylist> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('cover_asset')) {
      context.handle(
        _coverAssetMeta,
        coverAsset.isAcceptableOrUnknown(data['cover_asset']!, _coverAssetMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserPlaylist map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPlaylist(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      coverAsset: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_asset'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $UserPlaylistsTable createAlias(String alias) {
    return $UserPlaylistsTable(attachedDatabase, alias);
  }
}

class UserPlaylist extends DataClass implements Insertable<UserPlaylist> {
  final String id;
  final String name;
  final String description;
  final String? coverAsset;
  final DateTime createdAt;
  final DateTime updatedAt;
  const UserPlaylist({
    required this.id,
    required this.name,
    required this.description,
    this.coverAsset,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || coverAsset != null) {
      map['cover_asset'] = Variable<String>(coverAsset);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  UserPlaylistsCompanion toCompanion(bool nullToAbsent) {
    return UserPlaylistsCompanion(
      id: Value(id),
      name: Value(name),
      description: Value(description),
      coverAsset: coverAsset == null && nullToAbsent
          ? const Value.absent()
          : Value(coverAsset),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserPlaylist.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPlaylist(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String>(json['description']),
      coverAsset: serializer.fromJson<String?>(json['coverAsset']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String>(description),
      'coverAsset': serializer.toJson<String?>(coverAsset),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  UserPlaylist copyWith({
    String? id,
    String? name,
    String? description,
    Value<String?> coverAsset = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => UserPlaylist(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    coverAsset: coverAsset.present ? coverAsset.value : this.coverAsset,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  UserPlaylist copyWithCompanion(UserPlaylistsCompanion data) {
    return UserPlaylist(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      coverAsset: data.coverAsset.present
          ? data.coverAsset.value
          : this.coverAsset,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPlaylist(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('coverAsset: $coverAsset, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, description, coverAsset, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPlaylist &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.coverAsset == this.coverAsset &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserPlaylistsCompanion extends UpdateCompanion<UserPlaylist> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> description;
  final Value<String?> coverAsset;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const UserPlaylistsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.coverAsset = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserPlaylistsCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.coverAsset = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<UserPlaylist> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? coverAsset,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (coverAsset != null) 'cover_asset': coverAsset,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserPlaylistsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? description,
    Value<String?>? coverAsset,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return UserPlaylistsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverAsset: coverAsset ?? this.coverAsset,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (coverAsset.present) {
      map['cover_asset'] = Variable<String>(coverAsset.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPlaylistsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('coverAsset: $coverAsset, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserPlaylistTracksTable extends UserPlaylistTracks
    with TableInfo<$UserPlaylistTracksTable, UserPlaylistTrack> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserPlaylistTracksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<String> playlistId = GeneratedColumn<String>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user_playlists (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trackSnapshotMeta = const VerificationMeta(
    'trackSnapshot',
  );
  @override
  late final GeneratedColumn<String> trackSnapshot = GeneratedColumn<String>(
    'track_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    playlistId,
    trackId,
    trackSnapshot,
    sortOrder,
    addedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_playlist_tracks';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserPlaylistTrack> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('track_snapshot')) {
      context.handle(
        _trackSnapshotMeta,
        trackSnapshot.isAcceptableOrUnknown(
          data['track_snapshot']!,
          _trackSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_trackSnapshotMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {playlistId, trackId};
  @override
  UserPlaylistTrack map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserPlaylistTrack(
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playlist_id'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      trackSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_snapshot'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $UserPlaylistTracksTable createAlias(String alias) {
    return $UserPlaylistTracksTable(attachedDatabase, alias);
  }
}

class UserPlaylistTrack extends DataClass
    implements Insertable<UserPlaylistTrack> {
  final String playlistId;
  final String trackId;
  final String trackSnapshot;
  final int sortOrder;
  final DateTime addedAt;
  const UserPlaylistTrack({
    required this.playlistId,
    required this.trackId,
    required this.trackSnapshot,
    required this.sortOrder,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['playlist_id'] = Variable<String>(playlistId);
    map['track_id'] = Variable<String>(trackId);
    map['track_snapshot'] = Variable<String>(trackSnapshot);
    map['sort_order'] = Variable<int>(sortOrder);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  UserPlaylistTracksCompanion toCompanion(bool nullToAbsent) {
    return UserPlaylistTracksCompanion(
      playlistId: Value(playlistId),
      trackId: Value(trackId),
      trackSnapshot: Value(trackSnapshot),
      sortOrder: Value(sortOrder),
      addedAt: Value(addedAt),
    );
  }

  factory UserPlaylistTrack.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserPlaylistTrack(
      playlistId: serializer.fromJson<String>(json['playlistId']),
      trackId: serializer.fromJson<String>(json['trackId']),
      trackSnapshot: serializer.fromJson<String>(json['trackSnapshot']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'playlistId': serializer.toJson<String>(playlistId),
      'trackId': serializer.toJson<String>(trackId),
      'trackSnapshot': serializer.toJson<String>(trackSnapshot),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  UserPlaylistTrack copyWith({
    String? playlistId,
    String? trackId,
    String? trackSnapshot,
    int? sortOrder,
    DateTime? addedAt,
  }) => UserPlaylistTrack(
    playlistId: playlistId ?? this.playlistId,
    trackId: trackId ?? this.trackId,
    trackSnapshot: trackSnapshot ?? this.trackSnapshot,
    sortOrder: sortOrder ?? this.sortOrder,
    addedAt: addedAt ?? this.addedAt,
  );
  UserPlaylistTrack copyWithCompanion(UserPlaylistTracksCompanion data) {
    return UserPlaylistTrack(
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      trackSnapshot: data.trackSnapshot.present
          ? data.trackSnapshot.value
          : this.trackSnapshot,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserPlaylistTrack(')
          ..write('playlistId: $playlistId, ')
          ..write('trackId: $trackId, ')
          ..write('trackSnapshot: $trackSnapshot, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(playlistId, trackId, trackSnapshot, sortOrder, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserPlaylistTrack &&
          other.playlistId == this.playlistId &&
          other.trackId == this.trackId &&
          other.trackSnapshot == this.trackSnapshot &&
          other.sortOrder == this.sortOrder &&
          other.addedAt == this.addedAt);
}

class UserPlaylistTracksCompanion extends UpdateCompanion<UserPlaylistTrack> {
  final Value<String> playlistId;
  final Value<String> trackId;
  final Value<String> trackSnapshot;
  final Value<int> sortOrder;
  final Value<DateTime> addedAt;
  final Value<int> rowid;
  const UserPlaylistTracksCompanion({
    this.playlistId = const Value.absent(),
    this.trackId = const Value.absent(),
    this.trackSnapshot = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserPlaylistTracksCompanion.insert({
    required String playlistId,
    required String trackId,
    required String trackSnapshot,
    required int sortOrder,
    required DateTime addedAt,
    this.rowid = const Value.absent(),
  }) : playlistId = Value(playlistId),
       trackId = Value(trackId),
       trackSnapshot = Value(trackSnapshot),
       sortOrder = Value(sortOrder),
       addedAt = Value(addedAt);
  static Insertable<UserPlaylistTrack> custom({
    Expression<String>? playlistId,
    Expression<String>? trackId,
    Expression<String>? trackSnapshot,
    Expression<int>? sortOrder,
    Expression<DateTime>? addedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (playlistId != null) 'playlist_id': playlistId,
      if (trackId != null) 'track_id': trackId,
      if (trackSnapshot != null) 'track_snapshot': trackSnapshot,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (addedAt != null) 'added_at': addedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserPlaylistTracksCompanion copyWith({
    Value<String>? playlistId,
    Value<String>? trackId,
    Value<String>? trackSnapshot,
    Value<int>? sortOrder,
    Value<DateTime>? addedAt,
    Value<int>? rowid,
  }) {
    return UserPlaylistTracksCompanion(
      playlistId: playlistId ?? this.playlistId,
      trackId: trackId ?? this.trackId,
      trackSnapshot: trackSnapshot ?? this.trackSnapshot,
      sortOrder: sortOrder ?? this.sortOrder,
      addedAt: addedAt ?? this.addedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (playlistId.present) {
      map['playlist_id'] = Variable<String>(playlistId.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (trackSnapshot.present) {
      map['track_snapshot'] = Variable<String>(trackSnapshot.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserPlaylistTracksCompanion(')
          ..write('playlistId: $playlistId, ')
          ..write('trackId: $trackId, ')
          ..write('trackSnapshot: $trackSnapshot, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('addedAt: $addedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlaybackSessionsTable extends PlaybackSessions
    with TableInfo<$PlaybackSessionsTable, PlaybackSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaybackSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _queueSnapshotMeta = const VerificationMeta(
    'queueSnapshot',
  );
  @override
  late final GeneratedColumn<String> queueSnapshot = GeneratedColumn<String>(
    'queue_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currentIndexMeta = const VerificationMeta(
    'currentIndex',
  );
  @override
  late final GeneratedColumn<int> currentIndex = GeneratedColumn<int>(
    'current_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMsMeta = const VerificationMeta(
    'positionMs',
  );
  @override
  late final GeneratedColumn<int> positionMs = GeneratedColumn<int>(
    'position_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playbackModeMeta = const VerificationMeta(
    'playbackMode',
  );
  @override
  late final GeneratedColumn<String> playbackMode = GeneratedColumn<String>(
    'playback_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    queueSnapshot,
    currentIndex,
    positionMs,
    playbackMode,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playback_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaybackSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('queue_snapshot')) {
      context.handle(
        _queueSnapshotMeta,
        queueSnapshot.isAcceptableOrUnknown(
          data['queue_snapshot']!,
          _queueSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_queueSnapshotMeta);
    }
    if (data.containsKey('current_index')) {
      context.handle(
        _currentIndexMeta,
        currentIndex.isAcceptableOrUnknown(
          data['current_index']!,
          _currentIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentIndexMeta);
    }
    if (data.containsKey('position_ms')) {
      context.handle(
        _positionMsMeta,
        positionMs.isAcceptableOrUnknown(data['position_ms']!, _positionMsMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMsMeta);
    }
    if (data.containsKey('playback_mode')) {
      context.handle(
        _playbackModeMeta,
        playbackMode.isAcceptableOrUnknown(
          data['playback_mode']!,
          _playbackModeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_playbackModeMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaybackSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaybackSession(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      queueSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}queue_snapshot'],
      )!,
      currentIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_index'],
      )!,
      positionMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_ms'],
      )!,
      playbackMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playback_mode'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $PlaybackSessionsTable createAlias(String alias) {
    return $PlaybackSessionsTable(attachedDatabase, alias);
  }
}

class PlaybackSession extends DataClass implements Insertable<PlaybackSession> {
  final int id;
  final String queueSnapshot;
  final int currentIndex;
  final int positionMs;
  final String playbackMode;
  final DateTime updatedAt;
  const PlaybackSession({
    required this.id,
    required this.queueSnapshot,
    required this.currentIndex,
    required this.positionMs,
    required this.playbackMode,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['queue_snapshot'] = Variable<String>(queueSnapshot);
    map['current_index'] = Variable<int>(currentIndex);
    map['position_ms'] = Variable<int>(positionMs);
    map['playback_mode'] = Variable<String>(playbackMode);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  PlaybackSessionsCompanion toCompanion(bool nullToAbsent) {
    return PlaybackSessionsCompanion(
      id: Value(id),
      queueSnapshot: Value(queueSnapshot),
      currentIndex: Value(currentIndex),
      positionMs: Value(positionMs),
      playbackMode: Value(playbackMode),
      updatedAt: Value(updatedAt),
    );
  }

  factory PlaybackSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaybackSession(
      id: serializer.fromJson<int>(json['id']),
      queueSnapshot: serializer.fromJson<String>(json['queueSnapshot']),
      currentIndex: serializer.fromJson<int>(json['currentIndex']),
      positionMs: serializer.fromJson<int>(json['positionMs']),
      playbackMode: serializer.fromJson<String>(json['playbackMode']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'queueSnapshot': serializer.toJson<String>(queueSnapshot),
      'currentIndex': serializer.toJson<int>(currentIndex),
      'positionMs': serializer.toJson<int>(positionMs),
      'playbackMode': serializer.toJson<String>(playbackMode),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  PlaybackSession copyWith({
    int? id,
    String? queueSnapshot,
    int? currentIndex,
    int? positionMs,
    String? playbackMode,
    DateTime? updatedAt,
  }) => PlaybackSession(
    id: id ?? this.id,
    queueSnapshot: queueSnapshot ?? this.queueSnapshot,
    currentIndex: currentIndex ?? this.currentIndex,
    positionMs: positionMs ?? this.positionMs,
    playbackMode: playbackMode ?? this.playbackMode,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  PlaybackSession copyWithCompanion(PlaybackSessionsCompanion data) {
    return PlaybackSession(
      id: data.id.present ? data.id.value : this.id,
      queueSnapshot: data.queueSnapshot.present
          ? data.queueSnapshot.value
          : this.queueSnapshot,
      currentIndex: data.currentIndex.present
          ? data.currentIndex.value
          : this.currentIndex,
      positionMs: data.positionMs.present
          ? data.positionMs.value
          : this.positionMs,
      playbackMode: data.playbackMode.present
          ? data.playbackMode.value
          : this.playbackMode,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackSession(')
          ..write('id: $id, ')
          ..write('queueSnapshot: $queueSnapshot, ')
          ..write('currentIndex: $currentIndex, ')
          ..write('positionMs: $positionMs, ')
          ..write('playbackMode: $playbackMode, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    queueSnapshot,
    currentIndex,
    positionMs,
    playbackMode,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaybackSession &&
          other.id == this.id &&
          other.queueSnapshot == this.queueSnapshot &&
          other.currentIndex == this.currentIndex &&
          other.positionMs == this.positionMs &&
          other.playbackMode == this.playbackMode &&
          other.updatedAt == this.updatedAt);
}

class PlaybackSessionsCompanion extends UpdateCompanion<PlaybackSession> {
  final Value<int> id;
  final Value<String> queueSnapshot;
  final Value<int> currentIndex;
  final Value<int> positionMs;
  final Value<String> playbackMode;
  final Value<DateTime> updatedAt;
  const PlaybackSessionsCompanion({
    this.id = const Value.absent(),
    this.queueSnapshot = const Value.absent(),
    this.currentIndex = const Value.absent(),
    this.positionMs = const Value.absent(),
    this.playbackMode = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  PlaybackSessionsCompanion.insert({
    this.id = const Value.absent(),
    required String queueSnapshot,
    required int currentIndex,
    required int positionMs,
    required String playbackMode,
    required DateTime updatedAt,
  }) : queueSnapshot = Value(queueSnapshot),
       currentIndex = Value(currentIndex),
       positionMs = Value(positionMs),
       playbackMode = Value(playbackMode),
       updatedAt = Value(updatedAt);
  static Insertable<PlaybackSession> custom({
    Expression<int>? id,
    Expression<String>? queueSnapshot,
    Expression<int>? currentIndex,
    Expression<int>? positionMs,
    Expression<String>? playbackMode,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (queueSnapshot != null) 'queue_snapshot': queueSnapshot,
      if (currentIndex != null) 'current_index': currentIndex,
      if (positionMs != null) 'position_ms': positionMs,
      if (playbackMode != null) 'playback_mode': playbackMode,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  PlaybackSessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? queueSnapshot,
    Value<int>? currentIndex,
    Value<int>? positionMs,
    Value<String>? playbackMode,
    Value<DateTime>? updatedAt,
  }) {
    return PlaybackSessionsCompanion(
      id: id ?? this.id,
      queueSnapshot: queueSnapshot ?? this.queueSnapshot,
      currentIndex: currentIndex ?? this.currentIndex,
      positionMs: positionMs ?? this.positionMs,
      playbackMode: playbackMode ?? this.playbackMode,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (queueSnapshot.present) {
      map['queue_snapshot'] = Variable<String>(queueSnapshot.value);
    }
    if (currentIndex.present) {
      map['current_index'] = Variable<int>(currentIndex.value);
    }
    if (positionMs.present) {
      map['position_ms'] = Variable<int>(positionMs.value);
    }
    if (playbackMode.present) {
      map['playback_mode'] = Variable<String>(playbackMode.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackSessionsCompanion(')
          ..write('id: $id, ')
          ..write('queueSnapshot: $queueSnapshot, ')
          ..write('currentIndex: $currentIndex, ')
          ..write('positionMs: $positionMs, ')
          ..write('playbackMode: $playbackMode, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $PlaybackHistoriesTable extends PlaybackHistories
    with TableInfo<$PlaybackHistoriesTable, PlaybackHistory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaybackHistoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<String> trackId = GeneratedColumn<String>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trackSnapshotMeta = const VerificationMeta(
    'trackSnapshot',
  );
  @override
  late final GeneratedColumn<String> trackSnapshot = GeneratedColumn<String>(
    'track_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playCountMeta = const VerificationMeta(
    'playCount',
  );
  @override
  late final GeneratedColumn<int> playCount = GeneratedColumn<int>(
    'play_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalPlayedMsMeta = const VerificationMeta(
    'totalPlayedMs',
  );
  @override
  late final GeneratedColumn<int> totalPlayedMs = GeneratedColumn<int>(
    'total_played_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastPlayedAtMeta = const VerificationMeta(
    'lastPlayedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPlayedAt = GeneratedColumn<DateTime>(
    'last_played_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    trackId,
    trackSnapshot,
    playCount,
    totalPlayedMs,
    lastPlayedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playback_histories';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaybackHistory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('track_snapshot')) {
      context.handle(
        _trackSnapshotMeta,
        trackSnapshot.isAcceptableOrUnknown(
          data['track_snapshot']!,
          _trackSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_trackSnapshotMeta);
    }
    if (data.containsKey('play_count')) {
      context.handle(
        _playCountMeta,
        playCount.isAcceptableOrUnknown(data['play_count']!, _playCountMeta),
      );
    }
    if (data.containsKey('total_played_ms')) {
      context.handle(
        _totalPlayedMsMeta,
        totalPlayedMs.isAcceptableOrUnknown(
          data['total_played_ms']!,
          _totalPlayedMsMeta,
        ),
      );
    }
    if (data.containsKey('last_played_at')) {
      context.handle(
        _lastPlayedAtMeta,
        lastPlayedAt.isAcceptableOrUnknown(
          data['last_played_at']!,
          _lastPlayedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastPlayedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {trackId};
  @override
  PlaybackHistory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaybackHistory(
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_id'],
      )!,
      trackSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}track_snapshot'],
      )!,
      playCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}play_count'],
      )!,
      totalPlayedMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_played_ms'],
      )!,
      lastPlayedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_played_at'],
      )!,
    );
  }

  @override
  $PlaybackHistoriesTable createAlias(String alias) {
    return $PlaybackHistoriesTable(attachedDatabase, alias);
  }
}

class PlaybackHistory extends DataClass implements Insertable<PlaybackHistory> {
  final String trackId;
  final String trackSnapshot;
  final int playCount;
  final int totalPlayedMs;
  final DateTime lastPlayedAt;
  const PlaybackHistory({
    required this.trackId,
    required this.trackSnapshot,
    required this.playCount,
    required this.totalPlayedMs,
    required this.lastPlayedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['track_id'] = Variable<String>(trackId);
    map['track_snapshot'] = Variable<String>(trackSnapshot);
    map['play_count'] = Variable<int>(playCount);
    map['total_played_ms'] = Variable<int>(totalPlayedMs);
    map['last_played_at'] = Variable<DateTime>(lastPlayedAt);
    return map;
  }

  PlaybackHistoriesCompanion toCompanion(bool nullToAbsent) {
    return PlaybackHistoriesCompanion(
      trackId: Value(trackId),
      trackSnapshot: Value(trackSnapshot),
      playCount: Value(playCount),
      totalPlayedMs: Value(totalPlayedMs),
      lastPlayedAt: Value(lastPlayedAt),
    );
  }

  factory PlaybackHistory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaybackHistory(
      trackId: serializer.fromJson<String>(json['trackId']),
      trackSnapshot: serializer.fromJson<String>(json['trackSnapshot']),
      playCount: serializer.fromJson<int>(json['playCount']),
      totalPlayedMs: serializer.fromJson<int>(json['totalPlayedMs']),
      lastPlayedAt: serializer.fromJson<DateTime>(json['lastPlayedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'trackId': serializer.toJson<String>(trackId),
      'trackSnapshot': serializer.toJson<String>(trackSnapshot),
      'playCount': serializer.toJson<int>(playCount),
      'totalPlayedMs': serializer.toJson<int>(totalPlayedMs),
      'lastPlayedAt': serializer.toJson<DateTime>(lastPlayedAt),
    };
  }

  PlaybackHistory copyWith({
    String? trackId,
    String? trackSnapshot,
    int? playCount,
    int? totalPlayedMs,
    DateTime? lastPlayedAt,
  }) => PlaybackHistory(
    trackId: trackId ?? this.trackId,
    trackSnapshot: trackSnapshot ?? this.trackSnapshot,
    playCount: playCount ?? this.playCount,
    totalPlayedMs: totalPlayedMs ?? this.totalPlayedMs,
    lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
  );
  PlaybackHistory copyWithCompanion(PlaybackHistoriesCompanion data) {
    return PlaybackHistory(
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      trackSnapshot: data.trackSnapshot.present
          ? data.trackSnapshot.value
          : this.trackSnapshot,
      playCount: data.playCount.present ? data.playCount.value : this.playCount,
      totalPlayedMs: data.totalPlayedMs.present
          ? data.totalPlayedMs.value
          : this.totalPlayedMs,
      lastPlayedAt: data.lastPlayedAt.present
          ? data.lastPlayedAt.value
          : this.lastPlayedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackHistory(')
          ..write('trackId: $trackId, ')
          ..write('trackSnapshot: $trackSnapshot, ')
          ..write('playCount: $playCount, ')
          ..write('totalPlayedMs: $totalPlayedMs, ')
          ..write('lastPlayedAt: $lastPlayedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    trackId,
    trackSnapshot,
    playCount,
    totalPlayedMs,
    lastPlayedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaybackHistory &&
          other.trackId == this.trackId &&
          other.trackSnapshot == this.trackSnapshot &&
          other.playCount == this.playCount &&
          other.totalPlayedMs == this.totalPlayedMs &&
          other.lastPlayedAt == this.lastPlayedAt);
}

class PlaybackHistoriesCompanion extends UpdateCompanion<PlaybackHistory> {
  final Value<String> trackId;
  final Value<String> trackSnapshot;
  final Value<int> playCount;
  final Value<int> totalPlayedMs;
  final Value<DateTime> lastPlayedAt;
  final Value<int> rowid;
  const PlaybackHistoriesCompanion({
    this.trackId = const Value.absent(),
    this.trackSnapshot = const Value.absent(),
    this.playCount = const Value.absent(),
    this.totalPlayedMs = const Value.absent(),
    this.lastPlayedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaybackHistoriesCompanion.insert({
    required String trackId,
    required String trackSnapshot,
    this.playCount = const Value.absent(),
    this.totalPlayedMs = const Value.absent(),
    required DateTime lastPlayedAt,
    this.rowid = const Value.absent(),
  }) : trackId = Value(trackId),
       trackSnapshot = Value(trackSnapshot),
       lastPlayedAt = Value(lastPlayedAt);
  static Insertable<PlaybackHistory> custom({
    Expression<String>? trackId,
    Expression<String>? trackSnapshot,
    Expression<int>? playCount,
    Expression<int>? totalPlayedMs,
    Expression<DateTime>? lastPlayedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (trackId != null) 'track_id': trackId,
      if (trackSnapshot != null) 'track_snapshot': trackSnapshot,
      if (playCount != null) 'play_count': playCount,
      if (totalPlayedMs != null) 'total_played_ms': totalPlayedMs,
      if (lastPlayedAt != null) 'last_played_at': lastPlayedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaybackHistoriesCompanion copyWith({
    Value<String>? trackId,
    Value<String>? trackSnapshot,
    Value<int>? playCount,
    Value<int>? totalPlayedMs,
    Value<DateTime>? lastPlayedAt,
    Value<int>? rowid,
  }) {
    return PlaybackHistoriesCompanion(
      trackId: trackId ?? this.trackId,
      trackSnapshot: trackSnapshot ?? this.trackSnapshot,
      playCount: playCount ?? this.playCount,
      totalPlayedMs: totalPlayedMs ?? this.totalPlayedMs,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (trackId.present) {
      map['track_id'] = Variable<String>(trackId.value);
    }
    if (trackSnapshot.present) {
      map['track_snapshot'] = Variable<String>(trackSnapshot.value);
    }
    if (playCount.present) {
      map['play_count'] = Variable<int>(playCount.value);
    }
    if (totalPlayedMs.present) {
      map['total_played_ms'] = Variable<int>(totalPlayedMs.value);
    }
    if (lastPlayedAt.present) {
      map['last_played_at'] = Variable<DateTime>(lastPlayedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackHistoriesCompanion(')
          ..write('trackId: $trackId, ')
          ..write('trackSnapshot: $trackSnapshot, ')
          ..write('playCount: $playCount, ')
          ..write('totalPlayedMs: $totalPlayedMs, ')
          ..write('lastPlayedAt: $lastPlayedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FavoriteTracksTable favoriteTracks = $FavoriteTracksTable(this);
  late final $UserPlaylistsTable userPlaylists = $UserPlaylistsTable(this);
  late final $UserPlaylistTracksTable userPlaylistTracks =
      $UserPlaylistTracksTable(this);
  late final $PlaybackSessionsTable playbackSessions = $PlaybackSessionsTable(
    this,
  );
  late final $PlaybackHistoriesTable playbackHistories =
      $PlaybackHistoriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    favoriteTracks,
    userPlaylists,
    userPlaylistTracks,
    playbackSessions,
    playbackHistories,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'user_playlists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('user_playlist_tracks', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$FavoriteTracksTableCreateCompanionBuilder =
    FavoriteTracksCompanion Function({
      required String trackId,
      required String trackSnapshot,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$FavoriteTracksTableUpdateCompanionBuilder =
    FavoriteTracksCompanion Function({
      Value<String> trackId,
      Value<String> trackSnapshot,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$FavoriteTracksTableFilterComposer
    extends Composer<_$AppDatabase, $FavoriteTracksTable> {
  $$FavoriteTracksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackSnapshot => $composableBuilder(
    column: $table.trackSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FavoriteTracksTableOrderingComposer
    extends Composer<_$AppDatabase, $FavoriteTracksTable> {
  $$FavoriteTracksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackSnapshot => $composableBuilder(
    column: $table.trackSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FavoriteTracksTableAnnotationComposer
    extends Composer<_$AppDatabase, $FavoriteTracksTable> {
  $$FavoriteTracksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<String> get trackSnapshot => $composableBuilder(
    column: $table.trackSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$FavoriteTracksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FavoriteTracksTable,
          FavoriteTrack,
          $$FavoriteTracksTableFilterComposer,
          $$FavoriteTracksTableOrderingComposer,
          $$FavoriteTracksTableAnnotationComposer,
          $$FavoriteTracksTableCreateCompanionBuilder,
          $$FavoriteTracksTableUpdateCompanionBuilder,
          (
            FavoriteTrack,
            BaseReferences<_$AppDatabase, $FavoriteTracksTable, FavoriteTrack>,
          ),
          FavoriteTrack,
          PrefetchHooks Function()
        > {
  $$FavoriteTracksTableTableManager(
    _$AppDatabase db,
    $FavoriteTracksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FavoriteTracksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FavoriteTracksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FavoriteTracksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> trackId = const Value.absent(),
                Value<String> trackSnapshot = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FavoriteTracksCompanion(
                trackId: trackId,
                trackSnapshot: trackSnapshot,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String trackId,
                required String trackSnapshot,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => FavoriteTracksCompanion.insert(
                trackId: trackId,
                trackSnapshot: trackSnapshot,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FavoriteTracksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FavoriteTracksTable,
      FavoriteTrack,
      $$FavoriteTracksTableFilterComposer,
      $$FavoriteTracksTableOrderingComposer,
      $$FavoriteTracksTableAnnotationComposer,
      $$FavoriteTracksTableCreateCompanionBuilder,
      $$FavoriteTracksTableUpdateCompanionBuilder,
      (
        FavoriteTrack,
        BaseReferences<_$AppDatabase, $FavoriteTracksTable, FavoriteTrack>,
      ),
      FavoriteTrack,
      PrefetchHooks Function()
    >;
typedef $$UserPlaylistsTableCreateCompanionBuilder =
    UserPlaylistsCompanion Function({
      required String id,
      required String name,
      Value<String> description,
      Value<String?> coverAsset,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$UserPlaylistsTableUpdateCompanionBuilder =
    UserPlaylistsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> description,
      Value<String?> coverAsset,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$UserPlaylistsTableReferences
    extends BaseReferences<_$AppDatabase, $UserPlaylistsTable, UserPlaylist> {
  $$UserPlaylistsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$UserPlaylistTracksTable, List<UserPlaylistTrack>>
  _userPlaylistTracksRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.userPlaylistTracks,
        aliasName: $_aliasNameGenerator(
          db.userPlaylists.id,
          db.userPlaylistTracks.playlistId,
        ),
      );

  $$UserPlaylistTracksTableProcessedTableManager get userPlaylistTracksRefs {
    final manager = $$UserPlaylistTracksTableTableManager(
      $_db,
      $_db.userPlaylistTracks,
    ).filter((f) => f.playlistId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _userPlaylistTracksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UserPlaylistsTableFilterComposer
    extends Composer<_$AppDatabase, $UserPlaylistsTable> {
  $$UserPlaylistsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverAsset => $composableBuilder(
    column: $table.coverAsset,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> userPlaylistTracksRefs(
    Expression<bool> Function($$UserPlaylistTracksTableFilterComposer f) f,
  ) {
    final $$UserPlaylistTracksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userPlaylistTracks,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserPlaylistTracksTableFilterComposer(
            $db: $db,
            $table: $db.userPlaylistTracks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserPlaylistsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserPlaylistsTable> {
  $$UserPlaylistsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverAsset => $composableBuilder(
    column: $table.coverAsset,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserPlaylistsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserPlaylistsTable> {
  $$UserPlaylistsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverAsset => $composableBuilder(
    column: $table.coverAsset,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> userPlaylistTracksRefs<T extends Object>(
    Expression<T> Function($$UserPlaylistTracksTableAnnotationComposer a) f,
  ) {
    final $$UserPlaylistTracksTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.userPlaylistTracks,
          getReferencedColumn: (t) => t.playlistId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$UserPlaylistTracksTableAnnotationComposer(
                $db: $db,
                $table: $db.userPlaylistTracks,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$UserPlaylistsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserPlaylistsTable,
          UserPlaylist,
          $$UserPlaylistsTableFilterComposer,
          $$UserPlaylistsTableOrderingComposer,
          $$UserPlaylistsTableAnnotationComposer,
          $$UserPlaylistsTableCreateCompanionBuilder,
          $$UserPlaylistsTableUpdateCompanionBuilder,
          (UserPlaylist, $$UserPlaylistsTableReferences),
          UserPlaylist,
          PrefetchHooks Function({bool userPlaylistTracksRefs})
        > {
  $$UserPlaylistsTableTableManager(_$AppDatabase db, $UserPlaylistsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserPlaylistsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserPlaylistsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserPlaylistsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> coverAsset = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserPlaylistsCompanion(
                id: id,
                name: name,
                description: description,
                coverAsset: coverAsset,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> description = const Value.absent(),
                Value<String?> coverAsset = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => UserPlaylistsCompanion.insert(
                id: id,
                name: name,
                description: description,
                coverAsset: coverAsset,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserPlaylistsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userPlaylistTracksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (userPlaylistTracksRefs) db.userPlaylistTracks,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (userPlaylistTracksRefs)
                    await $_getPrefetchedData<
                      UserPlaylist,
                      $UserPlaylistsTable,
                      UserPlaylistTrack
                    >(
                      currentTable: table,
                      referencedTable: $$UserPlaylistsTableReferences
                          ._userPlaylistTracksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$UserPlaylistsTableReferences(
                            db,
                            table,
                            p0,
                          ).userPlaylistTracksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.playlistId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$UserPlaylistsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserPlaylistsTable,
      UserPlaylist,
      $$UserPlaylistsTableFilterComposer,
      $$UserPlaylistsTableOrderingComposer,
      $$UserPlaylistsTableAnnotationComposer,
      $$UserPlaylistsTableCreateCompanionBuilder,
      $$UserPlaylistsTableUpdateCompanionBuilder,
      (UserPlaylist, $$UserPlaylistsTableReferences),
      UserPlaylist,
      PrefetchHooks Function({bool userPlaylistTracksRefs})
    >;
typedef $$UserPlaylistTracksTableCreateCompanionBuilder =
    UserPlaylistTracksCompanion Function({
      required String playlistId,
      required String trackId,
      required String trackSnapshot,
      required int sortOrder,
      required DateTime addedAt,
      Value<int> rowid,
    });
typedef $$UserPlaylistTracksTableUpdateCompanionBuilder =
    UserPlaylistTracksCompanion Function({
      Value<String> playlistId,
      Value<String> trackId,
      Value<String> trackSnapshot,
      Value<int> sortOrder,
      Value<DateTime> addedAt,
      Value<int> rowid,
    });

final class $$UserPlaylistTracksTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $UserPlaylistTracksTable,
          UserPlaylistTrack
        > {
  $$UserPlaylistTracksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $UserPlaylistsTable _playlistIdTable(_$AppDatabase db) =>
      db.userPlaylists.createAlias(
        $_aliasNameGenerator(
          db.userPlaylistTracks.playlistId,
          db.userPlaylists.id,
        ),
      );

  $$UserPlaylistsTableProcessedTableManager get playlistId {
    final $_column = $_itemColumn<String>('playlist_id')!;

    final manager = $$UserPlaylistsTableTableManager(
      $_db,
      $_db.userPlaylists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UserPlaylistTracksTableFilterComposer
    extends Composer<_$AppDatabase, $UserPlaylistTracksTable> {
  $$UserPlaylistTracksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackSnapshot => $composableBuilder(
    column: $table.trackSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$UserPlaylistsTableFilterComposer get playlistId {
    final $$UserPlaylistsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.userPlaylists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserPlaylistsTableFilterComposer(
            $db: $db,
            $table: $db.userPlaylists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserPlaylistTracksTableOrderingComposer
    extends Composer<_$AppDatabase, $UserPlaylistTracksTable> {
  $$UserPlaylistTracksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackSnapshot => $composableBuilder(
    column: $table.trackSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$UserPlaylistsTableOrderingComposer get playlistId {
    final $$UserPlaylistsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.userPlaylists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserPlaylistsTableOrderingComposer(
            $db: $db,
            $table: $db.userPlaylists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserPlaylistTracksTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserPlaylistTracksTable> {
  $$UserPlaylistTracksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<String> get trackSnapshot => $composableBuilder(
    column: $table.trackSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$UserPlaylistsTableAnnotationComposer get playlistId {
    final $$UserPlaylistsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.userPlaylists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserPlaylistsTableAnnotationComposer(
            $db: $db,
            $table: $db.userPlaylists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserPlaylistTracksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserPlaylistTracksTable,
          UserPlaylistTrack,
          $$UserPlaylistTracksTableFilterComposer,
          $$UserPlaylistTracksTableOrderingComposer,
          $$UserPlaylistTracksTableAnnotationComposer,
          $$UserPlaylistTracksTableCreateCompanionBuilder,
          $$UserPlaylistTracksTableUpdateCompanionBuilder,
          (UserPlaylistTrack, $$UserPlaylistTracksTableReferences),
          UserPlaylistTrack,
          PrefetchHooks Function({bool playlistId})
        > {
  $$UserPlaylistTracksTableTableManager(
    _$AppDatabase db,
    $UserPlaylistTracksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserPlaylistTracksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserPlaylistTracksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserPlaylistTracksTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> playlistId = const Value.absent(),
                Value<String> trackId = const Value.absent(),
                Value<String> trackSnapshot = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserPlaylistTracksCompanion(
                playlistId: playlistId,
                trackId: trackId,
                trackSnapshot: trackSnapshot,
                sortOrder: sortOrder,
                addedAt: addedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String playlistId,
                required String trackId,
                required String trackSnapshot,
                required int sortOrder,
                required DateTime addedAt,
                Value<int> rowid = const Value.absent(),
              }) => UserPlaylistTracksCompanion.insert(
                playlistId: playlistId,
                trackId: trackId,
                trackSnapshot: trackSnapshot,
                sortOrder: sortOrder,
                addedAt: addedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserPlaylistTracksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (playlistId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.playlistId,
                                referencedTable:
                                    $$UserPlaylistTracksTableReferences
                                        ._playlistIdTable(db),
                                referencedColumn:
                                    $$UserPlaylistTracksTableReferences
                                        ._playlistIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$UserPlaylistTracksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserPlaylistTracksTable,
      UserPlaylistTrack,
      $$UserPlaylistTracksTableFilterComposer,
      $$UserPlaylistTracksTableOrderingComposer,
      $$UserPlaylistTracksTableAnnotationComposer,
      $$UserPlaylistTracksTableCreateCompanionBuilder,
      $$UserPlaylistTracksTableUpdateCompanionBuilder,
      (UserPlaylistTrack, $$UserPlaylistTracksTableReferences),
      UserPlaylistTrack,
      PrefetchHooks Function({bool playlistId})
    >;
typedef $$PlaybackSessionsTableCreateCompanionBuilder =
    PlaybackSessionsCompanion Function({
      Value<int> id,
      required String queueSnapshot,
      required int currentIndex,
      required int positionMs,
      required String playbackMode,
      required DateTime updatedAt,
    });
typedef $$PlaybackSessionsTableUpdateCompanionBuilder =
    PlaybackSessionsCompanion Function({
      Value<int> id,
      Value<String> queueSnapshot,
      Value<int> currentIndex,
      Value<int> positionMs,
      Value<String> playbackMode,
      Value<DateTime> updatedAt,
    });

class $$PlaybackSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaybackSessionsTable> {
  $$PlaybackSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get queueSnapshot => $composableBuilder(
    column: $table.queueSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get playbackMode => $composableBuilder(
    column: $table.playbackMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlaybackSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaybackSessionsTable> {
  $$PlaybackSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get queueSnapshot => $composableBuilder(
    column: $table.queueSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get playbackMode => $composableBuilder(
    column: $table.playbackMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaybackSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaybackSessionsTable> {
  $$PlaybackSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get queueSnapshot => $composableBuilder(
    column: $table.queueSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentIndex => $composableBuilder(
    column: $table.currentIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get positionMs => $composableBuilder(
    column: $table.positionMs,
    builder: (column) => column,
  );

  GeneratedColumn<String> get playbackMode => $composableBuilder(
    column: $table.playbackMode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$PlaybackSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaybackSessionsTable,
          PlaybackSession,
          $$PlaybackSessionsTableFilterComposer,
          $$PlaybackSessionsTableOrderingComposer,
          $$PlaybackSessionsTableAnnotationComposer,
          $$PlaybackSessionsTableCreateCompanionBuilder,
          $$PlaybackSessionsTableUpdateCompanionBuilder,
          (
            PlaybackSession,
            BaseReferences<
              _$AppDatabase,
              $PlaybackSessionsTable,
              PlaybackSession
            >,
          ),
          PlaybackSession,
          PrefetchHooks Function()
        > {
  $$PlaybackSessionsTableTableManager(
    _$AppDatabase db,
    $PlaybackSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaybackSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaybackSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaybackSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> queueSnapshot = const Value.absent(),
                Value<int> currentIndex = const Value.absent(),
                Value<int> positionMs = const Value.absent(),
                Value<String> playbackMode = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => PlaybackSessionsCompanion(
                id: id,
                queueSnapshot: queueSnapshot,
                currentIndex: currentIndex,
                positionMs: positionMs,
                playbackMode: playbackMode,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String queueSnapshot,
                required int currentIndex,
                required int positionMs,
                required String playbackMode,
                required DateTime updatedAt,
              }) => PlaybackSessionsCompanion.insert(
                id: id,
                queueSnapshot: queueSnapshot,
                currentIndex: currentIndex,
                positionMs: positionMs,
                playbackMode: playbackMode,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlaybackSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaybackSessionsTable,
      PlaybackSession,
      $$PlaybackSessionsTableFilterComposer,
      $$PlaybackSessionsTableOrderingComposer,
      $$PlaybackSessionsTableAnnotationComposer,
      $$PlaybackSessionsTableCreateCompanionBuilder,
      $$PlaybackSessionsTableUpdateCompanionBuilder,
      (
        PlaybackSession,
        BaseReferences<_$AppDatabase, $PlaybackSessionsTable, PlaybackSession>,
      ),
      PlaybackSession,
      PrefetchHooks Function()
    >;
typedef $$PlaybackHistoriesTableCreateCompanionBuilder =
    PlaybackHistoriesCompanion Function({
      required String trackId,
      required String trackSnapshot,
      Value<int> playCount,
      Value<int> totalPlayedMs,
      required DateTime lastPlayedAt,
      Value<int> rowid,
    });
typedef $$PlaybackHistoriesTableUpdateCompanionBuilder =
    PlaybackHistoriesCompanion Function({
      Value<String> trackId,
      Value<String> trackSnapshot,
      Value<int> playCount,
      Value<int> totalPlayedMs,
      Value<DateTime> lastPlayedAt,
      Value<int> rowid,
    });

class $$PlaybackHistoriesTableFilterComposer
    extends Composer<_$AppDatabase, $PlaybackHistoriesTable> {
  $$PlaybackHistoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get trackSnapshot => $composableBuilder(
    column: $table.trackSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalPlayedMs => $composableBuilder(
    column: $table.totalPlayedMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlaybackHistoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaybackHistoriesTable> {
  $$PlaybackHistoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get trackId => $composableBuilder(
    column: $table.trackId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get trackSnapshot => $composableBuilder(
    column: $table.trackSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get playCount => $composableBuilder(
    column: $table.playCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalPlayedMs => $composableBuilder(
    column: $table.totalPlayedMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaybackHistoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaybackHistoriesTable> {
  $$PlaybackHistoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get trackId =>
      $composableBuilder(column: $table.trackId, builder: (column) => column);

  GeneratedColumn<String> get trackSnapshot => $composableBuilder(
    column: $table.trackSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<int> get playCount =>
      $composableBuilder(column: $table.playCount, builder: (column) => column);

  GeneratedColumn<int> get totalPlayedMs => $composableBuilder(
    column: $table.totalPlayedMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastPlayedAt => $composableBuilder(
    column: $table.lastPlayedAt,
    builder: (column) => column,
  );
}

class $$PlaybackHistoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaybackHistoriesTable,
          PlaybackHistory,
          $$PlaybackHistoriesTableFilterComposer,
          $$PlaybackHistoriesTableOrderingComposer,
          $$PlaybackHistoriesTableAnnotationComposer,
          $$PlaybackHistoriesTableCreateCompanionBuilder,
          $$PlaybackHistoriesTableUpdateCompanionBuilder,
          (
            PlaybackHistory,
            BaseReferences<
              _$AppDatabase,
              $PlaybackHistoriesTable,
              PlaybackHistory
            >,
          ),
          PlaybackHistory,
          PrefetchHooks Function()
        > {
  $$PlaybackHistoriesTableTableManager(
    _$AppDatabase db,
    $PlaybackHistoriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaybackHistoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaybackHistoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaybackHistoriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> trackId = const Value.absent(),
                Value<String> trackSnapshot = const Value.absent(),
                Value<int> playCount = const Value.absent(),
                Value<int> totalPlayedMs = const Value.absent(),
                Value<DateTime> lastPlayedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaybackHistoriesCompanion(
                trackId: trackId,
                trackSnapshot: trackSnapshot,
                playCount: playCount,
                totalPlayedMs: totalPlayedMs,
                lastPlayedAt: lastPlayedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String trackId,
                required String trackSnapshot,
                Value<int> playCount = const Value.absent(),
                Value<int> totalPlayedMs = const Value.absent(),
                required DateTime lastPlayedAt,
                Value<int> rowid = const Value.absent(),
              }) => PlaybackHistoriesCompanion.insert(
                trackId: trackId,
                trackSnapshot: trackSnapshot,
                playCount: playCount,
                totalPlayedMs: totalPlayedMs,
                lastPlayedAt: lastPlayedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlaybackHistoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaybackHistoriesTable,
      PlaybackHistory,
      $$PlaybackHistoriesTableFilterComposer,
      $$PlaybackHistoriesTableOrderingComposer,
      $$PlaybackHistoriesTableAnnotationComposer,
      $$PlaybackHistoriesTableCreateCompanionBuilder,
      $$PlaybackHistoriesTableUpdateCompanionBuilder,
      (
        PlaybackHistory,
        BaseReferences<_$AppDatabase, $PlaybackHistoriesTable, PlaybackHistory>,
      ),
      PlaybackHistory,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FavoriteTracksTableTableManager get favoriteTracks =>
      $$FavoriteTracksTableTableManager(_db, _db.favoriteTracks);
  $$UserPlaylistsTableTableManager get userPlaylists =>
      $$UserPlaylistsTableTableManager(_db, _db.userPlaylists);
  $$UserPlaylistTracksTableTableManager get userPlaylistTracks =>
      $$UserPlaylistTracksTableTableManager(_db, _db.userPlaylistTracks);
  $$PlaybackSessionsTableTableManager get playbackSessions =>
      $$PlaybackSessionsTableTableManager(_db, _db.playbackSessions);
  $$PlaybackHistoriesTableTableManager get playbackHistories =>
      $$PlaybackHistoriesTableTableManager(_db, _db.playbackHistories);
}
