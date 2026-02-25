import 'package:equatable/equatable.dart';

class City extends Equatable {
  final String name;
  final double lat;
  final double lon;

  const City({required this.name, required this.lat, required this.lon});

  @override
  List<Object?> get props => [name, lat, lon];

  static const List<City> cities = [
    City(name: 'Toshkent', lat: 41.2995, lon: 69.2401),
    City(name: 'Samarqand', lat: 39.627, lon: 66.9749),
    City(name: 'Buxoro', lat: 39.7747, lon: 64.4286),
    City(name: 'Namangan', lat: 41.0011, lon: 71.6676),
    City(name: 'Andijon', lat: 40.7821, lon: 72.3442),
    City(name: "Farg'ona", lat: 40.3842, lon: 71.7843),
    City(name: 'Qarshi', lat: 38.8606, lon: 65.7891),
    City(name: 'Nukus', lat: 42.4619, lon: 59.6166),
    City(name: 'Termiz', lat: 37.2242, lon: 67.2783),
    City(name: 'Navoiy', lat: 40.0844, lon: 65.3792),
    City(name: 'Urganch', lat: 41.5533, lon: 60.6347),
    City(name: 'Sirdaryo', lat: 40.8347, lon: 68.6642),
    City(name: 'Jizzax', lat: 40.1158, lon: 67.8422),
    City(name: "Qo'qon", lat: 40.5283, lon: 70.9425),
  ];
}

/// Xarita sahifasi uchun viloyat ma'lumotlari (koordinatlar + harorat)
class RegionCity extends City {
  /// Uzbekiston xaritasida nisbiy joylashuvi (0.0–1.0)
  final double mapX;
  final double mapY;

  const RegionCity({
    required super.name,
    required super.lat,
    required super.lon,
    required this.mapX,
    required this.mapY,
  });

  static const List<RegionCity> allRegions = [
    RegionCity(
      name: 'Nukus',
      lat: 42.4619,
      lon: 59.6166,
      mapX: 0.10,
      mapY: 0.20,
    ),
    RegionCity(
      name: 'Urganch',
      lat: 41.5533,
      lon: 60.6347,
      mapX: 0.18,
      mapY: 0.36,
    ),
    RegionCity(
      name: 'Buxoro',
      lat: 39.7747,
      lon: 64.4286,
      mapX: 0.30,
      mapY: 0.62,
    ),
    RegionCity(
      name: 'Navoiy',
      lat: 40.0844,
      lon: 65.3792,
      mapX: 0.40,
      mapY: 0.54,
    ),
    RegionCity(
      name: 'Samarqand',
      lat: 39.627,
      lon: 66.9749,
      mapX: 0.46,
      mapY: 0.66,
    ),
    RegionCity(
      name: 'Qarshi',
      lat: 38.8606,
      lon: 65.7891,
      mapX: 0.46,
      mapY: 0.80,
    ),
    RegionCity(
      name: 'Termiz',
      lat: 37.2242,
      lon: 67.2783,
      mapX: 0.53,
      mapY: 0.92,
    ),
    RegionCity(
      name: 'Jizzax',
      lat: 40.1158,
      lon: 67.8422,
      mapX: 0.56,
      mapY: 0.52,
    ),
    RegionCity(
      name: 'Sirdaryo',
      lat: 40.8347,
      lon: 68.6642,
      mapX: 0.62,
      mapY: 0.42,
    ),
    RegionCity(
      name: 'Toshkent',
      lat: 41.2995,
      lon: 69.2401,
      mapX: 0.67,
      mapY: 0.30,
    ),
    RegionCity(
      name: "Farg'ona",
      lat: 40.3842,
      lon: 71.7843,
      mapX: 0.82,
      mapY: 0.50,
    ),
    RegionCity(
      name: 'Namangan',
      lat: 41.0011,
      lon: 71.6676,
      mapX: 0.80,
      mapY: 0.36,
    ),
    RegionCity(
      name: 'Andijon',
      lat: 40.7821,
      lon: 72.3442,
      mapX: 0.90,
      mapY: 0.44,
    ),
    RegionCity(
      name: "Qo'qon",
      lat: 40.5283,
      lon: 70.9425,
      mapX: 0.76,
      mapY: 0.52,
    ),
  ];
}
