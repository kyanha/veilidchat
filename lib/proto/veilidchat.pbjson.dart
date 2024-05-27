//
//  Generated code. Do not modify.
//  source: veilidchat.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use availabilityDescriptor instead')
const Availability$json = {
  '1': 'Availability',
  '2': [
    {'1': 'AVAILABILITY_UNSPECIFIED', '2': 0},
    {'1': 'AVAILABILITY_OFFLINE', '2': 1},
    {'1': 'AVAILABILITY_FREE', '2': 2},
    {'1': 'AVAILABILITY_BUSY', '2': 3},
    {'1': 'AVAILABILITY_AWAY', '2': 4},
  ],
};

/// Descriptor for `Availability`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List availabilityDescriptor = $convert.base64Decode(
    'CgxBdmFpbGFiaWxpdHkSHAoYQVZBSUxBQklMSVRZX1VOU1BFQ0lGSUVEEAASGAoUQVZBSUxBQk'
    'lMSVRZX09GRkxJTkUQARIVChFBVkFJTEFCSUxJVFlfRlJFRRACEhUKEUFWQUlMQUJJTElUWV9C'
    'VVNZEAMSFQoRQVZBSUxBQklMSVRZX0FXQVkQBA==');

@$core.Deprecated('Use encryptionKeyTypeDescriptor instead')
const EncryptionKeyType$json = {
  '1': 'EncryptionKeyType',
  '2': [
    {'1': 'ENCRYPTION_KEY_TYPE_UNSPECIFIED', '2': 0},
    {'1': 'ENCRYPTION_KEY_TYPE_NONE', '2': 1},
    {'1': 'ENCRYPTION_KEY_TYPE_PIN', '2': 2},
    {'1': 'ENCRYPTION_KEY_TYPE_PASSWORD', '2': 3},
  ],
};

/// Descriptor for `EncryptionKeyType`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List encryptionKeyTypeDescriptor = $convert.base64Decode(
    'ChFFbmNyeXB0aW9uS2V5VHlwZRIjCh9FTkNSWVBUSU9OX0tFWV9UWVBFX1VOU1BFQ0lGSUVEEA'
    'ASHAoYRU5DUllQVElPTl9LRVlfVFlQRV9OT05FEAESGwoXRU5DUllQVElPTl9LRVlfVFlQRV9Q'
    'SU4QAhIgChxFTkNSWVBUSU9OX0tFWV9UWVBFX1BBU1NXT1JEEAM=');

@$core.Deprecated('Use scopeDescriptor instead')
const Scope$json = {
  '1': 'Scope',
  '2': [
    {'1': 'WATCHERS', '2': 0},
    {'1': 'MODERATED', '2': 1},
    {'1': 'TALKERS', '2': 2},
    {'1': 'MODERATORS', '2': 3},
    {'1': 'ADMINS', '2': 4},
  ],
};

/// Descriptor for `Scope`. Decode as a `google.protobuf.EnumDescriptorProto`.
final $typed_data.Uint8List scopeDescriptor = $convert.base64Decode(
    'CgVTY29wZRIMCghXQVRDSEVSUxAAEg0KCU1PREVSQVRFRBABEgsKB1RBTEtFUlMQAhIOCgpNT0'
    'RFUkFUT1JTEAMSCgoGQURNSU5TEAQ=');

@$core.Deprecated('Use attachmentDescriptor instead')
const Attachment$json = {
  '1': 'Attachment',
  '2': [
    {'1': 'media', '3': 1, '4': 1, '5': 11, '6': '.veilidchat.AttachmentMedia', '9': 0, '10': 'media'},
    {'1': 'signature', '3': 2, '4': 1, '5': 11, '6': '.veilid.Signature', '10': 'signature'},
  ],
  '8': [
    {'1': 'kind'},
  ],
};

/// Descriptor for `Attachment`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List attachmentDescriptor = $convert.base64Decode(
    'CgpBdHRhY2htZW50EjMKBW1lZGlhGAEgASgLMhsudmVpbGlkY2hhdC5BdHRhY2htZW50TWVkaW'
    'FIAFIFbWVkaWESLwoJc2lnbmF0dXJlGAIgASgLMhEudmVpbGlkLlNpZ25hdHVyZVIJc2lnbmF0'
    'dXJlQgYKBGtpbmQ=');

@$core.Deprecated('Use attachmentMediaDescriptor instead')
const AttachmentMedia$json = {
  '1': 'AttachmentMedia',
  '2': [
    {'1': 'mime', '3': 1, '4': 1, '5': 9, '10': 'mime'},
    {'1': 'name', '3': 2, '4': 1, '5': 9, '10': 'name'},
    {'1': 'content', '3': 3, '4': 1, '5': 11, '6': '.dht.DataReference', '10': 'content'},
  ],
};

/// Descriptor for `AttachmentMedia`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List attachmentMediaDescriptor = $convert.base64Decode(
    'Cg9BdHRhY2htZW50TWVkaWESEgoEbWltZRgBIAEoCVIEbWltZRISCgRuYW1lGAIgASgJUgRuYW'
    '1lEiwKB2NvbnRlbnQYAyABKAsyEi5kaHQuRGF0YVJlZmVyZW5jZVIHY29udGVudA==');

