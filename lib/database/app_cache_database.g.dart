// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_cache_database.dart';

// ignore_for_file: type=lint
class $CachedDataTable extends CachedData
    with TableInfo<$CachedDataTable, CachedDataData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedDataTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dataTypeMeta = const VerificationMeta(
    'dataType',
  );
  @override
  late final GeneratedColumn<String> dataType = GeneratedColumn<String>(
    'data_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataJsonMeta = const VerificationMeta(
    'dataJson',
  );
  @override
  late final GeneratedColumn<String> dataJson = GeneratedColumn<String>(
    'data_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _validUntilMeta = const VerificationMeta(
    'validUntil',
  );
  @override
  late final GeneratedColumn<DateTime> validUntil = GeneratedColumn<DateTime>(
    'valid_until',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<String> metadata = GeneratedColumn<String>(
    'metadata',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    dataType,
    key,
    latitude,
    longitude,
    dataJson,
    fetchedAt,
    validUntil,
    metadata,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_data';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedDataData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('data_type')) {
      context.handle(
        _dataTypeMeta,
        dataType.isAcceptableOrUnknown(data['data_type']!, _dataTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_dataTypeMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('data_json')) {
      context.handle(
        _dataJsonMeta,
        dataJson.isAcceptableOrUnknown(data['data_json']!, _dataJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_dataJsonMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('valid_until')) {
      context.handle(
        _validUntilMeta,
        validUntil.isAcceptableOrUnknown(data['valid_until']!, _validUntilMeta),
      );
    } else if (isInserting) {
      context.missing(_validUntilMeta);
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedDataData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedDataData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      dataType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_type'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      dataJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}data_json'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
      validUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}valid_until'],
      )!,
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metadata'],
      ),
    );
  }

  @override
  $CachedDataTable createAlias(String alias) {
    return $CachedDataTable(attachedDatabase, alias);
  }
}

class CachedDataData extends DataClass implements Insertable<CachedDataData> {
  final int id;
  final String dataType;
  final String key;
  final double latitude;
  final double longitude;
  final String dataJson;
  final DateTime fetchedAt;
  final DateTime validUntil;
  final String? metadata;
  const CachedDataData({
    required this.id,
    required this.dataType,
    required this.key,
    required this.latitude,
    required this.longitude,
    required this.dataJson,
    required this.fetchedAt,
    required this.validUntil,
    this.metadata,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['data_type'] = Variable<String>(dataType);
    map['key'] = Variable<String>(key);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    map['data_json'] = Variable<String>(dataJson);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    map['valid_until'] = Variable<DateTime>(validUntil);
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<String>(metadata);
    }
    return map;
  }

  CachedDataCompanion toCompanion(bool nullToAbsent) {
    return CachedDataCompanion(
      id: Value(id),
      dataType: Value(dataType),
      key: Value(key),
      latitude: Value(latitude),
      longitude: Value(longitude),
      dataJson: Value(dataJson),
      fetchedAt: Value(fetchedAt),
      validUntil: Value(validUntil),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
    );
  }

