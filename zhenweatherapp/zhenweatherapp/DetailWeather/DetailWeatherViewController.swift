import UIKit
import SnapKit

protocol DetailWeatherView: UIViewController {
    var viewDidLoadView: ((String) -> Void)? { get set }
    
    func display(viewModel: [FiveDayInfo])
}

class DetailWeatherViewController: UIViewController, ViewProtocol {
    
    // MARK: - Constants
    
    struct Constants {
        static let beigeColor = UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1.00)
        static let cornerRadius: CGFloat = 25
        static let alphaComponent: CGFloat = 0.4
        static let standardOffset: CGFloat = 12
        static let largeOffset: CGFloat = 24
        static let nameLabelFontSize: CGFloat = 18
        static let timeLabelFontSize: CGFloat = 16
        static let temperatureLabelSize: CGSize = CGSize(width: 200, height: 80)
        static let temperatureLabelFontSize: CGFloat = 80
        static let temperatureLabelTopOffset: CGFloat = 420
        static let maxMintemperatureLabelFontSize: CGFloat = 20
        static let borderlineViewHeight: CGFloat = 5
        static let borderlineCornerRadius: CGFloat = 3
        static let descriptionLabelFontSize: CGFloat = 22
        static let collectionViewItemSize: CGSize = CGSize(width: 100, height: 120)
        static let collectionViewHeight: CGFloat = 120
        static let headerFontSize: CGFloat = 16
        static let infoFontSize: CGFloat = 42
        static let windInfoFontSize: CGFloat = 36
    }
    
    // MARK: - Callbacks
    
    var retain: Any?
    var viewDidLoadView: ((String) -> Void)?
    
    
    // MARK: - Properties
    
    private lazy var containerScrollView = UIScrollView()
    private lazy var containerView = UIView()
    private lazy var nameLabel = UILabel()
    private lazy var timeLabel = UILabel()
    private lazy var temperatureLabel = UILabel()
    private lazy var minTemperatureLabel = UILabel()
    private lazy var maxTemperatureLabel = UILabel()
    private lazy var borderlineView = UIView()
    private lazy var descriptionLabel = UILabel()
    private lazy var fiveDayCollectionView = UICollectionView(frame: .zero,
                                                              collectionViewLayout: collectionViewFlowLayout)
    private lazy var collectionViewFlowLayout = UICollectionViewFlowLayout()
    private lazy var feelsLikeView = UIView()
    private lazy var feelsLikeHeader = UILabel()
    private lazy var feelsLikeInfo = UILabel()
    private lazy var windSpeedView = UIView()
    private lazy var windSpeedHeader = UILabel()
    private lazy var windSpeedInfo = UILabel()
    private lazy var humidityView = UIView()
    private lazy var humidityHeader = UILabel()
    private lazy var humidityInfo = UILabel()
    private lazy var cloudsView = UIView()
    private lazy var cloudsHeader = UILabel()
    private lazy var cloudsInfo = UILabel()
    private lazy var backgroundImageView = UIImageView(image: sunBackgroundImage)
    private lazy var sunBackgroundImage = UIImage(named: "sunBackground")
    private lazy var cloudsBackgroundImage = UIImage(named: "cloudsBackground")
    private lazy var rainBackgroundImage = UIImage(named: "rainBackground")
    private lazy var snowBackgroundImage = UIImage(named: "snowBackground")
    private lazy var fogBackgroundImage = UIImage(named: "fogBackground")
    
    private var cellIdentifier = "myCell"
    private var cityName: String?
    private var timeZone: TimeZone?
    private var fiveDayWeather: [FiveDayInfo]?
    private var timer: Timer?
    
    
    // MARK: - Model
    
    struct Model {
        let name: String
        let temperature: Double
        let minTemperature: Double
        let maxTemperature: Double
        let weather: String
        let description: String
        let feelsLike: Double
        let pressure: Int
        let humidity: Int
        let windSpeed: Double
        let clouds: Int
        let timeZoneSeconds: Int
    }
    
    
    // MARK: - Override methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let cityName else {
            return
        }
        
        setupViews()
        viewDidLoadView?(cityName)
        
        timer = Timer.scheduledTimer(timeInterval: 0.1,
                                     target: self,
                                     selector: #selector(didTimerUpdated),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        timer?.invalidate()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        layoutSubviews()
    }
    
    
    // MARK: - Private methods
    
    private func setupViews() {
        view.addSubview(backgroundImageView)
        view.addSubview(containerScrollView)
        containerScrollView.addSubview(containerView)
        containerView.addSubview(nameLabel)
        containerView.addSubview(timeLabel)
        containerView.addSubview(temperatureLabel)
        containerView.addSubview(minTemperatureLabel)
        containerView.addSubview(maxTemperatureLabel)
        containerView.addSubview(borderlineView)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(fiveDayCollectionView)
        containerView.addSubview(feelsLikeView)
        feelsLikeView.addSubview(feelsLikeHeader)
        feelsLikeView.addSubview(feelsLikeInfo)
        containerView.addSubview(windSpeedView)
        windSpeedView.addSubview(windSpeedHeader)
        windSpeedView.addSubview(windSpeedInfo)
        containerView.addSubview(humidityView)
        humidityView.addSubview(humidityHeader)
        humidityView.addSubview(humidityInfo)
        containerView.addSubview(cloudsView)
        cloudsView.addSubview(cloudsHeader)
        cloudsView.addSubview(cloudsInfo)
        
        view.backgroundColor = .white
        
        containerScrollView.delegate = self
        containerScrollView.contentSize = CGSize(width: view.frame.width, height: view.frame.height + 250)
        containerScrollView.isScrollEnabled = true
        containerScrollView.showsVerticalScrollIndicator = false
        containerScrollView.backgroundColor = .clear
        
        containerView.backgroundColor = .clear
        
        nameLabel.font = UIFont(name: "HelveticaNeue-Bold", size: Constants.nameLabelFontSize)
        
        timeLabel.font = UIFont(name: "HelveticaNeue-Medium", size: Constants.timeLabelFontSize)
        
        temperatureLabel.font = UIFont(name: "HelveticaNeue-Bold", size: Constants.temperatureLabelFontSize)
        
        minTemperatureLabel.textAlignment = .right
        minTemperatureLabel.font = UIFont(name: "HelveticaNeue-Medium",
                                          size: Constants.maxMintemperatureLabelFontSize)
        
        maxTemperatureLabel.textAlignment = .right
        maxTemperatureLabel.font = UIFont(name: "HelveticaNeue-Medium",
                                          size: Constants.maxMintemperatureLabelFontSize)
        
        borderlineView.backgroundColor = .black
        borderlineView.layer.cornerRadius = Constants.borderlineCornerRadius
        
        descriptionLabel.font = UIFont(name: "HelveticaNeue-Italic", size: Constants.descriptionLabelFontSize)
        
        fiveDayCollectionView.delegate = self
        fiveDayCollectionView.dataSource = self
        fiveDayCollectionView.register(DetailWeatherCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionViewFlowLayout.scrollDirection = .horizontal
        fiveDayCollectionView.showsHorizontalScrollIndicator = false
        fiveDayCollectionView.backgroundColor = UIColor.white.withAlphaComponent(Constants.alphaComponent)
        fiveDayCollectionView.layer.cornerRadius = Constants.cornerRadius
        
        feelsLikeView.backgroundColor = UIColor.white.withAlphaComponent(Constants.alphaComponent)
        feelsLikeView.layer.cornerRadius = Constants.cornerRadius
        
        feelsLikeHeader.text = "Ощущается как"
        feelsLikeHeader.font = UIFont(name: "HelveticaNeue-Medium", size: Constants.headerFontSize)
        feelsLikeHeader.textColor = .darkGray
        feelsLikeHeader.textAlignment = .center
        
        feelsLikeInfo.font = UIFont(name: "HelveticaNeue-Bold", size: Constants.infoFontSize)
        feelsLikeInfo.textAlignment = .center
        
        windSpeedView.backgroundColor = UIColor.white.withAlphaComponent(Constants.alphaComponent)
        windSpeedView.layer.cornerRadius = Constants.cornerRadius
        
        windSpeedHeader.text = "Скорость ветра"
        windSpeedHeader.font = UIFont(name: "HelveticaNeue-Medium", size: Constants.headerFontSize)
        windSpeedHeader.textColor = .darkGray
        windSpeedHeader.textAlignment = .center
        
        windSpeedInfo.font = UIFont(name: "HelveticaNeue-Bold", size: Constants.windInfoFontSize)
        windSpeedInfo.textAlignment = .center
        
        humidityView.backgroundColor = UIColor.white.withAlphaComponent(Constants.alphaComponent)
        humidityView.layer.cornerRadius = Constants.cornerRadius
        
        humidityHeader.text = "Влажность"
        humidityHeader.font = UIFont(name: "HelveticaNeue-Medium", size: Constants.headerFontSize)
        humidityHeader.textColor = .darkGray
        humidityHeader.textAlignment = .center
        
        humidityInfo.font = UIFont(name: "HelveticaNeue-Bold", size: Constants.infoFontSize)
        humidityInfo.textAlignment = .center
        
        cloudsView.backgroundColor = UIColor.white.withAlphaComponent(Constants.alphaComponent)
        cloudsView.layer.cornerRadius = Constants.cornerRadius
        
        cloudsHeader.text = "Облачность"
        cloudsHeader.font = UIFont(name: "HelveticaNeue-Medium", size: Constants.headerFontSize)
        cloudsHeader.textColor = .darkGray
        cloudsHeader.textAlignment = .center
        
        cloudsInfo.font = UIFont(name: "HelveticaNeue-Bold", size: Constants.infoFontSize)
        cloudsInfo.textAlignment = .center
    }
    
    private func layoutSubviews() {
        backgroundImageView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        containerScrollView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
        
        containerView.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(containerScrollView.contentSize.height)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.left.equalToSuperview().offset(Constants.standardOffset)
        }
        
        timeLabel.snp.makeConstraints { make in
            make.left.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom)
        }
        
        temperatureLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constants.temperatureLabelTopOffset)
            make.left.equalToSuperview().offset(Constants.largeOffset)
            make.size.equalTo(Constants.temperatureLabelSize)
        }
        
        maxTemperatureLabel.snp.makeConstraints { make in
            make.top.equalTo(temperatureLabel.snp.top)
            make.right.equalToSuperview().offset(-Constants.largeOffset)
        }
        
        minTemperatureLabel.snp.makeConstraints { make in
            make.bottom.equalTo(temperatureLabel.snp.bottom)
            make.right.equalToSuperview().offset(-Constants.largeOffset)
        }
        
        borderlineView.snp.makeConstraints { make in
            make.top.equalTo(temperatureLabel.snp.bottom).offset(Constants.largeOffset)
            make.left.equalToSuperview().offset(Constants.standardOffset)
            make.right.equalToSuperview().offset(-Constants.standardOffset)
            make.height.equalTo(Constants.borderlineViewHeight)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(borderlineView.snp.bottom).offset(Constants.largeOffset)
            make.left.equalTo(borderlineView)
        }
        
        fiveDayCollectionView.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(Constants.largeOffset)
            make.left.right.equalTo(borderlineView)
            make.height.equalTo(Constants.collectionViewHeight)
        }
        
        feelsLikeView.snp.makeConstraints { make in
            make.top.equalTo(fiveDayCollectionView.snp.bottom).offset(Constants.largeOffset)
            make.left.equalTo(fiveDayCollectionView)
            make.height.width.equalTo(view.frame.width / 2 - Constants.largeOffset)
        }
        
        feelsLikeHeader.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constants.largeOffset)
            make.centerX.equalToSuperview()
        }
        
        feelsLikeInfo.snp.makeConstraints { make in
            make.top.equalTo(feelsLikeView.snp.centerY)
            make.centerX.equalToSuperview()
        }
        
        windSpeedView.snp.makeConstraints { make in
            make.top.equalTo(feelsLikeView)
            make.right.equalTo(fiveDayCollectionView)
            make.height.width.equalTo(feelsLikeView)
        }
        
        windSpeedHeader.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constants.largeOffset)
            make.centerX.equalToSuperview()
        }
        
        windSpeedInfo.snp.makeConstraints { make in
            make.top.equalTo(windSpeedView.snp.centerY)
            make.centerX.equalToSuperview()
        }
        
        humidityView.snp.makeConstraints { make in
            make.top.equalTo(feelsLikeView.snp.bottom).offset(Constants.largeOffset)
            make.left.equalTo(feelsLikeView)
            make.height.width.equalTo(feelsLikeView)
        }
        
        humidityHeader.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constants.largeOffset)
            make.centerX.equalToSuperview()
        }
        
        humidityInfo.snp.makeConstraints { make in
            make.top.equalTo(humidityView.snp.centerY)
            make.centerX.equalToSuperview()
        }
        
        cloudsView.snp.makeConstraints { make in
            make.top.equalTo(humidityView)
            make.right.equalTo(windSpeedView)
            make.height.width.equalTo(feelsLikeView)
        }
        
        cloudsHeader.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constants.largeOffset)
            make.centerX.equalToSuperview()
        }
        
        cloudsInfo.snp.makeConstraints { make in
            make.top.equalTo(cloudsView.snp.centerY)
            make.centerX.equalToSuperview()
        }
    }
    
    
    // MARK: - Methods
    
    func config(viewModel: DetailWeatherViewController.Model) {
        cityName = viewModel.name
        nameLabel.text = cityName
        temperatureLabel.text = "\(Int(viewModel.temperature))°"
        minTemperatureLabel.text = "↓ \(Int(viewModel.minTemperature))°"
        maxTemperatureLabel.text = "↑ \(Int(viewModel.maxTemperature))°"
        descriptionLabel.text = viewModel.description.capitalizedSentence
        feelsLikeInfo.text = "\(Int(viewModel.feelsLike))°"
        windSpeedInfo.text = "\(viewModel.windSpeed) м/с"
        humidityInfo.text = "\(viewModel.humidity)%"
        cloudsInfo.text = "\(viewModel.clouds)%"
        
        switch viewModel.weather {
        case "Clear":
            backgroundImageView.image = sunBackgroundImage
        case "Clouds":
            backgroundImageView.image = cloudsBackgroundImage
        case "Rain":
            backgroundImageView.image = rainBackgroundImage
        case "Snow":
            backgroundImageView.image = snowBackgroundImage
        case "Fog":
            backgroundImageView.image = fogBackgroundImage
        default:
            backgroundImageView.image = UIImage()
        }
        
        timeZone = TimeZone(secondsFromGMT: viewModel.timeZoneSeconds)
    }
    
    @objc
    private func didTimerUpdated() {
        guard let timeZone else {
            return
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = timeZone

        let formattedDate = dateFormatter.string(from: Date())
        timeLabel.text = formattedDate
    }
    
}


