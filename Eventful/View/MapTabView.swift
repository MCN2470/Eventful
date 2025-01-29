import SwiftUI
import MapKit
import CoreLocation

// This struct represents annotations (pins) on the map
struct CustomAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String?
}

struct MapTabView: View {
    @State private var searchLocation = "" // User input for destination search
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 22.3193, longitude: 114.1694), // Default: Hong Kong
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1) // Zoom level
    )
    @State private var annotations: [CustomAnnotation] = [] // Annotations for the map (pins)
    @State private var route: MKPolyline? // Route to display on the map
    @StateObject private var locationManager = LocationManager() // Location manager to get current location
    @State private var showPermissionDeniedAlert = false

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Search for a destination", text: $searchLocation, onCommit: {
                        searchForLocationAndRoute()
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                    Button(action: {
                        searchForLocationAndRoute()
                    }) {
                        Image(systemName: "magnifyingglass")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .clipShape(Circle())
                    }
                    .padding(.trailing)
                }

                // Button to center the map on the user's current location
                Button(action: {
                    if let location = locationManager.userLocation {
                        region.center = location
                        print("Centered map at user's current location: \(location.latitude), \(location.longitude)")
                        // Add a pin for the user's current location
                        annotations = [
                            CustomAnnotation(coordinate: location, title: "Current Location")
                        ]
                    } else {
                        print("User location is not available.")
                    }
                }) {
                    HStack {
                        Image(systemName: "location.fill")
                        Text("Go to Current Location")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()

                // Map view with annotations
                Map(coordinateRegion: $region,
                    annotationItems: annotations) { annotation in
                    MapAnnotation(coordinate: annotation.coordinate) {
                        VStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                                .font(.largeTitle)
                            if let title = annotation.title {
                                Text(title)
                                    .font(.caption)
                                    .padding(4)
                                    .background(Color.white)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .overlay(
                    MapRouteOverlay(route: route) // Add the route overlay to the map
                )
            }
            .navigationTitle("Map")
            .onAppear {
                locationManager.requestLocation() // Request the user's location

                // Check if location permissions are denied
                if locationManager.authorizationStatus == .denied {
                    showPermissionDeniedAlert = true
                }

                // Default to Hong Kong if location is unavailable
                if locationManager.userLocation == nil {
                    region.center = CLLocationCoordinate2D(latitude: 22.3193, longitude: 114.1694)
                    print("Location unavailable. Defaulting to Hong Kong.")
                }
            }
            .alert("Location Permission Denied", isPresented: $showPermissionDeniedAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please enable location services in settings to use this feature.")
            }
        }
    }

    private func searchForLocationAndRoute() {
        guard let userLocation = locationManager.userLocation else {
            print("User location is not available.")
            return
        }

        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(searchLocation) { placemarks, error in
            if let error = error {
                print("Error geocoding location: \(error.localizedDescription)")
                return
            }

            if let destinationLocation = placemarks?.first?.location {
                // Update the map's region to center on the destination
                region.center = destinationLocation.coordinate

                // Clear and reassign annotations to ensure the map updates
                let newAnnotations = [
                    CustomAnnotation(coordinate: userLocation, title: "Start: Current Location"),
                    CustomAnnotation(coordinate: destinationLocation.coordinate, title: "End: \(searchLocation)")
                ]
                self.annotations = [] // Clear annotations first
                self.annotations = newAnnotations // Assign new annotations

                // Calculate the route between the current location and the searched destination
                calculateRoute(from: userLocation, to: destinationLocation.coordinate)
            }
        }
    }

    // Calculate the route between two locations
    private func calculateRoute(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        let sourcePlacemark = MKPlacemark(coordinate: source)
        let destinationPlacemark = MKPlacemark(coordinate: destination)

        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: sourcePlacemark)
        request.destination = MKMapItem(placemark: destinationPlacemark)
        request.transportType = .automobile

        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            if let error = error {
                print("Error calculating route: \(error.localizedDescription)")
                return
            }

            if let route = response?.routes.first {
                // Update the route to be displayed on the map
                self.route = route.polyline
                region = MKCoordinateRegion(route.polyline.boundingMapRect)
            }
        }
    }
}

struct MapRouteOverlay: View {
    let route: MKPolyline?

    var body: some View {
        GeometryReader { geometry in
            if let route = route {
                MapOverlayView(route: route)
                    .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}


struct MapOverlayView: UIViewRepresentable {
    let route: MKPolyline

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeOverlays(mapView.overlays) // Remove existing overlays
        mapView.addOverlay(route) // Add the new route polyline
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .blue
                renderer.lineWidth = 5
                return renderer
            }
            return MKOverlayRenderer()
        }
    }
}
