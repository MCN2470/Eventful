import SwiftUI
import MapKit

struct AppleMapsAutocompleteView: View {
    @State private var searchText = ""
    @State private var suggestions: [MKMapItem] = []
    var onLocationSelected: (String) -> Void

    var body: some View {
        NavigationView {
            VStack {
                TextField("Search Location", text: $searchText, onEditingChanged: { isEditing in
                    if isEditing {
                        fetchSuggestions(for: searchText)
                    }
                }, onCommit: {
                    fetchSuggestions(for: searchText)
                })
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding()

                List(suggestions, id: \.self) { mapItem in
                    Button(action: {
                        let locationName = mapItem.name ?? "Unknown Location"
                        onLocationSelected(locationName)
                    }) {
                        VStack(alignment: .leading) {
                            Text(mapItem.name ?? "Unknown")
                                .font(.headline)
                            if let subtitle = mapItem.placemark.title {
                                Text(subtitle)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Search Location")
        }
        .onChange(of: searchText) { newValue in
            fetchSuggestions(for: newValue)
        }
    }

   
    private func fetchSuggestions(for query: String) {
        guard !query.isEmpty else {
            suggestions = []
            return
        }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let error = error {
                print("Error fetching suggestions: \(error.localizedDescription)")
                return
            }

            if let response = response {
                suggestions = response.mapItems
            }
        }
    }
}
