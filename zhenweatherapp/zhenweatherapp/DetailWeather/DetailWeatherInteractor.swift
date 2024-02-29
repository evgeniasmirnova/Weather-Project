import Alamofire

protocol DetailWeatherInteractorDelegate: AnyObject {
    func didFinish(viewModel: [FiveDayInfo])
}

class DetailWeatherInteractor {
    
    // MARK: - Properties
    
    weak var delegate: DetailWeatherInteractorDelegate?
    
    private let fiveDayURL = "https://api.openweathermap.org/data/2.5/forecast?appid=144414c043f182ed7d115a5bfc4f40bd&lang=ru&units=metric&q="
    private var fiveDayWeather: [FiveDayInfo] = []
    
    
    // MARK: - Methods
    
    func getFiveDayWeather(name: String?) {
        guard let name else {
            return
        }
        
        let url = fiveDayURL + name
        AF.request(url, parameters: nil, encoding: URLEncoding.default, headers: nil).responseData
        { [weak self] response in
            guard let self else {
                return
            }
            
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let fiveDayData = try decoder.decode(FiveDayWeather.self, from: data)
                    let tmpArray = fiveDayData.list.filter { $0.date.contains("12:00") }
                    self.fiveDayWeather.append(contentsOf: tmpArray)
                    self.delegate?.didFinish(viewModel: fiveDayWeather)
                } catch {
                    print(error)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
}
