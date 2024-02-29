import UIKit

class ScreenManager {
    
    private let masterNavigation = UINavigationController()
    private var weatherListScreen: WeatherListScreen?
    private var cityListScreen: CityListScreen?
    private var detailWeatherScreen: DetailWeatherScreen?
    
    func getRootScreen() -> UINavigationController {
        let weatherListVC = WeatherListViewController()
        let weatherListRouter = WeatherListRouter(view: weatherListVC)
        let weatherListPresenter = WeatherListPresenter(view: weatherListVC,
                                                        router: weatherListRouter)
        weatherListScreen = Screen(view: weatherListVC, presenter: weatherListPresenter)
        masterNavigation.viewControllers = [weatherListVC]
       
        return masterNavigation
    }
    
    func getCityListScreen(delegate: CityListPresenterDelegate) -> UIViewController {
        let cityListVC = CityListViewController()
        let cityListPresenter = CityListPresenter(view: cityListVC, delegate: delegate)
        cityListScreen = Screen(view: cityListVC, presenter: cityListPresenter)
        
        return cityListVC
    }
    
    func getDetailWeatherScreen(viewModel: DetailWeatherViewController.Model) -> UIViewController {
        let detailWeatherVC = DetailWeatherViewController()
        detailWeatherVC.config(viewModel: viewModel)
        let detailPrsenter = DetailWeatherPresenter(view: detailWeatherVC)
        detailWeatherScreen = Screen(view: detailWeatherVC, presenter: detailPrsenter)
        
        return detailWeatherVC
    }
    
}

class Screen<View: ViewProtocol, Presenter> {
    let view: View
    let presenter: Presenter
    
    public init(view: View, presenter: Presenter) {
        self.view = view
        self.presenter = presenter
        
        view.retain = presenter
    }
}

protocol ViewProtocol: UIViewController {
    var retain: Any? { get set }
}

typealias WeatherListScreen = Screen<WeatherListViewController, WeatherListPresenter>
typealias CityListScreen = Screen<CityListViewController, CityListPresenter>
typealias DetailWeatherScreen = Screen<DetailWeatherViewController, DetailWeatherPresenter>
