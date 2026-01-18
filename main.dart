import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WeatherHome(),
    );
  }
}

class WeatherHome extends StatefulWidget {
  @override
  State<WeatherHome> createState() => _WeatherHomeState();
}

class _WeatherHomeState extends State<WeatherHome> {
  final String apiKey = "2847f2b45c780102db64a3f7e62eea0c";
  Map<String, dynamic>? weatherData;

  @override
  void initState() {
    super.initState();
    getWeather();
  }

  Future<void> getWeather() async {
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final url =
        "https://api.openweathermap.org/data/3.0/onecall?lat=${pos.latitude}&lon=${pos.longitude}&units=metric&lang=id&appid=$apiKey";

    final res = await http.get(Uri.parse(url));
    setState(() {
      weatherData = json.decode(res.body);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (weatherData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Cuaca Saat Ini",
                style: TextStyle(color: Colors.white70),
              ),
              Text(
                "${weatherData!['current']['temp'].round()}°",
                style: const TextStyle(
                  fontSize: 90,
                  color: Colors.white,
                ),
              ),
              Text(
                weatherData!['current']['weather'][0]['description'],
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Perkiraan 7 Hari",
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final day = weatherData!['daily'][index];
                    return Card(
                      color: Colors.white.withOpacity(0.1),
                      child: ListTile(
                        title: Text(
                          DateFormat.EEEE('id').format(
                            DateTime.fromMillisecondsSinceEpoch(
                              day['dt'] * 1000,
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: Text(
                          "${day['temp']['day'].round()}°",
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

