import CoreData
import Foundation

class CCPersistenceController {
    static let shared = CCPersistenceController()

    let m_container: NSPersistentContainer

    var m_viewContext: NSManagedObjectContext {
        m_container.viewContext
    }

    init(inMemory: Bool = false) {
        m_container = NSPersistentContainer(name: "DVTWeather")
        if inMemory {
            m_container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        m_container.loadPersistentStores { _, error in
            if let error {
                fatalError("CoreData failed to load: \(error.localizedDescription)")
            }
        }
        m_container.viewContext.automaticallyMergesChangesFromParent = true
    }

    func saveWeatherCache(_ weather: CCCurrentWeather) {
        let m_context = m_viewContext
        let m_request = CDWeatherCache.fetchRequest()
        let m_existing = (try? m_context.fetch(m_request)) ?? []
        m_existing.forEach { m_context.delete($0) }

        let m_cache = CDWeatherCache(context: m_context)
        m_cache.cityName = weather.m_city
        m_cache.temperature = weather.m_temp
        m_cache.feelsLike = weather.m_feelsLike
        m_cache.minTemp = weather.m_tempMin
        m_cache.maxTemp = weather.m_tempMax
        m_cache.humidity = Int32(weather.m_humidity)
        m_cache.condition = weather.m_condition.rawValue
        m_cache.conditionDescription = weather.m_conditionDescription
        m_cache.weatherIcon = weather.m_weatherIcon
        m_cache.windSpeed = weather.m_windSpeed
        m_cache.latitude = weather.m_latitude
        m_cache.longitude = weather.m_longitude
        m_cache.timestamp = Date()
        try? m_context.save()
    }

    func fetchCachedWeather() -> CCCurrentWeather? {
        let m_request = CDWeatherCache.fetchRequest()
        guard let m_cache = (try? m_viewContext.fetch(m_request))?.first else { return nil }
        let m_condition = CCWeatherCondition(rawValue: m_cache.condition ?? "") ?? .clear
        return CCCurrentWeather(
            m_temp: m_cache.temperature,
            m_feelsLike: m_cache.feelsLike,
            m_tempMin: m_cache.minTemp,
            m_tempMax: m_cache.maxTemp,
            m_humidity: Int(m_cache.humidity),
            m_condition: m_condition,
            m_conditionDescription: m_cache.conditionDescription ?? "",
            m_weatherIcon: m_cache.weatherIcon ?? "",
            m_city: m_cache.cityName ?? "",
            m_windSpeed: m_cache.windSpeed,
            m_latitude: m_cache.latitude,
            m_longitude: m_cache.longitude,
            m_cachedAt: m_cache.timestamp
        )
    }

    func saveFavourite(_ location: CCFavouriteLocation) {
        let m_context = m_viewContext
        let m_request = CDFavouriteLocation.fetchRequest()
        m_request.predicate = NSPredicate(format: "id == %@", location.m_id as CVarArg)
        guard (try? m_context.fetch(m_request))?.first == nil else { return }

        let m_entity = CDFavouriteLocation(context: m_context)
        m_entity.id = location.m_id
        m_entity.name = location.m_name
        m_entity.latitude = location.m_lat
        m_entity.longitude = location.m_lon
        try? m_context.save()
    }

    func fetchFavourites() -> [CCFavouriteLocation] {
        let m_request = CDFavouriteLocation.fetchRequest()
        let m_results = (try? m_viewContext.fetch(m_request)) ?? []
        return m_results.compactMap { entity in
            guard let m_id = entity.id, let m_name = entity.name else { return nil }
            return CCFavouriteLocation(m_id: m_id, m_name: m_name, m_lat: entity.latitude, m_lon: entity.longitude)
        }
    }

    func deleteFavourite(_ location: CCFavouriteLocation) {
        let m_context = m_viewContext
        let m_request = CDFavouriteLocation.fetchRequest()
        m_request.predicate = NSPredicate(format: "id == %@", location.m_id as CVarArg)
        guard let m_entity = (try? m_context.fetch(m_request))?.first else { return }
        m_context.delete(m_entity)
        try? m_context.save()
    }
}
