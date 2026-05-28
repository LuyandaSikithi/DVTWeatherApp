import CoreData
import Foundation

@objc(CDFavouriteLocation)
public class CDFavouriteLocation: NSManagedObject {}

extension CDFavouriteLocation {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDFavouriteLocation> {
        NSFetchRequest<CDFavouriteLocation>(entityName: "CDFavouriteLocation")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name: String?
}