@$core.Deprecated('Use permissionsDescriptor instead')
const Permissions$json = {
  '1': 'Permissions',
  '2': [
    {'1': 'can_add_members', '3': 1, '4': 1, '5': 14, '6': '.veilidchat.Scope', '10': 'canAddMembers'},
    {'1': 'can_edit_info', '3': 2, '4': 1, '5': 14, '6': '.veilidchat.Scope', '10': 'canEditInfo'},
    {'1': 'moderated', '3': 3, '4': 1, '5': 8, '10': 'moderated'},
  ],
};

/// Descriptor for `Permissions`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List permissionsDescriptor = $convert.base64Decode(
    'CgtQZXJtaXNzaW9ucxI5Cg9jYW5fYWRkX21lbWJlcnMYASABKA4yES52ZWlsaWRjaGF0LlNjb3'
    'BlUg1jYW5BZGRNZW1iZXJzEjUKDWNhbl9lZGl0X2luZm8YAiABKA4yES52ZWlsaWRjaGF0LlNj'
    'b3BlUgtjYW5FZGl0SW5mbxIcCgltb2RlcmF0ZWQYAyABKAhSCW1vZGVyYXRlZA==');

@$core.Deprecated('Use membershipDescriptor instead')
const Membership$json = {
  '1': 'Membership',
  '2': [
    {'1': 'watchers', '3': 1, '4': 3, '5': 11, '6': '.veilid.TypedKey', '10': 'watchers'},
    {'1': 'moderated', '3': 2, '4': 3, '5': 11, '6': '.veilid.TypedKey', '10': 'moderated'},
    {'1': 'talkers', '3': 3, '4': 3, '5': 11, '6': '.veilid.TypedKey', '10': 'talkers'},
    {'1': 'moderators', '3': 4, '4': 3, '5': 11, '6': '.veilid.TypedKey', '10': 'moderators'},
    {'1': 'admins', '3': 5, '4': 3, '5': 11, '6': '.veilid.TypedKey', '10': 'admins'},
  ],
};

/// Descriptor for `Membership`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List membershipDescriptor = $convert.base64Decode(
    'CgpNZW1iZXJzaGlwEiwKCHdhdGNoZXJzGAEgAygLMhAudmVpbGlkLlR5cGVkS2V5Ugh3YXRjaG'
    'VycxIuCgltb2RlcmF0ZWQYAiADKAsyEC52ZWlsaWQuVHlwZWRLZXlSCW1vZGVyYXRlZBIqCgd0'
    'YWxrZXJzGAMgAygLMhAudmVpbGlkLlR5cGVkS2V5Ugd0YWxrZXJzEjAKCm1vZGVyYXRvcnMYBC'
    'ADKAsyEC52ZWlsaWQuVHlwZWRLZXlSCm1vZGVyYXRvcnMSKAoGYWRtaW5zGAUgAygLMhAudmVp'
    'bGlkLlR5cGVkS2V5UgZhZG1pbnM=');

@$core.Deprecated('Use chatSettingsDescriptor instead')
const ChatSettings$json = {
  '1': 'ChatSettings',
  '2': [
    {'1': 'title', '3': 1, '4': 1, '5': 9, '10': 'title'},
    {'1': 'description', '3': 2, '4': 1, '5': 9, '10': 'description'},
    {'1': 'icon', '3': 3, '4': 1, '5': 11, '6': '.dht.DataReference', '9': 0, '10': 'icon', '17': true},
    {'1': 'default_expiration', '3': 4, '4': 1, '5': 4, '10': 'defaultExpiration'},
  ],
  '8': [
    {'1': '_icon'},
  ],
};

/// Descriptor for `ChatSettings`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatSettingsDescriptor = $convert.base64Decode(
    'CgxDaGF0U2V0dGluZ3MSFAoFdGl0bGUYASABKAlSBXRpdGxlEiAKC2Rlc2NyaXB0aW9uGAIgAS'
    'gJUgtkZXNjcmlwdGlvbhIrCgRpY29uGAMgASgLMhIuZGh0LkRhdGFSZWZlcmVuY2VIAFIEaWNv'
    'bogBARItChJkZWZhdWx0X2V4cGlyYXRpb24YBCABKARSEWRlZmF1bHRFeHBpcmF0aW9uQgcKBV'
    '9pY29u');

