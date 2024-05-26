//
//  Generated code. Do not modify.
//  source: veilidchat.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class Availability extends $pb.ProtobufEnum {
  static const Availability AVAILABILITY_UNSPECIFIED = Availability._(0, _omitEnumNames ? '' : 'AVAILABILITY_UNSPECIFIED');
  static const Availability AVAILABILITY_OFFLINE = Availability._(1, _omitEnumNames ? '' : 'AVAILABILITY_OFFLINE');
  static const Availability AVAILABILITY_FREE = Availability._(2, _omitEnumNames ? '' : 'AVAILABILITY_FREE');
  static const Availability AVAILABILITY_BUSY = Availability._(3, _omitEnumNames ? '' : 'AVAILABILITY_BUSY');
  static const Availability AVAILABILITY_AWAY = Availability._(4, _omitEnumNames ? '' : 'AVAILABILITY_AWAY');

  static const $core.List<Availability> values = <Availability> [
    AVAILABILITY_UNSPECIFIED,
    AVAILABILITY_OFFLINE,
    AVAILABILITY_FREE,
    AVAILABILITY_BUSY,
    AVAILABILITY_AWAY,
  ];

  static final $core.Map<$core.int, Availability> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Availability? valueOf($core.int value) => _byValue[value];

  const Availability._($core.int v, $core.String n) : super(v, n);
}

class EncryptionKeyType extends $pb.ProtobufEnum {
  static const EncryptionKeyType ENCRYPTION_KEY_TYPE_UNSPECIFIED = EncryptionKeyType._(0, _omitEnumNames ? '' : 'ENCRYPTION_KEY_TYPE_UNSPECIFIED');
  static const EncryptionKeyType ENCRYPTION_KEY_TYPE_NONE = EncryptionKeyType._(1, _omitEnumNames ? '' : 'ENCRYPTION_KEY_TYPE_NONE');
  static const EncryptionKeyType ENCRYPTION_KEY_TYPE_PIN = EncryptionKeyType._(2, _omitEnumNames ? '' : 'ENCRYPTION_KEY_TYPE_PIN');
  static const EncryptionKeyType ENCRYPTION_KEY_TYPE_PASSWORD = EncryptionKeyType._(3, _omitEnumNames ? '' : 'ENCRYPTION_KEY_TYPE_PASSWORD');

  static const $core.List<EncryptionKeyType> values = <EncryptionKeyType> [
    ENCRYPTION_KEY_TYPE_UNSPECIFIED,
    ENCRYPTION_KEY_TYPE_NONE,
    ENCRYPTION_KEY_TYPE_PIN,
    ENCRYPTION_KEY_TYPE_PASSWORD,
  ];

  static final $core.Map<$core.int, EncryptionKeyType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static EncryptionKeyType? valueOf($core.int value) => _byValue[value];

  const EncryptionKeyType._($core.int v, $core.String n) : super(v, n);
}

class Scope extends $pb.ProtobufEnum {
  static const Scope WATCHERS = Scope._(0, _omitEnumNames ? '' : 'WATCHERS');
  static const Scope MODERATED = Scope._(1, _omitEnumNames ? '' : 'MODERATED');
  static const Scope TALKERS = Scope._(2, _omitEnumNames ? '' : 'TALKERS');
  static const Scope MODERATORS = Scope._(3, _omitEnumNames ? '' : 'MODERATORS');
  static const Scope ADMINS = Scope._(4, _omitEnumNames ? '' : 'ADMINS');

  static const $core.List<Scope> values = <Scope> [
    WATCHERS,
    MODERATED,
    TALKERS,
    MODERATORS,
    ADMINS,
  ];

  static final $core.Map<$core.int, Scope> _byValue = $pb.ProtobufEnum.initByValue(values);
  static Scope? valueOf($core.int value) => _byValue[value];

  const Scope._($core.int v, $core.String n) : super(v, n);
}


const _omitEnumNames = $core.bool.fromEnvironment('protobuf.omit_enum_names');
