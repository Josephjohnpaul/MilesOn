# MilesOn

MilesOn is a Flutter app for estimating trip fuel usage, total fuel cost, and refuel planning.

## Features

- Calculate trip fuel needed from distance and mileage.
- Calculate total trip fuel cost from fuel price per liter.
- Save multiple vehicle profiles with:
  - Name
  - Type (Scooter or Car)
  - Fixed mileage (km/l)
  - Fuel tank capacity (liters)
- Switch between manual mileage and a saved vehicle.
- Get refuel interval and estimated number of refuel stops for a trip.

## How Calculations Work

- Fuel used (liters) = `distance / mileage`
- Trip cost = `fuel used * fuel price`
- Refuel interval (km) = `mileage * tank capacity`
- Refuel stops = `max(0, ceil(distance / refuel interval) - 1)`

## Tech Stack

- Flutter
- Dart
- Material 3 UI

## Project Structure

- `lib/main.dart`: Main application, UI, state, vehicle management, and trip calculations.

## Getting Started

1. Install Flutter: <https://docs.flutter.dev/get-started/install>
2. In this folder, get dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Usage

1. Go to `Add Vehicle` to create one or more vehicle profiles (optional).
2. Go to `Home` and enter:
   - Distance (km)
   - Fuel price (per liter)
   - Mileage (if not using a saved vehicle)
3. Tap `Calculate Trip`.
4. Review:
   - Trip Cost
   - Fuel Needed
   - Refuel interval and estimated stops