// MARK: - Extensions

extension DetailWeatherViewController: DetailWeatherView {
    
    // MARK: - DetailWeatherView
    
    func display(viewModel: [FiveDayInfo]) {
        fiveDayWeather = viewModel
        fiveDayCollectionView.reloadData()
    }
}

extension DetailWeatherViewController: UICollectionViewDataSource {
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let fiveDayWeather else {
            return .zero
        }
        
        return fiveDayWeather.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = fiveDayCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, 
                                                                   for: indexPath) as? DetailWeatherCell,
              let fiveDayWeather = fiveDayWeather?[indexPath.row],
              let weatherState = fiveDayWeather.weather.first else {
            return UICollectionViewCell()
        }
        
        cell.config(viewModel: DetailWeatherCell.Model(date: fiveDayWeather.date,
                                                       temperature: fiveDayWeather.mainInfo.temp,
                                                       weatherState: weatherState.weatherState.rawValue))
        return cell
    }
    
}

extension DetailWeatherViewController: UICollectionViewDelegateFlowLayout {
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return Constants.collectionViewItemSize
    }
    
}

extension DetailWeatherViewController: UIScrollViewDelegate {
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = containerScrollView.contentOffset.y
        nameLabel.frame.origin.y = yOffset + Constants.standardOffset
        timeLabel.frame.origin.y = nameLabel.frame.origin.y + nameLabel.frame.height
    }
    
}