@$core.Deprecated('Use messageDescriptor instead')
const Message$json = {
  '1': 'Message',
  '2': [
    {'1': 'id', '3': 1, '4': 1, '5': 12, '10': 'id'},
    {'1': 'author', '3': 2, '4': 1, '5': 11, '6': '.veilid.TypedKey', '10': 'author'},
    {'1': 'timestamp', '3': 3, '4': 1, '5': 4, '10': 'timestamp'},
    {'1': 'text', '3': 4, '4': 1, '5': 11, '6': '.veilidchat.Message.Text', '9': 0, '10': 'text'},
    {'1': 'secret', '3': 5, '4': 1, '5': 11, '6': '.veilidchat.Message.Secret', '9': 0, '10': 'secret'},
    {'1': 'delete', '3': 6, '4': 1, '5': 11, '6': '.veilidchat.Message.ControlDelete', '9': 0, '10': 'delete'},
    {'1': 'erase', '3': 7, '4': 1, '5': 11, '6': '.veilidchat.Message.ControlErase', '9': 0, '10': 'erase'},
    {'1': 'settings', '3': 8, '4': 1, '5': 11, '6': '.veilidchat.Message.ControlSettings', '9': 0, '10': 'settings'},
    {'1': 'permissions', '3': 9, '4': 1, '5': 11, '6': '.veilidchat.Message.ControlPermissions', '9': 0, '10': 'permissions'},
    {'1': 'membership', '3': 10, '4': 1, '5': 11, '6': '.veilidchat.Message.ControlMembership', '9': 0, '10': 'membership'},
    {'1': 'moderation', '3': 11, '4': 1, '5': 11, '6': '.veilidchat.Message.ControlModeration', '9': 0, '10': 'moderation'},
    {'1': 'signature', '3': 12, '4': 1, '5': 11, '6': '.veilid.Signature', '10': 'signature'},
  ],
  '3': [Message_Text$json, Message_Secret$json, Message_ControlDelete$json, Message_ControlErase$json, Message_ControlSettings$json, Message_ControlPermissions$json, Message_ControlMembership$json, Message_ControlModeration$json],
  '8': [
    {'1': 'kind'},
  ],
};

@$core.Deprecated('Use messageDescriptor instead')
const Message_Text$json = {
  '1': 'Text',
  '2': [
    {'1': 'text', '3': 1, '4': 1, '5': 9, '10': 'text'},
    {'1': 'topic', '3': 2, '4': 1, '5': 9, '9': 0, '10': 'topic', '17': true},
    {'1': 'reply_id', '3': 3, '4': 1, '5': 12, '9': 1, '10': 'replyId', '17': true},
    {'1': 'expiration', '3': 4, '4': 1, '5': 4, '10': 'expiration'},
    {'1': 'view_limit', '3': 5, '4': 1, '5': 13, '10': 'viewLimit'},
    {'1': 'attachments', '3': 6, '4': 3, '5': 11, '6': '.veilidchat.Attachment', '10': 'attachments'},
  ],
  '8': [
    {'1': '_topic'},
    {'1': '_reply_id'},
  ],
};

@$core.Deprecated('Use messageDescriptor instead')
const Message_Secret$json = {
  '1': 'Secret',
  '2': [
    {'1': 'ciphertext', '3': 1, '4': 1, '5': 12, '10': 'ciphertext'},
    {'1': 'expiration', '3': 2, '4': 1, '5': 4, '10': 'expiration'},
  ],
};

@$core.Deprecated('Use messageDescriptor instead')
const Message_ControlDelete$json = {
  '1': 'ControlDelete',
  '2': [
    {'1': 'ids', '3': 1, '4': 3, '5': 11, '6': '.veilid.TypedKey', '10': 'ids'},
  ],
};

@$core.Deprecated('Use messageDescriptor instead')
const Message_ControlErase$json = {
  '1': 'ControlErase',
  '2': [
    {'1': 'timestamp', '3': 1, '4': 1, '5': 4, '10': 'timestamp'},
  ],
};

@$core.Deprecated('Use messageDescriptor instead')
const Message_ControlSettings$json = {
  '1': 'ControlSettings',
  '2': [
    {'1': 'settings', '3': 1, '4': 1, '5': 11, '6': '.veilidchat.ChatSettings', '10': 'settings'},
  ],
};

@$core.Deprecated('Use messageDescriptor instead')
const Message_ControlPermissions$json = {
  '1': 'ControlPermissions',
  '2': [
    {'1': 'permissions', '3': 1, '4': 1, '5': 11, '6': '.veilidchat.Permissions', '10': 'permissions'},
  ],
};

@$core.Deprecated('Use messageDescriptor instead')
const Message_ControlMembership$json = {
  '1': 'ControlMembership',
  '2': [
    {'1': 'membership', '3': 1, '4': 1, '5': 11, '6': '.veilidchat.Membership', '10': 'membership'},
  ],
};

@$core.Deprecated('Use messageDescriptor instead')
const Message_ControlModeration$json = {
  '1': 'ControlModeration',
  '2': [
    {'1': 'accepted_ids', '3': 1, '4': 3, '5': 11, '6': '.veilid.TypedKey', '10': 'acceptedIds'},
    {'1': 'rejected_ids', '3': 2, '4': 3, '5': 11, '6': '.veilid.TypedKey', '10': 'rejectedIds'},
  ],
};

