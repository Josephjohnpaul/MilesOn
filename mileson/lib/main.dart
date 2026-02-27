import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MilesOn',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          primary: const Color(0xFF0F766E),
          secondary: const Color(0xFFFB923C),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4F7F7),
        useMaterial3: true,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.2),
          ),
        ),
      ),
      home: const TripCostScreen(),
    );
  }
}

class VehicleProfile {
  const VehicleProfile({
    required this.name,
    required this.type,
    required this.mileage,
    required this.tankCapacity,
  });

  final String name;
  final VehicleType type;
  final double mileage;
  final double tankCapacity;
}

enum VehicleType { scooter, car }

extension VehicleTypeLabel on VehicleType {
  String get label {
    switch (this) {
      case VehicleType.scooter:
        return 'Scooter';
      case VehicleType.car:
        return 'Car';
    }
  }
}

class TripCostScreen extends StatefulWidget {
  const TripCostScreen({super.key});

  @override
  State<TripCostScreen> createState() => _TripCostScreenState();
}

class _TripCostScreenState extends State<TripCostScreen> {
  final TextEditingController distanceController = TextEditingController();
  final TextEditingController mileageController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  final TextEditingController vehicleNameController = TextEditingController();
  final TextEditingController vehicleMileageController = TextEditingController();
  final TextEditingController tankCapacityController = TextEditingController();

  final List<VehicleProfile> savedVehicles = <VehicleProfile>[];
  int? selectedVehicleIndex;
  VehicleType selectedVehicleType = VehicleType.car;

  int currentPageIndex = 0;

  double tripCost = 0;
  double fuelUsed = 0;
  double refuelIntervalKm = 0;
  int refuelStops = 0;

  VehicleProfile? get selectedVehicle {
    if (selectedVehicleIndex == null) {
      return null;
    }
    if (selectedVehicleIndex! < 0 || selectedVehicleIndex! >= savedVehicles.length) {
      return null;
    }
    return savedVehicles[selectedVehicleIndex!];
  }

  void saveVehicle() {
    final String name = vehicleNameController.text.trim();
    final double mileage = double.tryParse(vehicleMileageController.text) ?? 0;
    final double tank = double.tryParse(tankCapacityController.text) ?? 0;

    if (name.isEmpty || mileage <= 0 || tank <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid vehicle name, mileage and tank capacity.')),
      );
      return;
    }

    setState(() {
      savedVehicles.add(
        VehicleProfile(
          name: name,
          type: selectedVehicleType,
          mileage: mileage,
          tankCapacity: tank,
        ),
      );
      selectedVehicleIndex = savedVehicles.length - 1;
    });

