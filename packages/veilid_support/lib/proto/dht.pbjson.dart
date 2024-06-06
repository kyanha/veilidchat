//
//  Generated code. Do not modify.
//  source: dht.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use dHTDataDescriptor instead')
const DHTData$json = {
  '1': 'DHTData',
  '2': [
    {'1': 'keys', '3': 1, '4': 3, '5': 11, '6': '.veilid.TypedKey', '10': 'keys'},
    {'1': 'hash', '3': 2, '4': 1, '5': 11, '6': '.veilid.TypedKey', '10': 'hash'},
    {'1': 'chunk', '3': 3, '4': 1, '5': 13, '10': 'chunk'},
    {'1': 'size', '3': 4, '4': 1, '5': 13, '10': 'size'},
  ],
};

/// Descriptor for `DHTData`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dHTDataDescriptor = $convert.base64Decode(
    'CgdESFREYXRhEiQKBGtleXMYASADKAsyEC52ZWlsaWQuVHlwZWRLZXlSBGtleXMSJAoEaGFzaB'
    'gCIAEoCzIQLnZlaWxpZC5UeXBlZEtleVIEaGFzaBIUCgVjaHVuaxgDIAEoDVIFY2h1bmsSEgoE'
    'c2l6ZRgEIAEoDVIEc2l6ZQ==');

@$core.Deprecated('Use dHTLogDescriptor instead')
const DHTLog$json = {
  '1': 'DHTLog',
  '2': [
    {'1': 'head', '3': 1, '4': 1, '5': 13, '10': 'head'},
    {'1': 'tail', '3': 2, '4': 1, '5': 13, '10': 'tail'},
    {'1': 'stride', '3': 3, '4': 1, '5': 13, '10': 'stride'},
  ],
};

/// Descriptor for `DHTLog`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dHTLogDescriptor = $convert.base64Decode(
    'CgZESFRMb2cSEgoEaGVhZBgBIAEoDVIEaGVhZBISCgR0YWlsGAIgASgNUgR0YWlsEhYKBnN0cm'
    'lkZRgDIAEoDVIGc3RyaWRl');

@$core.Deprecated('Use dHTShortArrayDescriptor instead')
const DHTShortArray$json = {
  '1': 'DHTShortArray',
  '2': [
    {'1': 'keys', '3': 1, '4': 3, '5': 11, '6': '.veilid.TypedKey', '10': 'keys'},
    {'1': 'index', '3': 2, '4': 1, '5': 12, '10': 'index'},
    {'1': 'seqs', '3': 3, '4': 3, '5': 13, '10': 'seqs'},
  ],
};

/// Descriptor for `DHTShortArray`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dHTShortArrayDescriptor = $convert.base64Decode(
    'Cg1ESFRTaG9ydEFycmF5EiQKBGtleXMYASADKAsyEC52ZWlsaWQuVHlwZWRLZXlSBGtleXMSFA'
    'oFaW5kZXgYAiABKAxSBWluZGV4EhIKBHNlcXMYAyADKA1SBHNlcXM=');

@$core.Deprecated('Use dHTDataReferenceDescriptor instead')
const DHTDataReference$json = {
  '1': 'DHTDataReference',
  '2': [
    {'1': 'dht_data', '3': 1, '4': 1, '5': 11, '6': '.veilid.TypedKey', '10': 'dhtData'},
    {'1': 'hash', '3': 2, '4': 1, '5': 11, '6': '.veilid.TypedKey', '10': 'hash'},
  ],
};

/// Descriptor for `DHTDataReference`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dHTDataReferenceDescriptor = $convert.base64Decode(
    'ChBESFREYXRhUmVmZXJlbmNlEisKCGRodF9kYXRhGAEgASgLMhAudmVpbGlkLlR5cGVkS2V5Ug'
    'dkaHREYXRhEiQKBGhhc2gYAiABKAsyEC52ZWlsaWQuVHlwZWRLZXlSBGhhc2g=');

@$core.Deprecated('Use blockStoreDataReferenceDescriptor instead')
const BlockStoreDataReference$json = {
  '1': 'BlockStoreDataReference',
  '2': [
    {'1': 'block', '3': 1, '4': 1, '5': 11, '6': '.veilid.TypedKey', '10': 'block'},
  ],
};

/// Descriptor for `BlockStoreDataReference`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List blockStoreDataReferenceDescriptor = $convert.base64Decode(
    'ChdCbG9ja1N0b3JlRGF0YVJlZmVyZW5jZRImCgVibG9jaxgBIAEoCzIQLnZlaWxpZC5UeXBlZE'
    'tleVIFYmxvY2s=');

@$core.Deprecated('Use dataReferenceDescriptor instead')
const DataReference$json = {
  '1': 'DataReference',
  '2': [
    {'1': 'dht_data', '3': 1, '4': 1, '5': 11, '6': '.dht.DHTDataReference', '9': 0, '10': 'dhtData'},
    {'1': 'block_store_data', '3': 2, '4': 1, '5': 11, '6': '.dht.BlockStoreDataReference', '9': 0, '10': 'blockStoreData'},
  ],
  '8': [
    {'1': 'kind'},
  ],
};

/// Descriptor for `DataReference`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dataReferenceDescriptor = $convert.base64Decode(
    'Cg1EYXRhUmVmZXJlbmNlEjIKCGRodF9kYXRhGAEgASgLMhUuZGh0LkRIVERhdGFSZWZlcmVuY2'
    'VIAFIHZGh0RGF0YRJIChBibG9ja19zdG9yZV9kYXRhGAIgASgLMhwuZGh0LkJsb2NrU3RvcmVE'
    'YXRhUmVmZXJlbmNlSABSDmJsb2NrU3RvcmVEYXRhQgYKBGtpbmQ=');

@$core.Deprecated('Use ownedDHTRecordPointerDescriptor instead')
const OwnedDHTRecordPointer$json = {
  '1': 'OwnedDHTRecordPointer',
  '2': [
    {'1': 'record_key', '3': 1, '4': 1, '5': 11, '6': '.veilid.TypedKey', '10': 'recordKey'},
    {'1': 'owner', '3': 2, '4': 1, '5': 11, '6': '.veilid.KeyPair', '10': 'owner'},
  ],
};

/// Descriptor for `OwnedDHTRecordPointer`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List ownedDHTRecordPointerDescriptor = $convert.base64Decode(
    'ChVPd25lZERIVFJlY29yZFBvaW50ZXISLwoKcmVjb3JkX2tleRgBIAEoCzIQLnZlaWxpZC5UeX'
    'BlZEtleVIJcmVjb3JkS2V5EiUKBW93bmVyGAIgASgLMg8udmVpbGlkLktleVBhaXJSBW93bmVy');