/// Descriptor for `Message`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List messageDescriptor = $convert.base64Decode(
    'CgdNZXNzYWdlEg4KAmlkGAEgASgMUgJpZBIoCgZhdXRob3IYAiABKAsyEC52ZWlsaWQuVHlwZW'
    'RLZXlSBmF1dGhvchIcCgl0aW1lc3RhbXAYAyABKARSCXRpbWVzdGFtcBIuCgR0ZXh0GAQgASgL'
    'MhgudmVpbGlkY2hhdC5NZXNzYWdlLlRleHRIAFIEdGV4dBI0CgZzZWNyZXQYBSABKAsyGi52ZW'
    'lsaWRjaGF0Lk1lc3NhZ2UuU2VjcmV0SABSBnNlY3JldBI7CgZkZWxldGUYBiABKAsyIS52ZWls'
    'aWRjaGF0Lk1lc3NhZ2UuQ29udHJvbERlbGV0ZUgAUgZkZWxldGUSOAoFZXJhc2UYByABKAsyIC'
    '52ZWlsaWRjaGF0Lk1lc3NhZ2UuQ29udHJvbEVyYXNlSABSBWVyYXNlEkEKCHNldHRpbmdzGAgg'
    'ASgLMiMudmVpbGlkY2hhdC5NZXNzYWdlLkNvbnRyb2xTZXR0aW5nc0gAUghzZXR0aW5ncxJKCg'
    'twZXJtaXNzaW9ucxgJIAEoCzImLnZlaWxpZGNoYXQuTWVzc2FnZS5Db250cm9sUGVybWlzc2lv'
    'bnNIAFILcGVybWlzc2lvbnMSRwoKbWVtYmVyc2hpcBgKIAEoCzIlLnZlaWxpZGNoYXQuTWVzc2'
    'FnZS5Db250cm9sTWVtYmVyc2hpcEgAUgptZW1iZXJzaGlwEkcKCm1vZGVyYXRpb24YCyABKAsy'
    'JS52ZWlsaWRjaGF0Lk1lc3NhZ2UuQ29udHJvbE1vZGVyYXRpb25IAFIKbW9kZXJhdGlvbhIvCg'
    'lzaWduYXR1cmUYDCABKAsyES52ZWlsaWQuU2lnbmF0dXJlUglzaWduYXR1cmUa5QEKBFRleHQS'
    'EgoEdGV4dBgBIAEoCVIEdGV4dBIZCgV0b3BpYxgCIAEoCUgAUgV0b3BpY4gBARIeCghyZXBseV'
    '9pZBgDIAEoDEgBUgdyZXBseUlkiAEBEh4KCmV4cGlyYXRpb24YBCABKARSCmV4cGlyYXRpb24S'
    'HQoKdmlld19saW1pdBgFIAEoDVIJdmlld0xpbWl0EjgKC2F0dGFjaG1lbnRzGAYgAygLMhYudm'
    'VpbGlkY2hhdC5BdHRhY2htZW50UgthdHRhY2htZW50c0IICgZfdG9waWNCCwoJX3JlcGx5X2lk'
    'GkgKBlNlY3JldBIeCgpjaXBoZXJ0ZXh0GAEgASgMUgpjaXBoZXJ0ZXh0Eh4KCmV4cGlyYXRpb2'
    '4YAiABKARSCmV4cGlyYXRpb24aMwoNQ29udHJvbERlbGV0ZRIiCgNpZHMYASADKAsyEC52ZWls'
    'aWQuVHlwZWRLZXlSA2lkcxosCgxDb250cm9sRXJhc2USHAoJdGltZXN0YW1wGAEgASgEUgl0aW'
    '1lc3RhbXAaRwoPQ29udHJvbFNldHRpbmdzEjQKCHNldHRpbmdzGAEgASgLMhgudmVpbGlkY2hh'
    'dC5DaGF0U2V0dGluZ3NSCHNldHRpbmdzGk8KEkNvbnRyb2xQZXJtaXNzaW9ucxI5CgtwZXJtaX'
    'NzaW9ucxgBIAEoCzIXLnZlaWxpZGNoYXQuUGVybWlzc2lvbnNSC3Blcm1pc3Npb25zGksKEUNv'
    'bnRyb2xNZW1iZXJzaGlwEjYKCm1lbWJlcnNoaXAYASABKAsyFi52ZWlsaWRjaGF0Lk1lbWJlcn'
    'NoaXBSCm1lbWJlcnNoaXAafQoRQ29udHJvbE1vZGVyYXRpb24SMwoMYWNjZXB0ZWRfaWRzGAEg'
    'AygLMhAudmVpbGlkLlR5cGVkS2V5UgthY2NlcHRlZElkcxIzCgxyZWplY3RlZF9pZHMYAiADKA'
    'syEC52ZWlsaWQuVHlwZWRLZXlSC3JlamVjdGVkSWRzQgYKBGtpbmQ=');

@$core.Deprecated('Use reconciledMessageDescriptor instead')
const ReconciledMessage$json = {
  '1': 'ReconciledMessage',
  '2': [
    {'1': 'content', '3': 1, '4': 1, '5': 11, '6': '.veilidchat.Message', '10': 'content'},
    {'1': 'reconciled_time', '3': 2, '4': 1, '5': 4, '10': 'reconciledTime'},
  ],
};

/// Descriptor for `ReconciledMessage`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List reconciledMessageDescriptor = $convert.base64Decode(
    'ChFSZWNvbmNpbGVkTWVzc2FnZRItCgdjb250ZW50GAEgASgLMhMudmVpbGlkY2hhdC5NZXNzYW'
    'dlUgdjb250ZW50EicKD3JlY29uY2lsZWRfdGltZRgCIAEoBFIOcmVjb25jaWxlZFRpbWU=');

