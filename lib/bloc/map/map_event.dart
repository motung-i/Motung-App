abstract class MapEvent {
  const MapEvent();
}

class MapLocationServiceChecked extends MapEvent {
  const MapLocationServiceChecked();
}

class MapPermissionChecked extends MapEvent {
  const MapPermissionChecked();
}

class MapPermissionRequested extends MapEvent {
  const MapPermissionRequested();
}

class MapCurrentLocationRequested extends MapEvent {
  const MapCurrentLocationRequested();
}

class MapRouteDataRequested extends MapEvent {
  const MapRouteDataRequested();
}

class MapDirectionSelected extends MapEvent {
  final Object direction;

  const MapDirectionSelected({required this.direction});
}

class MapRandomLocationRequested extends MapEvent {
  final List<String>? regions;
  final List<String>? districts;

  const MapRandomLocationRequested({
    this.regions,
    this.districts,
  });
}

class MapRegionsRequested extends MapEvent {
  const MapRegionsRequested();
}

class MapDistrictsRequested extends MapEvent {
  final String region;

  const MapDistrictsRequested({required this.region});
}

class MapTourStartRequested extends MapEvent {
  const MapTourStartRequested();
}

class MapTourInfoRequested extends MapEvent {
  const MapTourInfoRequested();
}

class MapTourEndRequested extends MapEvent {
  const MapTourEndRequested();
}

class MapTourInfoGenerationRequested extends MapEvent {
  const MapTourInfoGenerationRequested();
}

class MapTourRouteRequested extends MapEvent {
  final double startLat;
  final double startLon;

  const MapTourRouteRequested({
    required this.startLat,
    required this.startLon,
  });
}
