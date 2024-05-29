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

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'package:veilid_support/proto/dht.pb.dart' as $1;
import 'package:veilid_support/proto/veilid.pb.dart' as $0;
import 'veilidchat.pbenum.dart';

export 'veilidchat.pbenum.dart';

enum Attachment_Kind {
  media, 
  notSet
}

class Attachment extends $pb.GeneratedMessage {
  factory Attachment() => create();
  Attachment._() : super();
  factory Attachment.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Attachment.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, Attachment_Kind> _Attachment_KindByTag = {
    1 : Attachment_Kind.media,
    0 : Attachment_Kind.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Attachment', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..oo(0, [1])
    ..aOM<AttachmentMedia>(1, _omitFieldNames ? '' : 'media', subBuilder: AttachmentMedia.create)
    ..aOM<$0.Signature>(2, _omitFieldNames ? '' : 'signature', subBuilder: $0.Signature.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Attachment clone() => Attachment()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Attachment copyWith(void Function(Attachment) updates) => super.copyWith((message) => updates(message as Attachment)) as Attachment;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Attachment create() => Attachment._();
  Attachment createEmptyInstance() => create();
  static $pb.PbList<Attachment> createRepeated() => $pb.PbList<Attachment>();
  @$core.pragma('dart2js:noInline')
  static Attachment getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Attachment>(create);
  static Attachment? _defaultInstance;

  Attachment_Kind whichKind() => _Attachment_KindByTag[$_whichOneof(0)]!;
  void clearKind() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  AttachmentMedia get media => $_getN(0);
  @$pb.TagNumber(1)
  set media(AttachmentMedia v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasMedia() => $_has(0);
  @$pb.TagNumber(1)
  void clearMedia() => clearField(1);
  @$pb.TagNumber(1)
  AttachmentMedia ensureMedia() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.Signature get signature => $_getN(1);
  @$pb.TagNumber(2)
  set signature($0.Signature v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasSignature() => $_has(1);
  @$pb.TagNumber(2)
  void clearSignature() => clearField(2);
  @$pb.TagNumber(2)
  $0.Signature ensureSignature() => $_ensure(1);
}

class AttachmentMedia extends $pb.GeneratedMessage {
  factory AttachmentMedia() => create();
  AttachmentMedia._() : super();
  factory AttachmentMedia.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AttachmentMedia.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'AttachmentMedia', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'mime')
    ..aOS(2, _omitFieldNames ? '' : 'name')
    ..aOM<$1.DataReference>(3, _omitFieldNames ? '' : 'content', subBuilder: $1.DataReference.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  AttachmentMedia clone() => AttachmentMedia()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  AttachmentMedia copyWith(void Function(AttachmentMedia) updates) => super.copyWith((message) => updates(message as AttachmentMedia)) as AttachmentMedia;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static AttachmentMedia create() => AttachmentMedia._();
  AttachmentMedia createEmptyInstance() => create();
  static $pb.PbList<AttachmentMedia> createRepeated() => $pb.PbList<AttachmentMedia>();
  @$core.pragma('dart2js:noInline')
  static AttachmentMedia getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AttachmentMedia>(create);
  static AttachmentMedia? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get mime => $_getSZ(0);
  @$pb.TagNumber(1)
  set mime($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasMime() => $_has(0);
  @$pb.TagNumber(1)
  void clearMime() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get name => $_getSZ(1);
  @$pb.TagNumber(2)
  set name($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasName() => $_has(1);
  @$pb.TagNumber(2)
  void clearName() => clearField(2);

  @$pb.TagNumber(3)
  $1.DataReference get content => $_getN(2);
  @$pb.TagNumber(3)
  set content($1.DataReference v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasContent() => $_has(2);
  @$pb.TagNumber(3)
  void clearContent() => clearField(3);
  @$pb.TagNumber(3)
  $1.DataReference ensureContent() => $_ensure(2);
}

class Permissions extends $pb.GeneratedMessage {
  factory Permissions() => create();
  Permissions._() : super();
  factory Permissions.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Permissions.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Permissions', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..e<Scope>(1, _omitFieldNames ? '' : 'canAddMembers', $pb.PbFieldType.OE, defaultOrMaker: Scope.WATCHERS, valueOf: Scope.valueOf, enumValues: Scope.values)
    ..e<Scope>(2, _omitFieldNames ? '' : 'canEditInfo', $pb.PbFieldType.OE, defaultOrMaker: Scope.WATCHERS, valueOf: Scope.valueOf, enumValues: Scope.values)
    ..aOB(3, _omitFieldNames ? '' : 'moderated')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Permissions clone() => Permissions()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Permissions copyWith(void Function(Permissions) updates) => super.copyWith((message) => updates(message as Permissions)) as Permissions;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Permissions create() => Permissions._();
  Permissions createEmptyInstance() => create();
  static $pb.PbList<Permissions> createRepeated() => $pb.PbList<Permissions>();
  @$core.pragma('dart2js:noInline')
  static Permissions getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Permissions>(create);
  static Permissions? _defaultInstance;

  @$pb.TagNumber(1)
  Scope get canAddMembers => $_getN(0);
  @$pb.TagNumber(1)
  set canAddMembers(Scope v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasCanAddMembers() => $_has(0);
  @$pb.TagNumber(1)
  void clearCanAddMembers() => clearField(1);

  @$pb.TagNumber(2)
  Scope get canEditInfo => $_getN(1);
  @$pb.TagNumber(2)
  set canEditInfo(Scope v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasCanEditInfo() => $_has(1);
  @$pb.TagNumber(2)
  void clearCanEditInfo() => clearField(2);

  @$pb.TagNumber(3)
  $core.bool get moderated => $_getBF(2);
  @$pb.TagNumber(3)
  set moderated($core.bool v) { $_setBool(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasModerated() => $_has(2);
  @$pb.TagNumber(3)
  void clearModerated() => clearField(3);
}

class Membership extends $pb.GeneratedMessage {
  factory Membership() => create();
  Membership._() : super();
  factory Membership.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Membership.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Membership', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..pc<$0.TypedKey>(1, _omitFieldNames ? '' : 'watchers', $pb.PbFieldType.PM, subBuilder: $0.TypedKey.create)
    ..pc<$0.TypedKey>(2, _omitFieldNames ? '' : 'moderated', $pb.PbFieldType.PM, subBuilder: $0.TypedKey.create)
    ..pc<$0.TypedKey>(3, _omitFieldNames ? '' : 'talkers', $pb.PbFieldType.PM, subBuilder: $0.TypedKey.create)
    ..pc<$0.TypedKey>(4, _omitFieldNames ? '' : 'moderators', $pb.PbFieldType.PM, subBuilder: $0.TypedKey.create)
    ..pc<$0.TypedKey>(5, _omitFieldNames ? '' : 'admins', $pb.PbFieldType.PM, subBuilder: $0.TypedKey.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Membership clone() => Membership()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Membership copyWith(void Function(Membership) updates) => super.copyWith((message) => updates(message as Membership)) as Membership;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Membership create() => Membership._();
  Membership createEmptyInstance() => create();
  static $pb.PbList<Membership> createRepeated() => $pb.PbList<Membership>();
  @$core.pragma('dart2js:noInline')
  static Membership getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Membership>(create);
  static Membership? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$0.TypedKey> get watchers => $_getList(0);

  @$pb.TagNumber(2)
  $core.List<$0.TypedKey> get moderated => $_getList(1);

  @$pb.TagNumber(3)
  $core.List<$0.TypedKey> get talkers => $_getList(2);

  @$pb.TagNumber(4)
  $core.List<$0.TypedKey> get moderators => $_getList(3);

  @$pb.TagNumber(5)
  $core.List<$0.TypedKey> get admins => $_getList(4);
}

class ChatSettings extends $pb.GeneratedMessage {
  factory ChatSettings() => create();
  ChatSettings._() : super();
  factory ChatSettings.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ChatSettings.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ChatSettings', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'title')
    ..aOS(2, _omitFieldNames ? '' : 'description')
    ..aOM<$1.DataReference>(3, _omitFieldNames ? '' : 'icon', subBuilder: $1.DataReference.create)
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'defaultExpiration', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ChatSettings clone() => ChatSettings()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ChatSettings copyWith(void Function(ChatSettings) updates) => super.copyWith((message) => updates(message as ChatSettings)) as ChatSettings;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ChatSettings create() => ChatSettings._();
  ChatSettings createEmptyInstance() => create();
  static $pb.PbList<ChatSettings> createRepeated() => $pb.PbList<ChatSettings>();
  @$core.pragma('dart2js:noInline')
  static ChatSettings getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChatSettings>(create);
  static ChatSettings? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get title => $_getSZ(0);
  @$pb.TagNumber(1)
  set title($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTitle() => $_has(0);
  @$pb.TagNumber(1)
  void clearTitle() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get description => $_getSZ(1);
  @$pb.TagNumber(2)
  set description($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDescription() => $_has(1);
  @$pb.TagNumber(2)
  void clearDescription() => clearField(2);

  @$pb.TagNumber(3)
  $1.DataReference get icon => $_getN(2);
  @$pb.TagNumber(3)
  set icon($1.DataReference v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasIcon() => $_has(2);
  @$pb.TagNumber(3)
  void clearIcon() => clearField(3);
  @$pb.TagNumber(3)
  $1.DataReference ensureIcon() => $_ensure(2);

  @$pb.TagNumber(4)
  $fixnum.Int64 get defaultExpiration => $_getI64(3);
  @$pb.TagNumber(4)
  set defaultExpiration($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDefaultExpiration() => $_has(3);
  @$pb.TagNumber(4)
  void clearDefaultExpiration() => clearField(4);
}

class Message_Text extends $pb.GeneratedMessage {
  factory Message_Text() => create();
  Message_Text._() : super();
  factory Message_Text.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Message_Text.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Message.Text', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'text')
    ..aOS(2, _omitFieldNames ? '' : 'topic')
    ..a<$core.List<$core.int>>(3, _omitFieldNames ? '' : 'replyId', $pb.PbFieldType.OY)
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'expiration', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.int>(5, _omitFieldNames ? '' : 'viewLimit', $pb.PbFieldType.OU3)
    ..pc<Attachment>(6, _omitFieldNames ? '' : 'attachments', $pb.PbFieldType.PM, subBuilder: Attachment.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Message_Text clone() => Message_Text()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Message_Text copyWith(void Function(Message_Text) updates) => super.copyWith((message) => updates(message as Message_Text)) as Message_Text;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Message_Text create() => Message_Text._();
  Message_Text createEmptyInstance() => create();
  static $pb.PbList<Message_Text> createRepeated() => $pb.PbList<Message_Text>();
  @$core.pragma('dart2js:noInline')
  static Message_Text getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Message_Text>(create);
  static Message_Text? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get text => $_getSZ(0);
  @$pb.TagNumber(1)
  set text($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasText() => $_has(0);
  @$pb.TagNumber(1)
  void clearText() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get topic => $_getSZ(1);
  @$pb.TagNumber(2)
  set topic($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTopic() => $_has(1);
  @$pb.TagNumber(2)
  void clearTopic() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get replyId => $_getN(2);
  @$pb.TagNumber(3)
  set replyId($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasReplyId() => $_has(2);
  @$pb.TagNumber(3)
  void clearReplyId() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get expiration => $_getI64(3);
  @$pb.TagNumber(4)
  set expiration($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasExpiration() => $_has(3);
  @$pb.TagNumber(4)
  void clearExpiration() => clearField(4);

  @$pb.TagNumber(5)
  $core.int get viewLimit => $_getIZ(4);
  @$pb.TagNumber(5)
  set viewLimit($core.int v) { $_setUnsignedInt32(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasViewLimit() => $_has(4);
  @$pb.TagNumber(5)
  void clearViewLimit() => clearField(5);

  @$pb.TagNumber(6)
  $core.List<Attachment> get attachments => $_getList(5);
}

class Message_Secret extends $pb.GeneratedMessage {
  factory Message_Secret() => create();
  Message_Secret._() : super();
  factory Message_Secret.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Message_Secret.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Message.Secret', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'ciphertext', $pb.PbFieldType.OY)
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'expiration', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Message_Secret clone() => Message_Secret()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Message_Secret copyWith(void Function(Message_Secret) updates) => super.copyWith((message) => updates(message as Message_Secret)) as Message_Secret;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Message_Secret create() => Message_Secret._();
  Message_Secret createEmptyInstance() => create();
  static $pb.PbList<Message_Secret> createRepeated() => $pb.PbList<Message_Secret>();
  @$core.pragma('dart2js:noInline')
  static Message_Secret getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Message_Secret>(create);
  static Message_Secret? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get ciphertext => $_getN(0);
  @$pb.TagNumber(1)
  set ciphertext($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCiphertext() => $_has(0);
  @$pb.TagNumber(1)
  void clearCiphertext() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get expiration => $_getI64(1);
  @$pb.TagNumber(2)
  set expiration($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasExpiration() => $_has(1);
  @$pb.TagNumber(2)
  void clearExpiration() => clearField(2);
}

class Message_ControlDelete extends $pb.GeneratedMessage {
  factory Message_ControlDelete() => create();
  Message_ControlDelete._() : super();
  factory Message_ControlDelete.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Message_ControlDelete.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Message.ControlDelete', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..p<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'ids', $pb.PbFieldType.PY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Message_ControlDelete clone() => Message_ControlDelete()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Message_ControlDelete copyWith(void Function(Message_ControlDelete) updates) => super.copyWith((message) => updates(message as Message_ControlDelete)) as Message_ControlDelete;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Message_ControlDelete create() => Message_ControlDelete._();
  Message_ControlDelete createEmptyInstance() => create();
  static $pb.PbList<Message_ControlDelete> createRepeated() => $pb.PbList<Message_ControlDelete>();
  @$core.pragma('dart2js:noInline')
  static Message_ControlDelete getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Message_ControlDelete>(create);
  static Message_ControlDelete? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.List<$core.int>> get ids => $_getList(0);
}

class Message_ControlErase extends $pb.GeneratedMessage {
  factory Message_ControlErase() => create();
  Message_ControlErase._() : super();
  factory Message_ControlErase.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Message_ControlErase.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Message.ControlErase', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'timestamp', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Message_ControlErase clone() => Message_ControlErase()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Message_ControlErase copyWith(void Function(Message_ControlErase) updates) => super.copyWith((message) => updates(message as Message_ControlErase)) as Message_ControlErase;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Message_ControlErase create() => Message_ControlErase._();
  Message_ControlErase createEmptyInstance() => create();
  static $pb.PbList<Message_ControlErase> createRepeated() => $pb.PbList<Message_ControlErase>();
  @$core.pragma('dart2js:noInline')
  static Message_ControlErase getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Message_ControlErase>(create);
  static Message_ControlErase? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get timestamp => $_getI64(0);
  @$pb.TagNumber(1)
  set timestamp($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTimestamp() => $_has(0);
  @$pb.TagNumber(1)
  void clearTimestamp() => clearField(1);
}

class Message_ControlSettings extends $pb.GeneratedMessage {
  factory Message_ControlSettings() => create();
  Message_ControlSettings._() : super();
  factory Message_ControlSettings.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Message_ControlSettings.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Message.ControlSettings', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..aOM<ChatSettings>(1, _omitFieldNames ? '' : 'settings', subBuilder: ChatSettings.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Message_ControlSettings clone() => Message_ControlSettings()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Message_ControlSettings copyWith(void Function(Message_ControlSettings) updates) => super.copyWith((message) => updates(message as Message_ControlSettings)) as Message_ControlSettings;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Message_ControlSettings create() => Message_ControlSettings._();
  Message_ControlSettings createEmptyInstance() => create();
  static $pb.PbList<Message_ControlSettings> createRepeated() => $pb.PbList<Message_ControlSettings>();
  @$core.pragma('dart2js:noInline')
  static Message_ControlSettings getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Message_ControlSettings>(create);
  static Message_ControlSettings? _defaultInstance;

  @$pb.TagNumber(1)
  ChatSettings get settings => $_getN(0);
  @$pb.TagNumber(1)
  set settings(ChatSettings v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSettings() => $_has(0);
  @$pb.TagNumber(1)
  void clearSettings() => clearField(1);
  @$pb.TagNumber(1)
  ChatSettings ensureSettings() => $_ensure(0);
}

class Message_ControlPermissions extends $pb.GeneratedMessage {
  factory Message_ControlPermissions() => create();
  Message_ControlPermissions._() : super();
  factory Message_ControlPermissions.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Message_ControlPermissions.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Message.ControlPermissions', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..aOM<Permissions>(1, _omitFieldNames ? '' : 'permissions', subBuilder: Permissions.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Message_ControlPermissions clone() => Message_ControlPermissions()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Message_ControlPermissions copyWith(void Function(Message_ControlPermissions) updates) => super.copyWith((message) => updates(message as Message_ControlPermissions)) as Message_ControlPermissions;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Message_ControlPermissions create() => Message_ControlPermissions._();
  Message_ControlPermissions createEmptyInstance() => create();
  static $pb.PbList<Message_ControlPermissions> createRepeated() => $pb.PbList<Message_ControlPermissions>();
  @$core.pragma('dart2js:noInline')
  static Message_ControlPermissions getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Message_ControlPermissions>(create);
  static Message_ControlPermissions? _defaultInstance;

  @$pb.TagNumber(1)
  Permissions get permissions => $_getN(0);
  @$pb.TagNumber(1)
  set permissions(Permissions v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasPermissions() => $_has(0);
  @$pb.TagNumber(1)
  void clearPermissions() => clearField(1);
  @$pb.TagNumber(1)
  Permissions ensurePermissions() => $_ensure(0);
}

class Message_ControlMembership extends $pb.GeneratedMessage {
  factory Message_ControlMembership() => create();
  Message_ControlMembership._() : super();
  factory Message_ControlMembership.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Message_ControlMembership.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Message.ControlMembership', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..aOM<Membership>(1, _omitFieldNames ? '' : 'membership', subBuilder: Membership.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Message_ControlMembership clone() => Message_ControlMembership()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Message_ControlMembership copyWith(void Function(Message_ControlMembership) updates) => super.copyWith((message) => updates(message as Message_ControlMembership)) as Message_ControlMembership;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Message_ControlMembership create() => Message_ControlMembership._();
  Message_ControlMembership createEmptyInstance() => create();
  static $pb.PbList<Message_ControlMembership> createRepeated() => $pb.PbList<Message_ControlMembership>();
  @$core.pragma('dart2js:noInline')
  static Message_ControlMembership getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Message_ControlMembership>(create);
  static Message_ControlMembership? _defaultInstance;

  @$pb.TagNumber(1)
  Membership get membership => $_getN(0);
  @$pb.TagNumber(1)
  set membership(Membership v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasMembership() => $_has(0);
  @$pb.TagNumber(1)
  void clearMembership() => clearField(1);
  @$pb.TagNumber(1)
  Membership ensureMembership() => $_ensure(0);
}

class Message_ControlModeration extends $pb.GeneratedMessage {
  factory Message_ControlModeration() => create();
  Message_ControlModeration._() : super();
  factory Message_ControlModeration.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Message_ControlModeration.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Message.ControlModeration', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..p<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'acceptedIds', $pb.PbFieldType.PY)
    ..p<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'rejectedIds', $pb.PbFieldType.PY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Message_ControlModeration clone() => Message_ControlModeration()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Message_ControlModeration copyWith(void Function(Message_ControlModeration) updates) => super.copyWith((message) => updates(message as Message_ControlModeration)) as Message_ControlModeration;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Message_ControlModeration create() => Message_ControlModeration._();
  Message_ControlModeration createEmptyInstance() => create();
  static $pb.PbList<Message_ControlModeration> createRepeated() => $pb.PbList<Message_ControlModeration>();
  @$core.pragma('dart2js:noInline')
  static Message_ControlModeration getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Message_ControlModeration>(create);
  static Message_ControlModeration? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.List<$core.int>> get acceptedIds => $_getList(0);

  @$pb.TagNumber(2)
  $core.List<$core.List<$core.int>> get rejectedIds => $_getList(1);
}

class Message_ControlReadReceipt extends $pb.GeneratedMessage {
  factory Message_ControlReadReceipt() => create();
  Message_ControlReadReceipt._() : super();
  factory Message_ControlReadReceipt.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Message_ControlReadReceipt.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Message.ControlReadReceipt', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..p<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'readIds', $pb.PbFieldType.PY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Message_ControlReadReceipt clone() => Message_ControlReadReceipt()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Message_ControlReadReceipt copyWith(void Function(Message_ControlReadReceipt) updates) => super.copyWith((message) => updates(message as Message_ControlReadReceipt)) as Message_ControlReadReceipt;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Message_ControlReadReceipt create() => Message_ControlReadReceipt._();
  Message_ControlReadReceipt createEmptyInstance() => create();
  static $pb.PbList<Message_ControlReadReceipt> createRepeated() => $pb.PbList<Message_ControlReadReceipt>();
  @$core.pragma('dart2js:noInline')
  static Message_ControlReadReceipt getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Message_ControlReadReceipt>(create);
  static Message_ControlReadReceipt? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.List<$core.int>> get readIds => $_getList(0);
}

enum Message_Kind {
  text, 
  secret, 
  delete, 
  erase, 
  settings, 
  permissions, 
  membership, 
  moderation, 
  notSet
}

class Message extends $pb.GeneratedMessage {
  factory Message() => create();
  Message._() : super();
  factory Message.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Message.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static const $core.Map<$core.int, Message_Kind> _Message_KindByTag = {
    4 : Message_Kind.text,
    5 : Message_Kind.secret,
    6 : Message_Kind.delete,
    7 : Message_Kind.erase,
    8 : Message_Kind.settings,
    9 : Message_Kind.permissions,
    10 : Message_Kind.membership,
    11 : Message_Kind.moderation,
    0 : Message_Kind.notSet
  };
  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Message', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..oo(0, [4, 5, 6, 7, 8, 9, 10, 11])
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'id', $pb.PbFieldType.OY)
    ..aOM<$0.TypedKey>(2, _omitFieldNames ? '' : 'author', subBuilder: $0.TypedKey.create)
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'timestamp', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<Message_Text>(4, _omitFieldNames ? '' : 'text', subBuilder: Message_Text.create)
    ..aOM<Message_Secret>(5, _omitFieldNames ? '' : 'secret', subBuilder: Message_Secret.create)
    ..aOM<Message_ControlDelete>(6, _omitFieldNames ? '' : 'delete', subBuilder: Message_ControlDelete.create)
    ..aOM<Message_ControlErase>(7, _omitFieldNames ? '' : 'erase', subBuilder: Message_ControlErase.create)
    ..aOM<Message_ControlSettings>(8, _omitFieldNames ? '' : 'settings', subBuilder: Message_ControlSettings.create)
    ..aOM<Message_ControlPermissions>(9, _omitFieldNames ? '' : 'permissions', subBuilder: Message_ControlPermissions.create)
    ..aOM<Message_ControlMembership>(10, _omitFieldNames ? '' : 'membership', subBuilder: Message_ControlMembership.create)
    ..aOM<Message_ControlModeration>(11, _omitFieldNames ? '' : 'moderation', subBuilder: Message_ControlModeration.create)
    ..aOM<$0.Signature>(12, _omitFieldNames ? '' : 'signature', subBuilder: $0.Signature.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Message clone() => Message()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Message copyWith(void Function(Message) updates) => super.copyWith((message) => updates(message as Message)) as Message;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Message create() => Message._();
  Message createEmptyInstance() => create();
  static $pb.PbList<Message> createRepeated() => $pb.PbList<Message>();
  @$core.pragma('dart2js:noInline')
  static Message getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Message>(create);
  static Message? _defaultInstance;

  Message_Kind whichKind() => _Message_KindByTag[$_whichOneof(0)]!;
  void clearKind() => clearField($_whichOneof(0));

  @$pb.TagNumber(1)
  $core.List<$core.int> get id => $_getN(0);
  @$pb.TagNumber(1)
  set id($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasId() => $_has(0);
  @$pb.TagNumber(1)
  void clearId() => clearField(1);

  @$pb.TagNumber(2)
  $0.TypedKey get author => $_getN(1);
  @$pb.TagNumber(2)
  set author($0.TypedKey v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasAuthor() => $_has(1);
  @$pb.TagNumber(2)
  void clearAuthor() => clearField(2);
  @$pb.TagNumber(2)
  $0.TypedKey ensureAuthor() => $_ensure(1);

  @$pb.TagNumber(3)
  $fixnum.Int64 get timestamp => $_getI64(2);
  @$pb.TagNumber(3)
  set timestamp($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTimestamp() => $_has(2);
  @$pb.TagNumber(3)
  void clearTimestamp() => clearField(3);

  @$pb.TagNumber(4)
  Message_Text get text => $_getN(3);
  @$pb.TagNumber(4)
  set text(Message_Text v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasText() => $_has(3);
  @$pb.TagNumber(4)
  void clearText() => clearField(4);
  @$pb.TagNumber(4)
  Message_Text ensureText() => $_ensure(3);

  @$pb.TagNumber(5)
  Message_Secret get secret => $_getN(4);
  @$pb.TagNumber(5)
  set secret(Message_Secret v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasSecret() => $_has(4);
  @$pb.TagNumber(5)
  void clearSecret() => clearField(5);
  @$pb.TagNumber(5)
  Message_Secret ensureSecret() => $_ensure(4);

  @$pb.TagNumber(6)
  Message_ControlDelete get delete => $_getN(5);
  @$pb.TagNumber(6)
  set delete(Message_ControlDelete v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasDelete() => $_has(5);
  @$pb.TagNumber(6)
  void clearDelete() => clearField(6);
  @$pb.TagNumber(6)
  Message_ControlDelete ensureDelete() => $_ensure(5);

  @$pb.TagNumber(7)
  Message_ControlErase get erase => $_getN(6);
  @$pb.TagNumber(7)
  set erase(Message_ControlErase v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasErase() => $_has(6);
  @$pb.TagNumber(7)
  void clearErase() => clearField(7);
  @$pb.TagNumber(7)
  Message_ControlErase ensureErase() => $_ensure(6);

  @$pb.TagNumber(8)
  Message_ControlSettings get settings => $_getN(7);
  @$pb.TagNumber(8)
  set settings(Message_ControlSettings v) { setField(8, v); }
  @$pb.TagNumber(8)
  $core.bool hasSettings() => $_has(7);
  @$pb.TagNumber(8)
  void clearSettings() => clearField(8);
  @$pb.TagNumber(8)
  Message_ControlSettings ensureSettings() => $_ensure(7);

  @$pb.TagNumber(9)
  Message_ControlPermissions get permissions => $_getN(8);
  @$pb.TagNumber(9)
  set permissions(Message_ControlPermissions v) { setField(9, v); }
  @$pb.TagNumber(9)
  $core.bool hasPermissions() => $_has(8);
  @$pb.TagNumber(9)
  void clearPermissions() => clearField(9);
  @$pb.TagNumber(9)
  Message_ControlPermissions ensurePermissions() => $_ensure(8);

  @$pb.TagNumber(10)
  Message_ControlMembership get membership => $_getN(9);
  @$pb.TagNumber(10)
  set membership(Message_ControlMembership v) { setField(10, v); }
  @$pb.TagNumber(10)
  $core.bool hasMembership() => $_has(9);
  @$pb.TagNumber(10)
  void clearMembership() => clearField(10);
  @$pb.TagNumber(10)
  Message_ControlMembership ensureMembership() => $_ensure(9);

  @$pb.TagNumber(11)
  Message_ControlModeration get moderation => $_getN(10);
  @$pb.TagNumber(11)
  set moderation(Message_ControlModeration v) { setField(11, v); }
  @$pb.TagNumber(11)
  $core.bool hasModeration() => $_has(10);
  @$pb.TagNumber(11)
  void clearModeration() => clearField(11);
  @$pb.TagNumber(11)
  Message_ControlModeration ensureModeration() => $_ensure(10);

  @$pb.TagNumber(12)
  $0.Signature get signature => $_getN(11);
  @$pb.TagNumber(12)
  set signature($0.Signature v) { setField(12, v); }
  @$pb.TagNumber(12)
  $core.bool hasSignature() => $_has(11);
  @$pb.TagNumber(12)
  void clearSignature() => clearField(12);
  @$pb.TagNumber(12)
  $0.Signature ensureSignature() => $_ensure(11);
}

class ReconciledMessage extends $pb.GeneratedMessage {
  factory ReconciledMessage() => create();
  ReconciledMessage._() : super();
  factory ReconciledMessage.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ReconciledMessage.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ReconciledMessage', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..aOM<Message>(1, _omitFieldNames ? '' : 'content', subBuilder: Message.create)
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'reconciledTime', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ReconciledMessage clone() => ReconciledMessage()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ReconciledMessage copyWith(void Function(ReconciledMessage) updates) => super.copyWith((message) => updates(message as ReconciledMessage)) as ReconciledMessage;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ReconciledMessage create() => ReconciledMessage._();
  ReconciledMessage createEmptyInstance() => create();
  static $pb.PbList<ReconciledMessage> createRepeated() => $pb.PbList<ReconciledMessage>();
  @$core.pragma('dart2js:noInline')
  static ReconciledMessage getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ReconciledMessage>(create);
  static ReconciledMessage? _defaultInstance;

  @$pb.TagNumber(1)
  Message get content => $_getN(0);
  @$pb.TagNumber(1)
  set content(Message v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasContent() => $_has(0);
  @$pb.TagNumber(1)
  void clearContent() => clearField(1);
  @$pb.TagNumber(1)
  Message ensureContent() => $_ensure(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get reconciledTime => $_getI64(1);
  @$pb.TagNumber(2)
  set reconciledTime($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasReconciledTime() => $_has(1);
  @$pb.TagNumber(2)
  void clearReconciledTime() => clearField(2);
}

class Conversation extends $pb.GeneratedMessage {
  factory Conversation() => create();
  Conversation._() : super();
  factory Conversation.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Conversation.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Conversation', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..aOM<Profile>(1, _omitFieldNames ? '' : 'profile', subBuilder: Profile.create)
    ..aOS(2, _omitFieldNames ? '' : 'identityMasterJson')
    ..aOM<$0.TypedKey>(3, _omitFieldNames ? '' : 'messages', subBuilder: $0.TypedKey.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Conversation clone() => Conversation()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Conversation copyWith(void Function(Conversation) updates) => super.copyWith((message) => updates(message as Conversation)) as Conversation;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Conversation create() => Conversation._();
  Conversation createEmptyInstance() => create();
  static $pb.PbList<Conversation> createRepeated() => $pb.PbList<Conversation>();
  @$core.pragma('dart2js:noInline')
  static Conversation getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Conversation>(create);
  static Conversation? _defaultInstance;

  @$pb.TagNumber(1)
  Profile get profile => $_getN(0);
  @$pb.TagNumber(1)
  set profile(Profile v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasProfile() => $_has(0);
  @$pb.TagNumber(1)
  void clearProfile() => clearField(1);
  @$pb.TagNumber(1)
  Profile ensureProfile() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.String get identityMasterJson => $_getSZ(1);
  @$pb.TagNumber(2)
  set identityMasterJson($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasIdentityMasterJson() => $_has(1);
  @$pb.TagNumber(2)
  void clearIdentityMasterJson() => clearField(2);

  @$pb.TagNumber(3)
  $0.TypedKey get messages => $_getN(2);
  @$pb.TagNumber(3)
  set messages($0.TypedKey v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasMessages() => $_has(2);
  @$pb.TagNumber(3)
  void clearMessages() => clearField(3);
  @$pb.TagNumber(3)
  $0.TypedKey ensureMessages() => $_ensure(2);
}

class Chat extends $pb.GeneratedMessage {
  factory Chat() => create();
  Chat._() : super();
  factory Chat.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Chat.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Chat', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..aOM<ChatSettings>(1, _omitFieldNames ? '' : 'settings', subBuilder: ChatSettings.create)
    ..aOM<$0.TypedKey>(2, _omitFieldNames ? '' : 'localConversationRecordKey', subBuilder: $0.TypedKey.create)
    ..aOM<$0.TypedKey>(3, _omitFieldNames ? '' : 'remoteConversationRecordKey', subBuilder: $0.TypedKey.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Chat clone() => Chat()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Chat copyWith(void Function(Chat) updates) => super.copyWith((message) => updates(message as Chat)) as Chat;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Chat create() => Chat._();
  Chat createEmptyInstance() => create();
  static $pb.PbList<Chat> createRepeated() => $pb.PbList<Chat>();
  @$core.pragma('dart2js:noInline')
  static Chat getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Chat>(create);
  static Chat? _defaultInstance;

  @$pb.TagNumber(1)
  ChatSettings get settings => $_getN(0);
  @$pb.TagNumber(1)
  set settings(ChatSettings v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSettings() => $_has(0);
  @$pb.TagNumber(1)
  void clearSettings() => clearField(1);
  @$pb.TagNumber(1)
  ChatSettings ensureSettings() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.TypedKey get localConversationRecordKey => $_getN(1);
  @$pb.TagNumber(2)
  set localConversationRecordKey($0.TypedKey v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasLocalConversationRecordKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearLocalConversationRecordKey() => clearField(2);
  @$pb.TagNumber(2)
  $0.TypedKey ensureLocalConversationRecordKey() => $_ensure(1);

  @$pb.TagNumber(3)
  $0.TypedKey get remoteConversationRecordKey => $_getN(2);
  @$pb.TagNumber(3)
  set remoteConversationRecordKey($0.TypedKey v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasRemoteConversationRecordKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearRemoteConversationRecordKey() => clearField(3);
  @$pb.TagNumber(3)
  $0.TypedKey ensureRemoteConversationRecordKey() => $_ensure(2);
}

class GroupChat extends $pb.GeneratedMessage {
  factory GroupChat() => create();
  GroupChat._() : super();
  factory GroupChat.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory GroupChat.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'GroupChat', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..aOM<ChatSettings>(1, _omitFieldNames ? '' : 'settings', subBuilder: ChatSettings.create)
    ..aOM<$0.TypedKey>(2, _omitFieldNames ? '' : 'localConversationRecordKey', subBuilder: $0.TypedKey.create)
    ..pc<$0.TypedKey>(3, _omitFieldNames ? '' : 'remoteConversationRecordKeys', $pb.PbFieldType.PM, subBuilder: $0.TypedKey.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  GroupChat clone() => GroupChat()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  GroupChat copyWith(void Function(GroupChat) updates) => super.copyWith((message) => updates(message as GroupChat)) as GroupChat;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static GroupChat create() => GroupChat._();
  GroupChat createEmptyInstance() => create();
  static $pb.PbList<GroupChat> createRepeated() => $pb.PbList<GroupChat>();
  @$core.pragma('dart2js:noInline')
  static GroupChat getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<GroupChat>(create);
  static GroupChat? _defaultInstance;

  @$pb.TagNumber(1)
  ChatSettings get settings => $_getN(0);
  @$pb.TagNumber(1)
  set settings(ChatSettings v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasSettings() => $_has(0);
  @$pb.TagNumber(1)
  void clearSettings() => clearField(1);
  @$pb.TagNumber(1)
  ChatSettings ensureSettings() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.TypedKey get localConversationRecordKey => $_getN(1);
  @$pb.TagNumber(2)
  set localConversationRecordKey($0.TypedKey v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasLocalConversationRecordKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearLocalConversationRecordKey() => clearField(2);
  @$pb.TagNumber(2)
  $0.TypedKey ensureLocalConversationRecordKey() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.List<$0.TypedKey> get remoteConversationRecordKeys => $_getList(2);
}

class Profile extends $pb.GeneratedMessage {
  factory Profile() => create();
  Profile._() : super();
  factory Profile.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Profile.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Profile', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'name')
    ..aOS(2, _omitFieldNames ? '' : 'pronouns')
    ..aOS(3, _omitFieldNames ? '' : 'about')
    ..aOS(4, _omitFieldNames ? '' : 'status')
    ..e<Availability>(5, _omitFieldNames ? '' : 'availability', $pb.PbFieldType.OE, defaultOrMaker: Availability.AVAILABILITY_UNSPECIFIED, valueOf: Availability.valueOf, enumValues: Availability.values)
    ..aOM<$0.TypedKey>(6, _omitFieldNames ? '' : 'avatar', subBuilder: $0.TypedKey.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Profile clone() => Profile()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Profile copyWith(void Function(Profile) updates) => super.copyWith((message) => updates(message as Profile)) as Profile;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Profile create() => Profile._();
  Profile createEmptyInstance() => create();
  static $pb.PbList<Profile> createRepeated() => $pb.PbList<Profile>();
  @$core.pragma('dart2js:noInline')
  static Profile getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Profile>(create);
  static Profile? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get name => $_getSZ(0);
  @$pb.TagNumber(1)
  set name($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasName() => $_has(0);
  @$pb.TagNumber(1)
  void clearName() => clearField(1);

  @$pb.TagNumber(2)
  $core.String get pronouns => $_getSZ(1);
  @$pb.TagNumber(2)
  set pronouns($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPronouns() => $_has(1);
  @$pb.TagNumber(2)
  void clearPronouns() => clearField(2);

  @$pb.TagNumber(3)
  $core.String get about => $_getSZ(2);
  @$pb.TagNumber(3)
  set about($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAbout() => $_has(2);
  @$pb.TagNumber(3)
  void clearAbout() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get status => $_getSZ(3);
  @$pb.TagNumber(4)
  set status($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasStatus() => $_has(3);
  @$pb.TagNumber(4)
  void clearStatus() => clearField(4);

  @$pb.TagNumber(5)
  Availability get availability => $_getN(4);
  @$pb.TagNumber(5)
  set availability(Availability v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasAvailability() => $_has(4);
  @$pb.TagNumber(5)
  void clearAvailability() => clearField(5);

  @$pb.TagNumber(6)
  $0.TypedKey get avatar => $_getN(5);
  @$pb.TagNumber(6)
  set avatar($0.TypedKey v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasAvatar() => $_has(5);
  @$pb.TagNumber(6)
  void clearAvatar() => clearField(6);
  @$pb.TagNumber(6)
  $0.TypedKey ensureAvatar() => $_ensure(5);
}

class Account extends $pb.GeneratedMessage {
  factory Account() => create();
  Account._() : super();
  factory Account.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Account.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Account', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..aOM<Profile>(1, _omitFieldNames ? '' : 'profile', subBuilder: Profile.create)
    ..aOB(2, _omitFieldNames ? '' : 'invisible')
    ..a<$core.int>(3, _omitFieldNames ? '' : 'autoAwayTimeoutSec', $pb.PbFieldType.OU3)
    ..aOM<$1.OwnedDHTRecordPointer>(4, _omitFieldNames ? '' : 'contactList', subBuilder: $1.OwnedDHTRecordPointer.create)
    ..aOM<$1.OwnedDHTRecordPointer>(5, _omitFieldNames ? '' : 'contactInvitationRecords', subBuilder: $1.OwnedDHTRecordPointer.create)
    ..aOM<$1.OwnedDHTRecordPointer>(6, _omitFieldNames ? '' : 'chatList', subBuilder: $1.OwnedDHTRecordPointer.create)
    ..aOM<$1.OwnedDHTRecordPointer>(7, _omitFieldNames ? '' : 'groupChatList', subBuilder: $1.OwnedDHTRecordPointer.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Account clone() => Account()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Account copyWith(void Function(Account) updates) => super.copyWith((message) => updates(message as Account)) as Account;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Account create() => Account._();
  Account createEmptyInstance() => create();
  static $pb.PbList<Account> createRepeated() => $pb.PbList<Account>();
  @$core.pragma('dart2js:noInline')
  static Account getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Account>(create);
  static Account? _defaultInstance;

  @$pb.TagNumber(1)
  Profile get profile => $_getN(0);
  @$pb.TagNumber(1)
  set profile(Profile v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasProfile() => $_has(0);
  @$pb.TagNumber(1)
  void clearProfile() => clearField(1);
  @$pb.TagNumber(1)
  Profile ensureProfile() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.bool get invisible => $_getBF(1);
  @$pb.TagNumber(2)
  set invisible($core.bool v) { $_setBool(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasInvisible() => $_has(1);
  @$pb.TagNumber(2)
  void clearInvisible() => clearField(2);

  @$pb.TagNumber(3)
  $core.int get autoAwayTimeoutSec => $_getIZ(2);
  @$pb.TagNumber(3)
  set autoAwayTimeoutSec($core.int v) { $_setUnsignedInt32(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAutoAwayTimeoutSec() => $_has(2);
  @$pb.TagNumber(3)
  void clearAutoAwayTimeoutSec() => clearField(3);

  @$pb.TagNumber(4)
  $1.OwnedDHTRecordPointer get contactList => $_getN(3);
  @$pb.TagNumber(4)
  set contactList($1.OwnedDHTRecordPointer v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasContactList() => $_has(3);
  @$pb.TagNumber(4)
  void clearContactList() => clearField(4);
  @$pb.TagNumber(4)
  $1.OwnedDHTRecordPointer ensureContactList() => $_ensure(3);

  @$pb.TagNumber(5)
  $1.OwnedDHTRecordPointer get contactInvitationRecords => $_getN(4);
  @$pb.TagNumber(5)
  set contactInvitationRecords($1.OwnedDHTRecordPointer v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasContactInvitationRecords() => $_has(4);
  @$pb.TagNumber(5)
  void clearContactInvitationRecords() => clearField(5);
  @$pb.TagNumber(5)
  $1.OwnedDHTRecordPointer ensureContactInvitationRecords() => $_ensure(4);

  @$pb.TagNumber(6)
  $1.OwnedDHTRecordPointer get chatList => $_getN(5);
  @$pb.TagNumber(6)
  set chatList($1.OwnedDHTRecordPointer v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasChatList() => $_has(5);
  @$pb.TagNumber(6)
  void clearChatList() => clearField(6);
  @$pb.TagNumber(6)
  $1.OwnedDHTRecordPointer ensureChatList() => $_ensure(5);

  @$pb.TagNumber(7)
  $1.OwnedDHTRecordPointer get groupChatList => $_getN(6);
  @$pb.TagNumber(7)
  set groupChatList($1.OwnedDHTRecordPointer v) { setField(7, v); }
  @$pb.TagNumber(7)
  $core.bool hasGroupChatList() => $_has(6);
  @$pb.TagNumber(7)
  void clearGroupChatList() => clearField(7);
  @$pb.TagNumber(7)
  $1.OwnedDHTRecordPointer ensureGroupChatList() => $_ensure(6);
}

class Contact extends $pb.GeneratedMessage {
  factory Contact() => create();
  Contact._() : super();
  factory Contact.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Contact.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Contact', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..aOM<Profile>(1, _omitFieldNames ? '' : 'editedProfile', subBuilder: Profile.create)
    ..aOM<Profile>(2, _omitFieldNames ? '' : 'remoteProfile', subBuilder: Profile.create)
    ..aOS(3, _omitFieldNames ? '' : 'identityMasterJson')
    ..aOM<$0.TypedKey>(4, _omitFieldNames ? '' : 'identityPublicKey', subBuilder: $0.TypedKey.create)
    ..aOM<$0.TypedKey>(5, _omitFieldNames ? '' : 'remoteConversationRecordKey', subBuilder: $0.TypedKey.create)
    ..aOM<$0.TypedKey>(6, _omitFieldNames ? '' : 'localConversationRecordKey', subBuilder: $0.TypedKey.create)
    ..aOB(7, _omitFieldNames ? '' : 'showAvailability')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  Contact clone() => Contact()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  Contact copyWith(void Function(Contact) updates) => super.copyWith((message) => updates(message as Contact)) as Contact;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Contact create() => Contact._();
  Contact createEmptyInstance() => create();
  static $pb.PbList<Contact> createRepeated() => $pb.PbList<Contact>();
  @$core.pragma('dart2js:noInline')
  static Contact getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Contact>(create);
  static Contact? _defaultInstance;

  @$pb.TagNumber(1)
  Profile get editedProfile => $_getN(0);
  @$pb.TagNumber(1)
  set editedProfile(Profile v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasEditedProfile() => $_has(0);
  @$pb.TagNumber(1)
  void clearEditedProfile() => clearField(1);
  @$pb.TagNumber(1)
  Profile ensureEditedProfile() => $_ensure(0);

  @$pb.TagNumber(2)
  Profile get remoteProfile => $_getN(1);
  @$pb.TagNumber(2)
  set remoteProfile(Profile v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasRemoteProfile() => $_has(1);
  @$pb.TagNumber(2)
  void clearRemoteProfile() => clearField(2);
  @$pb.TagNumber(2)
  Profile ensureRemoteProfile() => $_ensure(1);

  @$pb.TagNumber(3)
  $core.String get identityMasterJson => $_getSZ(2);
  @$pb.TagNumber(3)
  set identityMasterJson($core.String v) { $_setString(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasIdentityMasterJson() => $_has(2);
  @$pb.TagNumber(3)
  void clearIdentityMasterJson() => clearField(3);

  @$pb.TagNumber(4)
  $0.TypedKey get identityPublicKey => $_getN(3);
  @$pb.TagNumber(4)
  set identityPublicKey($0.TypedKey v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasIdentityPublicKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearIdentityPublicKey() => clearField(4);
  @$pb.TagNumber(4)
  $0.TypedKey ensureIdentityPublicKey() => $_ensure(3);

  @$pb.TagNumber(5)
  $0.TypedKey get remoteConversationRecordKey => $_getN(4);
  @$pb.TagNumber(5)
  set remoteConversationRecordKey($0.TypedKey v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasRemoteConversationRecordKey() => $_has(4);
  @$pb.TagNumber(5)
  void clearRemoteConversationRecordKey() => clearField(5);
  @$pb.TagNumber(5)
  $0.TypedKey ensureRemoteConversationRecordKey() => $_ensure(4);

  @$pb.TagNumber(6)
  $0.TypedKey get localConversationRecordKey => $_getN(5);
  @$pb.TagNumber(6)
  set localConversationRecordKey($0.TypedKey v) { setField(6, v); }
  @$pb.TagNumber(6)
  $core.bool hasLocalConversationRecordKey() => $_has(5);
  @$pb.TagNumber(6)
  void clearLocalConversationRecordKey() => clearField(6);
  @$pb.TagNumber(6)
  $0.TypedKey ensureLocalConversationRecordKey() => $_ensure(5);

  @$pb.TagNumber(7)
  $core.bool get showAvailability => $_getBF(6);
  @$pb.TagNumber(7)
  set showAvailability($core.bool v) { $_setBool(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasShowAvailability() => $_has(6);
  @$pb.TagNumber(7)
  void clearShowAvailability() => clearField(7);
}

class ContactInvitation extends $pb.GeneratedMessage {
  factory ContactInvitation() => create();
  ContactInvitation._() : super();
  factory ContactInvitation.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ContactInvitation.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ContactInvitation', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..aOM<$0.TypedKey>(1, _omitFieldNames ? '' : 'contactRequestInboxKey', subBuilder: $0.TypedKey.create)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'writerSecret', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ContactInvitation clone() => ContactInvitation()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ContactInvitation copyWith(void Function(ContactInvitation) updates) => super.copyWith((message) => updates(message as ContactInvitation)) as ContactInvitation;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ContactInvitation create() => ContactInvitation._();
  ContactInvitation createEmptyInstance() => create();
  static $pb.PbList<ContactInvitation> createRepeated() => $pb.PbList<ContactInvitation>();
  @$core.pragma('dart2js:noInline')
  static ContactInvitation getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ContactInvitation>(create);
  static ContactInvitation? _defaultInstance;

  @$pb.TagNumber(1)
  $0.TypedKey get contactRequestInboxKey => $_getN(0);
  @$pb.TagNumber(1)
  set contactRequestInboxKey($0.TypedKey v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasContactRequestInboxKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearContactRequestInboxKey() => clearField(1);
  @$pb.TagNumber(1)
  $0.TypedKey ensureContactRequestInboxKey() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.List<$core.int> get writerSecret => $_getN(1);
  @$pb.TagNumber(2)
  set writerSecret($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasWriterSecret() => $_has(1);
  @$pb.TagNumber(2)
  void clearWriterSecret() => clearField(2);
}

class SignedContactInvitation extends $pb.GeneratedMessage {
  factory SignedContactInvitation() => create();
  SignedContactInvitation._() : super();
  factory SignedContactInvitation.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SignedContactInvitation.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignedContactInvitation', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'contactInvitation', $pb.PbFieldType.OY)
    ..aOM<$0.Signature>(2, _omitFieldNames ? '' : 'identitySignature', subBuilder: $0.Signature.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SignedContactInvitation clone() => SignedContactInvitation()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SignedContactInvitation copyWith(void Function(SignedContactInvitation) updates) => super.copyWith((message) => updates(message as SignedContactInvitation)) as SignedContactInvitation;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SignedContactInvitation create() => SignedContactInvitation._();
  SignedContactInvitation createEmptyInstance() => create();
  static $pb.PbList<SignedContactInvitation> createRepeated() => $pb.PbList<SignedContactInvitation>();
  @$core.pragma('dart2js:noInline')
  static SignedContactInvitation getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SignedContactInvitation>(create);
  static SignedContactInvitation? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get contactInvitation => $_getN(0);
  @$pb.TagNumber(1)
  set contactInvitation($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasContactInvitation() => $_has(0);
  @$pb.TagNumber(1)
  void clearContactInvitation() => clearField(1);

  @$pb.TagNumber(2)
  $0.Signature get identitySignature => $_getN(1);
  @$pb.TagNumber(2)
  set identitySignature($0.Signature v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasIdentitySignature() => $_has(1);
  @$pb.TagNumber(2)
  void clearIdentitySignature() => clearField(2);
  @$pb.TagNumber(2)
  $0.Signature ensureIdentitySignature() => $_ensure(1);
}

class ContactRequest extends $pb.GeneratedMessage {
  factory ContactRequest() => create();
  ContactRequest._() : super();
  factory ContactRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ContactRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ContactRequest', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..e<EncryptionKeyType>(1, _omitFieldNames ? '' : 'encryptionKeyType', $pb.PbFieldType.OE, defaultOrMaker: EncryptionKeyType.ENCRYPTION_KEY_TYPE_UNSPECIFIED, valueOf: EncryptionKeyType.valueOf, enumValues: EncryptionKeyType.values)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'private', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ContactRequest clone() => ContactRequest()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ContactRequest copyWith(void Function(ContactRequest) updates) => super.copyWith((message) => updates(message as ContactRequest)) as ContactRequest;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ContactRequest create() => ContactRequest._();
  ContactRequest createEmptyInstance() => create();
  static $pb.PbList<ContactRequest> createRepeated() => $pb.PbList<ContactRequest>();
  @$core.pragma('dart2js:noInline')
  static ContactRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ContactRequest>(create);
  static ContactRequest? _defaultInstance;

  @$pb.TagNumber(1)
  EncryptionKeyType get encryptionKeyType => $_getN(0);
  @$pb.TagNumber(1)
  set encryptionKeyType(EncryptionKeyType v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasEncryptionKeyType() => $_has(0);
  @$pb.TagNumber(1)
  void clearEncryptionKeyType() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get private => $_getN(1);
  @$pb.TagNumber(2)
  set private($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPrivate() => $_has(1);
  @$pb.TagNumber(2)
  void clearPrivate() => clearField(2);
}

class ContactRequestPrivate extends $pb.GeneratedMessage {
  factory ContactRequestPrivate() => create();
  ContactRequestPrivate._() : super();
  factory ContactRequestPrivate.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ContactRequestPrivate.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ContactRequestPrivate', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..aOM<$0.CryptoKey>(1, _omitFieldNames ? '' : 'writerKey', subBuilder: $0.CryptoKey.create)
    ..aOM<Profile>(2, _omitFieldNames ? '' : 'profile', subBuilder: Profile.create)
    ..aOM<$0.TypedKey>(3, _omitFieldNames ? '' : 'identityMasterRecordKey', subBuilder: $0.TypedKey.create)
    ..aOM<$0.TypedKey>(4, _omitFieldNames ? '' : 'chatRecordKey', subBuilder: $0.TypedKey.create)
    ..a<$fixnum.Int64>(5, _omitFieldNames ? '' : 'expiration', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ContactRequestPrivate clone() => ContactRequestPrivate()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ContactRequestPrivate copyWith(void Function(ContactRequestPrivate) updates) => super.copyWith((message) => updates(message as ContactRequestPrivate)) as ContactRequestPrivate;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ContactRequestPrivate create() => ContactRequestPrivate._();
  ContactRequestPrivate createEmptyInstance() => create();
  static $pb.PbList<ContactRequestPrivate> createRepeated() => $pb.PbList<ContactRequestPrivate>();
  @$core.pragma('dart2js:noInline')
  static ContactRequestPrivate getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ContactRequestPrivate>(create);
  static ContactRequestPrivate? _defaultInstance;

  @$pb.TagNumber(1)
  $0.CryptoKey get writerKey => $_getN(0);
  @$pb.TagNumber(1)
  set writerKey($0.CryptoKey v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasWriterKey() => $_has(0);
  @$pb.TagNumber(1)
  void clearWriterKey() => clearField(1);
  @$pb.TagNumber(1)
  $0.CryptoKey ensureWriterKey() => $_ensure(0);

  @$pb.TagNumber(2)
  Profile get profile => $_getN(1);
  @$pb.TagNumber(2)
  set profile(Profile v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasProfile() => $_has(1);
  @$pb.TagNumber(2)
  void clearProfile() => clearField(2);
  @$pb.TagNumber(2)
  Profile ensureProfile() => $_ensure(1);

  @$pb.TagNumber(3)
  $0.TypedKey get identityMasterRecordKey => $_getN(2);
  @$pb.TagNumber(3)
  set identityMasterRecordKey($0.TypedKey v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasIdentityMasterRecordKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearIdentityMasterRecordKey() => clearField(3);
  @$pb.TagNumber(3)
  $0.TypedKey ensureIdentityMasterRecordKey() => $_ensure(2);

  @$pb.TagNumber(4)
  $0.TypedKey get chatRecordKey => $_getN(3);
  @$pb.TagNumber(4)
  set chatRecordKey($0.TypedKey v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasChatRecordKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearChatRecordKey() => clearField(4);
  @$pb.TagNumber(4)
  $0.TypedKey ensureChatRecordKey() => $_ensure(3);

  @$pb.TagNumber(5)
  $fixnum.Int64 get expiration => $_getI64(4);
  @$pb.TagNumber(5)
  set expiration($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasExpiration() => $_has(4);
  @$pb.TagNumber(5)
  void clearExpiration() => clearField(5);
}

class ContactResponse extends $pb.GeneratedMessage {
  factory ContactResponse() => create();
  ContactResponse._() : super();
  factory ContactResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ContactResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ContactResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..aOB(1, _omitFieldNames ? '' : 'accept')
    ..aOM<$0.TypedKey>(2, _omitFieldNames ? '' : 'identityMasterRecordKey', subBuilder: $0.TypedKey.create)
    ..aOM<$0.TypedKey>(3, _omitFieldNames ? '' : 'remoteConversationRecordKey', subBuilder: $0.TypedKey.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ContactResponse clone() => ContactResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ContactResponse copyWith(void Function(ContactResponse) updates) => super.copyWith((message) => updates(message as ContactResponse)) as ContactResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ContactResponse create() => ContactResponse._();
  ContactResponse createEmptyInstance() => create();
  static $pb.PbList<ContactResponse> createRepeated() => $pb.PbList<ContactResponse>();
  @$core.pragma('dart2js:noInline')
  static ContactResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ContactResponse>(create);
  static ContactResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.bool get accept => $_getBF(0);
  @$pb.TagNumber(1)
  set accept($core.bool v) { $_setBool(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAccept() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccept() => clearField(1);

  @$pb.TagNumber(2)
  $0.TypedKey get identityMasterRecordKey => $_getN(1);
  @$pb.TagNumber(2)
  set identityMasterRecordKey($0.TypedKey v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasIdentityMasterRecordKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearIdentityMasterRecordKey() => clearField(2);
  @$pb.TagNumber(2)
  $0.TypedKey ensureIdentityMasterRecordKey() => $_ensure(1);

  @$pb.TagNumber(3)
  $0.TypedKey get remoteConversationRecordKey => $_getN(2);
  @$pb.TagNumber(3)
  set remoteConversationRecordKey($0.TypedKey v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasRemoteConversationRecordKey() => $_has(2);
  @$pb.TagNumber(3)
  void clearRemoteConversationRecordKey() => clearField(3);
  @$pb.TagNumber(3)
  $0.TypedKey ensureRemoteConversationRecordKey() => $_ensure(2);
}

class SignedContactResponse extends $pb.GeneratedMessage {
  factory SignedContactResponse() => create();
  SignedContactResponse._() : super();
  factory SignedContactResponse.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SignedContactResponse.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'SignedContactResponse', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'contactResponse', $pb.PbFieldType.OY)
    ..aOM<$0.Signature>(2, _omitFieldNames ? '' : 'identitySignature', subBuilder: $0.Signature.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  SignedContactResponse clone() => SignedContactResponse()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  SignedContactResponse copyWith(void Function(SignedContactResponse) updates) => super.copyWith((message) => updates(message as SignedContactResponse)) as SignedContactResponse;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static SignedContactResponse create() => SignedContactResponse._();
  SignedContactResponse createEmptyInstance() => create();
  static $pb.PbList<SignedContactResponse> createRepeated() => $pb.PbList<SignedContactResponse>();
  @$core.pragma('dart2js:noInline')
  static SignedContactResponse getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SignedContactResponse>(create);
  static SignedContactResponse? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get contactResponse => $_getN(0);
  @$pb.TagNumber(1)
  set contactResponse($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasContactResponse() => $_has(0);
  @$pb.TagNumber(1)
  void clearContactResponse() => clearField(1);

  @$pb.TagNumber(2)
  $0.Signature get identitySignature => $_getN(1);
  @$pb.TagNumber(2)
  set identitySignature($0.Signature v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasIdentitySignature() => $_has(1);
  @$pb.TagNumber(2)
  void clearIdentitySignature() => clearField(2);
  @$pb.TagNumber(2)
  $0.Signature ensureIdentitySignature() => $_ensure(1);
}

class ContactInvitationRecord extends $pb.GeneratedMessage {
  factory ContactInvitationRecord() => create();
  ContactInvitationRecord._() : super();
  factory ContactInvitationRecord.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ContactInvitationRecord.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ContactInvitationRecord', package: const $pb.PackageName(_omitMessageNames ? '' : 'veilidchat'), createEmptyInstance: create)
    ..aOM<$1.OwnedDHTRecordPointer>(1, _omitFieldNames ? '' : 'contactRequestInbox', subBuilder: $1.OwnedDHTRecordPointer.create)
    ..aOM<$0.CryptoKey>(2, _omitFieldNames ? '' : 'writerKey', subBuilder: $0.CryptoKey.create)
    ..aOM<$0.CryptoKey>(3, _omitFieldNames ? '' : 'writerSecret', subBuilder: $0.CryptoKey.create)
    ..aOM<$0.TypedKey>(4, _omitFieldNames ? '' : 'localConversationRecordKey', subBuilder: $0.TypedKey.create)
    ..a<$fixnum.Int64>(5, _omitFieldNames ? '' : 'expiration', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.List<$core.int>>(6, _omitFieldNames ? '' : 'invitation', $pb.PbFieldType.OY)
    ..aOS(7, _omitFieldNames ? '' : 'message')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ContactInvitationRecord clone() => ContactInvitationRecord()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ContactInvitationRecord copyWith(void Function(ContactInvitationRecord) updates) => super.copyWith((message) => updates(message as ContactInvitationRecord)) as ContactInvitationRecord;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ContactInvitationRecord create() => ContactInvitationRecord._();
  ContactInvitationRecord createEmptyInstance() => create();
  static $pb.PbList<ContactInvitationRecord> createRepeated() => $pb.PbList<ContactInvitationRecord>();
  @$core.pragma('dart2js:noInline')
  static ContactInvitationRecord getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ContactInvitationRecord>(create);
  static ContactInvitationRecord? _defaultInstance;

  @$pb.TagNumber(1)
  $1.OwnedDHTRecordPointer get contactRequestInbox => $_getN(0);
  @$pb.TagNumber(1)
  set contactRequestInbox($1.OwnedDHTRecordPointer v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasContactRequestInbox() => $_has(0);
  @$pb.TagNumber(1)
  void clearContactRequestInbox() => clearField(1);
  @$pb.TagNumber(1)
  $1.OwnedDHTRecordPointer ensureContactRequestInbox() => $_ensure(0);

  @$pb.TagNumber(2)
  $0.CryptoKey get writerKey => $_getN(1);
  @$pb.TagNumber(2)
  set writerKey($0.CryptoKey v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasWriterKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearWriterKey() => clearField(2);
  @$pb.TagNumber(2)
  $0.CryptoKey ensureWriterKey() => $_ensure(1);

  @$pb.TagNumber(3)
  $0.CryptoKey get writerSecret => $_getN(2);
  @$pb.TagNumber(3)
  set writerSecret($0.CryptoKey v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasWriterSecret() => $_has(2);
  @$pb.TagNumber(3)
  void clearWriterSecret() => clearField(3);
  @$pb.TagNumber(3)
  $0.CryptoKey ensureWriterSecret() => $_ensure(2);

  @$pb.TagNumber(4)
  $0.TypedKey get localConversationRecordKey => $_getN(3);
  @$pb.TagNumber(4)
  set localConversationRecordKey($0.TypedKey v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasLocalConversationRecordKey() => $_has(3);
  @$pb.TagNumber(4)
  void clearLocalConversationRecordKey() => clearField(4);
  @$pb.TagNumber(4)
  $0.TypedKey ensureLocalConversationRecordKey() => $_ensure(3);

  @$pb.TagNumber(5)
  $fixnum.Int64 get expiration => $_getI64(4);
  @$pb.TagNumber(5)
  set expiration($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasExpiration() => $_has(4);
  @$pb.TagNumber(5)
  void clearExpiration() => clearField(5);

  @$pb.TagNumber(6)
  $core.List<$core.int> get invitation => $_getN(5);
  @$pb.TagNumber(6)
  set invitation($core.List<$core.int> v) { $_setBytes(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasInvitation() => $_has(5);
  @$pb.TagNumber(6)
  void clearInvitation() => clearField(6);

  @$pb.TagNumber(7)
  $core.String get message => $_getSZ(6);
  @$pb.TagNumber(7)
  set message($core.String v) { $_setString(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasMessage() => $_has(6);
  @$pb.TagNumber(7)
  void clearMessage() => clearField(7);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
