class WeatherListPresenter {
    
    // MARK: - Properties
    
    weak var view: WeatherListView?

    private var router: WeatherListRouter
    private var weatherListInteractor: WeatherListInteractor?
    
    
    // MARK: - Init
    
    init(view: WeatherListView,
         router: WeatherListRouter) {
        self.view = view
        self.router = router
        
        self.view?.viewDidLoadView = { [weak self] in
            self?.start()
        }
    }
    
    
    // MARK: - Private methods
    
    private func start() {
        setupCallbacks()
        setupInteractor()
    }
    
    private func setupInteractor() {
        let interactor = WeatherListInteractor()
        interactor.delegate = self
        weatherListInteractor = interactor
        interactor.getWeather()
    }
    
    private func setupCallbacks() {
        view?.didAddCity = { [weak self] cityName in
            self?.addCity(name: cityName)
        }
        
        view?.didDeleteCell = { [weak self] cityName in
            self?.removeCity(name: cityName)
        }
        
        view?.didTapPlusButton = { [weak self] in
            guard let view = self?.view else {
                return
            }
            
            self?.router.showCityList(delegate: view)
        }
        
        view?.didTapCity = { [weak self] viewModel in
            self?.router.showDetailWeatherScreen(viewModel: viewModel)
        }
    }
    
    private func addCity(name: String) {
        weatherListInteractor?.addCity(name: name)
    }
    
    private func removeCity(name: String) {
        weatherListInteractor?.removeCity(name: name)
    }
    
}


// MARK: - Extension

extension WeatherListPresenter: WeatherListInteractorDelegate {
    
    // MARK: - WeatherListInteractorDelegate
    
    func didFinish(viewModel: [CurrentWeather]) {
        view?.display(viewModel: viewModel)
    }
    
}
