import '../models/clinic_doctor_model.dart';
import '../models/clinic_service_model.dart';

class ClinicFallbackData {
  static List<String> getFeatures(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('dent')) {
      return ['Wheelchair access', 'Free parking', 'Digital scans', 'Painless dentistry'];
    }
    if (cat.contains('derm')) {
      return ['Advanced laser', 'Private cabins', 'Card/UPI payments', 'Cosmetic dermatology'];
    }
    if (cat.contains('pedi')) {
      return ['Child play area', 'Vaccination clinic', 'Emergency on-call', 'Wheelchair access'];
    }
    return ['Wheelchair access', 'Free parking', 'Card/UPI payments', 'Emergency on-call'];
  }

  static String getDescription(String name, String category) {
    final cat = category.toLowerCase();
    if (cat.contains('dent')) {
      return 'A modern dental clinic offering general and cosmetic dentistry, with same-day appointments and a dedicated live queue for walk-ins.';
    }
    if (cat.contains('derm')) {
      return 'Premier skincare and aesthetics clinic specializing in advanced dermatology, acne treatments, and clinical therapies.';
    }
    return 'A multidisciplinary healthcare facility committed to delivering prompt, high-quality primary and specialized medical care with live queue visibility.';
  }

  static List<ClinicServiceModel> getServices(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('dent')) {
      return const [
        ClinicServiceModel(id: 's-1', name: 'Dental Consultation', duration: 20, price: 400, departmentName: 'Dentistry'),
        ClinicServiceModel(id: 's-2', name: 'Teeth Cleaning & Polishing', duration: 30, price: 900, departmentName: 'Dentistry'),
        ClinicServiceModel(id: 's-3', name: 'Root Canal Treatment', duration: 45, price: 2500, departmentName: 'Dentistry'),
        ClinicServiceModel(id: 's-4', name: 'Teeth Whitening', duration: 40, price: 3500, departmentName: 'Dentistry'),
      ];
    }
    if (cat.contains('derm')) {
      return const [
        ClinicServiceModel(id: 's-5', name: 'Skin Consultation', duration: 20, price: 600, departmentName: 'Dermatology'),
        ClinicServiceModel(id: 's-6', name: 'Acne Care Treatment', duration: 35, price: 1500, departmentName: 'Dermatology'),
        ClinicServiceModel(id: 's-7', name: 'Laser Skin Therapy', duration: 45, price: 3200, departmentName: 'Dermatology'),
      ];
    }
    return const [
      ClinicServiceModel(id: 's-8', name: 'General Consultation', duration: 15, price: 400, departmentName: 'General Medicine'),
      ClinicServiceModel(id: 's-9', name: 'Follow-up Visit & Review', duration: 15, price: 250, departmentName: 'General Medicine'),
      ClinicServiceModel(id: 's-10', name: 'Preventive Health Checkup', duration: 30, price: 1200, departmentName: 'General Medicine'),
    ];
  }

  static List<ClinicDoctorModel> getDoctors(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('dent')) {
      return const [
        ClinicDoctorModel(id: 'd-1', name: 'Dr. Rahul Menon', initials: 'RM', title: 'BDS, MDS • Orthodontics', specialty: 'Orthodontics', schedule: 'Mon–Sat, 9:00 AM – 5:00 PM'),
        ClinicDoctorModel(id: 'd-2', name: 'Dr. Fatima Noor', initials: 'FN', title: 'BDS • Cosmetic Dentistry', specialty: 'Cosmetic Dentistry', schedule: 'Mon–Fri, 10:00 AM – 6:00 PM'),
      ];
    }
    if (cat.contains('derm')) {
      return const [
        ClinicDoctorModel(id: 'd-3', name: 'Dr. Meera Nair', initials: 'MN', title: 'MD • Consultant Dermatologist', specialty: 'Dermatology', schedule: 'Mon–Sat, 10:00 AM – 7:00 PM'),
      ];
    }
    return const [
      ClinicDoctorModel(id: 'd-4', name: 'Dr. Priya Sharma', initials: 'PS', title: 'MBBS, MD • Internal Medicine', specialty: 'General Physician', schedule: 'Mon–Sat, 9:00 AM – 5:00 PM'),
      ClinicDoctorModel(id: 'd-5', name: 'Dr. Anand Varma', initials: 'AV', title: 'MBBS • Family Physician', specialty: 'Family Medicine', schedule: 'Mon–Fri, 9:00 AM – 4:00 PM'),
    ];
  }
}
