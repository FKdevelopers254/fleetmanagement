import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';

class SelectRoutePointsPage extends StatefulWidget {
  @override
  _SelectRoutePointsPageState createState() => _SelectRoutePointsPageState();
}

class _SelectRoutePointsPageState extends State<SelectRoutePointsPage> {
  final mapController = MapController();
  List<LatLng> routePoints = [];

  void _handleTap(LatLng latlng) {
    setState(() {
      routePoints.add(latlng);
    });
  }

  void _saveRoutePoints() {
    Navigator.pop(context, routePoints);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Route Points'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveRoutePoints,
          ),
        ],
      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: LatLng(-1.5, 36.8),
          initialZoom: 6,
          maxZoom: 20,
          minZoom: 3,
          onTap: (tapPosition, latLng) {
            _handleTap(latLng);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'dev.fleaflet.flutter_map.example',
            tileProvider: CancellableNetworkTileProvider(),
          ),
          MarkerLayer(
            markers: routePoints.map((latLng) {
              return Marker(
                width: 80,
                height: 80,
                point: latLng,
                child:  Icon(
                  Icons.location_on,
                  size: 40,
                  color: Colors.blue,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
