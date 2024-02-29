import UIKit

class WeatherListRouter {
    
    weak var view: UIViewController?
    
    init(view: UIViewController) {
        self.view = view
    }
    
    func showDetailWeatherScreen(viewModel: DetailWeatherViewController.Model) {
        let detailWeatherScreen = ScreenManager().getDetailWeatherScreen(viewModel: viewModel)
        
        view?.present(detailWeatherScreen, animated: true)
    }
    
    func showCityList(delegate: CityListPresenterDelegate) {
        let cityListScreen = ScreenManager().getCityListScreen(delegate: delegate)
        
        view?.navigationController?.pushViewController(cityListScreen, animated: true)
    }
}