@$core.Deprecated('Use conversationDescriptor instead')
const Conversation$json = {
  '1': 'Conversation',
  '2': [
    {'1': 'profile', '3': 1, '4': 1, '5': 11, '6': '.veilidchat.Profile', '10': 'profile'},
    {'1': 'identity_master_json', '3': 2, '4': 1, '5': 9, '10': 'identityMasterJson'},
    {'1': 'messages', '3': 3, '4': 1, '5': 11, '6': '.veilid.TypedKey', '10': 'messages'},
  ],
};

/// Descriptor for `Conversation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List conversationDescriptor = $convert.base64Decode(
    'CgxDb252ZXJzYXRpb24SLQoHcHJvZmlsZRgBIAEoCzITLnZlaWxpZGNoYXQuUHJvZmlsZVIHcH'
    'JvZmlsZRIwChRpZGVudGl0eV9tYXN0ZXJfanNvbhgCIAEoCVISaWRlbnRpdHlNYXN0ZXJKc29u'
    'EiwKCG1lc3NhZ2VzGAMgASgLMhAudmVpbGlkLlR5cGVkS2V5UghtZXNzYWdlcw==');

@$core.Deprecated('Use chatDescriptor instead')
const Chat$json = {
  '1': 'Chat',
  '2': [
    {'1': 'settings', '3': 1, '4': 1, '5': 11, '6': '.veilidchat.ChatSettings', '10': 'settings'},
    {'1': 'local_conversation_record_key', '3': 2, '4': 1, '5': 11, '6': '.veilid.TypedKey', '10': 'localConversationRecordKey'},
    {'1': 'remote_conversation_record_key', '3': 3, '4': 1, '5': 11, '6': '.veilid.TypedKey', '10': 'remoteConversationRecordKey'},
  ],
};

/// Descriptor for `Chat`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List chatDescriptor = $convert.base64Decode(
    'CgRDaGF0EjQKCHNldHRpbmdzGAEgASgLMhgudmVpbGlkY2hhdC5DaGF0U2V0dGluZ3NSCHNldH'
    'RpbmdzElMKHWxvY2FsX2NvbnZlcnNhdGlvbl9yZWNvcmRfa2V5GAIgASgLMhAudmVpbGlkLlR5'
    'cGVkS2V5Uhpsb2NhbENvbnZlcnNhdGlvblJlY29yZEtleRJVCh5yZW1vdGVfY29udmVyc2F0aW'
    '9uX3JlY29yZF9rZXkYAyABKAsyEC52ZWlsaWQuVHlwZWRLZXlSG3JlbW90ZUNvbnZlcnNhdGlv'
    'blJlY29yZEtleQ==');

@$core.Deprecated('Use groupChatDescriptor instead')
const GroupChat$json = {
  '1': 'GroupChat',
  '2': [
    {'1': 'settings', '3': 1, '4': 1, '5': 11, '6': '.veilidchat.ChatSettings', '10': 'settings'},
    {'1': 'local_conversation_record_key', '3': 2, '4': 1, '5': 11, '6': '.veilid.TypedKey', '10': 'localConversationRecordKey'},
    {'1': 'remote_conversation_record_keys', '3': 3, '4': 3, '5': 11, '6': '.veilid.TypedKey', '10': 'remoteConversationRecordKeys'},
  ],
};

/// Descriptor for `GroupChat`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List groupChatDescriptor = $convert.base64Decode(
    'CglHcm91cENoYXQSNAoIc2V0dGluZ3MYASABKAsyGC52ZWlsaWRjaGF0LkNoYXRTZXR0aW5nc1'
    'IIc2V0dGluZ3MSUwodbG9jYWxfY29udmVyc2F0aW9uX3JlY29yZF9rZXkYAiABKAsyEC52ZWls'
    'aWQuVHlwZWRLZXlSGmxvY2FsQ29udmVyc2F0aW9uUmVjb3JkS2V5ElcKH3JlbW90ZV9jb252ZX'
    'JzYXRpb25fcmVjb3JkX2tleXMYAyADKAsyEC52ZWlsaWQuVHlwZWRLZXlSHHJlbW90ZUNvbnZl'
    'cnNhdGlvblJlY29yZEtleXM=');

@$core.Deprecated('Use profileDescriptor instead')
const Profile$json = {
  '1': 'Profile',
  '2': [
    {'1': 'name', '3': 1, '4': 1, '5': 9, '10': 'name'},
    {'1': 'pronouns', '3': 2, '4': 1, '5': 9, '10': 'pronouns'},
    {'1': 'about', '3': 3, '4': 1, '5': 9, '10': 'about'},
    {'1': 'status', '3': 4, '4': 1, '5': 9, '10': 'status'},
    {'1': 'availability', '3': 5, '4': 1, '5': 14, '6': '.veilidchat.Availability', '10': 'availability'},
    {'1': 'avatar', '3': 6, '4': 1, '5': 11, '6': '.veilid.TypedKey', '9': 0, '10': 'avatar', '17': true},
  ],
  '8': [
    {'1': '_avatar'},
  ],
};

/// Descriptor for `Profile`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List profileDescriptor = $convert.base64Decode(
    'CgdQcm9maWxlEhIKBG5hbWUYASABKAlSBG5hbWUSGgoIcHJvbm91bnMYAiABKAlSCHByb25vdW'
    '5zEhQKBWFib3V0GAMgASgJUgVhYm91dBIWCgZzdGF0dXMYBCABKAlSBnN0YXR1cxI8CgxhdmFp'
    'bGFiaWxpdHkYBSABKA4yGC52ZWlsaWRjaGF0LkF2YWlsYWJpbGl0eVIMYXZhaWxhYmlsaXR5Ei'
    '0KBmF2YXRhchgGIAEoCzIQLnZlaWxpZC5UeXBlZEtleUgAUgZhdmF0YXKIAQFCCQoHX2F2YXRh'
    'cg==');

