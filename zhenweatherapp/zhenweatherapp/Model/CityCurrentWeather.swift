struct CityCoordinates: Codable {
    let lat: Double
    let lon: Double
}

struct CurrentWeather: Codable {
    let weather: [Weather]
    let main: Main
    let wind: Wind
    let clouds: Clouds
    let timeZone: Int
    let name: String
    
    enum CodingKeys: String, CodingKey {
        case weather, main, wind, clouds, name
        case timeZone = "timezone"
    }
}

struct Weather: Codable {
    let main: String
    let description: String
}

struct Main: Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int
    
    enum CodingKeys: String, CodingKey {
        case temp, pressure, humidity
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
    }
}

struct Wind: Codable {
    let speed: Double
}

struct Clouds: Codable {
    let all: Int
}
