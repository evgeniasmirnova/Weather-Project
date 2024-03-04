import Foundation

protocol CityListPresenterDelegate: AnyObject {
    func didFinish(name: String)
}

class CityListPresenter {
    
    // MARK: - Properties
    
    weak var view: CityListView?
    private weak var delegate: CityListPresenterDelegate?
    private var cityNames: [CityNames] = []
    private var filteredCityNames: [CityNames] = []
    
    
    // MARK: - Init
    
    init(view: CityListView, delegate: CityListPresenterDelegate) {
        self.view = view
        self.delegate = delegate
        
        self.view?.viewDidLoadView = { [weak self] in
            self?.start()
        }
    }
    
    
    // MARK: - Private methods
    
    private func start() {
        getData()
        setupCallbacks()
    }
    
    private func getData() {
        if let path = Bundle.main.path(forResource: "cities", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(filePath: path))
                let decoder = JSONDecoder()
                let cityData = try decoder.decode(CityInfo.self, from: data)
                cityNames.append(contentsOf: Array(Set(cityData.city)))
                cityNames.sort { $0.name < $1.name }
                filteredCityNames = cityNames
                view?.display(viewModel: cityNames)
            } catch {
                print(error)
            }
        }
    }
    
    private func setupCallbacks() {
        view?.didSearchCity = { [weak self] searchedCity in
            self?.getCity(cityName: searchedCity)
        }
        
        view?.didTapCell = { [weak self] cellIndex in
            self?.getCityName(index: cellIndex)
        }
    }
    
    private func getCity(cityName: String?) {
        guard let cityName else {
            return
        }
        
        if cityName.isEmpty {
            view?.display(viewModel: cityNames)
        } else {
            filteredCityNames = cityNames.filter { city in
                if city.name.lowercased().contains(cityName.lowercased()) {
                    return true
                } else {
                    return false
                }
            }
            view?.display(viewModel: filteredCityNames)
        }
    }
    
    private func getCityName(index: Int) {
        let cityName = filteredCityNames[index].name
        delegate?.didFinish(name: cityName)
    }
    
}
