import Alamofire

protocol WeatherListInteractorDelegate: AnyObject {
    func didFinish(viewModel: [CurrentWeather])
}

class WeatherListInteractor {
    
    // MARK: - Constants
    
    struct Constants {
        static let userDefaultsKey = "citiesArray"
    }
    
    // MARK: - Properties
    
    weak var delegate: WeatherListInteractorDelegate?
    
    private lazy var coordsURL = "https://api.openweathermap.org/geo/1.0/direct?appid=144414c043f182ed7d115a5bfc4f40bd&limit=1&q="
    private lazy var currentWeatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=144414c043f182ed7d115a5bfc4f40bd&units=metric&lang=ru&"
    private lazy var startCities: [String] = ["Ярославль", "Москва", "Киото", "Канны"]
    private var currentWeatherArray: [CurrentWeather] = []
    
    private let dispatchGroup = DispatchGroup()
    private let userDefaults = UserDefaults.standard
    
    
    // MARK: - Methods
    
    func getWeather() {
        currentWeatherArray = []
        getCityNames()
        
        for city in startCities {
            dispatchGroup.enter()
            let url = coordsURL + city
            AF.request(url, parameters: nil, encoding: URLEncoding.default, headers: nil).responseData
            { [weak self] response in
                guard let self else {
                    return
                }
                
                switch response.result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let cityCoords = try decoder.decode([CityCoordinates].self, from: data)
                        self.getWeatherData(coords: cityCoords)
                    } catch {
                        print(error)
                    }
                case.failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) { [weak self] in
            guard let self else {
                return
            }
            
            let sortedWeatherArray = currentWeatherArray.sorted { $0.name < $1.name }
            DispatchQueue.main.async {
                self.delegate?.didFinish(viewModel: sortedWeatherArray)
            }
        }
    }
    
    func addCity(name: String) {
        startCities.append(name)
        userDefaults.set(startCities, forKey: Constants.userDefaultsKey)
        
        getWeather()
    }
    
    func removeCity(name: String) {
        guard let index = startCities.firstIndex(of: name) else {
            return
        }
        
        startCities.remove(at: index)
        userDefaults.setValue(startCities, forKey: Constants.userDefaultsKey)
        
        getWeather()
    }
    
    
    // MARK: - Private methods
    
    private func getWeatherData(coords: [CityCoordinates]) {
        guard let lat = coords.first?.lat,
              let lon = coords.first?.lon else {
            return
        }
        
        let url = currentWeatherURL + "lat=\(lat)" + "&lon=\(lon)"
        AF.request(url, parameters: nil, encoding: URLEncoding.default, headers: nil).responseData
        { [weak self] response in
            guard let self else {
                return
            }
            
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let currentWeather = try decoder.decode(CurrentWeather.self, from: data)
                    self.currentWeatherArray.append(currentWeather)
                } catch {
                    print(error)
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
            
            self.dispatchGroup.leave()
        }
    }
    
    private func getCityNames() {
        if let cityArray = userDefaults.stringArray(forKey: Constants.userDefaultsKey) {
            startCities = cityArray
        } else {
            userDefaults.setValue(startCities, forKey: Constants.userDefaultsKey)
        }
        
    }
    
}
