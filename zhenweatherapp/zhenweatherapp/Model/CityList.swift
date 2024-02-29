struct CityInfo: Codable, Hashable {
    let city: [CityNames]
}

struct CityNames: Codable, Hashable {
    let name: String
}
