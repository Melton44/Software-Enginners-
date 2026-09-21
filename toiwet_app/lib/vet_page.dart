import 'package:flutter/material.dart';

class VetPage extends StatefulWidget {
  const VetPage({super.key});

  @override
  State<VetPage> createState() => _VetPageState();
}

class _VetPageState extends State<VetPage> {
  // Doctor Profile State
  String _doctorName = "Dr. Jane Doe";
  String _doctorPhone = "+254 700 000 000";
  String _doctorId = "29485019";

  // Dynamic Lists
  final List<Map<String, String>> _vaccinations = [
    {
      'title': 'Foot & Mouth Disease (FMD)',
      'schedule': 'Administer every 6 Months',
      'targetTag': 'All Sheep'
    },
    {
      'title': 'Dewormer (Albendazole)',
      'schedule': 'Administer every 3 Months',
      'targetTag': 'Flock-wide'
    },
  ];

  final List<Map<String, String>> _medications = [
    {
      'sheepTag': 'TW-SH-089',
      'medName': 'Oxytetracycline 20%',
      'dosage': '5ml intramuscular',
      'date': '18/09/2026'
    },
  ];

  // Dialog: Edit Doctor Information
  void _showEditDoctorDialog() {
    final nameCtrl = TextEditingController(text: _doctorName);
    final phoneCtrl = TextEditingController(text: _doctorPhone);
    final idCtrl = TextEditingController(text: _doctorId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Update Doctor Profile', style: TextStyle(color: Color(0xFF1B5E20))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Doctor Name')),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Phone Number')),
            TextField(controller: idCtrl, decoration: const InputDecoration(labelText: 'National ID / License')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
            onPressed: () {
              setState(() {
                _doctorName = nameCtrl.text.trim();
                _doctorPhone = phoneCtrl.text.trim();
                _doctorId = idCtrl.text.trim();
              });
              Navigator.pop(context);
            },
            child: const Text('Save Profile', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  // Dialog: Add Vaccination Schedule
  void _showAddVaccineDialog() {
    final titleCtrl = TextEditingController();
    final scheduleCtrl = TextEditingController();
    final tagCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Add Vaccination Schedule', style: TextStyle(color: Color(0xFF1B5E20))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Vaccine Name')),
            TextField(controller: scheduleCtrl, decoration: const InputDecoration(labelText: 'Frequency / Interval')),
            TextField(controller: tagCtrl, decoration: const InputDecoration(labelText: 'Target Group / Sheep Tag')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty) return;
              setState(() {
                _vaccinations.add({
                  'title': titleCtrl.text.trim(),
                  'schedule': scheduleCtrl.text.trim(),
                  'targetTag': tagCtrl.text.trim().isEmpty ? 'All Sheep' : tagCtrl.text.trim(),
                });
              });
              Navigator.pop(context);
            },
            child: const Text('Add Schedule', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  // Dialog: Record Sheep Medication
  void _showAddMedicationDialog() {
    final tagCtrl = TextEditingController();
    final medCtrl = TextEditingController();
    final dosageCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Record Medication Prescribed', style: TextStyle(color: Color(0xFF1B5E20))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: tagCtrl, decoration: const InputDecoration(labelText: 'Sheep Tag Number')),
            TextField(controller: medCtrl, decoration: const InputDecoration(labelText: 'Medication Name')),
            TextField(controller: dosageCtrl, decoration: const InputDecoration(labelText: 'Dosage Instructions')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2E7D32)),
            onPressed: () {
              if (tagCtrl.text.trim().isEmpty || medCtrl.text.trim().isEmpty) return;
              setState(() {
                _medications.add({
                  'sheepTag': tagCtrl.text.trim(),
                  'medName': medCtrl.text.trim(),
                  'dosage': dosageCtrl.text.trim(),
                  'date': '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                });
              });
              Navigator.pop(context);
            },
            child: const Text('Log Medication', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF2E7D32);
    const Color darkGreen = Color(0xFF1B5E20);

    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/sheep.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(color: Colors.black.withValues(alpha: 0.25)),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Branding
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.asset(
                          'assets/logo.png',
                          height: 48,
                          width: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            height: 48,
                            width: 48,
                            decoration: const BoxDecoration(color: primaryGreen, shape: BoxShape.circle),
                            child: const Icon(Icons.medical_services, color: Colors.white, size: 28),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Tuiymet Ecofarmers',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(
                            'Veterinary & Health Services',
                            style: TextStyle(fontSize: 12, color: Colors.white70),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Doctor Profile Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: darkGreen.withValues(alpha: 0.90),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10)],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white24,
                          child: Icon(Icons.person, color: Colors.white, size: 36),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _doctorName,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              // CORRECT
Text('Tel: $_doctorPhone', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13)),
                              Text('ID / License: $_doctorId', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: _showEditDoctorDialog,
                          tooltip: 'Edit Profile',
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Section 1: Vaccination Schedules
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Vaccination Schedules',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      IconButton(
                        onPressed: _showAddVaccineDialog,
                        icon: const Icon(Icons.add_circle, color: Colors.white, size: 28),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  ..._vaccinations.map(
                    (vax) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.vaccines_outlined, color: primaryGreen, size: 32),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(vax['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: darkGreen)),
                                const SizedBox(height: 2),
                                Text(vax['schedule']!, style: const TextStyle(color: Colors.black87, fontSize: 13)),
                              ],
                            ),
                          ),
                          Chip(
                            label: Text(vax['targetTag']!, style: const TextStyle(fontSize: 11, color: primaryGreen)),
                            backgroundColor: primaryGreen.withValues(alpha: 0.12),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Section 2: Prescribed Medications
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sheep Medication Log',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      IconButton(
                        onPressed: _showAddMedicationDialog,
                        icon: const Icon(Icons.medication_liquid, color: Colors.white, size: 28),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  ..._medications.map(
                    (med) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.medical_information_outlined, color: primaryGreen, size: 32),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${med['medName']} (${med['sheepTag']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: darkGreen)),
                                const SizedBox(height: 2),
                                Text('Dosage: ${med['dosage']}', style: const TextStyle(color: Colors.black87, fontSize: 13)),
                                Text('Logged: ${med['date']}', style: const TextStyle(color: Colors.black54, fontSize: 11)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}