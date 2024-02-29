class DetailWeatherPresenter {
    
    // MARK: - Properties
    
    weak var view: DetailWeatherView?
    
    private var detailWeatherInteractor: DetailWeatherInteractor?
    private var cityName: String?
    
    
    // MARK: - Init
    
    init(view: DetailWeatherView) {
        self.view = view
        
        self.view?.viewDidLoadView = { [weak self] city in
            self?.cityName = city
            self?.start()
        }
    }
    
    
    // MARK: - Private methods
    
    private func start() {
        setupInteractor()
    }
    
    private func setupInteractor() {
        var interactor = DetailWeatherInteractor()
        interactor.delegate = self
        detailWeatherInteractor = interactor
        interactor.getFiveDayWeather(name: cityName)
    }
    
}


// MARK: - Extension

extension DetailWeatherPresenter: DetailWeatherInteractorDelegate {
    
    // MARK: - DetailWeatherInteractorDelegate
    
    func didFinish(viewModel: [FiveDayInfo]) {
        view?.display(viewModel: viewModel)
    }
    
}