@$core.Deprecated('Use accountDescriptor instead')
const Account$json = {
  '1': 'Account',
  '2': [
    {'1': 'profile', '3': 1, '4': 1, '5': 11, '6': '.veilidchat.Profile', '10': 'profile'},
    {'1': 'invisible', '3': 2, '4': 1, '5': 8, '10': 'invisible'},
    {'1': 'auto_away_timeout_sec', '3': 3, '4': 1, '5': 13, '10': 'autoAwayTimeoutSec'},
    {'1': 'contact_list', '3': 4, '4': 1, '5': 11, '6': '.dht.OwnedDHTRecordPointer', '10': 'contactList'},
    {'1': 'contact_invitation_records', '3': 5, '4': 1, '5': 11, '6': '.dht.OwnedDHTRecordPointer', '10': 'contactInvitationRecords'},
    {'1': 'chat_list', '3': 6, '4': 1, '5': 11, '6': '.dht.OwnedDHTRecordPointer', '10': 'chatList'},
    {'1': 'group_chat_list', '3': 7, '4': 1, '5': 11, '6': '.dht.OwnedDHTRecordPointer', '10': 'groupChatList'},
  ],
};

/// Descriptor for `Account`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List accountDescriptor = $convert.base64Decode(
    'CgdBY2NvdW50Ei0KB3Byb2ZpbGUYASABKAsyEy52ZWlsaWRjaGF0LlByb2ZpbGVSB3Byb2ZpbG'
    'USHAoJaW52aXNpYmxlGAIgASgIUglpbnZpc2libGUSMQoVYXV0b19hd2F5X3RpbWVvdXRfc2Vj'
    'GAMgASgNUhJhdXRvQXdheVRpbWVvdXRTZWMSPQoMY29udGFjdF9saXN0GAQgASgLMhouZGh0Lk'
    '93bmVkREhUUmVjb3JkUG9pbnRlclILY29udGFjdExpc3QSWAoaY29udGFjdF9pbnZpdGF0aW9u'
    'X3JlY29yZHMYBSABKAsyGi5kaHQuT3duZWRESFRSZWNvcmRQb2ludGVyUhhjb250YWN0SW52aX'
    'RhdGlvblJlY29yZHMSNwoJY2hhdF9saXN0GAYgASgLMhouZGh0Lk93bmVkREhUUmVjb3JkUG9p'
    'bnRlclIIY2hhdExpc3QSQgoPZ3JvdXBfY2hhdF9saXN0GAcgASgLMhouZGh0Lk93bmVkREhUUm'
    'Vjb3JkUG9pbnRlclINZ3JvdXBDaGF0TGlzdA==');

@$core.Deprecated('Use contactDescriptor instead')
const Contact$json = {
  '1': 'Contact',
  '2': [
    {'1': 'edited_profile', '3': 1, '4': 1, '5': 11, '6': '.veilidchat.Profile', '10': 'editedProfile'},
    {'1': 'remote_profile', '3': 2, '4': 1, '5': 11, '6': '.veilidchat.Profile', '10': 'remoteProfile'},
    {'1': 'identity_master_json', '3': 3, '4': 1, '5': 9, '10': 'identityMasterJson'},
    {'1': 'identity_public_key', '3': 4, '4': 1, '5': 11, '6': '.veilid.TypedKey', '10': 'identityPublicKey'},
    {'1': 'remote_conversation_record_key', '3': 5, '4': 1, '5': 11, '6': '.veilid.TypedKey', '10': 'remoteConversationRecordKey'},
    {'1': 'local_conversation_record_key', '3': 6, '4': 1, '5': 11, '6': '.veilid.TypedKey', '10': 'localConversationRecordKey'},
    {'1': 'show_availability', '3': 7, '4': 1, '5': 8, '10': 'showAvailability'},
  ],
};

/// Descriptor for `Contact`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contactDescriptor = $convert.base64Decode(
    'CgdDb250YWN0EjoKDmVkaXRlZF9wcm9maWxlGAEgASgLMhMudmVpbGlkY2hhdC5Qcm9maWxlUg'
    '1lZGl0ZWRQcm9maWxlEjoKDnJlbW90ZV9wcm9maWxlGAIgASgLMhMudmVpbGlkY2hhdC5Qcm9m'
    'aWxlUg1yZW1vdGVQcm9maWxlEjAKFGlkZW50aXR5X21hc3Rlcl9qc29uGAMgASgJUhJpZGVudG'
    'l0eU1hc3Rlckpzb24SQAoTaWRlbnRpdHlfcHVibGljX2tleRgEIAEoCzIQLnZlaWxpZC5UeXBl'
    'ZEtleVIRaWRlbnRpdHlQdWJsaWNLZXkSVQoecmVtb3RlX2NvbnZlcnNhdGlvbl9yZWNvcmRfa2'
    'V5GAUgASgLMhAudmVpbGlkLlR5cGVkS2V5UhtyZW1vdGVDb252ZXJzYXRpb25SZWNvcmRLZXkS'
    'UwodbG9jYWxfY29udmVyc2F0aW9uX3JlY29yZF9rZXkYBiABKAsyEC52ZWlsaWQuVHlwZWRLZX'
    'lSGmxvY2FsQ29udmVyc2F0aW9uUmVjb3JkS2V5EisKEXNob3dfYXZhaWxhYmlsaXR5GAcgASgI'
    'UhBzaG93QXZhaWxhYmlsaXR5');

