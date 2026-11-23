class PatientSearchDepartmentConstants {
  static const Map<String, List<String>> departmentServices = {
    'General Medicine': [
      'General Consultation',
      'Routine Health Checkup',
      'Follow-up Consultation',
      'Blood Pressure Screening',
      'Fever & Infection Care',
      'Prescription Renewal',
    ],
    'Dental & Oral Surgery': [
      'Dental Consultation',
      'Teeth Cleaning & Scaling',
      'Root Canal Treatment',
      'Tooth Extraction',
      'Cavity Filling',
      'Teeth Whitening',
      'Dental Braces Check',
    ],
    'Pediatrics': [
      'Child Wellness Check',
      'Pediatric Vaccination',
      'Growth & Nutrition Review',
      'Newborn Care & Screening',
      'Pediatric Allergy Consult',
    ],
    'Cardiology': [
      'Cardiac Consultation',
      'ECG Interpretation',
      'Echocardiogram Review',
      'Holter Monitor Analysis',
      'Hypertension Management',
    ],
    'Dermatology': [
      'Skin Consultation',
      'Acne & Scar Treatment',
      'Eczema & Allergy Care',
      'Hair Loss Consultation',
      'Mole Screening',
    ],
    'Orthopedics': [
      'Orthopedic Consultation',
      'Joint Pain Assessment',
      'Spine & Back Care',
      'Fracture Review & Cast Check',
      'Sports Injury Evaluation',
    ],
    'ENT': [
      'Ear, Nose & Throat Consult',
      'Hearing Screening',
      'Sinusitis & Allergy Care',
      'Throat Infection Check',
      'Wax Removal',
    ],
    'Ophthalmology': [
      'Eye Consultation',
      'Vision Test & Refraction',
      'Cataract Evaluation',
      'Glaucoma Screening',
      'Dry Eye Treatment',
    ],
    'Gynecology & Obstetrics': [
      'Gynecological Consultation',
      'Antenatal Checkup',
      'Ultrasound Scan Review',
      'Postnatal Follow-up',
      'Family Planning Consult',
    ],
    'Neurology': [
      'Neurological Consultation',
      'Headache & Migraine Care',
      'Nerve Conduction Review',
      'Epilepsy Care',
      'Vertigo Assessment',
    ],
    'Psychiatry': [
      'Mental Health Consultation',
      'Anxiety & Stress Care',
      'Depression Counseling',
      'Sleep Disorder Evaluation',
      'Addiction Counseling',
    ],
  };

  static List<String> getServicesForDepartment(String dept) {
    if (dept.toLowerCase() == 'all') return const [];
    for (final entry in departmentServices.entries) {
      if (entry.key.toLowerCase() == dept.toLowerCase() ||
          entry.key.toLowerCase().contains(dept.toLowerCase()) ||
          dept.toLowerCase().contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }
    return const [];
  }
}
