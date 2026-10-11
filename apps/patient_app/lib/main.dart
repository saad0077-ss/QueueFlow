import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
 
  // Initialize Firebase for Patient Mobile/Web App
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const PatientApp());
}

class PatientApp extends StatelessWidget {
  const PatientApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QueueFlow — Patient App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF02569B),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const PatientHomeScreen(),
    );
  }
}

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  int _currentIndex = 0;
  String? _myTokenNumber;
  final String _clinicId = 'clinic_main_01'; // Default clinic scope

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            const Icon(Icons.health_and_safety_rounded, color: Color(0xFF02569B)),
            const SizedBox(width: 8),
            const Text(
              'QueueFlow',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Patient',
                style: TextStyle(fontSize: 11, color: Color(0xFF0369A1), fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              border: Border.all(color: Colors.green.shade200),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.cloud_done_rounded, color: Colors.green, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Connected',
                  style: TextStyle(fontSize: 11, color: Colors.green.shade800, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildDiscoverTab(),
          _buildQueueTrackerTab(),
          _buildMyBookingsTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.local_hospital_outlined),
            selectedIcon: Icon(Icons.local_hospital_rounded),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.confirmation_number_outlined),
            selectedIcon: Icon(Icons.confirmation_number_rounded),
            label: 'My Queue',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Bookings',
          ),
        ],
      ),
    );
  }

  // 1. DISCOVER TAB
  Widget _buildDiscoverTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Search Banner
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF02569B), Color(0xFF0284C7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Book Smarter. Wait Less.',
                style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'Discover verified outpatient clinics, reserve digital queue tokens & track wait times in real time.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search_rounded, color: Colors.grey),
                    hintText: 'Search clinic, doctor or specialty...',
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        const Text(
          'Featured Outpatient Clinics',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        // Sample Clinics List
        _buildClinicCard(
          name: 'Metro Health Primary Care',
          specialty: 'General Medicine & Pediatrics',
          address: '42 Central Health Plaza, Suite 102',
          fee: '₹499',
          hours: '09:00 AM - 06:00 PM',
          rating: '4.8 (124 reviews)',
        ),
        _buildClinicCard(
          name: 'Apex Dental Studio',
          specialty: 'Orthodontics & Implants',
          address: '15 Diamond Avenue, 2nd Floor',
          fee: '₹799',
          hours: '10:00 AM - 08:00 PM',
          rating: '4.9 (88 reviews)',
        ),
        _buildClinicCard(
          name: 'CareFirst Dermatology Clinic',
          specialty: 'Skin & Laser Specialist',
          address: '88 Green Park Road',
          fee: '₹899',
          hours: '11:00 AM - 07:00 PM',
          rating: '4.7 (65 reviews)',
        ),
      ],
    );
  }

  Widget _buildClinicCard({
    required String name,
    required String specialty,
    required String address,
    required String fee,
    required String hours,
    required String rating,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(rating, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(specialty, style: const TextStyle(color: Color(0xFF02569B), fontSize: 13, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Expanded(child: Text(address, style: TextStyle(fontSize: 12, color: Colors.grey.shade600))),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.schedule_rounded, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(hours, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                const Spacer(),
                Text('Consultation: $fee', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              ],
            ),
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showBookingDialog(name, fee),
                    child: const Text('Book Appointment'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF02569B),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _joinLiveQueue(name),
                    child: const Text('Join Live Queue'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 2. LIVE QUEUE TRACKER TAB
  Widget _buildQueueTrackerTab() {
    if (_myTokenNumber == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.confirmation_number_outlined, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'No Active Queue Ticket',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Go to the Discover tab and tap "Join Live Queue" to get a real-time digital queue token.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF02569B),
                  foregroundColor: Colors.white,
                ),
                onPressed: () => setState(() => _currentIndex = 0),
                icon: const Icon(Icons.search_rounded),
                label: const Text('Discover Clinics & Join'),
              ),
            ],
          ),
        ),
      );
    }

    // Live Stream from Firestore
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('queues').doc(_clinicId).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        final currentToken = data['currentToken'] ?? '---';
        final int currentNum = int.tryParse(currentToken.replaceAll('A-', '')) ?? 0;
        final int myNum = int.tryParse((_myTokenNumber ?? 'A-000').replaceAll('A-', '')) ?? 0;
        final int peopleAhead = (myNum - currentNum - 1).clamp(0, 999);
        final bool isMyTurn = currentToken == _myTokenNumber;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Status Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isMyTurn ? Colors.green.shade50 : const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isMyTurn ? Colors.green.shade300 : const Color(0xFFBAE6FD)),
              ),
              child: Row(
                children: [
                  Icon(
                    isMyTurn ? Icons.notification_important_rounded : Icons.info_outline_rounded,
                    color: isMyTurn ? Colors.green.shade800 : const Color(0xFF0284C7),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isMyTurn
                          ? '🎉 IT IS YOUR TURN! Please enter the consultation room.'
                          : peopleAhead <= 2
                              ? '⚡ Almost your turn! You are $peopleAhead in line.'
                              : 'You are in line. We will notify you as your turn approaches.',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isMyTurn ? Colors.green.shade900 : const Color(0xFF0369A1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Token Highlight Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Text('YOUR TOKEN NUMBER', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      _myTokenNumber!,
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF02569B)),
                    ),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQueueStat('Now Serving', currentToken, Colors.blue),
                        _buildQueueStat('People Ahead', '$peopleAhead', Colors.orange),
                        _buildQueueStat('Est. Wait', '${peopleAhead * 10} mins', Colors.purple),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 5-Stage Progress Tracker
            const Text('Queue Progression Timeline', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildTimelineStep('1. Joined Queue', 'Token allocated successfully', true),
            _buildTimelineStep('2. Waiting in Line', '$peopleAhead patients ahead of you', peopleAhead > 0),
            _buildTimelineStep('3. Almost Your Turn', 'Approaching front of line', peopleAhead <= 2),
            _buildTimelineStep('4. Called to Room', 'Enter consultation room', isMyTurn),
            _buildTimelineStep('5. Consultation Complete', 'Visit concluded', false),
            const SizedBox(height: 24),

            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red.shade200),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => setState(() => _myTokenNumber = null),
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('Leave Queue'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQueueStat(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildTimelineStep(String title, String desc, bool isDone) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            color: isDone ? Colors.green : Colors.grey.shade400,
            size: 20,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDone ? Colors.black87 : Colors.grey),
              ),
              Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
        ],
      ),
    );
  }

  // 3. MY BOOKINGS TAB
  Widget _buildMyBookingsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('appointments').snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today_rounded, size: 54, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                const Text('No Appointments Booked Yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('Book an appointment from the Discover tab.', style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final ref = data['bookingRef'] ?? 'QF-XXXXX';
            final clinic = data['clinicName'] ?? 'Clinic';
            final date = data['date'] ?? 'Today';
            final slot = data['timeSlot'] ?? '10:00 AM';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFE0F2FE),
                  child: const Icon(Icons.event_available_rounded, color: Color(0xFF02569B)),
                ),
                title: Text(clinic, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Date: $date • Slot: $slot\nRef: $ref'),
                trailing: Chip(
                  label: const Text('Confirmed', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                  backgroundColor: Colors.green.shade50,
                  side: BorderSide.none,
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Action: Join live queue
  Future<void> _joinLiveQueue(String clinicName) async {
    final nameController = TextEditingController(text: 'Patient User');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Join Queue — $clinicName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Enter your name to reserve a live virtual queue token:'),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Patient Name', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF02569B), foregroundColor: Colors.white),
              onPressed: () async {
                final firestore = FirebaseFirestore.instance;
                final queueRef = firestore.collection('queues').doc(_clinicId);

                // Atomic Transaction
                final token = await firestore.runTransaction((transaction) async {
                  final snap = await transaction.get(queueRef);
                  int total = snap.exists ? (snap.data()?['totalIssued'] ?? 0) : 0;
                  int waiting = snap.exists ? (snap.data()?['waitingCount'] ?? 0) : 0;

                  final nextNum = total + 1;
                  final tokenStr = 'A-${nextNum.toString().padLeft(3, '0')}';

                  transaction.set(queueRef, {
                    'totalIssued': nextNum,
                    'waitingCount': waiting + 1,
                    'status': 'open',
                  }, SetOptions(merge: true));

                  return tokenStr;
                });

                // Write Ticket
                await firestore.collection('tickets').add({
                  'token': token,
                  'clinicId': _clinicId,
                  'patientName': nameController.text.trim(),
                  'status': 'waiting',
                  'joinedAt': FieldValue.serverTimestamp(),
                });

                setState(() {
                  _myTokenNumber = token;
                  _currentIndex = 1; // Switch to Queue tab
                });

                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Get My Token'),
            ),
          ],
        );
      },
    );
  }

  // Action: Book appointment
  Future<void> _showBookingDialog(String clinicName, String fee) async {
    final ref = 'QF-${(10000 + (DateTime.now().millisecondsSinceEpoch % 90000))}';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Confirm Booking — $clinicName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Consultation Fee: $fee', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Date: Tomorrow, 10:30 AM'),
              const SizedBox(height: 4),
              Text('Booking Reference: $ref', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF02569B), foregroundColor: Colors.white),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('appointments').add({
                  'bookingRef': ref,
                  'clinicName': clinicName,
                  'clinicId': _clinicId,
                  'date': 'Tomorrow',
                  'timeSlot': '10:30 AM',
                  'status': 'confirmed',
                  'createdAt': FieldValue.serverTimestamp(),
                });
                setState(() => _currentIndex = 2); // Switch to Bookings
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Confirm Appointment'),
            ),
          ],
        );
      },
    );
  }
}
