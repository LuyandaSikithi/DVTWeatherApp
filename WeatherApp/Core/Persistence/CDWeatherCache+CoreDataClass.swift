import CoreData
import Foundation

@objc(CDWeatherCache)
public class CDWeatherCache: NSManagedObject {}

extension CDWeatherCache {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDWeatherCache> {
        NSFetchRequest<CDWeatherCache>(entityName: "CDWeatherCache")
    }

    @NSManaged public var cityName: String?
    @NSManaged public var condition: String?
    @NSManaged public var conditionDescription: String?
    @NSManaged public var feelsLike: Double
    @NSManaged public var humidity: Int32
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var maxTemp: Double
    @NSManaged public var minTemp: Double
    @NSManaged public var temperature: Double
    @NSManaged public var timestamp: Date?
    @NSManaged public var weatherIcon: String?
    @NSManaged public var windSpeed: Double
}
