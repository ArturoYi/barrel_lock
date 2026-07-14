// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $VaultsTable extends Vaults with TableInfo<$VaultsTable, Vault> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VaultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _vaultUuidMeta = const VerificationMeta(
    'vaultUuid',
  );
  @override
  late final GeneratedColumn<String> vaultUuid = GeneratedColumn<String>(
    'vault_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerAccountIdMeta = const VerificationMeta(
    'ownerAccountId',
  );
  @override
  late final GeneratedColumn<String> ownerAccountId = GeneratedColumn<String>(
    'owner_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<Uint8List> name = GeneratedColumn<Uint8List>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconNameMeta = const VerificationMeta(
    'iconName',
  );
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
    'icon_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'color_hex',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPersonalMeta = const VerificationMeta(
    'isPersonal',
  );
  @override
  late final GeneratedColumn<bool> isPersonal = GeneratedColumn<bool>(
    'is_personal',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_personal" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isTrashedMeta = const VerificationMeta(
    'isTrashed',
  );
  @override
  late final GeneratedColumn<bool> isTrashed = GeneratedColumn<bool>(
    'is_trashed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_trashed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncRevisionMeta = const VerificationMeta(
    'syncRevision',
  );
  @override
  late final GeneratedColumn<DateTime> syncRevision = GeneratedColumn<DateTime>(
    'sync_revision',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localModifiedMeta = const VerificationMeta(
    'localModified',
  );
  @override
  late final GeneratedColumn<bool> localModified = GeneratedColumn<bool>(
    'local_modified',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("local_modified" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
    vaultUuid,
    ownerAccountId,
    name,
    iconName,
    colorHex,
    isPersonal,
    isTrashed,
    syncRevision,
    localModified,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vault';
  @override
  VerificationContext validateIntegrity(
    Insertable<Vault> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('vault_uuid')) {
      context.handle(
        _vaultUuidMeta,
        vaultUuid.isAcceptableOrUnknown(data['vault_uuid']!, _vaultUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_vaultUuidMeta);
    }
    if (data.containsKey('owner_account_id')) {
      context.handle(
        _ownerAccountIdMeta,
        ownerAccountId.isAcceptableOrUnknown(
          data['owner_account_id']!,
          _ownerAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_name')) {
      context.handle(
        _iconNameMeta,
        iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta),
      );
    }
    if (data.containsKey('color_hex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['color_hex']!, _colorHexMeta),
      );
    }
    if (data.containsKey('is_personal')) {
      context.handle(
        _isPersonalMeta,
        isPersonal.isAcceptableOrUnknown(data['is_personal']!, _isPersonalMeta),
      );
    }
    if (data.containsKey('is_trashed')) {
      context.handle(
        _isTrashedMeta,
        isTrashed.isAcceptableOrUnknown(data['is_trashed']!, _isTrashedMeta),
      );
    }
    if (data.containsKey('sync_revision')) {
      context.handle(
        _syncRevisionMeta,
        syncRevision.isAcceptableOrUnknown(
          data['sync_revision']!,
          _syncRevisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_syncRevisionMeta);
    }
    if (data.containsKey('local_modified')) {
      context.handle(
        _localModifiedMeta,
        localModified.isAcceptableOrUnknown(
          data['local_modified']!,
          _localModifiedMeta,
        ),
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
  Set<GeneratedColumn> get $primaryKey => {vaultUuid};
  @override
  Vault map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vault(
      vaultUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vault_uuid'],
      )!,
      ownerAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_account_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}name'],
      )!,
      iconName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_name'],
      ),
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}color_hex'],
      ),
      isPersonal: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_personal'],
      )!,
      isTrashed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_trashed'],
      )!,
      syncRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sync_revision'],
      )!,
      localModified: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}local_modified'],
      )!,
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
  $VaultsTable createAlias(String alias) {
    return $VaultsTable(attachedDatabase, alias);
  }
}

