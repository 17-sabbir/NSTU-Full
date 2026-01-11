/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

abstract class PrescriptionList
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  PrescriptionList._({
    required this.prescriptionId,
    required this.date,
    required this.doctorName,
  });

  factory PrescriptionList({
    required int prescriptionId,
    required DateTime date,
    required String doctorName,
  }) = _PrescriptionListImpl;

  factory PrescriptionList.fromJson(Map<String, dynamic> jsonSerialization) {
    return PrescriptionList(
      prescriptionId: jsonSerialization['prescriptionId'] as int,
      date: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['date']),
      doctorName: jsonSerialization['doctorName'] as String,
    );
  }

  int prescriptionId;

  DateTime date;

  String doctorName;

  /// Returns a shallow copy of this [PrescriptionList]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PrescriptionList copyWith({
    int? prescriptionId,
    DateTime? date,
    String? doctorName,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PrescriptionList',
      'prescriptionId': prescriptionId,
      'date': date.toJson(),
      'doctorName': doctorName,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PrescriptionList',
      'prescriptionId': prescriptionId,
      'date': date.toJson(),
      'doctorName': doctorName,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _PrescriptionListImpl extends PrescriptionList {
  _PrescriptionListImpl({
    required int prescriptionId,
    required DateTime date,
    required String doctorName,
  }) : super._(
         prescriptionId: prescriptionId,
         date: date,
         doctorName: doctorName,
       );

  /// Returns a shallow copy of this [PrescriptionList]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PrescriptionList copyWith({
    int? prescriptionId,
    DateTime? date,
    String? doctorName,
  }) {
    return PrescriptionList(
      prescriptionId: prescriptionId ?? this.prescriptionId,
      date: date ?? this.date,
      doctorName: doctorName ?? this.doctorName,
    );
  }
}
