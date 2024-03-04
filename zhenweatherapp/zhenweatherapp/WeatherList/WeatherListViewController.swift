import UIKit
import SnapKit

protocol WeatherListView: UIViewController, CityListPresenterDelegate {
    var viewDidLoadView: (() -> Void)? { get set }
    var didAddCity: ((String) -> Void)? { get set }
    var didDeleteCell: ((String) -> Void)? { get set }
    var didTapCity: ((DetailWeatherViewController.Model) -> Void)? { get set }
    var didTapPlusButton: (() -> Void)? { get set }
    
    func display(viewModel: [CurrentWeather])
}

class WeatherListViewController: UIViewController, ViewProtocol {
    
    // MARK: - Constants
    
    struct Constants {
        static let titleFontSize: CGFloat = 36
        static let sideOffset: CGFloat = 12
        static let topOffset: CGFloat = 24
        static let tableViewOffset: CGFloat = 140
        static let tableViewCellHeight: CGFloat = 140
        static let addButtonSize: CGSize = CGSize(width: 35, height: 35)
        static let addButtonOffset: CGFloat = 6
    }
    
    
    // MARK: - Callbacks
    
    var retain: Any?
    var viewDidLoadView: (() -> Void)?
    var didAddCity: ((String) -> Void)?
    var didDeleteCell: ((String) -> Void)?
    var didTapCity: ((DetailWeatherViewController.Model) -> Void)?
    var didTapPlusButton: (() -> Void)?
    
    
    // MARK: - Properties
    
    private lazy var titleLabel = UILabel()
    private lazy var addButton = UIButton()
    private lazy var weatherListTableView = UITableView()
    private lazy var addButtonImage = UIImage(named: "addButtonImage")
    private var tableViewIdentifier = "myCell"
    private var currentWeatherArray: [CurrentWeather]?
    

    // MARK: - Override methods
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewDidLoadView?()
        setupViews()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        layoutSubviews()
    }
    
    
    // MARK: - Private methods
    
    private func setupViews() {
        view.backgroundColor = .white
        
        view.addSubview(titleLabel)
        view.addSubview(addButton)
        view.addSubview(weatherListTableView)
        
        let backButton = UIBarButtonItem()
        navigationItem.backBarButtonItem = backButton
        backButton.tintColor = .black
        backButton.title = "Назад"
        
        titleLabel.text = "Погода"
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: Constants.titleFontSize)
        
        addButton.setImage(addButtonImage, for: .normal)
        addButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        
        weatherListTableView.separatorStyle = .none
        weatherListTableView.delegate = self
        weatherListTableView.dataSource = self
        weatherListTableView.register(WeatherListCell.self, forCellReuseIdentifier: tableViewIdentifier)
    }
    
    private func layoutSubviews() {
        titleLabel.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(Constants.sideOffset)
            make.bottom.equalTo(weatherListTableView.snp.top).offset(-Constants.topOffset)
        }
        
        addButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel).offset(Constants.addButtonOffset)
            make.right.equalToSuperview().offset(-Constants.sideOffset)
            make.size.equalTo(Constants.addButtonSize)
        }
        
        weatherListTableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constants.tableViewOffset)
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
        }
    }

    
    // MARK: - ObjC methods
    
    
    @objc
    private func didTapButton() {
        didTapPlusButton?()
    }
    
}


// MARK: - Extension

extension WeatherListViewController: WeatherListView {

    // MARK: - WeatherListView
    
    func display(viewModel: [CurrentWeather]) {
        currentWeatherArray = viewModel
        weatherListTableView.reloadData()
    }
    
}

extension WeatherListViewController: CityListPresenterDelegate {
    
    // MARK: - CityListPresenterDelegate
    
    func didFinish(name: String) {
        didAddCity?(name)
    }
    
}

extension WeatherListViewController: UITableViewDelegate {
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.tableViewCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let currentWeather = currentWeatherArray?[indexPath.row],
              let weatherDescription = currentWeatherArray?[indexPath.row].weather.first else {
            return
        }
        
        weatherListTableView.cellForRow(at: indexPath)?.selectionStyle = .none
        
        let viewModel = DetailWeatherViewController.Model(name: currentWeather.name,
                                                          temperature: currentWeather.main.temp,
                                                          minTemperature: currentWeather.main.tempMin,
                                                          maxTemperature: currentWeather.main.tempMax,
                                                          weather: weatherDescription.main,
                                                          description: weatherDescription.description,
                                                          feelsLike: currentWeather.main.feelsLike,
                                                          pressure: currentWeather.main.pressure,
                                                          humidity: currentWeather.main.humidity,
                                                          windSpeed: currentWeather.wind.speed,
                                                          clouds: currentWeather.clouds.all, 
                                                          timeZoneSeconds: currentWeather.timeZone)
        
        didTapCity?(viewModel)
    }
    
}

extension WeatherListViewController: UITableViewDataSource {
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let currentWeatherArray else {
            return .zero
        }
        
        return currentWeatherArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = weatherListTableView.dequeueReusableCell(withIdentifier: tableViewIdentifier, 
                                                                  for: indexPath) as? WeatherListCell,
              let currentWeather = currentWeatherArray?[indexPath.row],
              let weatherDescription = currentWeatherArray?[indexPath.row].weather.first else {
            return UITableViewCell()
        }
        
        cell.config(viewModel: WeatherListCell.Model(name: currentWeather.name,
                                                     temperature: currentWeather.main.temp,
                                                     weather: weatherDescription.main,
                                                     description: weatherDescription.description,
                                                     timeZoneSeconds: currentWeather.timeZone))
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let cellName = (tableView.cellForRow(at: indexPath) as? WeatherListCell)?.name else {
                return
            }
            
            didDeleteCell?(cellName)
        }
    }
    
}
