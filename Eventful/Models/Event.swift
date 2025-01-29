import Foundation
import CoreLocation

struct Event: Identifiable {
    let id = UUID()
    var title: String
    var startDate: Date
    var endDate: Date
    var notes: String
    var location: String 
}