class Vault extends DataClass implements Insertable<Vault> {
  final String vaultUuid;
  final String? ownerAccountId;
  final Uint8List name;
  final String? iconName;
  final String? colorHex;
  final bool isPersonal;
  final bool isTrashed;
  final DateTime syncRevision;
  final bool localModified;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Vault({
    required this.vaultUuid,
    this.ownerAccountId,
    required this.name,
    this.iconName,
    this.colorHex,
    required this.isPersonal,
    required this.isTrashed,
    required this.syncRevision,
    required this.localModified,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['vault_uuid'] = Variable<String>(vaultUuid);
    if (!nullToAbsent || ownerAccountId != null) {
      map['owner_account_id'] = Variable<String>(ownerAccountId);
    }
    map['name'] = Variable<Uint8List>(name);
    if (!nullToAbsent || iconName != null) {
      map['icon_name'] = Variable<String>(iconName);
    }
    if (!nullToAbsent || colorHex != null) {
      map['color_hex'] = Variable<String>(colorHex);
    }
    map['is_personal'] = Variable<bool>(isPersonal);
    map['is_trashed'] = Variable<bool>(isTrashed);
    map['sync_revision'] = Variable<DateTime>(syncRevision);
    map['local_modified'] = Variable<bool>(localModified);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  VaultsCompanion toCompanion(bool nullToAbsent) {
    return VaultsCompanion(
      vaultUuid: Value(vaultUuid),
      ownerAccountId: ownerAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerAccountId),
      name: Value(name),
      iconName: iconName == null && nullToAbsent
          ? const Value.absent()
          : Value(iconName),
      colorHex: colorHex == null && nullToAbsent
          ? const Value.absent()
          : Value(colorHex),
      isPersonal: Value(isPersonal),
      isTrashed: Value(isTrashed),
      syncRevision: Value(syncRevision),
      localModified: Value(localModified),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Vault.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vault(
      vaultUuid: serializer.fromJson<String>(json['vaultUuid']),
      ownerAccountId: serializer.fromJson<String?>(json['ownerAccountId']),
      name: serializer.fromJson<Uint8List>(json['name']),
      iconName: serializer.fromJson<String?>(json['iconName']),
      colorHex: serializer.fromJson<String?>(json['colorHex']),
      isPersonal: serializer.fromJson<bool>(json['isPersonal']),
      isTrashed: serializer.fromJson<bool>(json['isTrashed']),
      syncRevision: serializer.fromJson<DateTime>(json['syncRevision']),
      localModified: serializer.fromJson<bool>(json['localModified']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'vaultUuid': serializer.toJson<String>(vaultUuid),
      'ownerAccountId': serializer.toJson<String?>(ownerAccountId),
      'name': serializer.toJson<Uint8List>(name),
      'iconName': serializer.toJson<String?>(iconName),
      'colorHex': serializer.toJson<String?>(colorHex),
      'isPersonal': serializer.toJson<bool>(isPersonal),
      'isTrashed': serializer.toJson<bool>(isTrashed),
      'syncRevision': serializer.toJson<DateTime>(syncRevision),
      'localModified': serializer.toJson<bool>(localModified),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Vault copyWith({
    String? vaultUuid,
    Value<String?> ownerAccountId = const Value.absent(),
    Uint8List? name,
    Value<String?> iconName = const Value.absent(),
    Value<String?> colorHex = const Value.absent(),
    bool? isPersonal,
    bool? isTrashed,
    DateTime? syncRevision,
    bool? localModified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Vault(
    vaultUuid: vaultUuid ?? this.vaultUuid,
    ownerAccountId: ownerAccountId.present
        ? ownerAccountId.value
        : this.ownerAccountId,
    name: name ?? this.name,
    iconName: iconName.present ? iconName.value : this.iconName,
    colorHex: colorHex.present ? colorHex.value : this.colorHex,
    isPersonal: isPersonal ?? this.isPersonal,
    isTrashed: isTrashed ?? this.isTrashed,
    syncRevision: syncRevision ?? this.syncRevision,
    localModified: localModified ?? this.localModified,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Vault copyWithCompanion(VaultsCompanion data) {
    return Vault(
      vaultUuid: data.vaultUuid.present ? data.vaultUuid.value : this.vaultUuid,
      ownerAccountId: data.ownerAccountId.present
          ? data.ownerAccountId.value
          : this.ownerAccountId,
      name: data.name.present ? data.name.value : this.name,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      isPersonal: data.isPersonal.present
          ? data.isPersonal.value
          : this.isPersonal,
      isTrashed: data.isTrashed.present ? data.isTrashed.value : this.isTrashed,
      syncRevision: data.syncRevision.present
          ? data.syncRevision.value
          : this.syncRevision,
      localModified: data.localModified.present
          ? data.localModified.value
          : this.localModified,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vault(')
          ..write('vaultUuid: $vaultUuid, ')
          ..write('ownerAccountId: $ownerAccountId, ')
          ..write('name: $name, ')
          ..write('iconName: $iconName, ')
          ..write('colorHex: $colorHex, ')
          ..write('isPersonal: $isPersonal, ')
          ..write('isTrashed: $isTrashed, ')
          ..write('syncRevision: $syncRevision, ')
          ..write('localModified: $localModified, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    vaultUuid,
    ownerAccountId,
    $driftBlobEquality.hash(name),
    iconName,
    colorHex,
    isPersonal,
    isTrashed,
    syncRevision,
    localModified,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vault &&
          other.vaultUuid == this.vaultUuid &&
          other.ownerAccountId == this.ownerAccountId &&
          $driftBlobEquality.equals(other.name, this.name) &&
          other.iconName == this.iconName &&
          other.colorHex == this.colorHex &&
          other.isPersonal == this.isPersonal &&
          other.isTrashed == this.isTrashed &&
          other.syncRevision == this.syncRevision &&
          other.localModified == this.localModified &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class VaultsCompanion extends UpdateCompanion<Vault> {
  final Value<String> vaultUuid;
  final Value<String?> ownerAccountId;
  final Value<Uint8List> name;
  final Value<String?> iconName;
  final Value<String?> colorHex;
  final Value<bool> isPersonal;
  final Value<bool> isTrashed;
  final Value<DateTime> syncRevision;
  final Value<bool> localModified;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const VaultsCompanion({
    this.vaultUuid = const Value.absent(),
    this.ownerAccountId = const Value.absent(),
    this.name = const Value.absent(),
    this.iconName = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.isPersonal = const Value.absent(),
    this.isTrashed = const Value.absent(),
    this.syncRevision = const Value.absent(),
    this.localModified = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VaultsCompanion.insert({
    required String vaultUuid,
    this.ownerAccountId = const Value.absent(),
    required Uint8List name,
    this.iconName = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.isPersonal = const Value.absent(),
    this.isTrashed = const Value.absent(),
    required DateTime syncRevision,
    this.localModified = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : vaultUuid = Value(vaultUuid),
       name = Value(name),
       syncRevision = Value(syncRevision),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Vault> custom({
    Expression<String>? vaultUuid,
    Expression<String>? ownerAccountId,
    Expression<Uint8List>? name,
    Expression<String>? iconName,
    Expression<String>? colorHex,
    Expression<bool>? isPersonal,
    Expression<bool>? isTrashed,
    Expression<DateTime>? syncRevision,
    Expression<bool>? localModified,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (vaultUuid != null) 'vault_uuid': vaultUuid,
      if (ownerAccountId != null) 'owner_account_id': ownerAccountId,
      if (name != null) 'name': name,
      if (iconName != null) 'icon_name': iconName,
      if (colorHex != null) 'color_hex': colorHex,
      if (isPersonal != null) 'is_personal': isPersonal,
      if (isTrashed != null) 'is_trashed': isTrashed,
      if (syncRevision != null) 'sync_revision': syncRevision,
      if (localModified != null) 'local_modified': localModified,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VaultsCompanion copyWith({
    Value<String>? vaultUuid,
    Value<String?>? ownerAccountId,
    Value<Uint8List>? name,
    Value<String?>? iconName,
    Value<String?>? colorHex,
    Value<bool>? isPersonal,
    Value<bool>? isTrashed,
    Value<DateTime>? syncRevision,
    Value<bool>? localModified,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return VaultsCompanion(
      vaultUuid: vaultUuid ?? this.vaultUuid,
      ownerAccountId: ownerAccountId ?? this.ownerAccountId,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      isPersonal: isPersonal ?? this.isPersonal,
      isTrashed: isTrashed ?? this.isTrashed,
      syncRevision: syncRevision ?? this.syncRevision,
      localModified: localModified ?? this.localModified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (vaultUuid.present) {
      map['vault_uuid'] = Variable<String>(vaultUuid.value);
    }
    if (ownerAccountId.present) {
      map['owner_account_id'] = Variable<String>(ownerAccountId.value);
    }
    if (name.present) {
      map['name'] = Variable<Uint8List>(name.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (colorHex.present) {
      map['color_hex'] = Variable<String>(colorHex.value);
    }
    if (isPersonal.present) {
      map['is_personal'] = Variable<bool>(isPersonal.value);
    }
    if (isTrashed.present) {
      map['is_trashed'] = Variable<bool>(isTrashed.value);
    }
    if (syncRevision.present) {
      map['sync_revision'] = Variable<DateTime>(syncRevision.value);
    }
    if (localModified.present) {
      map['local_modified'] = Variable<bool>(localModified.value);
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
    return (StringBuffer('VaultsCompanion(')
          ..write('vaultUuid: $vaultUuid, ')
          ..write('ownerAccountId: $ownerAccountId, ')
          ..write('name: $name, ')
          ..write('iconName: $iconName, ')
          ..write('colorHex: $colorHex, ')
          ..write('isPersonal: $isPersonal, ')
          ..write('isTrashed: $isTrashed, ')
          ..write('syncRevision: $syncRevision, ')
          ..write('localModified: $localModified, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FoldersTable extends Folders with TableInfo<$FoldersTable, Folder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FoldersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _folderUuidMeta = const VerificationMeta(
    'folderUuid',
  );
  @override
  late final GeneratedColumn<String> folderUuid = GeneratedColumn<String>(
    'folder_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vaultUuidMeta = const VerificationMeta(
    'vaultUuid',
  );
  @override
  late final GeneratedColumn<String> vaultUuid = GeneratedColumn<String>(
    'vault_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vault (vault_uuid) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ownerAccountIdMeta = const VerificationMeta(
    'ownerAccountId',
  );
  @override
  late final GeneratedColumn<String> ownerAccountId = GeneratedColumn<String>(
    'owner_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<Uint8List> name = GeneratedColumn<Uint8List>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isTrashedMeta = const VerificationMeta(
    'isTrashed',
  );
  @override
  late final GeneratedColumn<bool> isTrashed = GeneratedColumn<bool>(
    'is_trashed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_trashed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncRevisionMeta = const VerificationMeta(
    'syncRevision',
  );
  @override
  late final GeneratedColumn<DateTime> syncRevision = GeneratedColumn<DateTime>(
    'sync_revision',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localModifiedMeta = const VerificationMeta(
    'localModified',
  );
  @override
  late final GeneratedColumn<bool> localModified = GeneratedColumn<bool>(
    'local_modified',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("local_modified" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
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
    folderUuid,
    vaultUuid,
    ownerAccountId,
    name,
    isTrashed,
    syncRevision,
    localModified,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'folder';
  @override
  VerificationContext validateIntegrity(
    Insertable<Folder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('folder_uuid')) {
      context.handle(
        _folderUuidMeta,
        folderUuid.isAcceptableOrUnknown(data['folder_uuid']!, _folderUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_folderUuidMeta);
    }
    if (data.containsKey('vault_uuid')) {
      context.handle(
        _vaultUuidMeta,
        vaultUuid.isAcceptableOrUnknown(data['vault_uuid']!, _vaultUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_vaultUuidMeta);
    }
    if (data.containsKey('owner_account_id')) {
      context.handle(
        _ownerAccountIdMeta,
        ownerAccountId.isAcceptableOrUnknown(
          data['owner_account_id']!,
          _ownerAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_trashed')) {
      context.handle(
        _isTrashedMeta,
        isTrashed.isAcceptableOrUnknown(data['is_trashed']!, _isTrashedMeta),
      );
    }
    if (data.containsKey('sync_revision')) {
      context.handle(
        _syncRevisionMeta,
        syncRevision.isAcceptableOrUnknown(
          data['sync_revision']!,
          _syncRevisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_syncRevisionMeta);
    }
    if (data.containsKey('local_modified')) {
      context.handle(
        _localModifiedMeta,
        localModified.isAcceptableOrUnknown(
          data['local_modified']!,
          _localModifiedMeta,
        ),
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
  Set<GeneratedColumn> get $primaryKey => {folderUuid};
  @override
  Folder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Folder(
      folderUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_uuid'],
      )!,
      vaultUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vault_uuid'],
      )!,
      ownerAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_account_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}name'],
      )!,
      isTrashed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_trashed'],
      )!,
      syncRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sync_revision'],
      )!,
      localModified: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}local_modified'],
      )!,
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
  $FoldersTable createAlias(String alias) {
    return $FoldersTable(attachedDatabase, alias);
  }
}

class Folder extends DataClass implements Insertable<Folder> {
  final String folderUuid;
  final String vaultUuid;
  final String? ownerAccountId;
  final Uint8List name;
  final bool isTrashed;
  final DateTime syncRevision;
  final bool localModified;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Folder({
    required this.folderUuid,
    required this.vaultUuid,
    this.ownerAccountId,
    required this.name,
    required this.isTrashed,
    required this.syncRevision,
    required this.localModified,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['folder_uuid'] = Variable<String>(folderUuid);
    map['vault_uuid'] = Variable<String>(vaultUuid);
    if (!nullToAbsent || ownerAccountId != null) {
      map['owner_account_id'] = Variable<String>(ownerAccountId);
    }
    map['name'] = Variable<Uint8List>(name);
    map['is_trashed'] = Variable<bool>(isTrashed);
    map['sync_revision'] = Variable<DateTime>(syncRevision);
    map['local_modified'] = Variable<bool>(localModified);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FoldersCompanion toCompanion(bool nullToAbsent) {
    return FoldersCompanion(
      folderUuid: Value(folderUuid),
      vaultUuid: Value(vaultUuid),
      ownerAccountId: ownerAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerAccountId),
      name: Value(name),
      isTrashed: Value(isTrashed),
      syncRevision: Value(syncRevision),
      localModified: Value(localModified),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Folder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Folder(
      folderUuid: serializer.fromJson<String>(json['folderUuid']),
      vaultUuid: serializer.fromJson<String>(json['vaultUuid']),
      ownerAccountId: serializer.fromJson<String?>(json['ownerAccountId']),
      name: serializer.fromJson<Uint8List>(json['name']),
      isTrashed: serializer.fromJson<bool>(json['isTrashed']),
      syncRevision: serializer.fromJson<DateTime>(json['syncRevision']),
      localModified: serializer.fromJson<bool>(json['localModified']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'folderUuid': serializer.toJson<String>(folderUuid),
      'vaultUuid': serializer.toJson<String>(vaultUuid),
      'ownerAccountId': serializer.toJson<String?>(ownerAccountId),
      'name': serializer.toJson<Uint8List>(name),
      'isTrashed': serializer.toJson<bool>(isTrashed),
      'syncRevision': serializer.toJson<DateTime>(syncRevision),
      'localModified': serializer.toJson<bool>(localModified),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Folder copyWith({
    String? folderUuid,
    String? vaultUuid,
    Value<String?> ownerAccountId = const Value.absent(),
    Uint8List? name,
    bool? isTrashed,
    DateTime? syncRevision,
    bool? localModified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Folder(
    folderUuid: folderUuid ?? this.folderUuid,
    vaultUuid: vaultUuid ?? this.vaultUuid,
    ownerAccountId: ownerAccountId.present
        ? ownerAccountId.value
        : this.ownerAccountId,
    name: name ?? this.name,
    isTrashed: isTrashed ?? this.isTrashed,
    syncRevision: syncRevision ?? this.syncRevision,
    localModified: localModified ?? this.localModified,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Folder copyWithCompanion(FoldersCompanion data) {
    return Folder(
      folderUuid: data.folderUuid.present
          ? data.folderUuid.value
          : this.folderUuid,
      vaultUuid: data.vaultUuid.present ? data.vaultUuid.value : this.vaultUuid,
      ownerAccountId: data.ownerAccountId.present
          ? data.ownerAccountId.value
          : this.ownerAccountId,
      name: data.name.present ? data.name.value : this.name,
      isTrashed: data.isTrashed.present ? data.isTrashed.value : this.isTrashed,
      syncRevision: data.syncRevision.present
          ? data.syncRevision.value
          : this.syncRevision,
      localModified: data.localModified.present
          ? data.localModified.value
          : this.localModified,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Folder(')
          ..write('folderUuid: $folderUuid, ')
          ..write('vaultUuid: $vaultUuid, ')
          ..write('ownerAccountId: $ownerAccountId, ')
          ..write('name: $name, ')
          ..write('isTrashed: $isTrashed, ')
          ..write('syncRevision: $syncRevision, ')
          ..write('localModified: $localModified, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    folderUuid,
    vaultUuid,
    ownerAccountId,
    $driftBlobEquality.hash(name),
    isTrashed,
    syncRevision,
    localModified,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Folder &&
          other.folderUuid == this.folderUuid &&
          other.vaultUuid == this.vaultUuid &&
          other.ownerAccountId == this.ownerAccountId &&
          $driftBlobEquality.equals(other.name, this.name) &&
          other.isTrashed == this.isTrashed &&
          other.syncRevision == this.syncRevision &&
          other.localModified == this.localModified &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FoldersCompanion extends UpdateCompanion<Folder> {
  final Value<String> folderUuid;
  final Value<String> vaultUuid;
  final Value<String?> ownerAccountId;
  final Value<Uint8List> name;
  final Value<bool> isTrashed;
  final Value<DateTime> syncRevision;
  final Value<bool> localModified;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FoldersCompanion({
    this.folderUuid = const Value.absent(),
    this.vaultUuid = const Value.absent(),
    this.ownerAccountId = const Value.absent(),
    this.name = const Value.absent(),
    this.isTrashed = const Value.absent(),
    this.syncRevision = const Value.absent(),
    this.localModified = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FoldersCompanion.insert({
    required String folderUuid,
    required String vaultUuid,
    this.ownerAccountId = const Value.absent(),
    required Uint8List name,
    this.isTrashed = const Value.absent(),
    required DateTime syncRevision,
    this.localModified = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : folderUuid = Value(folderUuid),
       vaultUuid = Value(vaultUuid),
       name = Value(name),
       syncRevision = Value(syncRevision),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Folder> custom({
    Expression<String>? folderUuid,
    Expression<String>? vaultUuid,
    Expression<String>? ownerAccountId,
    Expression<Uint8List>? name,
    Expression<bool>? isTrashed,
    Expression<DateTime>? syncRevision,
    Expression<bool>? localModified,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (folderUuid != null) 'folder_uuid': folderUuid,
      if (vaultUuid != null) 'vault_uuid': vaultUuid,
      if (ownerAccountId != null) 'owner_account_id': ownerAccountId,
      if (name != null) 'name': name,
      if (isTrashed != null) 'is_trashed': isTrashed,
      if (syncRevision != null) 'sync_revision': syncRevision,
      if (localModified != null) 'local_modified': localModified,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FoldersCompanion copyWith({
    Value<String>? folderUuid,
    Value<String>? vaultUuid,
    Value<String?>? ownerAccountId,
    Value<Uint8List>? name,
    Value<bool>? isTrashed,
    Value<DateTime>? syncRevision,
    Value<bool>? localModified,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return FoldersCompanion(
      folderUuid: folderUuid ?? this.folderUuid,
      vaultUuid: vaultUuid ?? this.vaultUuid,
      ownerAccountId: ownerAccountId ?? this.ownerAccountId,
      name: name ?? this.name,
      isTrashed: isTrashed ?? this.isTrashed,
      syncRevision: syncRevision ?? this.syncRevision,
      localModified: localModified ?? this.localModified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (folderUuid.present) {
      map['folder_uuid'] = Variable<String>(folderUuid.value);
    }
    if (vaultUuid.present) {
      map['vault_uuid'] = Variable<String>(vaultUuid.value);
    }
    if (ownerAccountId.present) {
      map['owner_account_id'] = Variable<String>(ownerAccountId.value);
    }
    if (name.present) {
      map['name'] = Variable<Uint8List>(name.value);
    }
    if (isTrashed.present) {
      map['is_trashed'] = Variable<bool>(isTrashed.value);
    }
    if (syncRevision.present) {
      map['sync_revision'] = Variable<DateTime>(syncRevision.value);
    }
    if (localModified.present) {
      map['local_modified'] = Variable<bool>(localModified.value);
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
    return (StringBuffer('FoldersCompanion(')
          ..write('folderUuid: $folderUuid, ')
          ..write('vaultUuid: $vaultUuid, ')
          ..write('ownerAccountId: $ownerAccountId, ')
          ..write('name: $name, ')
          ..write('isTrashed: $isTrashed, ')
          ..write('syncRevision: $syncRevision, ')
          ..write('localModified: $localModified, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CipherEntriesTable extends CipherEntries
    with TableInfo<$CipherEntriesTable, CipherEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CipherEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cipherUuidMeta = const VerificationMeta(
    'cipherUuid',
  );
  @override
  late final GeneratedColumn<String> cipherUuid = GeneratedColumn<String>(
    'cipher_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vaultUuidMeta = const VerificationMeta(
    'vaultUuid',
  );
  @override
  late final GeneratedColumn<String> vaultUuid = GeneratedColumn<String>(
    'vault_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vault (vault_uuid) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _folderUuidMeta = const VerificationMeta(
    'folderUuid',
  );
  @override
  late final GeneratedColumn<String> folderUuid = GeneratedColumn<String>(
    'folder_uuid',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES folder (folder_uuid) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _ownerAccountIdMeta = const VerificationMeta(
    'ownerAccountId',
  );
  @override
  late final GeneratedColumn<String> ownerAccountId = GeneratedColumn<String>(
    'owner_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _overviewBlobMeta = const VerificationMeta(
    'overviewBlob',
  );
  @override
  late final GeneratedColumn<Uint8List> overviewBlob =
      GeneratedColumn<Uint8List>(
        'overview_blob',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _fullDataBlobMeta = const VerificationMeta(
    'fullDataBlob',
  );
  @override
  late final GeneratedColumn<Uint8List> fullDataBlob =
      GeneratedColumn<Uint8List>(
        'full_data_blob',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncRevisionMeta = const VerificationMeta(
    'syncRevision',
  );
  @override
  late final GeneratedColumn<DateTime> syncRevision = GeneratedColumn<DateTime>(
    'sync_revision',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localModifiedMeta = const VerificationMeta(
    'localModified',
  );
  @override
  late final GeneratedColumn<bool> localModified = GeneratedColumn<bool>(
    'local_modified',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("local_modified" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _remoteIdMeta = const VerificationMeta(
    'remoteId',
  );
  @override
  late final GeneratedColumn<String> remoteId = GeneratedColumn<String>(
    'remote_id',
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
    cipherUuid,
    vaultUuid,
    folderUuid,
    ownerAccountId,
    type,
    overviewBlob,
    fullDataBlob,
    isFavorite,
    deletedAt,
    syncRevision,
    localModified,
    remoteId,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cipher';
  @override
  VerificationContext validateIntegrity(
    Insertable<CipherEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cipher_uuid')) {
      context.handle(
        _cipherUuidMeta,
        cipherUuid.isAcceptableOrUnknown(data['cipher_uuid']!, _cipherUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_cipherUuidMeta);
    }
    if (data.containsKey('vault_uuid')) {
      context.handle(
        _vaultUuidMeta,
        vaultUuid.isAcceptableOrUnknown(data['vault_uuid']!, _vaultUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_vaultUuidMeta);
    }
    if (data.containsKey('folder_uuid')) {
      context.handle(
        _folderUuidMeta,
        folderUuid.isAcceptableOrUnknown(data['folder_uuid']!, _folderUuidMeta),
      );
    }
    if (data.containsKey('owner_account_id')) {
      context.handle(
        _ownerAccountIdMeta,
        ownerAccountId.isAcceptableOrUnknown(
          data['owner_account_id']!,
          _ownerAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('overview_blob')) {
      context.handle(
        _overviewBlobMeta,
        overviewBlob.isAcceptableOrUnknown(
          data['overview_blob']!,
          _overviewBlobMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_overviewBlobMeta);
    }
    if (data.containsKey('full_data_blob')) {
      context.handle(
        _fullDataBlobMeta,
        fullDataBlob.isAcceptableOrUnknown(
          data['full_data_blob']!,
          _fullDataBlobMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fullDataBlobMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_revision')) {
      context.handle(
        _syncRevisionMeta,
        syncRevision.isAcceptableOrUnknown(
          data['sync_revision']!,
          _syncRevisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_syncRevisionMeta);
    }
    if (data.containsKey('local_modified')) {
      context.handle(
        _localModifiedMeta,
        localModified.isAcceptableOrUnknown(
          data['local_modified']!,
          _localModifiedMeta,
        ),
      );
    }
    if (data.containsKey('remote_id')) {
      context.handle(
        _remoteIdMeta,
        remoteId.isAcceptableOrUnknown(data['remote_id']!, _remoteIdMeta),
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
  Set<GeneratedColumn> get $primaryKey => {cipherUuid};
  @override
  CipherEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CipherEntry(
      cipherUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cipher_uuid'],
      )!,
      vaultUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vault_uuid'],
      )!,
      folderUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_uuid'],
      ),
      ownerAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_account_id'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      overviewBlob: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}overview_blob'],
      )!,
      fullDataBlob: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}full_data_blob'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sync_revision'],
      )!,
      localModified: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}local_modified'],
      )!,
      remoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remote_id'],
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
  $CipherEntriesTable createAlias(String alias) {
    return $CipherEntriesTable(attachedDatabase, alias);
  }
}

class CipherEntry extends DataClass implements Insertable<CipherEntry> {
  final String cipherUuid;
  final String vaultUuid;
  final String? folderUuid;
  final String? ownerAccountId;
  final int type;
  final Uint8List overviewBlob;
  final Uint8List fullDataBlob;
  final bool isFavorite;
  final DateTime? deletedAt;
  final DateTime syncRevision;
  final bool localModified;
  final String? remoteId;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CipherEntry({
    required this.cipherUuid,
    required this.vaultUuid,
    this.folderUuid,
    this.ownerAccountId,
    required this.type,
    required this.overviewBlob,
    required this.fullDataBlob,
    required this.isFavorite,
    this.deletedAt,
    required this.syncRevision,
    required this.localModified,
    this.remoteId,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cipher_uuid'] = Variable<String>(cipherUuid);
    map['vault_uuid'] = Variable<String>(vaultUuid);
    if (!nullToAbsent || folderUuid != null) {
      map['folder_uuid'] = Variable<String>(folderUuid);
    }
    if (!nullToAbsent || ownerAccountId != null) {
      map['owner_account_id'] = Variable<String>(ownerAccountId);
    }
    map['type'] = Variable<int>(type);
    map['overview_blob'] = Variable<Uint8List>(overviewBlob);
    map['full_data_blob'] = Variable<Uint8List>(fullDataBlob);
    map['is_favorite'] = Variable<bool>(isFavorite);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_revision'] = Variable<DateTime>(syncRevision);
    map['local_modified'] = Variable<bool>(localModified);
    if (!nullToAbsent || remoteId != null) {
      map['remote_id'] = Variable<String>(remoteId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CipherEntriesCompanion toCompanion(bool nullToAbsent) {
    return CipherEntriesCompanion(
      cipherUuid: Value(cipherUuid),
      vaultUuid: Value(vaultUuid),
      folderUuid: folderUuid == null && nullToAbsent
          ? const Value.absent()
          : Value(folderUuid),
      ownerAccountId: ownerAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerAccountId),
      type: Value(type),
      overviewBlob: Value(overviewBlob),
      fullDataBlob: Value(fullDataBlob),
      isFavorite: Value(isFavorite),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncRevision: Value(syncRevision),
      localModified: Value(localModified),
      remoteId: remoteId == null && nullToAbsent
          ? const Value.absent()
          : Value(remoteId),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CipherEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CipherEntry(
      cipherUuid: serializer.fromJson<String>(json['cipherUuid']),
      vaultUuid: serializer.fromJson<String>(json['vaultUuid']),
      folderUuid: serializer.fromJson<String?>(json['folderUuid']),
      ownerAccountId: serializer.fromJson<String?>(json['ownerAccountId']),
      type: serializer.fromJson<int>(json['type']),
      overviewBlob: serializer.fromJson<Uint8List>(json['overviewBlob']),
      fullDataBlob: serializer.fromJson<Uint8List>(json['fullDataBlob']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncRevision: serializer.fromJson<DateTime>(json['syncRevision']),
      localModified: serializer.fromJson<bool>(json['localModified']),
      remoteId: serializer.fromJson<String?>(json['remoteId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cipherUuid': serializer.toJson<String>(cipherUuid),
      'vaultUuid': serializer.toJson<String>(vaultUuid),
      'folderUuid': serializer.toJson<String?>(folderUuid),
      'ownerAccountId': serializer.toJson<String?>(ownerAccountId),
      'type': serializer.toJson<int>(type),
      'overviewBlob': serializer.toJson<Uint8List>(overviewBlob),
      'fullDataBlob': serializer.toJson<Uint8List>(fullDataBlob),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncRevision': serializer.toJson<DateTime>(syncRevision),
      'localModified': serializer.toJson<bool>(localModified),
      'remoteId': serializer.toJson<String?>(remoteId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CipherEntry copyWith({
    String? cipherUuid,
    String? vaultUuid,
    Value<String?> folderUuid = const Value.absent(),
    Value<String?> ownerAccountId = const Value.absent(),
    int? type,
    Uint8List? overviewBlob,
    Uint8List? fullDataBlob,
    bool? isFavorite,
    Value<DateTime?> deletedAt = const Value.absent(),
    DateTime? syncRevision,
    bool? localModified,
    Value<String?> remoteId = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => CipherEntry(
    cipherUuid: cipherUuid ?? this.cipherUuid,
    vaultUuid: vaultUuid ?? this.vaultUuid,
    folderUuid: folderUuid.present ? folderUuid.value : this.folderUuid,
    ownerAccountId: ownerAccountId.present
        ? ownerAccountId.value
        : this.ownerAccountId,
    type: type ?? this.type,
    overviewBlob: overviewBlob ?? this.overviewBlob,
    fullDataBlob: fullDataBlob ?? this.fullDataBlob,
    isFavorite: isFavorite ?? this.isFavorite,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncRevision: syncRevision ?? this.syncRevision,
    localModified: localModified ?? this.localModified,
    remoteId: remoteId.present ? remoteId.value : this.remoteId,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CipherEntry copyWithCompanion(CipherEntriesCompanion data) {
    return CipherEntry(
      cipherUuid: data.cipherUuid.present
          ? data.cipherUuid.value
          : this.cipherUuid,
      vaultUuid: data.vaultUuid.present ? data.vaultUuid.value : this.vaultUuid,
      folderUuid: data.folderUuid.present
          ? data.folderUuid.value
          : this.folderUuid,
      ownerAccountId: data.ownerAccountId.present
          ? data.ownerAccountId.value
          : this.ownerAccountId,
      type: data.type.present ? data.type.value : this.type,
      overviewBlob: data.overviewBlob.present
          ? data.overviewBlob.value
          : this.overviewBlob,
      fullDataBlob: data.fullDataBlob.present
          ? data.fullDataBlob.value
          : this.fullDataBlob,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncRevision: data.syncRevision.present
          ? data.syncRevision.value
          : this.syncRevision,
      localModified: data.localModified.present
          ? data.localModified.value
          : this.localModified,
      remoteId: data.remoteId.present ? data.remoteId.value : this.remoteId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CipherEntry(')
          ..write('cipherUuid: $cipherUuid, ')
          ..write('vaultUuid: $vaultUuid, ')
          ..write('folderUuid: $folderUuid, ')
          ..write('ownerAccountId: $ownerAccountId, ')
          ..write('type: $type, ')
          ..write('overviewBlob: $overviewBlob, ')
          ..write('fullDataBlob: $fullDataBlob, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncRevision: $syncRevision, ')
          ..write('localModified: $localModified, ')
          ..write('remoteId: $remoteId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    cipherUuid,
    vaultUuid,
    folderUuid,
    ownerAccountId,
    type,
    $driftBlobEquality.hash(overviewBlob),
    $driftBlobEquality.hash(fullDataBlob),
    isFavorite,
    deletedAt,
    syncRevision,
    localModified,
    remoteId,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CipherEntry &&
          other.cipherUuid == this.cipherUuid &&
          other.vaultUuid == this.vaultUuid &&
          other.folderUuid == this.folderUuid &&
          other.ownerAccountId == this.ownerAccountId &&
          other.type == this.type &&
          $driftBlobEquality.equals(other.overviewBlob, this.overviewBlob) &&
          $driftBlobEquality.equals(other.fullDataBlob, this.fullDataBlob) &&
          other.isFavorite == this.isFavorite &&
          other.deletedAt == this.deletedAt &&
          other.syncRevision == this.syncRevision &&
          other.localModified == this.localModified &&
          other.remoteId == this.remoteId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CipherEntriesCompanion extends UpdateCompanion<CipherEntry> {
  final Value<String> cipherUuid;
  final Value<String> vaultUuid;
  final Value<String?> folderUuid;
  final Value<String?> ownerAccountId;
  final Value<int> type;
  final Value<Uint8List> overviewBlob;
  final Value<Uint8List> fullDataBlob;
  final Value<bool> isFavorite;
  final Value<DateTime?> deletedAt;
  final Value<DateTime> syncRevision;
  final Value<bool> localModified;
  final Value<String?> remoteId;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CipherEntriesCompanion({
    this.cipherUuid = const Value.absent(),
    this.vaultUuid = const Value.absent(),
    this.folderUuid = const Value.absent(),
    this.ownerAccountId = const Value.absent(),
    this.type = const Value.absent(),
    this.overviewBlob = const Value.absent(),
    this.fullDataBlob = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncRevision = const Value.absent(),
    this.localModified = const Value.absent(),
    this.remoteId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CipherEntriesCompanion.insert({
    required String cipherUuid,
    required String vaultUuid,
    this.folderUuid = const Value.absent(),
    this.ownerAccountId = const Value.absent(),
    required int type,
    required Uint8List overviewBlob,
    required Uint8List fullDataBlob,
    this.isFavorite = const Value.absent(),
    this.deletedAt = const Value.absent(),
    required DateTime syncRevision,
    this.localModified = const Value.absent(),
    this.remoteId = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : cipherUuid = Value(cipherUuid),
       vaultUuid = Value(vaultUuid),
       type = Value(type),
       overviewBlob = Value(overviewBlob),
       fullDataBlob = Value(fullDataBlob),
       syncRevision = Value(syncRevision),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<CipherEntry> custom({
    Expression<String>? cipherUuid,
    Expression<String>? vaultUuid,
    Expression<String>? folderUuid,
    Expression<String>? ownerAccountId,
    Expression<int>? type,
    Expression<Uint8List>? overviewBlob,
    Expression<Uint8List>? fullDataBlob,
    Expression<bool>? isFavorite,
    Expression<DateTime>? deletedAt,
    Expression<DateTime>? syncRevision,
    Expression<bool>? localModified,
    Expression<String>? remoteId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cipherUuid != null) 'cipher_uuid': cipherUuid,
      if (vaultUuid != null) 'vault_uuid': vaultUuid,
      if (folderUuid != null) 'folder_uuid': folderUuid,
      if (ownerAccountId != null) 'owner_account_id': ownerAccountId,
      if (type != null) 'type': type,
      if (overviewBlob != null) 'overview_blob': overviewBlob,
      if (fullDataBlob != null) 'full_data_blob': fullDataBlob,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncRevision != null) 'sync_revision': syncRevision,
      if (localModified != null) 'local_modified': localModified,
      if (remoteId != null) 'remote_id': remoteId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CipherEntriesCompanion copyWith({
    Value<String>? cipherUuid,
    Value<String>? vaultUuid,
    Value<String?>? folderUuid,
    Value<String?>? ownerAccountId,
    Value<int>? type,
    Value<Uint8List>? overviewBlob,
    Value<Uint8List>? fullDataBlob,
    Value<bool>? isFavorite,
    Value<DateTime?>? deletedAt,
    Value<DateTime>? syncRevision,
    Value<bool>? localModified,
    Value<String?>? remoteId,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CipherEntriesCompanion(
      cipherUuid: cipherUuid ?? this.cipherUuid,
      vaultUuid: vaultUuid ?? this.vaultUuid,
      folderUuid: folderUuid ?? this.folderUuid,
      ownerAccountId: ownerAccountId ?? this.ownerAccountId,
      type: type ?? this.type,
      overviewBlob: overviewBlob ?? this.overviewBlob,
      fullDataBlob: fullDataBlob ?? this.fullDataBlob,
      isFavorite: isFavorite ?? this.isFavorite,
      deletedAt: deletedAt ?? this.deletedAt,
      syncRevision: syncRevision ?? this.syncRevision,
      localModified: localModified ?? this.localModified,
      remoteId: remoteId ?? this.remoteId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cipherUuid.present) {
      map['cipher_uuid'] = Variable<String>(cipherUuid.value);
    }
    if (vaultUuid.present) {
      map['vault_uuid'] = Variable<String>(vaultUuid.value);
    }
    if (folderUuid.present) {
      map['folder_uuid'] = Variable<String>(folderUuid.value);
    }
    if (ownerAccountId.present) {
      map['owner_account_id'] = Variable<String>(ownerAccountId.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (overviewBlob.present) {
      map['overview_blob'] = Variable<Uint8List>(overviewBlob.value);
    }
    if (fullDataBlob.present) {
      map['full_data_blob'] = Variable<Uint8List>(fullDataBlob.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncRevision.present) {
      map['sync_revision'] = Variable<DateTime>(syncRevision.value);
    }
    if (localModified.present) {
      map['local_modified'] = Variable<bool>(localModified.value);
    }
    if (remoteId.present) {
      map['remote_id'] = Variable<String>(remoteId.value);
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
    return (StringBuffer('CipherEntriesCompanion(')
          ..write('cipherUuid: $cipherUuid, ')
          ..write('vaultUuid: $vaultUuid, ')
          ..write('folderUuid: $folderUuid, ')
          ..write('ownerAccountId: $ownerAccountId, ')
          ..write('type: $type, ')
          ..write('overviewBlob: $overviewBlob, ')
          ..write('fullDataBlob: $fullDataBlob, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncRevision: $syncRevision, ')
          ..write('localModified: $localModified, ')
          ..write('remoteId: $remoteId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CipherAttachmentsTable extends CipherAttachments
    with TableInfo<$CipherAttachmentsTable, CipherAttachment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CipherAttachmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _attachUuidMeta = const VerificationMeta(
    'attachUuid',
  );
  @override
  late final GeneratedColumn<String> attachUuid = GeneratedColumn<String>(
    'attach_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cipherUuidMeta = const VerificationMeta(
    'cipherUuid',
  );
  @override
  late final GeneratedColumn<String> cipherUuid = GeneratedColumn<String>(
    'cipher_uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES cipher (cipher_uuid) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _ownerAccountIdMeta = const VerificationMeta(
    'ownerAccountId',
  );
  @override
  late final GeneratedColumn<String> ownerAccountId = GeneratedColumn<String>(
    'owner_account_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<Uint8List> fileName = GeneratedColumn<Uint8List>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _encryptedFileMeta = const VerificationMeta(
    'encryptedFile',
  );
  @override
  late final GeneratedColumn<Uint8List> encryptedFile =
      GeneratedColumn<Uint8List>(
        'encrypted_file',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncRevisionMeta = const VerificationMeta(
    'syncRevision',
  );
  @override
  late final GeneratedColumn<DateTime> syncRevision = GeneratedColumn<DateTime>(
    'sync_revision',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
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
  List<GeneratedColumn> get $columns => [
    attachUuid,
    cipherUuid,
    ownerAccountId,
    fileName,
    encryptedFile,
    fileSize,
    syncRevision,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cipher_attachment';
  @override
  VerificationContext validateIntegrity(
    Insertable<CipherAttachment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('attach_uuid')) {
      context.handle(
        _attachUuidMeta,
        attachUuid.isAcceptableOrUnknown(data['attach_uuid']!, _attachUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_attachUuidMeta);
    }
    if (data.containsKey('cipher_uuid')) {
      context.handle(
        _cipherUuidMeta,
        cipherUuid.isAcceptableOrUnknown(data['cipher_uuid']!, _cipherUuidMeta),
      );
    } else if (isInserting) {
      context.missing(_cipherUuidMeta);
    }
    if (data.containsKey('owner_account_id')) {
      context.handle(
        _ownerAccountIdMeta,
        ownerAccountId.isAcceptableOrUnknown(
          data['owner_account_id']!,
          _ownerAccountIdMeta,
        ),
      );
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('encrypted_file')) {
      context.handle(
        _encryptedFileMeta,
        encryptedFile.isAcceptableOrUnknown(
          data['encrypted_file']!,
          _encryptedFileMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_encryptedFileMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_fileSizeMeta);
    }
    if (data.containsKey('sync_revision')) {
      context.handle(
        _syncRevisionMeta,
        syncRevision.isAcceptableOrUnknown(
          data['sync_revision']!,
          _syncRevisionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_syncRevisionMeta);
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
  Set<GeneratedColumn> get $primaryKey => {attachUuid};
  @override
  CipherAttachment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CipherAttachment(
      attachUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attach_uuid'],
      )!,
      cipherUuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cipher_uuid'],
      )!,
      ownerAccountId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_account_id'],
      ),
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}file_name'],
      )!,
      encryptedFile: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}encrypted_file'],
      )!,
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      )!,
      syncRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sync_revision'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CipherAttachmentsTable createAlias(String alias) {
    return $CipherAttachmentsTable(attachedDatabase, alias);
  }
}

class CipherAttachment extends DataClass
    implements Insertable<CipherAttachment> {
  final String attachUuid;
  final String cipherUuid;
  final String? ownerAccountId;
  final Uint8List fileName;
  final Uint8List encryptedFile;
  final int fileSize;
  final DateTime syncRevision;
  final DateTime createdAt;
  const CipherAttachment({
    required this.attachUuid,
    required this.cipherUuid,
    this.ownerAccountId,
    required this.fileName,
    required this.encryptedFile,
    required this.fileSize,
    required this.syncRevision,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['attach_uuid'] = Variable<String>(attachUuid);
    map['cipher_uuid'] = Variable<String>(cipherUuid);
    if (!nullToAbsent || ownerAccountId != null) {
      map['owner_account_id'] = Variable<String>(ownerAccountId);
    }
    map['file_name'] = Variable<Uint8List>(fileName);
    map['encrypted_file'] = Variable<Uint8List>(encryptedFile);
    map['file_size'] = Variable<int>(fileSize);
    map['sync_revision'] = Variable<DateTime>(syncRevision);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CipherAttachmentsCompanion toCompanion(bool nullToAbsent) {
    return CipherAttachmentsCompanion(
      attachUuid: Value(attachUuid),
      cipherUuid: Value(cipherUuid),
      ownerAccountId: ownerAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerAccountId),
      fileName: Value(fileName),
      encryptedFile: Value(encryptedFile),
      fileSize: Value(fileSize),
      syncRevision: Value(syncRevision),
      createdAt: Value(createdAt),
    );
  }

  factory CipherAttachment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CipherAttachment(
      attachUuid: serializer.fromJson<String>(json['attachUuid']),
      cipherUuid: serializer.fromJson<String>(json['cipherUuid']),
      ownerAccountId: serializer.fromJson<String?>(json['ownerAccountId']),
      fileName: serializer.fromJson<Uint8List>(json['fileName']),
      encryptedFile: serializer.fromJson<Uint8List>(json['encryptedFile']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
      syncRevision: serializer.fromJson<DateTime>(json['syncRevision']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'attachUuid': serializer.toJson<String>(attachUuid),
      'cipherUuid': serializer.toJson<String>(cipherUuid),
      'ownerAccountId': serializer.toJson<String?>(ownerAccountId),
      'fileName': serializer.toJson<Uint8List>(fileName),
      'encryptedFile': serializer.toJson<Uint8List>(encryptedFile),
      'fileSize': serializer.toJson<int>(fileSize),
      'syncRevision': serializer.toJson<DateTime>(syncRevision),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CipherAttachment copyWith({
    String? attachUuid,
    String? cipherUuid,
    Value<String?> ownerAccountId = const Value.absent(),
    Uint8List? fileName,
    Uint8List? encryptedFile,
    int? fileSize,
    DateTime? syncRevision,
    DateTime? createdAt,
  }) => CipherAttachment(
    attachUuid: attachUuid ?? this.attachUuid,
    cipherUuid: cipherUuid ?? this.cipherUuid,
    ownerAccountId: ownerAccountId.present
        ? ownerAccountId.value
        : this.ownerAccountId,
    fileName: fileName ?? this.fileName,
    encryptedFile: encryptedFile ?? this.encryptedFile,
    fileSize: fileSize ?? this.fileSize,
    syncRevision: syncRevision ?? this.syncRevision,
    createdAt: createdAt ?? this.createdAt,
  );
  CipherAttachment copyWithCompanion(CipherAttachmentsCompanion data) {
    return CipherAttachment(
      attachUuid: data.attachUuid.present
          ? data.attachUuid.value
          : this.attachUuid,
      cipherUuid: data.cipherUuid.present
          ? data.cipherUuid.value
          : this.cipherUuid,
      ownerAccountId: data.ownerAccountId.present
          ? data.ownerAccountId.value
          : this.ownerAccountId,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      encryptedFile: data.encryptedFile.present
          ? data.encryptedFile.value
          : this.encryptedFile,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      syncRevision: data.syncRevision.present
          ? data.syncRevision.value
          : this.syncRevision,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CipherAttachment(')
          ..write('attachUuid: $attachUuid, ')
          ..write('cipherUuid: $cipherUuid, ')
          ..write('ownerAccountId: $ownerAccountId, ')
          ..write('fileName: $fileName, ')
          ..write('encryptedFile: $encryptedFile, ')
          ..write('fileSize: $fileSize, ')
          ..write('syncRevision: $syncRevision, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    attachUuid,
    cipherUuid,
    ownerAccountId,
    $driftBlobEquality.hash(fileName),
    $driftBlobEquality.hash(encryptedFile),
    fileSize,
    syncRevision,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CipherAttachment &&
          other.attachUuid == this.attachUuid &&
          other.cipherUuid == this.cipherUuid &&
          other.ownerAccountId == this.ownerAccountId &&
          $driftBlobEquality.equals(other.fileName, this.fileName) &&
          $driftBlobEquality.equals(other.encryptedFile, this.encryptedFile) &&
          other.fileSize == this.fileSize &&
          other.syncRevision == this.syncRevision &&
          other.createdAt == this.createdAt);
}

class CipherAttachmentsCompanion extends UpdateCompanion<CipherAttachment> {
  final Value<String> attachUuid;
  final Value<String> cipherUuid;
  final Value<String?> ownerAccountId;
  final Value<Uint8List> fileName;
  final Value<Uint8List> encryptedFile;
  final Value<int> fileSize;
  final Value<DateTime> syncRevision;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CipherAttachmentsCompanion({
    this.attachUuid = const Value.absent(),
    this.cipherUuid = const Value.absent(),
    this.ownerAccountId = const Value.absent(),
    this.fileName = const Value.absent(),
    this.encryptedFile = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.syncRevision = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CipherAttachmentsCompanion.insert({
    required String attachUuid,
    required String cipherUuid,
    this.ownerAccountId = const Value.absent(),
    required Uint8List fileName,
    required Uint8List encryptedFile,
    required int fileSize,
    required DateTime syncRevision,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : attachUuid = Value(attachUuid),
       cipherUuid = Value(cipherUuid),
       fileName = Value(fileName),
       encryptedFile = Value(encryptedFile),
       fileSize = Value(fileSize),
       syncRevision = Value(syncRevision),
       createdAt = Value(createdAt);
  static Insertable<CipherAttachment> custom({
    Expression<String>? attachUuid,
    Expression<String>? cipherUuid,
    Expression<String>? ownerAccountId,
    Expression<Uint8List>? fileName,
    Expression<Uint8List>? encryptedFile,
    Expression<int>? fileSize,
    Expression<DateTime>? syncRevision,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (attachUuid != null) 'attach_uuid': attachUuid,
      if (cipherUuid != null) 'cipher_uuid': cipherUuid,
      if (ownerAccountId != null) 'owner_account_id': ownerAccountId,
      if (fileName != null) 'file_name': fileName,
      if (encryptedFile != null) 'encrypted_file': encryptedFile,
      if (fileSize != null) 'file_size': fileSize,
      if (syncRevision != null) 'sync_revision': syncRevision,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CipherAttachmentsCompanion copyWith({
    Value<String>? attachUuid,
    Value<String>? cipherUuid,
    Value<String?>? ownerAccountId,
    Value<Uint8List>? fileName,
    Value<Uint8List>? encryptedFile,
    Value<int>? fileSize,
    Value<DateTime>? syncRevision,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CipherAttachmentsCompanion(
      attachUuid: attachUuid ?? this.attachUuid,
      cipherUuid: cipherUuid ?? this.cipherUuid,
      ownerAccountId: ownerAccountId ?? this.ownerAccountId,
      fileName: fileName ?? this.fileName,
      encryptedFile: encryptedFile ?? this.encryptedFile,
      fileSize: fileSize ?? this.fileSize,
      syncRevision: syncRevision ?? this.syncRevision,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (attachUuid.present) {
      map['attach_uuid'] = Variable<String>(attachUuid.value);
    }
    if (cipherUuid.present) {
      map['cipher_uuid'] = Variable<String>(cipherUuid.value);
    }
    if (ownerAccountId.present) {
      map['owner_account_id'] = Variable<String>(ownerAccountId.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<Uint8List>(fileName.value);
    }
    if (encryptedFile.present) {
      map['encrypted_file'] = Variable<Uint8List>(encryptedFile.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (syncRevision.present) {
      map['sync_revision'] = Variable<DateTime>(syncRevision.value);
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
    return (StringBuffer('CipherAttachmentsCompanion(')
          ..write('attachUuid: $attachUuid, ')
          ..write('cipherUuid: $cipherUuid, ')
          ..write('ownerAccountId: $ownerAccountId, ')
          ..write('fileName: $fileName, ')
          ..write('encryptedFile: $encryptedFile, ')
          ..write('fileSize: $fileSize, ')
          ..write('syncRevision: $syncRevision, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BackupLogsTable extends BackupLogs
    with TableInfo<$BackupLogsTable, BackupLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BackupLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _logIdMeta = const VerificationMeta('logId');
  @override
  late final GeneratedColumn<String> logId = GeneratedColumn<String>(
    'log_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _backupTimeMeta = const VerificationMeta(
    'backupTime',
  );
  @override
  late final GeneratedColumn<DateTime> backupTime = GeneratedColumn<DateTime>(
    'backup_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _backupPathMeta = const VerificationMeta(
    'backupPath',
  );
  @override
  late final GeneratedColumn<String> backupPath = GeneratedColumn<String>(
    'backup_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _backupPasswordSaltMeta =
      const VerificationMeta('backupPasswordSalt');
  @override
  late final GeneratedColumn<Uint8List> backupPasswordSalt =
      GeneratedColumn<Uint8List>(
        'backup_password_salt',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _vaultVersionMeta = const VerificationMeta(
    'vaultVersion',
  );
  @override
  late final GeneratedColumn<int> vaultVersion = GeneratedColumn<int>(
    'vault_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isEncryptedMeta = const VerificationMeta(
    'isEncrypted',
  );
  @override
  late final GeneratedColumn<bool> isEncrypted = GeneratedColumn<bool>(
    'is_encrypted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_encrypted" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
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
  @override
  List<GeneratedColumn> get $columns => [
    logId,
    backupTime,
    backupPath,
    backupPasswordSalt,
    vaultVersion,
    isEncrypted,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'backup_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<BackupLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('log_id')) {
      context.handle(
        _logIdMeta,
        logId.isAcceptableOrUnknown(data['log_id']!, _logIdMeta),
      );
    } else if (isInserting) {
      context.missing(_logIdMeta);
    }
    if (data.containsKey('backup_time')) {
      context.handle(
        _backupTimeMeta,
        backupTime.isAcceptableOrUnknown(data['backup_time']!, _backupTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_backupTimeMeta);
    }
    if (data.containsKey('backup_path')) {
      context.handle(
        _backupPathMeta,
        backupPath.isAcceptableOrUnknown(data['backup_path']!, _backupPathMeta),
      );
    }
    if (data.containsKey('backup_password_salt')) {
      context.handle(
        _backupPasswordSaltMeta,
        backupPasswordSalt.isAcceptableOrUnknown(
          data['backup_password_salt']!,
          _backupPasswordSaltMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_backupPasswordSaltMeta);
    }
    if (data.containsKey('vault_version')) {
      context.handle(
        _vaultVersionMeta,
        vaultVersion.isAcceptableOrUnknown(
          data['vault_version']!,
          _vaultVersionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vaultVersionMeta);
    }
    if (data.containsKey('is_encrypted')) {
      context.handle(
        _isEncryptedMeta,
        isEncrypted.isAcceptableOrUnknown(
          data['is_encrypted']!,
          _isEncryptedMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {logId};
  @override
  BackupLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BackupLog(
      logId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}log_id'],
      )!,
      backupTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}backup_time'],
      )!,
      backupPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}backup_path'],
      ),
      backupPasswordSalt: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}backup_password_salt'],
      )!,
      vaultVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vault_version'],
      )!,
      isEncrypted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_encrypted'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BackupLogsTable createAlias(String alias) {
    return $BackupLogsTable(attachedDatabase, alias);
  }
}

class BackupLog extends DataClass implements Insertable<BackupLog> {
  final String logId;
  final DateTime backupTime;
  final String? backupPath;
  final Uint8List backupPasswordSalt;
  final int vaultVersion;
  final bool isEncrypted;
  final String? note;
  final DateTime createdAt;
  const BackupLog({
    required this.logId,
    required this.backupTime,
    this.backupPath,
    required this.backupPasswordSalt,
    required this.vaultVersion,
    required this.isEncrypted,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['log_id'] = Variable<String>(logId);
    map['backup_time'] = Variable<DateTime>(backupTime);
    if (!nullToAbsent || backupPath != null) {
      map['backup_path'] = Variable<String>(backupPath);
    }
    map['backup_password_salt'] = Variable<Uint8List>(backupPasswordSalt);
    map['vault_version'] = Variable<int>(vaultVersion);
    map['is_encrypted'] = Variable<bool>(isEncrypted);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BackupLogsCompanion toCompanion(bool nullToAbsent) {
    return BackupLogsCompanion(
      logId: Value(logId),
      backupTime: Value(backupTime),
      backupPath: backupPath == null && nullToAbsent
          ? const Value.absent()
          : Value(backupPath),
      backupPasswordSalt: Value(backupPasswordSalt),
      vaultVersion: Value(vaultVersion),
      isEncrypted: Value(isEncrypted),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory BackupLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BackupLog(
      logId: serializer.fromJson<String>(json['logId']),
      backupTime: serializer.fromJson<DateTime>(json['backupTime']),
      backupPath: serializer.fromJson<String?>(json['backupPath']),
      backupPasswordSalt: serializer.fromJson<Uint8List>(
        json['backupPasswordSalt'],
      ),
      vaultVersion: serializer.fromJson<int>(json['vaultVersion']),
      isEncrypted: serializer.fromJson<bool>(json['isEncrypted']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'logId': serializer.toJson<String>(logId),
      'backupTime': serializer.toJson<DateTime>(backupTime),
      'backupPath': serializer.toJson<String?>(backupPath),
      'backupPasswordSalt': serializer.toJson<Uint8List>(backupPasswordSalt),
      'vaultVersion': serializer.toJson<int>(vaultVersion),
      'isEncrypted': serializer.toJson<bool>(isEncrypted),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BackupLog copyWith({
    String? logId,
    DateTime? backupTime,
    Value<String?> backupPath = const Value.absent(),
    Uint8List? backupPasswordSalt,
    int? vaultVersion,
    bool? isEncrypted,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => BackupLog(
    logId: logId ?? this.logId,
    backupTime: backupTime ?? this.backupTime,
    backupPath: backupPath.present ? backupPath.value : this.backupPath,
    backupPasswordSalt: backupPasswordSalt ?? this.backupPasswordSalt,
    vaultVersion: vaultVersion ?? this.vaultVersion,
    isEncrypted: isEncrypted ?? this.isEncrypted,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  BackupLog copyWithCompanion(BackupLogsCompanion data) {
    return BackupLog(
      logId: data.logId.present ? data.logId.value : this.logId,
      backupTime: data.backupTime.present
          ? data.backupTime.value
          : this.backupTime,
      backupPath: data.backupPath.present
          ? data.backupPath.value
          : this.backupPath,
      backupPasswordSalt: data.backupPasswordSalt.present
          ? data.backupPasswordSalt.value
          : this.backupPasswordSalt,
      vaultVersion: data.vaultVersion.present
          ? data.vaultVersion.value
          : this.vaultVersion,
      isEncrypted: data.isEncrypted.present
          ? data.isEncrypted.value
          : this.isEncrypted,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BackupLog(')
          ..write('logId: $logId, ')
          ..write('backupTime: $backupTime, ')
          ..write('backupPath: $backupPath, ')
          ..write('backupPasswordSalt: $backupPasswordSalt, ')
          ..write('vaultVersion: $vaultVersion, ')
          ..write('isEncrypted: $isEncrypted, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    logId,
    backupTime,
    backupPath,
    $driftBlobEquality.hash(backupPasswordSalt),
    vaultVersion,
    isEncrypted,
    note,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BackupLog &&
          other.logId == this.logId &&
          other.backupTime == this.backupTime &&
          other.backupPath == this.backupPath &&
          $driftBlobEquality.equals(
            other.backupPasswordSalt,
            this.backupPasswordSalt,
          ) &&
          other.vaultVersion == this.vaultVersion &&
          other.isEncrypted == this.isEncrypted &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class BackupLogsCompanion extends UpdateCompanion<BackupLog> {
  final Value<String> logId;
  final Value<DateTime> backupTime;
  final Value<String?> backupPath;
  final Value<Uint8List> backupPasswordSalt;
  final Value<int> vaultVersion;
  final Value<bool> isEncrypted;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const BackupLogsCompanion({
    this.logId = const Value.absent(),
    this.backupTime = const Value.absent(),
    this.backupPath = const Value.absent(),
    this.backupPasswordSalt = const Value.absent(),
    this.vaultVersion = const Value.absent(),
    this.isEncrypted = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BackupLogsCompanion.insert({
    required String logId,
    required DateTime backupTime,
    this.backupPath = const Value.absent(),
    required Uint8List backupPasswordSalt,
    required int vaultVersion,
    this.isEncrypted = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : logId = Value(logId),
       backupTime = Value(backupTime),
       backupPasswordSalt = Value(backupPasswordSalt),
       vaultVersion = Value(vaultVersion),
       createdAt = Value(createdAt);
  static Insertable<BackupLog> custom({
    Expression<String>? logId,
    Expression<DateTime>? backupTime,
    Expression<String>? backupPath,
    Expression<Uint8List>? backupPasswordSalt,
    Expression<int>? vaultVersion,
    Expression<bool>? isEncrypted,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (logId != null) 'log_id': logId,
      if (backupTime != null) 'backup_time': backupTime,
      if (backupPath != null) 'backup_path': backupPath,
      if (backupPasswordSalt != null)
        'backup_password_salt': backupPasswordSalt,
      if (vaultVersion != null) 'vault_version': vaultVersion,
      if (isEncrypted != null) 'is_encrypted': isEncrypted,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BackupLogsCompanion copyWith({
    Value<String>? logId,
    Value<DateTime>? backupTime,
    Value<String?>? backupPath,
    Value<Uint8List>? backupPasswordSalt,
    Value<int>? vaultVersion,
    Value<bool>? isEncrypted,
    Value<String?>? note,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return BackupLogsCompanion(
      logId: logId ?? this.logId,
      backupTime: backupTime ?? this.backupTime,
      backupPath: backupPath ?? this.backupPath,
      backupPasswordSalt: backupPasswordSalt ?? this.backupPasswordSalt,
      vaultVersion: vaultVersion ?? this.vaultVersion,
      isEncrypted: isEncrypted ?? this.isEncrypted,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (logId.present) {
      map['log_id'] = Variable<String>(logId.value);
    }
    if (backupTime.present) {
      map['backup_time'] = Variable<DateTime>(backupTime.value);
    }
    if (backupPath.present) {
      map['backup_path'] = Variable<String>(backupPath.value);
    }
    if (backupPasswordSalt.present) {
      map['backup_password_salt'] = Variable<Uint8List>(
        backupPasswordSalt.value,
      );
    }
    if (vaultVersion.present) {
      map['vault_version'] = Variable<int>(vaultVersion.value);
    }
    if (isEncrypted.present) {
      map['is_encrypted'] = Variable<bool>(isEncrypted.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
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
    return (StringBuffer('BackupLogsCompanion(')
          ..write('logId: $logId, ')
          ..write('backupTime: $backupTime, ')
          ..write('backupPath: $backupPath, ')
          ..write('backupPasswordSalt: $backupPasswordSalt, ')
          ..write('vaultVersion: $vaultVersion, ')
          ..write('isEncrypted: $isEncrypted, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $VaultsTable vaults = $VaultsTable(this);
  late final $FoldersTable folders = $FoldersTable(this);
  late final $CipherEntriesTable cipherEntries = $CipherEntriesTable(this);
  late final $CipherAttachmentsTable cipherAttachments =
      $CipherAttachmentsTable(this);
  late final $BackupLogsTable backupLogs = $BackupLogsTable(this);
  late final Index idxVaultOwner = Index(
    'idx_vault_owner',
    'CREATE INDEX idx_vault_owner ON vault (owner_account_id)',
  );
  late final Index idxFolderVault = Index(
    'idx_folder_vault',
    'CREATE INDEX idx_folder_vault ON folder (vault_uuid)',
  );
  late final Index idxCipherVault = Index(
    'idx_cipher_vault',
    'CREATE INDEX idx_cipher_vault ON cipher (vault_uuid)',
  );
  late final Index idxCipherRevision = Index(
    'idx_cipher_revision',
    'CREATE INDEX idx_cipher_revision ON cipher (sync_revision)',
  );
  late final Index idxCipherDeleted = Index(
    'idx_cipher_deleted',
    'CREATE INDEX idx_cipher_deleted ON cipher (deleted_at)',
  );
  late final Index idxAttachCipher = Index(
    'idx_attach_cipher',
    'CREATE INDEX idx_attach_cipher ON cipher_attachment (cipher_uuid)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    vaults,
    folders,
    cipherEntries,
    cipherAttachments,
    backupLogs,
    idxVaultOwner,
    idxFolderVault,
    idxCipherVault,
    idxCipherRevision,
    idxCipherDeleted,
    idxAttachCipher,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vault',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('folder', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vault',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('cipher', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'folder',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('cipher', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cipher',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('cipher_attachment', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$VaultsTableCreateCompanionBuilder =
    VaultsCompanion Function({
      required String vaultUuid,
      Value<String?> ownerAccountId,
      required Uint8List name,
      Value<String?> iconName,
      Value<String?> colorHex,
      Value<bool> isPersonal,
      Value<bool> isTrashed,
      required DateTime syncRevision,
      Value<bool> localModified,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$VaultsTableUpdateCompanionBuilder =
    VaultsCompanion Function({
      Value<String> vaultUuid,
      Value<String?> ownerAccountId,
      Value<Uint8List> name,
      Value<String?> iconName,
      Value<String?> colorHex,
      Value<bool> isPersonal,
      Value<bool> isTrashed,
      Value<DateTime> syncRevision,
      Value<bool> localModified,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$VaultsTableReferences
    extends BaseReferences<_$AppDatabase, $VaultsTable, Vault> {
  $$VaultsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FoldersTable, List<Folder>> _foldersRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.folders,
    aliasName: 'vault__vault_uuid__folder__vault_uuid',
  );

  $$FoldersTableProcessedTableManager get foldersRefs {
    final manager = $$FoldersTableTableManager($_db, $_db.folders).filter(
      (f) =>
          f.vaultUuid.vaultUuid.sqlEquals($_itemColumn<String>('vault_uuid')!),
    );

    final cache = $_typedResult.readTableOrNull(_foldersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CipherEntriesTable, List<CipherEntry>>
  _cipherEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cipherEntries,
    aliasName: 'vault__vault_uuid__cipher__vault_uuid',
  );

  $$CipherEntriesTableProcessedTableManager get cipherEntriesRefs {
    final manager = $$CipherEntriesTableTableManager($_db, $_db.cipherEntries)
        .filter(
          (f) => f.vaultUuid.vaultUuid.sqlEquals(
            $_itemColumn<String>('vault_uuid')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_cipherEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VaultsTableFilterComposer
    extends Composer<_$AppDatabase, $VaultsTable> {
  $$VaultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get vaultUuid => $composableBuilder(
    column: $table.vaultUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerAccountId => $composableBuilder(
    column: $table.ownerAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPersonal => $composableBuilder(
    column: $table.isPersonal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTrashed => $composableBuilder(
    column: $table.isTrashed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncRevision => $composableBuilder(
    column: $table.syncRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get localModified => $composableBuilder(
    column: $table.localModified,
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

  Expression<bool> foldersRefs(
    Expression<bool> Function($$FoldersTableFilterComposer f) f,
  ) {
    final $$FoldersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultUuid,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.vaultUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableFilterComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> cipherEntriesRefs(
    Expression<bool> Function($$CipherEntriesTableFilterComposer f) f,
  ) {
    final $$CipherEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultUuid,
      referencedTable: $db.cipherEntries,
      getReferencedColumn: (t) => t.vaultUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CipherEntriesTableFilterComposer(
            $db: $db,
            $table: $db.cipherEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VaultsTableOrderingComposer
    extends Composer<_$AppDatabase, $VaultsTable> {
  $$VaultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get vaultUuid => $composableBuilder(
    column: $table.vaultUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerAccountId => $composableBuilder(
    column: $table.ownerAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconName => $composableBuilder(
    column: $table.iconName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPersonal => $composableBuilder(
    column: $table.isPersonal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTrashed => $composableBuilder(
    column: $table.isTrashed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncRevision => $composableBuilder(
    column: $table.syncRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get localModified => $composableBuilder(
    column: $table.localModified,
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

class $$VaultsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VaultsTable> {
  $$VaultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get vaultUuid =>
      $composableBuilder(column: $table.vaultUuid, builder: (column) => column);

  GeneratedColumn<String> get ownerAccountId => $composableBuilder(
    column: $table.ownerAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<bool> get isPersonal => $composableBuilder(
    column: $table.isPersonal,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isTrashed =>
      $composableBuilder(column: $table.isTrashed, builder: (column) => column);

  GeneratedColumn<DateTime> get syncRevision => $composableBuilder(
    column: $table.syncRevision,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get localModified => $composableBuilder(
    column: $table.localModified,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> foldersRefs<T extends Object>(
    Expression<T> Function($$FoldersTableAnnotationComposer a) f,
  ) {
    final $$FoldersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultUuid,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.vaultUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableAnnotationComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> cipherEntriesRefs<T extends Object>(
    Expression<T> Function($$CipherEntriesTableAnnotationComposer a) f,
  ) {
    final $$CipherEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultUuid,
      referencedTable: $db.cipherEntries,
      getReferencedColumn: (t) => t.vaultUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CipherEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.cipherEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VaultsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VaultsTable,
          Vault,
          $$VaultsTableFilterComposer,
          $$VaultsTableOrderingComposer,
          $$VaultsTableAnnotationComposer,
          $$VaultsTableCreateCompanionBuilder,
          $$VaultsTableUpdateCompanionBuilder,
          (Vault, $$VaultsTableReferences),
          Vault,
          PrefetchHooks Function({bool foldersRefs, bool cipherEntriesRefs})
        > {
  $$VaultsTableTableManager(_$AppDatabase db, $VaultsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VaultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VaultsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VaultsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> vaultUuid = const Value.absent(),
                Value<String?> ownerAccountId = const Value.absent(),
                Value<Uint8List> name = const Value.absent(),
                Value<String?> iconName = const Value.absent(),
                Value<String?> colorHex = const Value.absent(),
                Value<bool> isPersonal = const Value.absent(),
                Value<bool> isTrashed = const Value.absent(),
                Value<DateTime> syncRevision = const Value.absent(),
                Value<bool> localModified = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VaultsCompanion(
                vaultUuid: vaultUuid,
                ownerAccountId: ownerAccountId,
                name: name,
                iconName: iconName,
                colorHex: colorHex,
                isPersonal: isPersonal,
                isTrashed: isTrashed,
                syncRevision: syncRevision,
                localModified: localModified,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String vaultUuid,
                Value<String?> ownerAccountId = const Value.absent(),
                required Uint8List name,
                Value<String?> iconName = const Value.absent(),
                Value<String?> colorHex = const Value.absent(),
                Value<bool> isPersonal = const Value.absent(),
                Value<bool> isTrashed = const Value.absent(),
                required DateTime syncRevision,
                Value<bool> localModified = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => VaultsCompanion.insert(
                vaultUuid: vaultUuid,
                ownerAccountId: ownerAccountId,
                name: name,
                iconName: iconName,
                colorHex: colorHex,
                isPersonal: isPersonal,
                isTrashed: isTrashed,
                syncRevision: syncRevision,
                localModified: localModified,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$VaultsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({foldersRefs = false, cipherEntriesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (foldersRefs) db.folders,
                    if (cipherEntriesRefs) db.cipherEntries,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (foldersRefs)
                        await $_getPrefetchedData<Vault, $VaultsTable, Folder>(
                          currentTable: table,
                          referencedTable: $$VaultsTableReferences
                              ._foldersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VaultsTableReferences(
                                db,
                                table,
                                p0,
                              ).foldersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vaultUuid == item.vaultUuid,
                              ),
                          typedResults: items,
                        ),
                      if (cipherEntriesRefs)
                        await $_getPrefetchedData<
                          Vault,
                          $VaultsTable,
                          CipherEntry
                        >(
                          currentTable: table,
                          referencedTable: $$VaultsTableReferences
                              ._cipherEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VaultsTableReferences(
                                db,
                                table,
                                p0,
                              ).cipherEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vaultUuid == item.vaultUuid,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$VaultsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VaultsTable,
      Vault,
      $$VaultsTableFilterComposer,
      $$VaultsTableOrderingComposer,
      $$VaultsTableAnnotationComposer,
      $$VaultsTableCreateCompanionBuilder,
      $$VaultsTableUpdateCompanionBuilder,
      (Vault, $$VaultsTableReferences),
      Vault,
      PrefetchHooks Function({bool foldersRefs, bool cipherEntriesRefs})
    >;
typedef $$FoldersTableCreateCompanionBuilder =
    FoldersCompanion Function({
      required String folderUuid,
      required String vaultUuid,
      Value<String?> ownerAccountId,
      required Uint8List name,
      Value<bool> isTrashed,
      required DateTime syncRevision,
      Value<bool> localModified,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$FoldersTableUpdateCompanionBuilder =
    FoldersCompanion Function({
      Value<String> folderUuid,
      Value<String> vaultUuid,
      Value<String?> ownerAccountId,
      Value<Uint8List> name,
      Value<bool> isTrashed,
      Value<DateTime> syncRevision,
      Value<bool> localModified,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$FoldersTableReferences
    extends BaseReferences<_$AppDatabase, $FoldersTable, Folder> {
  $$FoldersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $VaultsTable _vaultUuidTable(_$AppDatabase db) =>
      db.vaults.createAlias('folder__vault_uuid__vault__vault_uuid');

  $$VaultsTableProcessedTableManager get vaultUuid {
    final $_column = $_itemColumn<String>('vault_uuid')!;

    final manager = $$VaultsTableTableManager(
      $_db,
      $_db.vaults,
    ).filter((f) => f.vaultUuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vaultUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CipherEntriesTable, List<CipherEntry>>
  _cipherEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cipherEntries,
    aliasName: 'folder__folder_uuid__cipher__folder_uuid',
  );

  $$CipherEntriesTableProcessedTableManager get cipherEntriesRefs {
    final manager = $$CipherEntriesTableTableManager($_db, $_db.cipherEntries)
        .filter(
          (f) => f.folderUuid.folderUuid.sqlEquals(
            $_itemColumn<String>('folder_uuid')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(_cipherEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FoldersTableFilterComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get folderUuid => $composableBuilder(
    column: $table.folderUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerAccountId => $composableBuilder(
    column: $table.ownerAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTrashed => $composableBuilder(
    column: $table.isTrashed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncRevision => $composableBuilder(
    column: $table.syncRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get localModified => $composableBuilder(
    column: $table.localModified,
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

  $$VaultsTableFilterComposer get vaultUuid {
    final $$VaultsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultUuid,
      referencedTable: $db.vaults,
      getReferencedColumn: (t) => t.vaultUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VaultsTableFilterComposer(
            $db: $db,
            $table: $db.vaults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> cipherEntriesRefs(
    Expression<bool> Function($$CipherEntriesTableFilterComposer f) f,
  ) {
    final $$CipherEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderUuid,
      referencedTable: $db.cipherEntries,
      getReferencedColumn: (t) => t.folderUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CipherEntriesTableFilterComposer(
            $db: $db,
            $table: $db.cipherEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoldersTableOrderingComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get folderUuid => $composableBuilder(
    column: $table.folderUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerAccountId => $composableBuilder(
    column: $table.ownerAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTrashed => $composableBuilder(
    column: $table.isTrashed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncRevision => $composableBuilder(
    column: $table.syncRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get localModified => $composableBuilder(
    column: $table.localModified,
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

  $$VaultsTableOrderingComposer get vaultUuid {
    final $$VaultsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultUuid,
      referencedTable: $db.vaults,
      getReferencedColumn: (t) => t.vaultUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VaultsTableOrderingComposer(
            $db: $db,
            $table: $db.vaults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FoldersTableAnnotationComposer
    extends Composer<_$AppDatabase, $FoldersTable> {
  $$FoldersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get folderUuid => $composableBuilder(
    column: $table.folderUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerAccountId => $composableBuilder(
    column: $table.ownerAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isTrashed =>
      $composableBuilder(column: $table.isTrashed, builder: (column) => column);

  GeneratedColumn<DateTime> get syncRevision => $composableBuilder(
    column: $table.syncRevision,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get localModified => $composableBuilder(
    column: $table.localModified,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$VaultsTableAnnotationComposer get vaultUuid {
    final $$VaultsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultUuid,
      referencedTable: $db.vaults,
      getReferencedColumn: (t) => t.vaultUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VaultsTableAnnotationComposer(
            $db: $db,
            $table: $db.vaults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> cipherEntriesRefs<T extends Object>(
    Expression<T> Function($$CipherEntriesTableAnnotationComposer a) f,
  ) {
    final $$CipherEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderUuid,
      referencedTable: $db.cipherEntries,
      getReferencedColumn: (t) => t.folderUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CipherEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.cipherEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FoldersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FoldersTable,
          Folder,
          $$FoldersTableFilterComposer,
          $$FoldersTableOrderingComposer,
          $$FoldersTableAnnotationComposer,
          $$FoldersTableCreateCompanionBuilder,
          $$FoldersTableUpdateCompanionBuilder,
          (Folder, $$FoldersTableReferences),
          Folder,
          PrefetchHooks Function({bool vaultUuid, bool cipherEntriesRefs})
        > {
  $$FoldersTableTableManager(_$AppDatabase db, $FoldersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FoldersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FoldersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FoldersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> folderUuid = const Value.absent(),
                Value<String> vaultUuid = const Value.absent(),
                Value<String?> ownerAccountId = const Value.absent(),
                Value<Uint8List> name = const Value.absent(),
                Value<bool> isTrashed = const Value.absent(),
                Value<DateTime> syncRevision = const Value.absent(),
                Value<bool> localModified = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FoldersCompanion(
                folderUuid: folderUuid,
                vaultUuid: vaultUuid,
                ownerAccountId: ownerAccountId,
                name: name,
                isTrashed: isTrashed,
                syncRevision: syncRevision,
                localModified: localModified,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String folderUuid,
                required String vaultUuid,
                Value<String?> ownerAccountId = const Value.absent(),
                required Uint8List name,
                Value<bool> isTrashed = const Value.absent(),
                required DateTime syncRevision,
                Value<bool> localModified = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => FoldersCompanion.insert(
                folderUuid: folderUuid,
                vaultUuid: vaultUuid,
                ownerAccountId: ownerAccountId,
                name: name,
                isTrashed: isTrashed,
                syncRevision: syncRevision,
                localModified: localModified,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FoldersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({vaultUuid = false, cipherEntriesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (cipherEntriesRefs) db.cipherEntries,
                  ],
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
                        if (vaultUuid) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.vaultUuid,
                                    referencedTable: $$FoldersTableReferences
                                        ._vaultUuidTable(db),
                                    referencedColumn: $$FoldersTableReferences
                                        ._vaultUuidTable(db)
                                        .vaultUuid,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (cipherEntriesRefs)
                        await $_getPrefetchedData<
                          Folder,
                          $FoldersTable,
                          CipherEntry
                        >(
                          currentTable: table,
                          referencedTable: $$FoldersTableReferences
                              ._cipherEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FoldersTableReferences(
                                db,
                                table,
                                p0,
                              ).cipherEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.folderUuid == item.folderUuid,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$FoldersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FoldersTable,
      Folder,
      $$FoldersTableFilterComposer,
      $$FoldersTableOrderingComposer,
      $$FoldersTableAnnotationComposer,
      $$FoldersTableCreateCompanionBuilder,
      $$FoldersTableUpdateCompanionBuilder,
      (Folder, $$FoldersTableReferences),
      Folder,
      PrefetchHooks Function({bool vaultUuid, bool cipherEntriesRefs})
    >;
typedef $$CipherEntriesTableCreateCompanionBuilder =
    CipherEntriesCompanion Function({
      required String cipherUuid,
      required String vaultUuid,
      Value<String?> folderUuid,
      Value<String?> ownerAccountId,
      required int type,
      required Uint8List overviewBlob,
      required Uint8List fullDataBlob,
      Value<bool> isFavorite,
      Value<DateTime?> deletedAt,
      required DateTime syncRevision,
      Value<bool> localModified,
      Value<String?> remoteId,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$CipherEntriesTableUpdateCompanionBuilder =
    CipherEntriesCompanion Function({
      Value<String> cipherUuid,
      Value<String> vaultUuid,
      Value<String?> folderUuid,
      Value<String?> ownerAccountId,
      Value<int> type,
      Value<Uint8List> overviewBlob,
      Value<Uint8List> fullDataBlob,
      Value<bool> isFavorite,
      Value<DateTime?> deletedAt,
      Value<DateTime> syncRevision,
      Value<bool> localModified,
      Value<String?> remoteId,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$CipherEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $CipherEntriesTable, CipherEntry> {
  $$CipherEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $VaultsTable _vaultUuidTable(_$AppDatabase db) =>
      db.vaults.createAlias('cipher__vault_uuid__vault__vault_uuid');

  $$VaultsTableProcessedTableManager get vaultUuid {
    final $_column = $_itemColumn<String>('vault_uuid')!;

    final manager = $$VaultsTableTableManager(
      $_db,
      $_db.vaults,
    ).filter((f) => f.vaultUuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vaultUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FoldersTable _folderUuidTable(_$AppDatabase db) =>
      db.folders.createAlias('cipher__folder_uuid__folder__folder_uuid');

  $$FoldersTableProcessedTableManager? get folderUuid {
    final $_column = $_itemColumn<String>('folder_uuid');
    if ($_column == null) return null;
    final manager = $$FoldersTableTableManager(
      $_db,
      $_db.folders,
    ).filter((f) => f.folderUuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_folderUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CipherAttachmentsTable, List<CipherAttachment>>
  _cipherAttachmentsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.cipherAttachments,
        aliasName: 'cipher__cipher_uuid__cipher_attachment__cipher_uuid',
      );

  $$CipherAttachmentsTableProcessedTableManager get cipherAttachmentsRefs {
    final manager =
        $$CipherAttachmentsTableTableManager(
          $_db,
          $_db.cipherAttachments,
        ).filter(
          (f) => f.cipherUuid.cipherUuid.sqlEquals(
            $_itemColumn<String>('cipher_uuid')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _cipherAttachmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CipherEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $CipherEntriesTable> {
  $$CipherEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cipherUuid => $composableBuilder(
    column: $table.cipherUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerAccountId => $composableBuilder(
    column: $table.ownerAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get overviewBlob => $composableBuilder(
    column: $table.overviewBlob,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get fullDataBlob => $composableBuilder(
    column: $table.fullDataBlob,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncRevision => $composableBuilder(
    column: $table.syncRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get localModified => $composableBuilder(
    column: $table.localModified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
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

  $$VaultsTableFilterComposer get vaultUuid {
    final $$VaultsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultUuid,
      referencedTable: $db.vaults,
      getReferencedColumn: (t) => t.vaultUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VaultsTableFilterComposer(
            $db: $db,
            $table: $db.vaults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FoldersTableFilterComposer get folderUuid {
    final $$FoldersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderUuid,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.folderUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableFilterComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> cipherAttachmentsRefs(
    Expression<bool> Function($$CipherAttachmentsTableFilterComposer f) f,
  ) {
    final $$CipherAttachmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cipherUuid,
      referencedTable: $db.cipherAttachments,
      getReferencedColumn: (t) => t.cipherUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CipherAttachmentsTableFilterComposer(
            $db: $db,
            $table: $db.cipherAttachments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CipherEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CipherEntriesTable> {
  $$CipherEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cipherUuid => $composableBuilder(
    column: $table.cipherUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerAccountId => $composableBuilder(
    column: $table.ownerAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get overviewBlob => $composableBuilder(
    column: $table.overviewBlob,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get fullDataBlob => $composableBuilder(
    column: $table.fullDataBlob,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncRevision => $composableBuilder(
    column: $table.syncRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get localModified => $composableBuilder(
    column: $table.localModified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remoteId => $composableBuilder(
    column: $table.remoteId,
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

  $$VaultsTableOrderingComposer get vaultUuid {
    final $$VaultsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultUuid,
      referencedTable: $db.vaults,
      getReferencedColumn: (t) => t.vaultUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VaultsTableOrderingComposer(
            $db: $db,
            $table: $db.vaults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FoldersTableOrderingComposer get folderUuid {
    final $$FoldersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderUuid,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.folderUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableOrderingComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CipherEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CipherEntriesTable> {
  $$CipherEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cipherUuid => $composableBuilder(
    column: $table.cipherUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerAccountId => $composableBuilder(
    column: $table.ownerAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<Uint8List> get overviewBlob => $composableBuilder(
    column: $table.overviewBlob,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get fullDataBlob => $composableBuilder(
    column: $table.fullDataBlob,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get syncRevision => $composableBuilder(
    column: $table.syncRevision,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get localModified => $composableBuilder(
    column: $table.localModified,
    builder: (column) => column,
  );

  GeneratedColumn<String> get remoteId =>
      $composableBuilder(column: $table.remoteId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$VaultsTableAnnotationComposer get vaultUuid {
    final $$VaultsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vaultUuid,
      referencedTable: $db.vaults,
      getReferencedColumn: (t) => t.vaultUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VaultsTableAnnotationComposer(
            $db: $db,
            $table: $db.vaults,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FoldersTableAnnotationComposer get folderUuid {
    final $$FoldersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.folderUuid,
      referencedTable: $db.folders,
      getReferencedColumn: (t) => t.folderUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FoldersTableAnnotationComposer(
            $db: $db,
            $table: $db.folders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> cipherAttachmentsRefs<T extends Object>(
    Expression<T> Function($$CipherAttachmentsTableAnnotationComposer a) f,
  ) {
    final $$CipherAttachmentsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.cipherUuid,
          referencedTable: $db.cipherAttachments,
          getReferencedColumn: (t) => t.cipherUuid,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CipherAttachmentsTableAnnotationComposer(
                $db: $db,
                $table: $db.cipherAttachments,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$CipherEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CipherEntriesTable,
          CipherEntry,
          $$CipherEntriesTableFilterComposer,
          $$CipherEntriesTableOrderingComposer,
          $$CipherEntriesTableAnnotationComposer,
          $$CipherEntriesTableCreateCompanionBuilder,
          $$CipherEntriesTableUpdateCompanionBuilder,
          (CipherEntry, $$CipherEntriesTableReferences),
          CipherEntry,
          PrefetchHooks Function({
            bool vaultUuid,
            bool folderUuid,
            bool cipherAttachmentsRefs,
          })
        > {
  $$CipherEntriesTableTableManager(_$AppDatabase db, $CipherEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CipherEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CipherEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CipherEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cipherUuid = const Value.absent(),
                Value<String> vaultUuid = const Value.absent(),
                Value<String?> folderUuid = const Value.absent(),
                Value<String?> ownerAccountId = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<Uint8List> overviewBlob = const Value.absent(),
                Value<Uint8List> fullDataBlob = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<DateTime> syncRevision = const Value.absent(),
                Value<bool> localModified = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CipherEntriesCompanion(
                cipherUuid: cipherUuid,
                vaultUuid: vaultUuid,
                folderUuid: folderUuid,
                ownerAccountId: ownerAccountId,
                type: type,
                overviewBlob: overviewBlob,
                fullDataBlob: fullDataBlob,
                isFavorite: isFavorite,
                deletedAt: deletedAt,
                syncRevision: syncRevision,
                localModified: localModified,
                remoteId: remoteId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cipherUuid,
                required String vaultUuid,
                Value<String?> folderUuid = const Value.absent(),
                Value<String?> ownerAccountId = const Value.absent(),
                required int type,
                required Uint8List overviewBlob,
                required Uint8List fullDataBlob,
                Value<bool> isFavorite = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                required DateTime syncRevision,
                Value<bool> localModified = const Value.absent(),
                Value<String?> remoteId = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CipherEntriesCompanion.insert(
                cipherUuid: cipherUuid,
                vaultUuid: vaultUuid,
                folderUuid: folderUuid,
                ownerAccountId: ownerAccountId,
                type: type,
                overviewBlob: overviewBlob,
                fullDataBlob: fullDataBlob,
                isFavorite: isFavorite,
                deletedAt: deletedAt,
                syncRevision: syncRevision,
                localModified: localModified,
                remoteId: remoteId,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CipherEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                vaultUuid = false,
                folderUuid = false,
                cipherAttachmentsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (cipherAttachmentsRefs) db.cipherAttachments,
                  ],
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
                        if (vaultUuid) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.vaultUuid,
                                    referencedTable:
                                        $$CipherEntriesTableReferences
                                            ._vaultUuidTable(db),
                                    referencedColumn:
                                        $$CipherEntriesTableReferences
                                            ._vaultUuidTable(db)
                                            .vaultUuid,
                                  )
                                  as T;
                        }
                        if (folderUuid) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.folderUuid,
                                    referencedTable:
                                        $$CipherEntriesTableReferences
                                            ._folderUuidTable(db),
                                    referencedColumn:
                                        $$CipherEntriesTableReferences
                                            ._folderUuidTable(db)
                                            .folderUuid,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (cipherAttachmentsRefs)
                        await $_getPrefetchedData<
                          CipherEntry,
                          $CipherEntriesTable,
                          CipherAttachment
                        >(
                          currentTable: table,
                          referencedTable: $$CipherEntriesTableReferences
                              ._cipherAttachmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CipherEntriesTableReferences(
                                db,
                                table,
                                p0,
                              ).cipherAttachmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cipherUuid == item.cipherUuid,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CipherEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CipherEntriesTable,
      CipherEntry,
      $$CipherEntriesTableFilterComposer,
      $$CipherEntriesTableOrderingComposer,
      $$CipherEntriesTableAnnotationComposer,
      $$CipherEntriesTableCreateCompanionBuilder,
      $$CipherEntriesTableUpdateCompanionBuilder,
      (CipherEntry, $$CipherEntriesTableReferences),
      CipherEntry,
      PrefetchHooks Function({
        bool vaultUuid,
        bool folderUuid,
        bool cipherAttachmentsRefs,
      })
    >;
typedef $$CipherAttachmentsTableCreateCompanionBuilder =
    CipherAttachmentsCompanion Function({
      required String attachUuid,
      required String cipherUuid,
      Value<String?> ownerAccountId,
      required Uint8List fileName,
      required Uint8List encryptedFile,
      required int fileSize,
      required DateTime syncRevision,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$CipherAttachmentsTableUpdateCompanionBuilder =
    CipherAttachmentsCompanion Function({
      Value<String> attachUuid,
      Value<String> cipherUuid,
      Value<String?> ownerAccountId,
      Value<Uint8List> fileName,
      Value<Uint8List> encryptedFile,
      Value<int> fileSize,
      Value<DateTime> syncRevision,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$CipherAttachmentsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CipherAttachmentsTable,
          CipherAttachment
        > {
  $$CipherAttachmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CipherEntriesTable _cipherUuidTable(_$AppDatabase db) => db
      .cipherEntries
      .createAlias('cipher_attachment__cipher_uuid__cipher__cipher_uuid');

  $$CipherEntriesTableProcessedTableManager get cipherUuid {
    final $_column = $_itemColumn<String>('cipher_uuid')!;

    final manager = $$CipherEntriesTableTableManager(
      $_db,
      $_db.cipherEntries,
    ).filter((f) => f.cipherUuid.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cipherUuidTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CipherAttachmentsTableFilterComposer
    extends Composer<_$AppDatabase, $CipherAttachmentsTable> {
  $$CipherAttachmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get attachUuid => $composableBuilder(
    column: $table.attachUuid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerAccountId => $composableBuilder(
    column: $table.ownerAccountId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get encryptedFile => $composableBuilder(
    column: $table.encryptedFile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncRevision => $composableBuilder(
    column: $table.syncRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CipherEntriesTableFilterComposer get cipherUuid {
    final $$CipherEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cipherUuid,
      referencedTable: $db.cipherEntries,
      getReferencedColumn: (t) => t.cipherUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CipherEntriesTableFilterComposer(
            $db: $db,
            $table: $db.cipherEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CipherAttachmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $CipherAttachmentsTable> {
  $$CipherAttachmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get attachUuid => $composableBuilder(
    column: $table.attachUuid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerAccountId => $composableBuilder(
    column: $table.ownerAccountId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get encryptedFile => $composableBuilder(
    column: $table.encryptedFile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncRevision => $composableBuilder(
    column: $table.syncRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CipherEntriesTableOrderingComposer get cipherUuid {
    final $$CipherEntriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cipherUuid,
      referencedTable: $db.cipherEntries,
      getReferencedColumn: (t) => t.cipherUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CipherEntriesTableOrderingComposer(
            $db: $db,
            $table: $db.cipherEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CipherAttachmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CipherAttachmentsTable> {
  $$CipherAttachmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get attachUuid => $composableBuilder(
    column: $table.attachUuid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ownerAccountId => $composableBuilder(
    column: $table.ownerAccountId,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<Uint8List> get encryptedFile => $composableBuilder(
    column: $table.encryptedFile,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumn<DateTime> get syncRevision => $composableBuilder(
    column: $table.syncRevision,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CipherEntriesTableAnnotationComposer get cipherUuid {
    final $$CipherEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cipherUuid,
      referencedTable: $db.cipherEntries,
      getReferencedColumn: (t) => t.cipherUuid,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CipherEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.cipherEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CipherAttachmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CipherAttachmentsTable,
          CipherAttachment,
          $$CipherAttachmentsTableFilterComposer,
          $$CipherAttachmentsTableOrderingComposer,
          $$CipherAttachmentsTableAnnotationComposer,
          $$CipherAttachmentsTableCreateCompanionBuilder,
          $$CipherAttachmentsTableUpdateCompanionBuilder,
          (CipherAttachment, $$CipherAttachmentsTableReferences),
          CipherAttachment,
          PrefetchHooks Function({bool cipherUuid})
        > {
  $$CipherAttachmentsTableTableManager(
    _$AppDatabase db,
    $CipherAttachmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CipherAttachmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CipherAttachmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CipherAttachmentsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> attachUuid = const Value.absent(),
                Value<String> cipherUuid = const Value.absent(),
                Value<String?> ownerAccountId = const Value.absent(),
                Value<Uint8List> fileName = const Value.absent(),
                Value<Uint8List> encryptedFile = const Value.absent(),
                Value<int> fileSize = const Value.absent(),
                Value<DateTime> syncRevision = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CipherAttachmentsCompanion(
                attachUuid: attachUuid,
                cipherUuid: cipherUuid,
                ownerAccountId: ownerAccountId,
                fileName: fileName,
                encryptedFile: encryptedFile,
                fileSize: fileSize,
                syncRevision: syncRevision,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String attachUuid,
                required String cipherUuid,
                Value<String?> ownerAccountId = const Value.absent(),
                required Uint8List fileName,
                required Uint8List encryptedFile,
                required int fileSize,
                required DateTime syncRevision,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CipherAttachmentsCompanion.insert(
                attachUuid: attachUuid,
                cipherUuid: cipherUuid,
                ownerAccountId: ownerAccountId,
                fileName: fileName,
                encryptedFile: encryptedFile,
                fileSize: fileSize,
                syncRevision: syncRevision,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CipherAttachmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({cipherUuid = false}) {
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
                    if (cipherUuid) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.cipherUuid,
                                referencedTable:
                                    $$CipherAttachmentsTableReferences
                                        ._cipherUuidTable(db),
                                referencedColumn:
                                    $$CipherAttachmentsTableReferences
                                        ._cipherUuidTable(db)
                                        .cipherUuid,
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

typedef $$CipherAttachmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CipherAttachmentsTable,
      CipherAttachment,
      $$CipherAttachmentsTableFilterComposer,
      $$CipherAttachmentsTableOrderingComposer,
      $$CipherAttachmentsTableAnnotationComposer,
      $$CipherAttachmentsTableCreateCompanionBuilder,
      $$CipherAttachmentsTableUpdateCompanionBuilder,
      (CipherAttachment, $$CipherAttachmentsTableReferences),
      CipherAttachment,
      PrefetchHooks Function({bool cipherUuid})
    >;
typedef $$BackupLogsTableCreateCompanionBuilder =
    BackupLogsCompanion Function({
      required String logId,
      required DateTime backupTime,
      Value<String?> backupPath,
      required Uint8List backupPasswordSalt,
      required int vaultVersion,
      Value<bool> isEncrypted,
      Value<String?> note,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$BackupLogsTableUpdateCompanionBuilder =
    BackupLogsCompanion Function({
      Value<String> logId,
      Value<DateTime> backupTime,
      Value<String?> backupPath,
      Value<Uint8List> backupPasswordSalt,
      Value<int> vaultVersion,
      Value<bool> isEncrypted,
      Value<String?> note,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$BackupLogsTableFilterComposer
    extends Composer<_$AppDatabase, $BackupLogsTable> {
  $$BackupLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get logId => $composableBuilder(
    column: $table.logId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get backupTime => $composableBuilder(
    column: $table.backupTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backupPath => $composableBuilder(
    column: $table.backupPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get backupPasswordSalt => $composableBuilder(
    column: $table.backupPasswordSalt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get vaultVersion => $composableBuilder(
    column: $table.vaultVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEncrypted => $composableBuilder(
    column: $table.isEncrypted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BackupLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $BackupLogsTable> {
  $$BackupLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get logId => $composableBuilder(
    column: $table.logId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get backupTime => $composableBuilder(
    column: $table.backupTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backupPath => $composableBuilder(
    column: $table.backupPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get backupPasswordSalt => $composableBuilder(
    column: $table.backupPasswordSalt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get vaultVersion => $composableBuilder(
    column: $table.vaultVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEncrypted => $composableBuilder(
    column: $table.isEncrypted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BackupLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BackupLogsTable> {
  $$BackupLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get logId =>
      $composableBuilder(column: $table.logId, builder: (column) => column);

  GeneratedColumn<DateTime> get backupTime => $composableBuilder(
    column: $table.backupTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get backupPath => $composableBuilder(
    column: $table.backupPath,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get backupPasswordSalt => $composableBuilder(
    column: $table.backupPasswordSalt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get vaultVersion => $composableBuilder(
    column: $table.vaultVersion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isEncrypted => $composableBuilder(
    column: $table.isEncrypted,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BackupLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BackupLogsTable,
          BackupLog,
          $$BackupLogsTableFilterComposer,
          $$BackupLogsTableOrderingComposer,
          $$BackupLogsTableAnnotationComposer,
          $$BackupLogsTableCreateCompanionBuilder,
          $$BackupLogsTableUpdateCompanionBuilder,
          (
            BackupLog,
            BaseReferences<_$AppDatabase, $BackupLogsTable, BackupLog>,
          ),
          BackupLog,
          PrefetchHooks Function()
        > {
  $$BackupLogsTableTableManager(_$AppDatabase db, $BackupLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BackupLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BackupLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BackupLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> logId = const Value.absent(),
                Value<DateTime> backupTime = const Value.absent(),
                Value<String?> backupPath = const Value.absent(),
                Value<Uint8List> backupPasswordSalt = const Value.absent(),
                Value<int> vaultVersion = const Value.absent(),
                Value<bool> isEncrypted = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BackupLogsCompanion(
                logId: logId,
                backupTime: backupTime,
                backupPath: backupPath,
                backupPasswordSalt: backupPasswordSalt,
                vaultVersion: vaultVersion,
                isEncrypted: isEncrypted,
                note: note,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String logId,
                required DateTime backupTime,
                Value<String?> backupPath = const Value.absent(),
                required Uint8List backupPasswordSalt,
                required int vaultVersion,
                Value<bool> isEncrypted = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => BackupLogsCompanion.insert(
                logId: logId,
                backupTime: backupTime,
                backupPath: backupPath,
                backupPasswordSalt: backupPasswordSalt,
                vaultVersion: vaultVersion,
                isEncrypted: isEncrypted,
                note: note,
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

typedef $$BackupLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BackupLogsTable,
      BackupLog,
      $$BackupLogsTableFilterComposer,
      $$BackupLogsTableOrderingComposer,
      $$BackupLogsTableAnnotationComposer,
      $$BackupLogsTableCreateCompanionBuilder,
      $$BackupLogsTableUpdateCompanionBuilder,
      (BackupLog, BaseReferences<_$AppDatabase, $BackupLogsTable, BackupLog>),
      BackupLog,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$VaultsTableTableManager get vaults =>
      $$VaultsTableTableManager(_db, _db.vaults);
  $$FoldersTableTableManager get folders =>
      $$FoldersTableTableManager(_db, _db.folders);
  $$CipherEntriesTableTableManager get cipherEntries =>
      $$CipherEntriesTableTableManager(_db, _db.cipherEntries);
  $$CipherAttachmentsTableTableManager get cipherAttachments =>
      $$CipherAttachmentsTableTableManager(_db, _db.cipherAttachments);
  $$BackupLogsTableTableManager get backupLogs =>
      $$BackupLogsTableTableManager(_db, _db.backupLogs);
}
