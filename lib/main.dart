import 'package:dishari/src/change_password.dart';
import 'package:flutter/material.dart';
import 'src/notifications.dart';
// Admin imports
import 'src/admin/admin_profile.dart';
import 'src/admin/history_screen.dart';
import 'src/admin/inventory_management.dart';
import 'src/admin/reports_analytics.dart';
import 'src/admin/staff_rostering.dart';
import 'src/admin/user_management.dart';
import 'src/admin/admin_dashboard.dart';

// Doctor imports
import 'src/doctor/patient_records.dart';
import 'src/doctor/doctor_dashboard.dart';
import 'src/doctor/prescription_page.dart';
import 'src/doctor/doctor_profile.dart';

// Lab imports
import 'src/lab_test/lab_tester_home.dart';

// Dispenser imports
import 'src/dispenser/dispenser_dashboard.dart';
import 'src/dispenser/dispenser_profile.dart';

// Patient imports
import 'src/patient/patient_dashboard.dart';
import 'src/patient/patient_profile.dart';
import 'src/patient/patient_prescriptions.dart';
import 'src/patient/patient_report.dart';
import 'src/patient/patient_report_upload.dart';
import 'src/patient/patient_lab_test_availability.dart';
import 'src/patient/patient_ambulance_staff.dart';
import 'src/patient/patient_signup.dart';

// Login
import 'src/universal_login.dart';
// Forgot password
import 'src/forget_password.dart';
//notification
import 'src/notifications.dart';
// Import from your existing backend_client package
import 'package:backend_client/backend_client.dart';

void main(){
  // Initialize Serverpod client before running app
  WidgetsFlutterBinding.ensureInitialized();
  initServerpodClient();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NSTU Medical Center',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Raleway',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        // Main routes
        '/': (context) => const HomePage(),

        // Admin routes (grouped under /admin)
        '/admin': (context) => const AdminDashboard(),
        '/admin-dashboard': (context) => const AdminDashboard(), // alias used in navigation
        '/admin/profile': (context) => const AdminProfile(),
        '/admin/users': (context) => const UserManagement(),
        '/admin/inventory': (context) => const InventoryManagement(),
        '/admin/reports': (context) => const ReportsAnalytics(),
        '/admin/history': (context) => const HistoryScreen(),
        '/admin/roster': (context) => const StaffRostering(),

        // Doctor routes (grouped under /doctor)
        '/doctor': (context) => const DoctorDashboard(),
        '/doctor-dashboard': (context) => const DoctorDashboard(), // alias
        '/doctor/profile': (context) => const ProfilePage(),
        '/doctor/patients': (context) => const PatientRecordsPage(),
        '/doctor/prescriptions': (context) => const PrescriptionPage(),

        // Dispenser routes (grouped under /dispenser)
        '/dispenser': (context) => const DispenserDashboard(),
        '/dispenser-dashboard': (context) => const DispenserDashboard(), // alias
        '/dispenser/profile': (context) => const DispenserProfile(),

        // Lab tester routes (grouped under /lab)
        '/lab': (context) => const LabTesterHome(),
        '/lab-dashboard': (context) => const LabTesterHome(), // alias

        // Patient routes (grouped under /patient)
        '/patient': (context) => const PatientDashboard(name: '', email: ''),
        '/patient-dashboard': (context) => const PatientDashboard(name: '', email: ''), // alias
        '/patient/profile': (context) => const PatientProfilePage(),
        '/patient/prescriptions': (context) => const PatientPrescriptions(),
        '/patient/reports': (context) => const PatientReports(),
        '/patient/upload': (context) => const PatientReportUpload(),
        '/patient/lab': (context) => const PatientLabTestAvailability(),
        '/patient/ambulance': (context) => const PatientAmbulanceStaff(),

        // Signup & forgot
        '/signup': (context) => const PatientSignupPage(),
        '/patient-signup': (context) => const PatientSignupPage(), // alias for links coming from login
        '/forgotpassword': (context) => const ForgetPassword(),
        '/change-password': (context) => const ChangePasswordPage(),

        //notifications
        '/notifications': (context) => const Notifications(),


      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => Scaffold(
          body: Center(child: Text("Page not found: ${settings.name}")),
        ),
      ),
    );
  }
}
