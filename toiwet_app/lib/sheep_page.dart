import 'package:flutter/material.dart';

class Sheep {
  final String tagNumber;
  final String breed;
  final int ageMonths;
  final double weightKg;
  final String motherTag;
  final String feedType;

  Sheep({
    required this.tagNumber,
    required this.breed,
    required this.ageMonths,
    required this.weightKg,
    required this.motherTag,
    required this.feedType,
  });
}

class SheepPage extends StatefulWidget {
  const SheepPage({super.key});

  @override
  State<SheepPage> createState() => _SheepPageState();
}

class _SheepPageState extends State<SheepPage> {
  // Initial interactive sheep list
  final List<Sheep> _sheepList = [
    Sheep(
      tagNumber: 'TW-SH-089',
      breed: 'Dorper',
      ageMonths: 14,
      weightKg: 45.0,
      motherTag: 'TW-SH-012',
      feedType: 'Rhodes Grass',
    ),
    Sheep(
      tagNumber: 'TW-SH-090',
      breed: 'Merino',
      ageMonths: 8,
      weightKg: 32.5,
      motherTag: 'TW-SH-005',
      feedType: 'Alfalfa Hay',
    ),
  ];

  // Open Add Sheep Dialog
  void _showAddSheepDialog() {
    final tagController = TextEditingController();
    final breedController = TextEditingController();
    final ageController = TextEditingController();
    final weightController = TextEditingController();
    final motherTagController = TextEditingController();
    final feedController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Register New Sheep',
            style: TextStyle(color: Color(0xFF1B5E20), fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: tagController,
                  decoration: const InputDecoration(labelText: 'Tag Number (e.g. TW-SH-091)'),
                ),
                TextField(
                  controller: breedController,
                  decoration: const InputDecoration(labelText: 'Breed (e.g. Dorper)'),
                ),
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Age (Months)'),
                ),
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Weight (kg)'),
                ),
                TextField(
                  controller: motherTagController,
                  decoration: const InputDecoration(labelText: 'Mother Tag'),
                ),
                TextField(
                  controller: feedController,
                  decoration: const InputDecoration(labelText: 'Primary Feed Type'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                if (tagController.text.trim().isEmpty) return;

                setState(() {
                  _sheepList.add(
                    Sheep(
                      tagNumber: tagController.text.trim(),
                      breed: breedController.text.trim().isEmpty ? 'Unknown' : breedController.text.trim(),
                      ageMonths: int.tryParse(ageController.text.trim()) ?? 0,
                      weightKg: double.tryParse(weightController.text.trim()) ?? 0.0,
                      motherTag: motherTagController.text.trim().isEmpty ? 'N/A' : motherTagController.text.trim(),
                      feedType: feedController.text.trim().isEmpty ? 'Standard Pasture' : feedController.text.trim(),
                    ),
                  );
                });
                Navigator.pop(context);
              },
              child: const Text('Add Record', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _removeSheep(int index) {
    setState(() {
      _sheepList.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sheep record removed successfully.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF2E7D32);
    const Color darkGreen = Color(0xFF1B5E20);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheepDialog,
        backgroundColor: primaryGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Sheep', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
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
          // Dark Overlay
          Container(
            color: Colors.black.withValues(alpha: 0.25),
          ),
          SafeArea(
            child: Column(
              children: [
                // Branding Navigation Header
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                                decoration: const BoxDecoration(
                                  color: primaryGreen,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.pets, color: Colors.white, size: 28),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Tuiymet Ecofarmers',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                                ),
                              ),
                              Text(
                                'Livestock & Sheep Registry',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Interactive Sheep Cards List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: _sheepList.length,
                    itemBuilder: (context, index) {
                      final item = _sheepList[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.12),
                              blurRadius: 15,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            // Banner / Image Container
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                              child: Container(
                                height: 120,
                                width: double.infinity,
                                decoration: const BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('assets/sheep.jpeg'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  alignment: Alignment.topRight,
                                  child: IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.white),
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.black45,
                                    ),
                                    onPressed: () => _removeSheep(index),
                                  ),
                                ),
                              ),
                            ),
                            // Content Section
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Tag #${item.tagNumber}',
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: darkGreen,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: primaryGreen.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          'Feed: ${item.feedType}',
                                          style: const TextStyle(
                                            color: primaryGreen,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Breed: ${item.breed}  |  Age: ${item.ageMonths} Months  |  Weight: ${item.weightKg}kg',
                                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Mother Tag: ${item.motherTag}',
                                    style: const TextStyle(fontSize: 13, color: Colors.black54),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}