    vehicleNameController.clear();
    vehicleMileageController.clear();
    tankCapacityController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved vehicle: $name')),
    );
  }

  void removeSelectedVehicle() {
    final int? index = selectedVehicleIndex;
    if (index == null || index < 0 || index >= savedVehicles.length) {
      return;
    }

    final String removedName = savedVehicles[index].name;
    setState(() {
      savedVehicles.removeAt(index);
      if (savedVehicles.isEmpty) {
        selectedVehicleIndex = null;
      } else if (index >= savedVehicles.length) {
        selectedVehicleIndex = savedVehicles.length - 1;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed vehicle: $removedName')),
    );
  }

  void calculateCost() {
    final double distance = double.tryParse(distanceController.text) ?? 0;
    final double price = double.tryParse(priceController.text) ?? 0;

    final double activeMileage = selectedVehicle?.mileage ?? (double.tryParse(mileageController.text) ?? 0);
    final double activeTank = selectedVehicle?.tankCapacity ?? 0;

    if (distance <= 0 || price <= 0 || activeMileage <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid distance, fuel price and mileage.')),
      );
      return;
    }

    final double used = distance / activeMileage;
    final double cost = used * price;

    double interval = 0;
    int stops = 0;

    if (activeTank > 0) {
      interval = activeMileage * activeTank;
      stops = max(0, (distance / interval).ceil() - 1);
    }

    setState(() {
      fuelUsed = used;
      tripCost = cost;
      refuelIntervalKm = interval;
      refuelStops = stops;
    });
  }

  @override
  void dispose() {
    distanceController.dispose();
    mileageController.dispose();
    priceController.dispose();
    vehicleNameController.dispose();
    vehicleMileageController.dispose();
    tankCapacityController.dispose();
    super.dispose();
  }

  Widget _sectionCard({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildHomePage() {
    final bool hasVehicle = selectedVehicle != null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'MilesOn',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: Color(0xFF115E59),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Trip cost and refuel planner',
          style: TextStyle(fontSize: 16, color: Color(0xFF475569)),
        ),
        const SizedBox(height: 20),
        _sectionCard(
          title: 'Trip Inputs',
          children: [
            TextField(
              controller: distanceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Distance (km)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Fuel price (per liter)'),
            ),
            if (!hasVehicle) ...[
              const SizedBox(height: 12),
              TextField(
                controller: mileageController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Mileage (km/l)'),
              ),
            ],
            if (savedVehicles.isNotEmpty) ...[
              const SizedBox(height: 12),
              InputDecorator(
                decoration: const InputDecoration(labelText: 'Selected vehicle'),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int?>(
                    isExpanded: true,
                    value: selectedVehicleIndex,
                    items: <DropdownMenuItem<int?>>[
                      const DropdownMenuItem<int?>(
                        value: null,
                        child: Text('Use manual mileage'),
                      ),
                      ...List<DropdownMenuItem<int?>>.generate(
                        savedVehicles.length,
                        (int index) {
                          final VehicleProfile v = savedVehicles[index];
                          return DropdownMenuItem<int?>(
                            value: index,
                            child: Text(
                              '${v.name} (${v.type.label}, ${v.mileage.toStringAsFixed(1)} km/l)',
                            ),
                          );
                        },
                      ),
                    ],
                    onChanged: (int? value) {
                      setState(() {
                        selectedVehicleIndex = value;
                      });
                    },
                  ),
                ),
              ),
            ],
            if (hasVehicle) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE7F7F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Using ${selectedVehicle!.name} (${selectedVehicle!.type.label})',
                  style: const TextStyle(
                    color: Color(0xFF065F46),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          onPressed: calculateCost,
          child: const Text('Calculate Trip'),
        ),
        const SizedBox(height: 16),
        _sectionCard(
          title: 'Results',
          children: [
            Text(
              'Trip Cost: INR ${tripCost.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Fuel Needed: ${fuelUsed.toStringAsFixed(2)} liters',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              refuelIntervalKm > 0
                  ? 'Refuel every ${refuelIntervalKm.toStringAsFixed(0)} km (about $refuelStops stop(s) in this trip)'
                  : 'Select/save a vehicle with tank capacity to get refuel interval',
              style: TextStyle(
                fontSize: 16,
                color: refuelIntervalKm > 0 ? const Color(0xFF0F766E) : const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAddVehiclePage() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Add Vehicle',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: Color(0xFF115E59),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Create and manage saved vehicles',
          style: TextStyle(fontSize: 16, color: Color(0xFF475569)),
        ),
        const SizedBox(height: 20),
        _sectionCard(
          title: 'New Vehicle',
          children: [
            TextField(
              controller: vehicleNameController,
              decoration: const InputDecoration(labelText: 'Vehicle name'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<VehicleType>(
              initialValue: selectedVehicleType,
              decoration: const InputDecoration(labelText: 'Vehicle type'),
              items: VehicleType.values
                  .map(
                    (VehicleType type) => DropdownMenuItem<VehicleType>(
                      value: type,
                      child: Text(type.label),
                    ),
                  )
                  .toList(),
              onChanged: (VehicleType? value) {
                if (value == null) return;
                setState(() {
                  selectedVehicleType = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: vehicleMileageController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Fixed mileage (km/l)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tankCapacityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Fuel tank capacity (liters)'),
            ),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: saveVehicle,
              child: const Text('Save Vehicle'),
            ),
          ],
        ),
        _sectionCard(
          title: 'Saved Vehicles',
          children: [
            if (savedVehicles.isEmpty)
              const Text(
                'No saved vehicles yet.',
                style: TextStyle(color: Color(0xFF64748B)),
              ),
            if (savedVehicles.isNotEmpty)
              ...List<Widget>.generate(savedVehicles.length, (int index) {
                final VehicleProfile vehicle = savedVehicles[index];
                final bool isSelected = selectedVehicleIndex == index;
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFE7F7F2) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    onTap: () {
                      setState(() {
                        selectedVehicleIndex = index;
                      });
                    },
                    title: Text(vehicle.name),
                    subtitle: Text(
                      '${vehicle.type.label} | ${vehicle.mileage.toStringAsFixed(1)} km/l | ${vehicle.tankCapacity.toStringAsFixed(1)} L',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        setState(() {
                          savedVehicles.removeAt(index);
                          if (savedVehicles.isEmpty) {
                            selectedVehicleIndex = null;
                          } else if (selectedVehicleIndex == index) {
                            selectedVehicleIndex = 0;
                          } else if (selectedVehicleIndex != null && selectedVehicleIndex! > index) {
                            selectedVehicleIndex = selectedVehicleIndex! - 1;
                          }
                        });
                      },
                    ),
                  ),
                );
              }),
            if (savedVehicles.isNotEmpty)
              OutlinedButton(
                onPressed: removeSelectedVehicle,
                child: const Text('Remove Selected Vehicle'),
              ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE6F6F4), Color(0xFFF9F7F2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: currentPageIndex == 0 ? _buildHomePage() : _buildAddVehiclePage(),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentPageIndex,
        onDestinationSelected: (int index) {
          setState(() {
            currentPageIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car),
            label: 'Add Vehicle',
          ),
        ],
      ),
    );
  }
}