@$core.Deprecated('Use contactInvitationDescriptor instead')
const ContactInvitation$json = {
  '1': 'ContactInvitation',
  '2': [
    {'1': 'contact_request_inbox_key', '3': 1, '4': 1, '5': 11, '6': '.veilid.TypedKey', '10': 'contactRequestInboxKey'},
    {'1': 'writer_secret', '3': 2, '4': 1, '5': 12, '10': 'writerSecret'},
  ],
};

/// Descriptor for `ContactInvitation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contactInvitationDescriptor = $convert.base64Decode(
    'ChFDb250YWN0SW52aXRhdGlvbhJLChljb250YWN0X3JlcXVlc3RfaW5ib3hfa2V5GAEgASgLMh'
    'AudmVpbGlkLlR5cGVkS2V5UhZjb250YWN0UmVxdWVzdEluYm94S2V5EiMKDXdyaXRlcl9zZWNy'
    'ZXQYAiABKAxSDHdyaXRlclNlY3JldA==');

@$core.Deprecated('Use signedContactInvitationDescriptor instead')
const SignedContactInvitation$json = {
  '1': 'SignedContactInvitation',
  '2': [
    {'1': 'contact_invitation', '3': 1, '4': 1, '5': 12, '10': 'contactInvitation'},
    {'1': 'identity_signature', '3': 2, '4': 1, '5': 11, '6': '.veilid.Signature', '10': 'identitySignature'},
  ],
};

/// Descriptor for `SignedContactInvitation`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List signedContactInvitationDescriptor = $convert.base64Decode(
    'ChdTaWduZWRDb250YWN0SW52aXRhdGlvbhItChJjb250YWN0X2ludml0YXRpb24YASABKAxSEW'
    'NvbnRhY3RJbnZpdGF0aW9uEkAKEmlkZW50aXR5X3NpZ25hdHVyZRgCIAEoCzIRLnZlaWxpZC5T'
    'aWduYXR1cmVSEWlkZW50aXR5U2lnbmF0dXJl');

@$core.Deprecated('Use contactRequestDescriptor instead')
const ContactRequest$json = {
  '1': 'ContactRequest',
  '2': [
    {'1': 'encryption_key_type', '3': 1, '4': 1, '5': 14, '6': '.veilidchat.EncryptionKeyType', '10': 'encryptionKeyType'},
    {'1': 'private', '3': 2, '4': 1, '5': 12, '10': 'private'},
  ],
};

/// Descriptor for `ContactRequest`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contactRequestDescriptor = $convert.base64Decode(
    'Cg5Db250YWN0UmVxdWVzdBJNChNlbmNyeXB0aW9uX2tleV90eXBlGAEgASgOMh0udmVpbGlkY2'
    'hhdC5FbmNyeXB0aW9uS2V5VHlwZVIRZW5jcnlwdGlvbktleVR5cGUSGAoHcHJpdmF0ZRgCIAEo'
    'DFIHcHJpdmF0ZQ==');

@$core.Deprecated('Use contactRequestPrivateDescriptor instead')
const ContactRequestPrivate$json = {
  '1': 'ContactRequestPrivate',
  '2': [
    {'1': 'writer_key', '3': 1, '4': 1, '5': 11, '6': '.veilid.CryptoKey', '10': 'writerKey'},
    {'1': 'profile', '3': 2, '4': 1, '5': 11, '6': '.veilidchat.Profile', '10': 'profile'},
    {'1': 'identity_master_record_key', '3': 3, '4': 1, '5': 11, '6': '.veilid.TypedKey', '10': 'identityMasterRecordKey'},
    {'1': 'chat_record_key', '3': 4, '4': 1, '5': 11, '6': '.veilid.TypedKey', '10': 'chatRecordKey'},
    {'1': 'expiration', '3': 5, '4': 1, '5': 4, '10': 'expiration'},
  ],
};

/// Descriptor for `ContactRequestPrivate`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contactRequestPrivateDescriptor = $convert.base64Decode(
    'ChVDb250YWN0UmVxdWVzdFByaXZhdGUSMAoKd3JpdGVyX2tleRgBIAEoCzIRLnZlaWxpZC5Dcn'
    'lwdG9LZXlSCXdyaXRlcktleRItCgdwcm9maWxlGAIgASgLMhMudmVpbGlkY2hhdC5Qcm9maWxl'
    'Ugdwcm9maWxlEk0KGmlkZW50aXR5X21hc3Rlcl9yZWNvcmRfa2V5GAMgASgLMhAudmVpbGlkLl'
    'R5cGVkS2V5UhdpZGVudGl0eU1hc3RlclJlY29yZEtleRI4Cg9jaGF0X3JlY29yZF9rZXkYBCAB'
    'KAsyEC52ZWlsaWQuVHlwZWRLZXlSDWNoYXRSZWNvcmRLZXkSHgoKZXhwaXJhdGlvbhgFIAEoBF'
    'IKZXhwaXJhdGlvbg==');

