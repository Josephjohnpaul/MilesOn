import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: TripCostScreen(),
    );
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

  double tripCost = 0;

  void calculateCost() {
    double distance = double.tryParse(distanceController.text) ?? 0;
    double mileage = double.tryParse(mileageController.text) ?? 0;
    double price = double.tryParse(priceController.text) ?? 0;

    if (mileage > 0) {
      double fuelUsed = distance / mileage;
      setState(() {
        tripCost = fuelUsed * price;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Trip Cost Calculator"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            TextField(
              controller: distanceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Distance (km)",
              ),
            ),

            TextField(
              controller: mileageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Mileage (km/l)",
              ),
            ),

            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Fuel Price (₹)",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: calculateCost,
              child: const Text("Calculate"),
            ),

            const SizedBox(height: 20),

            Text(
              "Trip Cost: ₹${tripCost.toStringAsFixed(2)}",
              style: const TextStyle(fontSize: 22),
            ),
          ],
        ),
      ),
    );
  }
}