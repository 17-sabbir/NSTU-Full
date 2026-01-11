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
import '../endpoints/admin_endpoints.dart' as _i2;
import '../endpoints/admin_inventory_endpoints.dart' as _i3;
import '../endpoints/admin_report_endpoints.dart' as _i4;
import '../endpoints/auth_endpoint.dart' as _i5;
import '../endpoints/dispenser_endpoints.dart' as _i6;
import '../endpoints/doctor_endpoints.dart' as _i7;
import '../endpoints/lab_endpoints.dart' as _i8;
import '../endpoints/notifications_endpoint.dart' as _i9;
import '../endpoints/password_endpoint.dart' as _i10;
import '../endpoints/patient_endpoints.dart' as _i11;
import '../greeting_endpoint.dart' as _i12;
import 'package:backend_server/src/generated/dispense_request.dart' as _i13;
import 'package:backend_server/src/generated/prescription.dart' as _i14;
import 'package:backend_server/src/generated/PrescribedItem.dart' as _i15;
import 'package:backend_server/src/generated/patient_return_tests.dart' as _i16;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'adminEndpoints': _i2.AdminEndpoints()
        ..initialize(
          server,
          'adminEndpoints',
          null,
        ),
      'adminInventoryEndpoints': _i3.AdminInventoryEndpoints()
        ..initialize(
          server,
          'adminInventoryEndpoints',
          null,
        ),
      'adminReportEndpoints': _i4.AdminReportEndpoints()
        ..initialize(
          server,
          'adminReportEndpoints',
          null,
        ),
      'auth': _i5.AuthEndpoint()
        ..initialize(
          server,
          'auth',
          null,
        ),
      'dispenser': _i6.DispenserEndpoint()
        ..initialize(
          server,
          'dispenser',
          null,
        ),
      'doctor': _i7.DoctorEndpoint()
        ..initialize(
          server,
          'doctor',
          null,
        ),
      'lab': _i8.LabEndpoint()
        ..initialize(
          server,
          'lab',
          null,
        ),
      'notification': _i9.NotificationEndpoint()
        ..initialize(
          server,
          'notification',
          null,
        ),
      'password': _i10.PasswordEndpoint()
        ..initialize(
          server,
          'password',
          null,
        ),
      'patient': _i11.PatientEndpoint()
        ..initialize(
          server,
          'patient',
          null,
        ),
      'greeting': _i12.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
    };
    connectors['adminEndpoints'] = _i1.EndpointConnector(
      name: 'adminEndpoints',
      endpoint: endpoints['adminEndpoints']!,
      methodConnectors: {
        'listUsersByRole': _i1.MethodConnector(
          name: 'listUsersByRole',
          params: {
            'role': _i1.ParameterDescription(
              name: 'role',
              type: _i1.getType<String>(),
              nullable: false,
            ),
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
              ) async => (endpoints['adminEndpoints'] as _i2.AdminEndpoints)
                  .listUsersByRole(
                    session,
                    params['role'],
                    params['limit'],
                  ),
        ),
        'toggleUserActive': _i1.MethodConnector(
          name: 'toggleUserActive',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['adminEndpoints'] as _i2.AdminEndpoints)
                  .toggleUserActive(
                    session,
                    params['userId'],
                  ),
        ),
        'createUser': _i1.MethodConnector(
          name: 'createUser',
          params: {
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
            'passwordHash': _i1.ParameterDescription(
              name: 'passwordHash',
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
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['adminEndpoints'] as _i2.AdminEndpoints)
                  .createUser(
                    session,
                    params['name'],
                    params['email'],
                    params['passwordHash'],
                    params['role'],
                    params['phone'],
                  ),
        ),
        'createUserWithPassword': _i1.MethodConnector(
          name: 'createUserWithPassword',
          params: {
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
            'password': _i1.ParameterDescription(
              name: 'password',
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
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['adminEndpoints'] as _i2.AdminEndpoints)
                  .createUserWithPassword(
                    session,
                    params['name'],
                    params['email'],
                    params['password'],
                    params['role'],
                    params['phone'],
                  ),
        ),
        'getRosters': _i1.MethodConnector(
          name: 'getRosters',
          params: {
            'staffId': _i1.ParameterDescription(
              name: 'staffId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'fromDate': _i1.ParameterDescription(
              name: 'fromDate',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            ),
            'toDate': _i1.ParameterDescription(
              name: 'toDate',
              type: _i1.getType<DateTime?>(),
              nullable: true,
            ),
            'includeDeleted': _i1.ParameterDescription(
              name: 'includeDeleted',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['adminEndpoints'] as _i2.AdminEndpoints)
                  .getRosters(
                    session,
                    params['staffId'],
                    params['fromDate'],
                    params['toDate'],
                    includeDeleted: params['includeDeleted'],
                  ),
        ),
        'deleteRoster': _i1.MethodConnector(
          name: 'deleteRoster',
          params: {
            'rosterId': _i1.ParameterDescription(
              name: 'rosterId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['adminEndpoints'] as _i2.AdminEndpoints)
                  .deleteRoster(
                    session,
                    params['rosterId'],
                  ),
        ),
        'saveRoster': _i1.MethodConnector(
          name: 'saveRoster',
          params: {
            'rosterId': _i1.ParameterDescription(
              name: 'rosterId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'staffId': _i1.ParameterDescription(
              name: 'staffId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'shiftType': _i1.ParameterDescription(
              name: 'shiftType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'shiftDate': _i1.ParameterDescription(
              name: 'shiftDate',
              type: _i1.getType<DateTime>(),
              nullable: false,
            ),
            'timeRange': _i1.ParameterDescription(
              name: 'timeRange',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'status': _i1.ParameterDescription(
              name: 'status',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'approvedBy': _i1.ParameterDescription(
              name: 'approvedBy',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['adminEndpoints'] as _i2.AdminEndpoints)
                  .saveRoster(
                    session,
                    params['rosterId'],
                    params['staffId'],
                    params['shiftType'],
                    params['shiftDate'],
                    params['timeRange'],
                    params['status'],
                    params['approvedBy'],
                  ),
        ),
        'listStaff': _i1.MethodConnector(
          name: 'listStaff',
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
              ) async =>
                  (endpoints['adminEndpoints'] as _i2.AdminEndpoints).listStaff(
                    session,
                    params['limit'],
                  ),
        ),
        'getAdminProfile': _i1.MethodConnector(
          name: 'getAdminProfile',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['adminEndpoints'] as _i2.AdminEndpoints)
                  .getAdminProfile(
                    session,
                    params['userId'],
                  ),
        ),
        'updateAdminProfile': _i1.MethodConnector(
          name: 'updateAdminProfile',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<String>(),
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
            'profilePictureData': _i1.ParameterDescription(
              name: 'profilePictureData',
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
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['adminEndpoints'] as _i2.AdminEndpoints)
                  .updateAdminProfile(
                    session,
                    params['userId'],
                    params['name'],
                    params['phone'],
                    params['profilePictureData'],
                    params['designation'],
                    params['qualification'],
                  ),
        ),
        'changePassword': _i1.MethodConnector(
          name: 'changePassword',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
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
              ) async => (endpoints['adminEndpoints'] as _i2.AdminEndpoints)
                  .changePassword(
                    session,
                    params['userId'],
                    params['currentPassword'],
                    params['newPassword'],
                  ),
        ),
        'createAuditLog': _i1.MethodConnector(
          name: 'createAuditLog',
          params: {
            'adminId': _i1.ParameterDescription(
              name: 'adminId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'action': _i1.ParameterDescription(
              name: 'action',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'targetId': _i1.ParameterDescription(
              name: 'targetId',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['adminEndpoints'] as _i2.AdminEndpoints)
                  .createAuditLog(
                    session,
                    adminId: params['adminId'],
                    action: params['action'],
                    targetId: params['targetId'],
                  ),
        ),
        'getAuditLogs': _i1.MethodConnector(
          name: 'getAuditLogs',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['adminEndpoints'] as _i2.AdminEndpoints)
                  .getAuditLogs(session),
        ),
        'addAmbulanceContact': _i1.MethodConnector(
          name: 'addAmbulanceContact',
          params: {
            'title': _i1.ParameterDescription(
              name: 'title',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'phoneBn': _i1.ParameterDescription(
              name: 'phoneBn',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'phoneEn': _i1.ParameterDescription(
              name: 'phoneEn',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'isPrimary': _i1.ParameterDescription(
              name: 'isPrimary',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['adminEndpoints'] as _i2.AdminEndpoints)
                  .addAmbulanceContact(
                    session,
                    params['title'],
                    params['phoneBn'],
                    params['phoneEn'],
                    params['isPrimary'],
                  ),
        ),
        'updateAmbulanceContact': _i1.MethodConnector(
          name: 'updateAmbulanceContact',
          params: {
            'id': _i1.ParameterDescription(
              name: 'id',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'title': _i1.ParameterDescription(
              name: 'title',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'phoneBn': _i1.ParameterDescription(
              name: 'phoneBn',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'phoneEn': _i1.ParameterDescription(
              name: 'phoneEn',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'isPrimary': _i1.ParameterDescription(
              name: 'isPrimary',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['adminEndpoints'] as _i2.AdminEndpoints)
                  .updateAmbulanceContact(
                    session,
                    params['id'],
                    params['title'],
                    params['phoneBn'],
                    params['phoneEn'],
                    params['isPrimary'],
                  ),
        ),
      },
    );
    connectors['adminInventoryEndpoints'] = _i1.EndpointConnector(
      name: 'adminInventoryEndpoints',
      endpoint: endpoints['adminInventoryEndpoints']!,
      methodConnectors: {
        'addInventoryCategory': _i1.MethodConnector(
          name: 'addInventoryCategory',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'description': _i1.ParameterDescription(
              name: 'description',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['adminInventoryEndpoints']
                          as _i3.AdminInventoryEndpoints)
                      .addInventoryCategory(
                        session,
                        params['name'],
                        params['description'],
                      ),
        ),
        'listInventoryCategories': _i1.MethodConnector(
          name: 'listInventoryCategories',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['adminInventoryEndpoints']
                          as _i3.AdminInventoryEndpoints)
                      .listInventoryCategories(session),
        ),
        'addInventoryItem': _i1.MethodConnector(
          name: 'addInventoryItem',
          params: {
            'categoryId': _i1.ParameterDescription(
              name: 'categoryId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'itemName': _i1.ParameterDescription(
              name: 'itemName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'unit': _i1.ParameterDescription(
              name: 'unit',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'minimumStock': _i1.ParameterDescription(
              name: 'minimumStock',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'initialStock': _i1.ParameterDescription(
              name: 'initialStock',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'canRestockDispenser': _i1.ParameterDescription(
              name: 'canRestockDispenser',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
            'adminUserId': _i1.ParameterDescription(
              name: 'adminUserId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['adminInventoryEndpoints']
                          as _i3.AdminInventoryEndpoints)
                      .addInventoryItem(
                        session,
                        categoryId: params['categoryId'],
                        itemName: params['itemName'],
                        unit: params['unit'],
                        minimumStock: params['minimumStock'],
                        initialStock: params['initialStock'],
                        canRestockDispenser: params['canRestockDispenser'],
                        adminUserId: params['adminUserId'],
                      ),
        ),
        'updateInventoryStock': _i1.MethodConnector(
          name: 'updateInventoryStock',
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
            'type': _i1.ParameterDescription(
              name: 'type',
              type: _i1.getType<String>(),
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
              ) async =>
                  (endpoints['adminInventoryEndpoints']
                          as _i3.AdminInventoryEndpoints)
                      .updateInventoryStock(
                        session,
                        itemId: params['itemId'],
                        quantity: params['quantity'],
                        type: params['type'],
                        userId: params['userId'],
                      ),
        ),
        'updateDispenserRestockFlag': _i1.MethodConnector(
          name: 'updateDispenserRestockFlag',
          params: {
            'itemId': _i1.ParameterDescription(
              name: 'itemId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'canRestock': _i1.ParameterDescription(
              name: 'canRestock',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
            'adminUserId': _i1.ParameterDescription(
              name: 'adminUserId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['adminInventoryEndpoints']
                          as _i3.AdminInventoryEndpoints)
                      .updateDispenserRestockFlag(
                        session,
                        itemId: params['itemId'],
                        canRestock: params['canRestock'],
                        adminUserId: params['adminUserId'],
                      ),
        ),
        'listInventoryItems': _i1.MethodConnector(
          name: 'listInventoryItems',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['adminInventoryEndpoints']
                          as _i3.AdminInventoryEndpoints)
                      .listInventoryItems(session),
        ),
        'updateMinimumThreshold': _i1.MethodConnector(
          name: 'updateMinimumThreshold',
          params: {
            'itemId': _i1.ParameterDescription(
              name: 'itemId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'newThreshold': _i1.ParameterDescription(
              name: 'newThreshold',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'adminUserId': _i1.ParameterDescription(
              name: 'adminUserId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['adminInventoryEndpoints']
                          as _i3.AdminInventoryEndpoints)
                      .updateMinimumThreshold(
                        session,
                        itemId: params['itemId'],
                        newThreshold: params['newThreshold'],
                        adminUserId: params['adminUserId'],
                      ),
        ),
        'getItemTransactions': _i1.MethodConnector(
          name: 'getItemTransactions',
          params: {
            'itemId': _i1.ParameterDescription(
              name: 'itemId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['adminInventoryEndpoints']
                          as _i3.AdminInventoryEndpoints)
                      .getItemTransactions(
                        session,
                        params['itemId'],
                      ),
        ),
        'getInventoryAuditLogs': _i1.MethodConnector(
          name: 'getInventoryAuditLogs',
          params: {
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
              ) async =>
                  (endpoints['adminInventoryEndpoints']
                          as _i3.AdminInventoryEndpoints)
                      .getInventoryAuditLogs(
                        session,
                        params['limit'],
                        params['offset'],
                      ),
        ),
      },
    );
    connectors['adminReportEndpoints'] = _i1.EndpointConnector(
      name: 'adminReportEndpoints',
      endpoint: endpoints['adminReportEndpoints']!,
      methodConnectors: {
        'getDashboardAnalytics': _i1.MethodConnector(
          name: 'getDashboardAnalytics',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['adminReportEndpoints']
                          as _i4.AdminReportEndpoints)
                      .getDashboardAnalytics(session),
        ),
      },
    );
    connectors['auth'] = _i1.EndpointConnector(
      name: 'auth',
      endpoint: endpoints['auth']!,
      methodConnectors: {
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
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['auth'] as _i5.AuthEndpoint).login(
                session,
                params['email'],
                params['password'],
              ),
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
              ) async => (endpoints['auth'] as _i5.AuthEndpoint).register(
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
              ) async => (endpoints['auth'] as _i5.AuthEndpoint).resendOtp(
                session,
                params['email'],
                params['password'],
                params['name'],
                params['role'],
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
              ) async => (endpoints['auth'] as _i5.AuthEndpoint).verifyOtp(
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
                  (endpoints['auth'] as _i5.AuthEndpoint).requestPasswordReset(
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
                  (endpoints['auth'] as _i5.AuthEndpoint).verifyPasswordReset(
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
              ) async => (endpoints['auth'] as _i5.AuthEndpoint).resetPassword(
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
              ) async => (endpoints['auth'] as _i5.AuthEndpoint)
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
              ) async => (endpoints['dispenser'] as _i6.DispenserEndpoint)
                  .getDispenserProfile(
                    session,
                    params['userId'],
                  ),
        ),
        'updateDispenserProfile': _i1.MethodConnector(
          name: 'updateDispenserProfile',
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
            'base64Image': _i1.ParameterDescription(
              name: 'base64Image',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['dispenser'] as _i6.DispenserEndpoint)
                  .updateDispenserProfile(
                    session,
                    userId: params['userId'],
                    name: params['name'],
                    phone: params['phone'],
                    qualification: params['qualification'],
                    designation: params['designation'],
                    base64Image: params['base64Image'],
                  ),
        ),
        'listInventoryItems': _i1.MethodConnector(
          name: 'listInventoryItems',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['dispenser'] as _i6.DispenserEndpoint)
                  .listInventoryItems(session),
        ),
        'restockItem': _i1.MethodConnector(
          name: 'restockItem',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
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
                  (endpoints['dispenser'] as _i6.DispenserEndpoint).restockItem(
                    session,
                    userId: params['userId'],
                    itemId: params['itemId'],
                    quantity: params['quantity'],
                  ),
        ),
        'getDispenserHistory': _i1.MethodConnector(
          name: 'getDispenserHistory',
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
              ) async => (endpoints['dispenser'] as _i6.DispenserEndpoint)
                  .getDispenserHistory(
                    session,
                    params['userId'],
                  ),
        ),
        'getPendingPrescriptions': _i1.MethodConnector(
          name: 'getPendingPrescriptions',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['dispenser'] as _i6.DispenserEndpoint)
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
              ) async => (endpoints['dispenser'] as _i6.DispenserEndpoint)
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
              ) async => (endpoints['dispenser'] as _i6.DispenserEndpoint)
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
              ) async => (endpoints['dispenser'] as _i6.DispenserEndpoint)
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
              type: _i1.getType<List<_i13.DispenseItemRequest>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['dispenser'] as _i6.DispenserEndpoint)
                  .dispensePrescription(
                    session,
                    prescriptionId: params['prescriptionId'],
                    dispenserId: params['dispenserId'],
                    items: params['items'],
                  ),
        ),
      },
    );
    connectors['doctor'] = _i1.EndpointConnector(
      name: 'doctor',
      endpoint: endpoints['doctor']!,
      methodConnectors: {
        'getDoctorInfo': _i1.MethodConnector(
          name: 'getDoctorInfo',
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
                  (endpoints['doctor'] as _i7.DoctorEndpoint).getDoctorInfo(
                    session,
                    params['doctorId'],
                  ),
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
                  (endpoints['doctor'] as _i7.DoctorEndpoint).getDoctorProfile(
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
              ) async => (endpoints['doctor'] as _i7.DoctorEndpoint)
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
                  (endpoints['doctor'] as _i7.DoctorEndpoint).getPatientByPhone(
                    session,
                    params['phone'],
                  ),
        ),
        'createPrescription': _i1.MethodConnector(
          name: 'createPrescription',
          params: {
            'prescription': _i1.ParameterDescription(
              name: 'prescription',
              type: _i1.getType<_i14.Prescription>(),
              nullable: false,
            ),
            'items': _i1.ParameterDescription(
              name: 'items',
              type: _i1.getType<List<_i15.PrescribedItem>>(),
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
              ) async => (endpoints['doctor'] as _i7.DoctorEndpoint)
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
              ) async => (endpoints['doctor'] as _i7.DoctorEndpoint)
                  .getReportsForDoctor(
                    session,
                    params['doctorId'],
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
              type: _i1.getType<List<_i15.PrescribedItem>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['doctor'] as _i7.DoctorEndpoint)
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
              ) async => (endpoints['doctor'] as _i7.DoctorEndpoint)
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
              ) async => (endpoints['doctor'] as _i7.DoctorEndpoint)
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
                  (endpoints['lab'] as _i8.LabEndpoint).getAllLabTests(session),
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
              ) async => (endpoints['lab'] as _i8.LabEndpoint).createTestResult(
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
              type: _i1.getType<_i16.LabTests>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lab'] as _i8.LabEndpoint).createLabTest(
                session,
                params['test'],
              ),
        ),
        'updateLabTest': _i1.MethodConnector(
          name: 'updateLabTest',
          params: {
            'test': _i1.ParameterDescription(
              name: 'test',
              type: _i1.getType<_i16.LabTests>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lab'] as _i8.LabEndpoint).updateLabTest(
                session,
                params['test'],
              ),
        ),
        'attachResultFileCloudinary': _i1.MethodConnector(
          name: 'attachResultFileCloudinary',
          params: {
            'resultId': _i1.ParameterDescription(
              name: 'resultId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'base64Data': _i1.ParameterDescription(
              name: 'base64Data',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'fileName': _i1.ParameterDescription(
              name: 'fileName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lab'] as _i8.LabEndpoint)
                  .attachResultFileCloudinary(
                    session,
                    resultId: params['resultId'],
                    base64Data: params['base64Data'],
                    fileName: params['fileName'],
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
              ) async => (endpoints['lab'] as _i8.LabEndpoint).sendDummySms(
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
              ) async => (endpoints['lab'] as _i8.LabEndpoint).submitResult(
                session,
                resultId: params['resultId'],
              ),
        ),
        'submitResultWithFile': _i1.MethodConnector(
          name: 'submitResultWithFile',
          params: {
            'resultId': _i1.ParameterDescription(
              name: 'resultId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'base64Data': _i1.ParameterDescription(
              name: 'base64Data',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'fileName': _i1.ParameterDescription(
              name: 'fileName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['lab'] as _i8.LabEndpoint).submitResultWithFile(
                    session,
                    resultId: params['resultId'],
                    base64Data: params['base64Data'],
                    fileName: params['fileName'],
                  ),
        ),
        'getAllTestResults': _i1.MethodConnector(
          name: 'getAllTestResults',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lab'] as _i8.LabEndpoint)
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
              ) async => (endpoints['lab'] as _i8.LabEndpoint).getStaffProfile(
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
                  (endpoints['lab'] as _i8.LabEndpoint).updateStaffProfile(
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
        'uploadProfileImage': _i1.MethodConnector(
          name: 'uploadProfileImage',
          params: {
            'base64Data': _i1.ParameterDescription(
              name: 'base64Data',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['lab'] as _i8.LabEndpoint).uploadProfileImage(
                    session,
                    params['base64Data'],
                  ),
        ),
        'getLabHomeTwoDaySummary': _i1.MethodConnector(
          name: 'getLabHomeTwoDaySummary',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lab'] as _i8.LabEndpoint)
                  .getLabHomeTwoDaySummary(session),
        ),
        'getLast10TestHistory': _i1.MethodConnector(
          name: 'getLast10TestHistory',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['lab'] as _i8.LabEndpoint)
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
              ) async => (endpoints['notification'] as _i9.NotificationEndpoint)
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
              ) async => (endpoints['notification'] as _i9.NotificationEndpoint)
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
              ) async => (endpoints['notification'] as _i9.NotificationEndpoint)
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
              ) async => (endpoints['notification'] as _i9.NotificationEndpoint)
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
              ) async => (endpoints['notification'] as _i9.NotificationEndpoint)
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
              ) async => (endpoints['notification'] as _i9.NotificationEndpoint)
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
        'changePasswordByUserIdEmail': _i1.MethodConnector(
          name: 'changePasswordByUserIdEmail',
          params: {
            'userId': _i1.ParameterDescription(
              name: 'userId',
              type: _i1.getType<int>(),
              nullable: false,
            ),
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
              ) async => (endpoints['password'] as _i10.PasswordEndpoint)
                  .changePasswordByUserIdEmail(
                    session,
                    userId: params['userId'],
                    email: params['email'],
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
              ) async => (endpoints['patient'] as _i11.PatientEndpoint)
                  .getPatientProfile(
                    session,
                    params['userId'],
                  ),
        ),
        'listTests': _i1.MethodConnector(
          name: 'listTests',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['patient'] as _i11.PatientEndpoint)
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
                  (endpoints['patient'] as _i11.PatientEndpoint).getUserRole(
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
            'allergies': _i1.ParameterDescription(
              name: 'allergies',
              type: _i1.getType<String>(),
              nullable: false,
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
              ) async => (endpoints['patient'] as _i11.PatientEndpoint)
                  .updatePatientProfile(
                    session,
                    params['userId'],
                    params['name'],
                    params['phone'],
                    params['allergies'],
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
              ) async => (endpoints['patient'] as _i11.PatientEndpoint)
                  .getMyLabReports(
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
              ) async => (endpoints['patient'] as _i11.PatientEndpoint)
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
            'base64Data': _i1.ParameterDescription(
              name: 'base64Data',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'fileName': _i1.ParameterDescription(
              name: 'fileName',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['patient'] as _i11.PatientEndpoint)
                  .finalizeReportUpload(
                    session,
                    patientId: params['patientId'],
                    prescriptionId: params['prescriptionId'],
                    reportType: params['reportType'],
                    base64Data: params['base64Data'],
                    fileName: params['fileName'],
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
              ) async => (endpoints['patient'] as _i11.PatientEndpoint)
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
              ) async => (endpoints['patient'] as _i11.PatientEndpoint)
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
              ) async => (endpoints['patient'] as _i11.PatientEndpoint)
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
              ) async => (endpoints['patient'] as _i11.PatientEndpoint)
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
              ) async => (endpoints['patient'] as _i11.PatientEndpoint)
                  .getMedicalStaff(session),
        ),
        'getAmbulanceContacts': _i1.MethodConnector(
          name: 'getAmbulanceContacts',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['patient'] as _i11.PatientEndpoint)
                  .getAmbulanceContacts(session),
        ),
        'getOndutyStaff': _i1.MethodConnector(
          name: 'getOndutyStaff',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['patient'] as _i11.PatientEndpoint)
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
              ) async => (endpoints['greeting'] as _i12.GreetingEndpoint).hello(
                session,
                params['name'],
              ),
        ),
      },
    );
  }
}
