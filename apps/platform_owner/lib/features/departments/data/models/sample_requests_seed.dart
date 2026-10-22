const sampleExpansionRequestsSeed = [
  {
    'clinicId': 'sunrise-health',
    'clinicName': 'Sunrise Health Clinic',
    'departmentIds': ['dept-dent', 'dept-ortho'],
    'departmentNames': ['Dental & Oral Surgery', 'Orthopedics & Sports Rehab'],
    'departmentIcons': ['🦷', '🦴'],
    'expectedDoctorCount': 2,
    'targetDate': 'Next Month',
    'reason': 'Onboarding visiting dental and orthopedic specialists for rehab.',
    'requestedBy': 'Dr. Priya Sharma',
    'status': 'pending',
    'createdAt': 'Recent',
  },
];

const sampleServiceRequestsSeed = [
  {
    'clinicId': 'smile-dental',
    'clinicName': 'Smile Dental Clinic',
    'departmentId': 'dept-dent',
    'departmentName': 'Dental & Oral Surgery',
    'serviceName': 'Invisalign Clear Aligners & 3D Scan',
    'duration': 45,
    'suggestedPrice': 3500,
    'description': 'High-resolution 3D intraoral scanning & aligner fitting.',
    'requestedBy': 'Dr. Rahul Menon',
    'notes': 'Acquired 3D scanner; patients asking for aligners.',
    'status': 'pending',
    'createdAt': 'Recent',
  },
];
