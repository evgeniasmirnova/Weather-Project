struct FiveDayWeather: Codable {
    let list: [FiveDayInfo]
}

struct FiveDayInfo: Codable {
    let mainInfo: MainInfoStruct
    let weather: [WeatherStruct]
    let date: String
    
    enum CodingKeys: String, CodingKey {
        case mainInfo = "main"
        case weather = "weather"
        case date = "dt_txt"
    }
}

struct MainInfoStruct: Codable {
    let temp: Double
}

struct WeatherStruct: Codable {
    let weatherState: WeatherEnum
    
    enum CodingKeys: String, CodingKey {
        case weatherState = "main"
    }
}

enum WeatherEnum: String, Codable {
        case clouds = "Clouds"
        case snow = "Snow"
        case rain = "Rain"
        case clear = "Clear"
        case fog = "Fog"
        case storm = "Storm"
}