  factory CachedDataData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedDataData(
      id: serializer.fromJson<int>(json['id']),
      dataType: serializer.fromJson<String>(json['dataType']),
      key: serializer.fromJson<String>(json['key']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      dataJson: serializer.fromJson<String>(json['dataJson']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      validUntil: serializer.fromJson<DateTime>(json['validUntil']),
      metadata: serializer.fromJson<String?>(json['metadata']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'dataType': serializer.toJson<String>(dataType),
      'key': serializer.toJson<String>(key),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'dataJson': serializer.toJson<String>(dataJson),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'validUntil': serializer.toJson<DateTime>(validUntil),
      'metadata': serializer.toJson<String?>(metadata),
    };
  }

  CachedDataData copyWith({
    int? id,
    String? dataType,
    String? key,
    double? latitude,
    double? longitude,
    String? dataJson,
    DateTime? fetchedAt,
    DateTime? validUntil,
    Value<String?> metadata = const Value.absent(),
  }) => CachedDataData(
    id: id ?? this.id,
    dataType: dataType ?? this.dataType,
    key: key ?? this.key,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    dataJson: dataJson ?? this.dataJson,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    validUntil: validUntil ?? this.validUntil,
    metadata: metadata.present ? metadata.value : this.metadata,
  );
  CachedDataData copyWithCompanion(CachedDataCompanion data) {
    return CachedDataData(
      id: data.id.present ? data.id.value : this.id,
      dataType: data.dataType.present ? data.dataType.value : this.dataType,
      key: data.key.present ? data.key.value : this.key,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      dataJson: data.dataJson.present ? data.dataJson.value : this.dataJson,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      validUntil: data.validUntil.present
          ? data.validUntil.value
          : this.validUntil,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedDataData(')
          ..write('id: $id, ')
          ..write('dataType: $dataType, ')
          ..write('key: $key, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('dataJson: $dataJson, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('validUntil: $validUntil, ')
          ..write('metadata: $metadata')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dataType,
    key,
    latitude,
    longitude,
    dataJson,
    fetchedAt,
    validUntil,
    metadata,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedDataData &&
          other.id == this.id &&
          other.dataType == this.dataType &&
          other.key == this.key &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.dataJson == this.dataJson &&
          other.fetchedAt == this.fetchedAt &&
          other.validUntil == this.validUntil &&
          other.metadata == this.metadata);
}

class CachedDataCompanion extends UpdateCompanion<CachedDataData> {
  final Value<int> id;
  final Value<String> dataType;
  final Value<String> key;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<String> dataJson;
  final Value<DateTime> fetchedAt;
  final Value<DateTime> validUntil;
  final Value<String?> metadata;
  const CachedDataCompanion({
    this.id = const Value.absent(),
    this.dataType = const Value.absent(),
    this.key = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.dataJson = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.validUntil = const Value.absent(),
    this.metadata = const Value.absent(),
  });
  CachedDataCompanion.insert({
    this.id = const Value.absent(),
    required String dataType,
    required String key,
    required double latitude,
    required double longitude,
    required String dataJson,
    required DateTime fetchedAt,
    required DateTime validUntil,
    this.metadata = const Value.absent(),
  }) : dataType = Value(dataType),
       key = Value(key),
       latitude = Value(latitude),
       longitude = Value(longitude),
       dataJson = Value(dataJson),
       fetchedAt = Value(fetchedAt),
       validUntil = Value(validUntil);
  static Insertable<CachedDataData> custom({
    Expression<int>? id,
    Expression<String>? dataType,
    Expression<String>? key,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<String>? dataJson,
    Expression<DateTime>? fetchedAt,
    Expression<DateTime>? validUntil,
    Expression<String>? metadata,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dataType != null) 'data_type': dataType,
      if (key != null) 'key': key,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (dataJson != null) 'data_json': dataJson,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (validUntil != null) 'valid_until': validUntil,
      if (metadata != null) 'metadata': metadata,
    });
  }

  CachedDataCompanion copyWith({
    Value<int>? id,
    Value<String>? dataType,
    Value<String>? key,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<String>? dataJson,
    Value<DateTime>? fetchedAt,
    Value<DateTime>? validUntil,
    Value<String?>? metadata,
  }) {
    return CachedDataCompanion(
      id: id ?? this.id,
      dataType: dataType ?? this.dataType,
      key: key ?? this.key,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      dataJson: dataJson ?? this.dataJson,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      validUntil: validUntil ?? this.validUntil,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (dataType.present) {
      map['data_type'] = Variable<String>(dataType.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (dataJson.present) {
      map['data_json'] = Variable<String>(dataJson.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (validUntil.present) {
      map['valid_until'] = Variable<DateTime>(validUntil.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<String>(metadata.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedDataCompanion(')
          ..write('id: $id, ')
          ..write('dataType: $dataType, ')
          ..write('key: $key, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('dataJson: $dataJson, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('validUntil: $validUntil, ')
          ..write('metadata: $metadata')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppCacheDatabase extends GeneratedDatabase {
  _$AppCacheDatabase(QueryExecutor e) : super(e);
  $AppCacheDatabaseManager get managers => $AppCacheDatabaseManager(this);
  late final $CachedDataTable cachedData = $CachedDataTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [cachedData];
}

typedef $$CachedDataTableCreateCompanionBuilder =
    CachedDataCompanion Function({
      Value<int> id,
      required String dataType,
      required String key,
      required double latitude,
      required double longitude,
      required String dataJson,
      required DateTime fetchedAt,
      required DateTime validUntil,
      Value<String?> metadata,
    });
typedef $$CachedDataTableUpdateCompanionBuilder =
    CachedDataCompanion Function({
      Value<int> id,
      Value<String> dataType,
      Value<String> key,
      Value<double> latitude,
      Value<double> longitude,
      Value<String> dataJson,
      Value<DateTime> fetchedAt,
      Value<DateTime> validUntil,
      Value<String?> metadata,
    });

class $$CachedDataTableFilterComposer
    extends Composer<_$AppCacheDatabase, $CachedDataTable> {
  $$CachedDataTableFilterComposer({
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

  ColumnFilters<String> get dataType => $composableBuilder(
    column: $table.dataType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dataJson => $composableBuilder(
    column: $table.dataJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get validUntil => $composableBuilder(
    column: $table.validUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedDataTableOrderingComposer
    extends Composer<_$AppCacheDatabase, $CachedDataTable> {
  $$CachedDataTableOrderingComposer({
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

  ColumnOrderings<String> get dataType => $composableBuilder(
    column: $table.dataType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dataJson => $composableBuilder(
    column: $table.dataJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get validUntil => $composableBuilder(
    column: $table.validUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedDataTableAnnotationComposer
    extends Composer<_$AppCacheDatabase, $CachedDataTable> {
  $$CachedDataTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dataType =>
      $composableBuilder(column: $table.dataType, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<String> get dataJson =>
      $composableBuilder(column: $table.dataJson, builder: (column) => column);

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get validUntil => $composableBuilder(
    column: $table.validUntil,
    builder: (column) => column,
  );

  GeneratedColumn<String> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);
}

class $$CachedDataTableTableManager
    extends
        RootTableManager<
          _$AppCacheDatabase,
          $CachedDataTable,
          CachedDataData,
          $$CachedDataTableFilterComposer,
          $$CachedDataTableOrderingComposer,
          $$CachedDataTableAnnotationComposer,
          $$CachedDataTableCreateCompanionBuilder,
          $$CachedDataTableUpdateCompanionBuilder,
          (
            CachedDataData,
            BaseReferences<
              _$AppCacheDatabase,
              $CachedDataTable,
              CachedDataData
            >,
          ),
          CachedDataData,
          PrefetchHooks Function()
        > {
  $$CachedDataTableTableManager(_$AppCacheDatabase db, $CachedDataTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedDataTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedDataTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedDataTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> dataType = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<String> dataJson = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<DateTime> validUntil = const Value.absent(),
                Value<String?> metadata = const Value.absent(),
              }) => CachedDataCompanion(
                id: id,
                dataType: dataType,
                key: key,
                latitude: latitude,
                longitude: longitude,
                dataJson: dataJson,
                fetchedAt: fetchedAt,
                validUntil: validUntil,
                metadata: metadata,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String dataType,
                required String key,
                required double latitude,
                required double longitude,
                required String dataJson,
                required DateTime fetchedAt,
                required DateTime validUntil,
                Value<String?> metadata = const Value.absent(),
              }) => CachedDataCompanion.insert(
                id: id,
                dataType: dataType,
                key: key,
                latitude: latitude,
                longitude: longitude,
                dataJson: dataJson,
                fetchedAt: fetchedAt,
                validUntil: validUntil,
                metadata: metadata,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedDataTableProcessedTableManager =
    ProcessedTableManager<
      _$AppCacheDatabase,
      $CachedDataTable,
      CachedDataData,
      $$CachedDataTableFilterComposer,
      $$CachedDataTableOrderingComposer,
      $$CachedDataTableAnnotationComposer,
      $$CachedDataTableCreateCompanionBuilder,
      $$CachedDataTableUpdateCompanionBuilder,
      (
        CachedDataData,
        BaseReferences<_$AppCacheDatabase, $CachedDataTable, CachedDataData>,
      ),
      CachedDataData,
      PrefetchHooks Function()
    >;

class $AppCacheDatabaseManager {
  final _$AppCacheDatabase _db;
  $AppCacheDatabaseManager(this._db);
  $$CachedDataTableTableManager get cachedData =>
      $$CachedDataTableTableManager(_db, _db.cachedData);
}
