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
import '../endpoints/auth_endpoint.dart' as _i2;
import '../endpoints/dispenser_endpoints.dart' as _i3;
import '../endpoints/doctor_endpoints.dart' as _i4;
import '../endpoints/lab_endpoints.dart' as _i5;
import '../endpoints/notifications_endpoint.dart' as _i6;
import '../endpoints/password_endpoint.dart' as _i7;
import '../endpoints/patient_endpoints.dart' as _i8;
import '../greeting_endpoint.dart' as _i9;
import 'package:backend_server/src/generated/dispense_request.dart' as _i10;
import 'package:backend_server/src/generated/prescription.dart' as _i11;
import 'package:backend_server/src/generated/PrescribedItem.dart' as _i12;
import 'package:backend_server/src/generated/patient_return_tests.dart' as _i13;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'auth': _i2.AuthEndpoint()
        ..initialize(
          server,
          'auth',
          null,
        ),
      'dispenser': _i3.DispenserEndpoint()
        ..initialize(
          server,
          'dispenser',
          null,
        ),
      'doctor': _i4.DoctorEndpoint()
        ..initialize(
          server,
          'doctor',
          null,
        ),
      'lab': _i5.LabEndpoint()
        ..initialize(
          server,
          'lab',
          null,
        ),
      'notification': _i6.NotificationEndpoint()
        ..initialize(
          server,
          'notification',
          null,
        ),
      'password': _i7.PasswordEndpoint()
        ..initialize(
          server,
          'password',
          null,
        ),
      'patient': _i8.PatientEndpoint()
        ..initialize(
          server,
          'patient',
          null,
        ),
      'greeting': _i9.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
    };
    connectors['auth'] = _i1.EndpointConnector(
      name: 'auth',
      endpoint: endpoints['auth']!,
      methodConnectors: {
        'requestProfileEmailChangeOtp': _i1.MethodConnector(
          name: 'requestProfileEmailChangeOtp',
          params: {
            'newEmail': _i1.ParameterDescription(
              name: 'newEmail',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['auth'] as _i2.AuthEndpoint)
                  .requestProfileEmailChangeOtp(
                    session,
                    params['newEmail'],
                  ),
        ),
        'verifyProfileEmailChangeOtp': _i1.MethodConnector(
          name: 'verifyProfileEmailChangeOtp',
          params: {
            'newEmail': _i1.ParameterDescription(
              name: 'newEmail',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'otp': _i1.ParameterDescription(
              name: 'otp',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'otpToken': _i1.ParameterDescription(
              name: 'otpToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['auth'] as _i2.AuthEndpoint)
                  .verifyProfileEmailChangeOtp(
                    session,
                    params['newEmail'],
                    params['otp'],
                    params['otpToken'],
                  ),
        ),
        'updateMyEmailWithOtp': _i1.MethodConnector(
          name: 'updateMyEmailWithOtp',
          params: {
            'newEmail': _i1.ParameterDescription(
              name: 'newEmail',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'otp': _i1.ParameterDescription(
              name: 'otp',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'otpToken': _i1.ParameterDescription(
              name: 'otpToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['auth'] as _i2.AuthEndpoint).updateMyEmailWithOtp(
                    session,
                    params['newEmail'],
                    params['otp'],
                    params['otpToken'],
                  ),
        ),
        'login': _i1.MethodConnector(
          name: 'login',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'deviceId': _i1.ParameterDescription(
              name: 'deviceId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['auth'] as _i2.AuthEndpoint).login(
                session,
                params['email'],
                params['password'],
                deviceId: params['deviceId'],
              ),
        ),
        'startSignupPhoneOtp': _i1.MethodConnector(
          name: 'startSignupPhoneOtp',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'phone': _i1.ParameterDescription(
              name: 'phone',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['auth'] as _i2.AuthEndpoint).startSignupPhoneOtp(
                    session,
                    params['email'],
                    params['phone'],
                  ),
        ),
        'verifyLoginOtp': _i1.MethodConnector(
          name: 'verifyLoginOtp',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'otp': _i1.ParameterDescription(
              name: 'otp',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'otpToken': _i1.ParameterDescription(
              name: 'otpToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'deviceId': _i1.ParameterDescription(
              name: 'deviceId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['auth'] as _i2.AuthEndpoint).verifyLoginOtp(
                session,
                params['email'],
                params['otp'],
                params['otpToken'],
                deviceId: params['deviceId'],
              ),
        ),
        'logout': _i1.MethodConnector(
          name: 'logout',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['auth'] as _i2.AuthEndpoint).logout(session),
        ),
        'register': _i1.MethodConnector(
          name: 'register',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'role': _i1.ParameterDescription(
              name: 'role',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['auth'] as _i2.AuthEndpoint).register(
                session,
                params['email'],
                params['password'],
                params['name'],
                params['role'],
              ),
        ),
        'resendOtp': _i1.MethodConnector(
          name: 'resendOtp',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'role': _i1.ParameterDescription(
              name: 'role',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['auth'] as _i2.AuthEndpoint).resendOtp(
                session,
                params['email'],
                params['password'],
                params['name'],
                params['role'],
              ),
        ),
        'verifySignupEmailAndStartPhoneOtp': _i1.MethodConnector(
          name: 'verifySignupEmailAndStartPhoneOtp',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'emailOtp': _i1.ParameterDescription(
              name: 'emailOtp',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'emailOtpToken': _i1.ParameterDescription(
              name: 'emailOtpToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'phone': _i1.ParameterDescription(
              name: 'phone',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['auth'] as _i2.AuthEndpoint)
                  .verifySignupEmailAndStartPhoneOtp(
                    session,
                    params['email'],
                    params['emailOtp'],
                    params['emailOtpToken'],
                    params['phone'],
                  ),
        ),
        'completeSignupWithPhoneOtp': _i1.MethodConnector(
          name: 'completeSignupWithPhoneOtp',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'phone': _i1.ParameterDescription(
              name: 'phone',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'phoneOtp': _i1.ParameterDescription(
              name: 'phoneOtp',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'phoneOtpToken': _i1.ParameterDescription(
              name: 'phoneOtpToken',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'role': _i1.ParameterDescription(
              name: 'role',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'bloodGroup': _i1.ParameterDescription(
              name: 'bloodGroup',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'dateOfBirth': _i1.ParameterDescription(
              name: 'dateOfBirth',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            ),
            'gender': _i1.ParameterDescription(
              name: 'gender',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['auth'] as _i2.AuthEndpoint)
                  .completeSignupWithPhoneOtp(
                    session,
                    params['email'],
                    params['phone'],
                    params['phoneOtp'],
                    params['phoneOtpToken'],
                    params['password'],
                    params['name'],
                    params['role'],
                    params['bloodGroup'],
                    params['dateOfBirth'],
                    params['gender'],
                  ),
        ),
        'sendWelcomeEmailViaResend': _i1.MethodConnector(
          name: 'sendWelcomeEmailViaResend',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['auth'] as _i2.AuthEndpoint)
                  .sendWelcomeEmailViaResend(
                    session,
                    params['email'],
                    params['name'],
                  ),
        ),
        'verifyOtp': _i1.MethodConnector(
          name: 'verifyOtp',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'otp': _i1.ParameterDescription(
              name: 'otp',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'token': _i1.ParameterDescription(
              name: 'token',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'password': _i1.ParameterDescription(
              name: 'password',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'role': _i1.ParameterDescription(
              name: 'role',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'phone': _i1.ParameterDescription(
              name: 'phone',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'bloodGroup': _i1.ParameterDescription(
              name: 'bloodGroup',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'allergies': _i1.ParameterDescription(
              name: 'allergies',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['auth'] as _i2.AuthEndpoint).verifyOtp(
                session,
                params['email'],
                params['otp'],
                params['token'],
                params['password'],
                params['name'],
                params['role'],
                params['phone'],
                params['bloodGroup'],
                params['allergies'],
              ),
        ),
        'requestPasswordReset': _i1.MethodConnector(
          name: 'requestPasswordReset',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['auth'] as _i2.AuthEndpoint).requestPasswordReset(
                    session,
                    params['email'],
                  ),
        ),
        'verifyPasswordReset': _i1.MethodConnector(
          name: 'verifyPasswordReset',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'otp': _i1.ParameterDescription(
              name: 'otp',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'token': _i1.ParameterDescription(
              name: 'token',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['auth'] as _i2.AuthEndpoint).verifyPasswordReset(
                    session,
                    params['email'],
                    params['otp'],
                    params['token'],
                  ),
        ),
        'resetPassword': _i1.MethodConnector(
          name: 'resetPassword',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'token': _i1.ParameterDescription(
              name: 'token',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'newPassword': _i1.ParameterDescription(
              name: 'newPassword',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['auth'] as _i2.AuthEndpoint).resetPassword(
                session,
                params['email'],
                params['token'],
                params['newPassword'],
              ),
        ),
        'changePasswordUniversal': _i1.MethodConnector(
          name: 'changePasswordUniversal',
          params: {
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'currentPassword': _i1.ParameterDescription(
              name: 'currentPassword',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'newPassword': _i1.ParameterDescription(
              name: 'newPassword',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['auth'] as _i2.AuthEndpoint)
                  .changePasswordUniversal(
                    session,
                    params['email'],
                    params['currentPassword'],
                    params['newPassword'],
                  ),
        ),
      },
    );
    connectors['dispenser'] = _i1.EndpointConnector(
      name: 'dispenser',
      endpoint: endpoints['dispenser']!,
      methodConnectors: {
        'getDispenserProfile': _i1.MethodConnector(
          name: 'getDispenserProfile',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['dispenser'] as _i3.DispenserEndpoint)
                  .getDispenserProfile(session),
        ),
        'updateDispenserProfile': _i1.MethodConnector(
          name: 'updateDispenserProfile',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'phone': _i1.ParameterDescription(
              name: 'phone',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'qualification': _i1.ParameterDescription(
              name: 'qualification',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'designation': _i1.ParameterDescription(
              name: 'designation',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'profilePictureUrl': _i1.ParameterDescription(
              name: 'profilePictureUrl',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['dispenser'] as _i3.DispenserEndpoint)
                  .updateDispenserProfile(
                    session,
                    name: params['name'],
                    phone: params['phone'],
                    qualification: params['qualification'],
                    designation: params['designation'],
                    profilePictureUrl: params['profilePictureUrl'],
                  ),
        ),
        'listInventoryItems': _i1.MethodConnector(
          name: 'listInventoryItems',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['dispenser'] as _i3.DispenserEndpoint)
                  .listInventoryItems(session),
        ),
        'restockItem': _i1.MethodConnector(
          name: 'restockItem',
          params: {
            'itemId': _i1.ParameterDescription(
              name: 'itemId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'quantity': _i1.ParameterDescription(
              name: 'quantity',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['dispenser'] as _i3.DispenserEndpoint).restockItem(
                    session,
                    itemId: params['itemId'],
                    quantity: params['quantity'],
                  ),
        ),
        'getDispenserHistory': _i1.MethodConnector(
          name: 'getDispenserHistory',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['dispenser'] as _i3.DispenserEndpoint)
                  .getDispenserHistory(session),
        ),
        'getPendingPrescriptions': _i1.MethodConnector(
          name: 'getPendingPrescriptions',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['dispenser'] as _i3.DispenserEndpoint)
                  .getPendingPrescriptions(session),
        ),
        'getPrescriptionDetail': _i1.MethodConnector(
          name: 'getPrescriptionDetail',
          params: {
            'prescriptionId': _i1.ParameterDescription(
              name: 'prescriptionId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['dispenser'] as _i3.DispenserEndpoint)
                  .getPrescriptionDetail(
                    session,
                    params['prescriptionId'],
                  ),
        ),
        'getStockByFirstWord': _i1.MethodConnector(
          name: 'getStockByFirstWord',
          params: {
            'medicineName': _i1.ParameterDescription(
              name: 'medicineName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['dispenser'] as _i3.DispenserEndpoint)
                  .getStockByFirstWord(
                    session,
                    params['medicineName'],
                  ),
        ),
        'searchInventoryItems': _i1.MethodConnector(
          name: 'searchInventoryItems',
          params: {
            'query': _i1.ParameterDescription(
              name: 'query',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['dispenser'] as _i3.DispenserEndpoint)
                  .searchInventoryItems(
                    session,
                    params['query'],
                  ),
        ),
        'dispensePrescription': _i1.MethodConnector(
          name: 'dispensePrescription',
          params: {
            'prescriptionId': _i1.ParameterDescription(
              name: 'prescriptionId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'dispenserId': _i1.ParameterDescription(
              name: 'dispenserId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'items': _i1.ParameterDescription(
              name: 'items',
              type: _i1.getType<List<_i10.DispenseItemRequest>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['dispenser'] as _i3.DispenserEndpoint)
                  .dispensePrescription(
                    session,
                    prescriptionId: params['prescriptionId'],
                    dispenserId: params['dispenserId'],
                    items: params['items'],
                  ),
        ),
        'getDispenserDispenseHistory': _i1.MethodConnector(
          name: 'getDispenserDispenseHistory',
          params: {
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['dispenser'] as _i3.DispenserEndpoint)
                  .getDispenserDispenseHistory(
                    session,
                    limit: params['limit'],
                  ),
        ),
      },
    );
    connectors['doctor'] = _i1.EndpointConnector(
      name: 'doctor',
      endpoint: endpoints['doctor']!,
      methodConnectors: {
        'getDoctorHomeData': _i1.MethodConnector(
          name: 'getDoctorHomeData',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['doctor'] as _i4.DoctorEndpoint)
                  .getDoctorHomeData(session),
        ),
        'getDoctorInfo': _i1.MethodConnector(
          name: 'getDoctorInfo',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['doctor'] as _i4.DoctorEndpoint)
                  .getDoctorInfo(session),
        ),
        'getDoctorProfile': _i1.MethodConnector(
          name: 'getDoctorProfile',
          params: {
            'doctorId': _i1.ParameterDescription(
              name: 'doctorId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['doctor'] as _i4.DoctorEndpoint).getDoctorProfile(
                    session,
                    params['doctorId'],
                  ),
        ),
        'updateDoctorProfile': _i1.MethodConnector(
          name: 'updateDoctorProfile',
          params: {
            'doctorId': _i1.ParameterDescription(
              name: 'doctorId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'phone': _i1.ParameterDescription(
              name: 'phone',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'profilePictureUrl': _i1.ParameterDescription(
              name: 'profilePictureUrl',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'designation': _i1.ParameterDescription(
              name: 'designation',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'qualification': _i1.ParameterDescription(
              name: 'qualification',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'signatureUrl': _i1.ParameterDescription(
              name: 'signatureUrl',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['doctor'] as _i4.DoctorEndpoint)
                  .updateDoctorProfile(
                    session,
                    params['doctorId'],
                    params['name'],
                    params['email'],
                    params['phone'],
                    params['profilePictureUrl'],
                    params['designation'],
                    params['qualification'],
                    params['signatureUrl'],
                  ),
        ),
        'getPatientByPhone': _i1.MethodConnector(
          name: 'getPatientByPhone',
          params: {
            'phone': _i1.ParameterDescription(
              name: 'phone',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['doctor'] as _i4.DoctorEndpoint).getPatientByPhone(
                    session,
                    params['phone'],
                  ),
        ),
        'createPrescription': _i1.MethodConnector(
          name: 'createPrescription',
          params: {
            'prescription': _i1.ParameterDescription(
              name: 'prescription',
              type: _i1.getType<_i11.Prescription>(),
              nullable: false,
            ),
            'items': _i1.ParameterDescription(
              name: 'items',
              type: _i1.getType<List<_i12.PrescribedItem>>(),
              nullable: false,
            ),
            'patientPhone': _i1.ParameterDescription(
              name: 'patientPhone',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['doctor'] as _i4.DoctorEndpoint)
                  .createPrescription(
                    session,
                    params['prescription'],
                    params['items'],
                    params['patientPhone'],
                  ),
        ),
        'getReportsForDoctor': _i1.MethodConnector(
          name: 'getReportsForDoctor',
          params: {
            'doctorId': _i1.ParameterDescription(
              name: 'doctorId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['doctor'] as _i4.DoctorEndpoint)
                  .getReportsForDoctor(
                    session,
                    params['doctorId'],
                  ),
        ),
        'markReportReviewed': _i1.MethodConnector(
          name: 'markReportReviewed',
          params: {
            'reportId': _i1.ParameterDescription(
              name: 'reportId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['doctor'] as _i4.DoctorEndpoint)
                  .markReportReviewed(
                    session,
                    params['reportId'],
                  ),
        ),
        'revisePrescription': _i1.MethodConnector(
          name: 'revisePrescription',
          params: {
            'originalPrescriptionId': _i1.ParameterDescription(
              name: 'originalPrescriptionId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'newAdvice': _i1.ParameterDescription(
              name: 'newAdvice',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'newItems': _i1.ParameterDescription(
              name: 'newItems',
              type: _i1.getType<List<_i12.PrescribedItem>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['doctor'] as _i4.DoctorEndpoint)
                  .revisePrescription(
                    session,
                    originalPrescriptionId: params['originalPrescriptionId'],
                    newAdvice: params['newAdvice'],
                    newItems: params['newItems'],
                  ),
        ),
        'getPatientPrescriptionList': _i1.MethodConnector(
          name: 'getPatientPrescriptionList',
          params: {
            'query': _i1.ParameterDescription(
              name: 'query',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'offset': _i1.ParameterDescription(
              name: 'offset',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['doctor'] as _i4.DoctorEndpoint)
                  .getPatientPrescriptionList(
                    session,
                    query: params['query'],
                    limit: params['limit'],
                    offset: params['offset'],
                  ),
        ),
        'getPrescriptionDetails': _i1.MethodConnector(
          name: 'getPrescriptionDetails',
          params: {
            'prescriptionId': _i1.ParameterDescription(
              name: 'prescriptionId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['doctor'] as _i4.DoctorEndpoint)
                  .getPrescriptionDetails(
                    session,
                    prescriptionId: params['prescriptionId'],
                  ),
        ),
      },
    );
    connectors['lab'] = _i1.EndpointConnector(
      name: 'lab',
      endpoint: endpoints['lab']!,
      methodConnectors: {
        'getAllLabTests': _i1.MethodConnector(
          name: 'getAllLabTests',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['lab'] as _i5.LabEndpoint).getAllLabTests(session),
        ),
        'createTestResult': _i1.MethodConnector(
          name: 'createTestResult',
          params: {
            'testId': _i1.ParameterDescription(
              name: 'testId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'patientName': _i1.ParameterDescription(
              name: 'patientName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'mobileNumber': _i1.ParameterDescription(
              name: 'mobileNumber',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'patientType': _i1.ParameterDescription(
              name: 'patientType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lab'] as _i5.LabEndpoint).createTestResult(
                session,
                testId: params['testId'],
                patientName: params['patientName'],
                mobileNumber: params['mobileNumber'],
                patientType: params['patientType'],
              ),
        ),
        'createLabTest': _i1.MethodConnector(
          name: 'createLabTest',
          params: {
            'test': _i1.ParameterDescription(
              name: 'test',
              type: _i1.getType<_i13.LabTests>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lab'] as _i5.LabEndpoint).createLabTest(
                session,
                params['test'],
              ),
        ),
        'updateLabTest': _i1.MethodConnector(
          name: 'updateLabTest',
          params: {
            'test': _i1.ParameterDescription(
              name: 'test',
              type: _i1.getType<_i13.LabTests>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lab'] as _i5.LabEndpoint).updateLabTest(
                session,
                params['test'],
              ),
        ),
        'sendDummySms': _i1.MethodConnector(
          name: 'sendDummySms',
          params: {
            'mobileNumber': _i1.ParameterDescription(
              name: 'mobileNumber',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'message': _i1.ParameterDescription(
              name: 'message',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lab'] as _i5.LabEndpoint).sendDummySms(
                session,
                mobileNumber: params['mobileNumber'],
                message: params['message'],
              ),
        ),
        'submitResult': _i1.MethodConnector(
          name: 'submitResult',
          params: {
            'resultId': _i1.ParameterDescription(
              name: 'resultId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lab'] as _i5.LabEndpoint).submitResult(
                session,
                resultId: params['resultId'],
              ),
        ),
        'submitResultWithUrl': _i1.MethodConnector(
          name: 'submitResultWithUrl',
          params: {
            'resultId': _i1.ParameterDescription(
              name: 'resultId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'attachmentUrl': _i1.ParameterDescription(
              name: 'attachmentUrl',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['lab'] as _i5.LabEndpoint).submitResultWithUrl(
                    session,
                    resultId: params['resultId'],
                    attachmentUrl: params['attachmentUrl'],
                  ),
        ),
        'getAllTestResults': _i1.MethodConnector(
          name: 'getAllTestResults',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lab'] as _i5.LabEndpoint)
                  .getAllTestResults(session),
        ),
        'getStaffProfile': _i1.MethodConnector(
          name: 'getStaffProfile',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lab'] as _i5.LabEndpoint).getStaffProfile(
                session,
                params['userId'],
              ),
        ),
        'updateStaffProfile': _i1.MethodConnector(
          name: 'updateStaffProfile',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'phone': _i1.ParameterDescription(
              name: 'phone',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'email': _i1.ParameterDescription(
              name: 'email',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'designation': _i1.ParameterDescription(
              name: 'designation',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'qualification': _i1.ParameterDescription(
              name: 'qualification',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'profilePictureUrl': _i1.ParameterDescription(
              name: 'profilePictureUrl',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['lab'] as _i5.LabEndpoint).updateStaffProfile(
                    session,
                    userId: params['userId'],
                    name: params['name'],
                    phone: params['phone'],
                    email: params['email'],
                    designation: params['designation'],
                    qualification: params['qualification'],
                    profilePictureUrl: params['profilePictureUrl'],
                  ),
        ),
        'getLabHomeTwoDaySummary': _i1.MethodConnector(
          name: 'getLabHomeTwoDaySummary',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lab'] as _i5.LabEndpoint)
                  .getLabHomeTwoDaySummary(session),
        ),
        'getLast10TestHistory': _i1.MethodConnector(
          name: 'getLast10TestHistory',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lab'] as _i5.LabEndpoint)
                  .getLast10TestHistory(session),
        ),
      },
    );
    connectors['notification'] = _i1.EndpointConnector(
      name: 'notification',
      endpoint: endpoints['notification']!,
      methodConnectors: {
        'createNotification': _i1.MethodConnector(
          name: 'createNotification',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'title': _i1.ParameterDescription(
              name: 'title',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'message': _i1.ParameterDescription(
              name: 'message',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['notification'] as _i6.NotificationEndpoint)
                  .createNotification(
                    session,
                    userId: params['userId'],
                    title: params['title'],
                    message: params['message'],
                  ),
        ),
        'getMyNotifications': _i1.MethodConnector(
          name: 'getMyNotifications',
          params: {
            'limit': _i1.ParameterDescription(
              name: 'limit',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['notification'] as _i6.NotificationEndpoint)
                  .getMyNotifications(
                    session,
                    limit: params['limit'],
                    userId: params['userId'],
                  ),
        ),
        'getMyNotificationCounts': _i1.MethodConnector(
          name: 'getMyNotificationCounts',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['notification'] as _i6.NotificationEndpoint)
                  .getMyNotificationCounts(
                    session,
                    userId: params['userId'],
                  ),
        ),
        'getNotificationById': _i1.MethodConnector(
          name: 'getNotificationById',
          params: {
            'notificationId': _i1.ParameterDescription(
              name: 'notificationId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['notification'] as _i6.NotificationEndpoint)
                  .getNotificationById(
                    session,
                    notificationId: params['notificationId'],
                    userId: params['userId'],
                  ),
        ),
        'markAsRead': _i1.MethodConnector(
          name: 'markAsRead',
          params: {
            'notificationId': _i1.ParameterDescription(
              name: 'notificationId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['notification'] as _i6.NotificationEndpoint)
                  .markAsRead(
                    session,
                    notificationId: params['notificationId'],
                    userId: params['userId'],
                  ),
        ),
        'markAllAsRead': _i1.MethodConnector(
          name: 'markAllAsRead',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['notification'] as _i6.NotificationEndpoint)
                  .markAllAsRead(
                    session,
                    userId: params['userId'],
                  ),
        ),
      },
    );
    connectors['password'] = _i1.EndpointConnector(
      name: 'password',
      endpoint: endpoints['password']!,
      methodConnectors: {
        'changePassword': _i1.MethodConnector(
          name: 'changePassword',
          params: {
            'currentPassword': _i1.ParameterDescription(
              name: 'currentPassword',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'newPassword': _i1.ParameterDescription(
              name: 'newPassword',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['password'] as _i7.PasswordEndpoint)
                  .changePassword(
                    session,
                    currentPassword: params['currentPassword'],
                    newPassword: params['newPassword'],
                  ),
        ),
      },
    );
    connectors['patient'] = _i1.EndpointConnector(
      name: 'patient',
      endpoint: endpoints['patient']!,
      methodConnectors: {
        'getPatientProfile': _i1.MethodConnector(
          name: 'getPatientProfile',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['patient'] as _i8.PatientEndpoint)
                  .getPatientProfile(session),
        ),
        'listTests': _i1.MethodConnector(
          name: 'listTests',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['patient'] as _i8.PatientEndpoint)
                  .listTests(session),
        ),
        'getUserRole': _i1.MethodConnector(
          name: 'getUserRole',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['patient'] as _i8.PatientEndpoint).getUserRole(
                    session,
                    params['userId'],
                  ),
        ),
        'updatePatientProfile': _i1.MethodConnector(
          name: 'updatePatientProfile',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'phone': _i1.ParameterDescription(
              name: 'phone',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'bloodGroup': _i1.ParameterDescription(
              name: 'bloodGroup',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'dateOfBirth': _i1.ParameterDescription(
              name: 'dateOfBirth',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            ),
            'gender': _i1.ParameterDescription(
              name: 'gender',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'profileImageUrl': _i1.ParameterDescription(
              name: 'profileImageUrl',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['patient'] as _i8.PatientEndpoint)
                  .updatePatientProfile(
                    session,
                    params['userId'],
                    params['name'],
                    params['phone'],
                    params['bloodGroup'],
                    params['dateOfBirth'],
                    params['gender'],
                    params['profileImageUrl'],
                  ),
        ),
        'getMyLabReports': _i1.MethodConnector(
          name: 'getMyLabReports',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['patient'] as _i8.PatientEndpoint).getMyLabReports(
                    session,
                    params['userId'],
                  ),
        ),
        'getMyPrescriptionList': _i1.MethodConnector(
          name: 'getMyPrescriptionList',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['patient'] as _i8.PatientEndpoint)
                  .getMyPrescriptionList(
                    session,
                    params['userId'],
                  ),
        ),
        'finalizeReportUpload': _i1.MethodConnector(
          name: 'finalizeReportUpload',
          params: {
            'patientId': _i1.ParameterDescription(
              name: 'patientId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'prescriptionId': _i1.ParameterDescription(
              name: 'prescriptionId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'reportType': _i1.ParameterDescription(
              name: 'reportType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'fileUrl': _i1.ParameterDescription(
              name: 'fileUrl',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['patient'] as _i8.PatientEndpoint)
                  .finalizeReportUpload(
                    session,
                    patientId: params['patientId'],
                    prescriptionId: params['prescriptionId'],
                    reportType: params['reportType'],
                    fileUrl: params['fileUrl'],
                  ),
        ),
        'getMyExternalReports': _i1.MethodConnector(
          name: 'getMyExternalReports',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['patient'] as _i8.PatientEndpoint)
                  .getMyExternalReports(
                    session,
                    params['userId'],
                  ),
        ),
        'getPrescriptionList': _i1.MethodConnector(
          name: 'getPrescriptionList',
          params: {
            'patientId': _i1.ParameterDescription(
              name: 'patientId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['patient'] as _i8.PatientEndpoint)
                  .getPrescriptionList(
                    session,
                    params['patientId'],
                  ),
        ),
        'getPrescriptionsByPatientId': _i1.MethodConnector(
          name: 'getPrescriptionsByPatientId',
          params: {
            'patientId': _i1.ParameterDescription(
              name: 'patientId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['patient'] as _i8.PatientEndpoint)
                  .getPrescriptionsByPatientId(
                    session,
                    params['patientId'],
                  ),
        ),
        'getPrescriptionDetail': _i1.MethodConnector(
          name: 'getPrescriptionDetail',
          params: {
            'prescriptionId': _i1.ParameterDescription(
              name: 'prescriptionId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['patient'] as _i8.PatientEndpoint)
                  .getPrescriptionDetail(
                    session,
                    params['prescriptionId'],
                  ),
        ),
        'getMedicalStaff': _i1.MethodConnector(
          name: 'getMedicalStaff',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['patient'] as _i8.PatientEndpoint)
                  .getMedicalStaff(session),
        ),
        'getAmbulanceContacts': _i1.MethodConnector(
          name: 'getAmbulanceContacts',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['patient'] as _i8.PatientEndpoint)
                  .getAmbulanceContacts(session),
        ),
        'getOndutyStaff': _i1.MethodConnector(
          name: 'getOndutyStaff',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['patient'] as _i8.PatientEndpoint)
                  .getOndutyStaff(session),
        ),
      },
    );
    connectors['greeting'] = _i1.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _i1.MethodConnector(
          name: 'hello',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['greeting'] as _i9.GreetingEndpoint).hello(
                session,
                params['name'],
              ),
        ),
      },
    );
  }
}