@$core.Deprecated('Use contactResponseDescriptor instead')
const ContactResponse$json = {
  '1': 'ContactResponse',
  '2': [
    {'1': 'accept', '3': 1, '4': 1, '5': 8, '10': 'accept'},
    {'1': 'identity_master_record_key', '3': 2, '4': 1, '5': 11, '6': '.veilid.TypedKey', '10': 'identityMasterRecordKey'},
    {'1': 'remote_conversation_record_key', '3': 3, '4': 1, '5': 11, '6': '.veilid.TypedKey', '10': 'remoteConversationRecordKey'},
  ],
};

/// Descriptor for `ContactResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contactResponseDescriptor = $convert.base64Decode(
    'Cg9Db250YWN0UmVzcG9uc2USFgoGYWNjZXB0GAEgASgIUgZhY2NlcHQSTQoaaWRlbnRpdHlfbW'
    'FzdGVyX3JlY29yZF9rZXkYAiABKAsyEC52ZWlsaWQuVHlwZWRLZXlSF2lkZW50aXR5TWFzdGVy'
    'UmVjb3JkS2V5ElUKHnJlbW90ZV9jb252ZXJzYXRpb25fcmVjb3JkX2tleRgDIAEoCzIQLnZlaW'
    'xpZC5UeXBlZEtleVIbcmVtb3RlQ29udmVyc2F0aW9uUmVjb3JkS2V5');

@$core.Deprecated('Use signedContactResponseDescriptor instead')
const SignedContactResponse$json = {
  '1': 'SignedContactResponse',
  '2': [
    {'1': 'contact_response', '3': 1, '4': 1, '5': 12, '10': 'contactResponse'},
    {'1': 'identity_signature', '3': 2, '4': 1, '5': 11, '6': '.veilid.Signature', '10': 'identitySignature'},
  ],
};

/// Descriptor for `SignedContactResponse`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List signedContactResponseDescriptor = $convert.base64Decode(
    'ChVTaWduZWRDb250YWN0UmVzcG9uc2USKQoQY29udGFjdF9yZXNwb25zZRgBIAEoDFIPY29udG'
    'FjdFJlc3BvbnNlEkAKEmlkZW50aXR5X3NpZ25hdHVyZRgCIAEoCzIRLnZlaWxpZC5TaWduYXR1'
    'cmVSEWlkZW50aXR5U2lnbmF0dXJl');

@$core.Deprecated('Use contactInvitationRecordDescriptor instead')
const ContactInvitationRecord$json = {
  '1': 'ContactInvitationRecord',
  '2': [
    {'1': 'contact_request_inbox', '3': 1, '4': 1, '5': 11, '6': '.dht.OwnedDHTRecordPointer', '10': 'contactRequestInbox'},
    {'1': 'writer_key', '3': 2, '4': 1, '5': 11, '6': '.veilid.CryptoKey', '10': 'writerKey'},
    {'1': 'writer_secret', '3': 3, '4': 1, '5': 11, '6': '.veilid.CryptoKey', '10': 'writerSecret'},
    {'1': 'local_conversation_record_key', '3': 4, '4': 1, '5': 11, '6': '.veilid.TypedKey', '10': 'localConversationRecordKey'},
    {'1': 'expiration', '3': 5, '4': 1, '5': 4, '10': 'expiration'},
    {'1': 'invitation', '3': 6, '4': 1, '5': 12, '10': 'invitation'},
    {'1': 'message', '3': 7, '4': 1, '5': 9, '10': 'message'},
  ],
};

/// Descriptor for `ContactInvitationRecord`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List contactInvitationRecordDescriptor = $convert.base64Decode(
    'ChdDb250YWN0SW52aXRhdGlvblJlY29yZBJOChVjb250YWN0X3JlcXVlc3RfaW5ib3gYASABKA'
    'syGi5kaHQuT3duZWRESFRSZWNvcmRQb2ludGVyUhNjb250YWN0UmVxdWVzdEluYm94EjAKCndy'
    'aXRlcl9rZXkYAiABKAsyES52ZWlsaWQuQ3J5cHRvS2V5Ugl3cml0ZXJLZXkSNgoNd3JpdGVyX3'
    'NlY3JldBgDIAEoCzIRLnZlaWxpZC5DcnlwdG9LZXlSDHdyaXRlclNlY3JldBJTCh1sb2NhbF9j'
    'b252ZXJzYXRpb25fcmVjb3JkX2tleRgEIAEoCzIQLnZlaWxpZC5UeXBlZEtleVIabG9jYWxDb2'
    '52ZXJzYXRpb25SZWNvcmRLZXkSHgoKZXhwaXJhdGlvbhgFIAEoBFIKZXhwaXJhdGlvbhIeCgpp'
    'bnZpdGF0aW9uGAYgASgMUgppbnZpdGF0aW9uEhgKB21lc3NhZ2UYByABKAlSB21lc3NhZ2U=');

