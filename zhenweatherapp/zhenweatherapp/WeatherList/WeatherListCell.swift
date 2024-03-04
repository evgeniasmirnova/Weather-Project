import UIKit
import PinLayout

class WeatherListCell: UITableViewCell {
    
    // MARK: - Constants
    
    struct Constants {
        static let beigeColor = UIColor(red: 0.93, green: 0.93, blue: 0.93, alpha: 1.00)
        static let margin: CGFloat = 6
        static let cornerRadius: CGFloat = 25
        static let topBottomOffset: CGFloat = 24
        static let leftRightOffset: CGFloat = 18
        static let iconOffset: CGFloat = 18
        static let cityNameLabelFontSize: CGFloat = 24
        static let descriptionLabelFontSize: CGFloat = 18
        static let temperatureLabelFontSize: CGFloat = 36
        static let timeLabelFontSize: CGFloat = 14
        static let cityNameLabelSize: CGSize = CGSize(width: 200, height: 30)
        static let temperatureLabelSize: CGSize = CGSize(width: 70, height: 40)
        static let iconImageViewSize: CGSize = CGSize(width: 50, height: 50)
        static let timeLabelSize: CGSize = CGSize(width: 45, height: 17)
    }
    
    
    // MARK: - Storage
    
    var name: String?
    
    private var timeZone: TimeZone?
    private var timer: Timer?
    
    
    // MARK: - Properties
    
    private lazy var backView = UIView()
    private lazy var cityNameLabel = UILabel()
    private lazy var descriptionLabel = UILabel()
    private lazy var temperatureLabel = UILabel()
    private lazy var iconImageView = UIImageView()
    private lazy var timeLabel = UILabel()
    private lazy var sunIconImage = UIImage(named: "currentSun")
    private lazy var cloudsIconImage = UIImage(named: "currentClouds")
    private lazy var rainIconImage = UIImage(named: "currentRain")
    private lazy var snowIconImage = UIImage(named: "currentSnow")
    private lazy var stormIconImage = UIImage(named: "currentStorm")
    private lazy var fogIconImage = UIImage(named: "currentFog")
    
    
    // MARK: - Model
    
    struct Model {
        let name: String
        let temperature: Double
        let weather: String
        let description: String
        let timeZoneSeconds: Int
    }
    
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(backView)
        addSubview(cityNameLabel)
        addSubview(descriptionLabel)
        addSubview(temperatureLabel)
        addSubview(iconImageView)
        addSubview(timeLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Override methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        backView.pin
            .all(Constants.margin)
        
        cityNameLabel.pin
            .top(Constants.topBottomOffset)
            .left(Constants.leftRightOffset)
            .size(Constants.cityNameLabelSize)
        
        descriptionLabel.pin
            .left(Constants.leftRightOffset)
            .bottom(Constants.topBottomOffset)
            .sizeToFit()
        
        temperatureLabel.pin
            .right(Constants.leftRightOffset)
            .bottom(Constants.topBottomOffset)
            .size(Constants.temperatureLabelSize)
        
        iconImageView.pin
            .right(Constants.iconOffset)
            .top(Constants.iconOffset)
            .size(Constants.iconImageViewSize)
        
        timeLabel.pin
            .below(of: cityNameLabel)
            .left(Constants.leftRightOffset)
            .size(Constants.timeLabelSize)
    }
    
    
    // MARK: - Methods
    
    private func updateTimeLabel(with timeZone: TimeZone) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.timeZone = timeZone

        let formattedDate = dateFormatter.string(from: Date())
        timeLabel.text = formattedDate
    }
    
    @objc
    private func didTimerUpdated() {
        guard let timeZone else {
            return
        }
        
        updateTimeLabel(with: timeZone)
    }
    
    func config(viewModel: Model) {
        backView.backgroundColor = Constants.beigeColor
        backView.layer.cornerRadius = Constants.cornerRadius
        
        name = viewModel.name
        cityNameLabel.text = name
        cityNameLabel.font = UIFont(name: "HelveticaNeue-Medium", size: Constants.cityNameLabelFontSize)
        
        descriptionLabel.text = viewModel.description.capitalizedSentence
        descriptionLabel.font = UIFont(name: "HelveticaNeue-Italic", size: Constants.descriptionLabelFontSize)
        
        temperatureLabel.text = "\(Int(viewModel.temperature))°"
        temperatureLabel.textAlignment = .right
        temperatureLabel.font = UIFont(name: "HelveticaNeue-Bold", size: Constants.temperatureLabelFontSize)
        
        switch viewModel.weather {
        case "Clear":
            iconImageView.image = sunIconImage
        case "Clouds":
            iconImageView.image = cloudsIconImage
        case "Rain":
            iconImageView.image = rainIconImage
        case "Snow":
            iconImageView.image = snowIconImage
        case "Fog":
            iconImageView.image = fogIconImage
        case "Storm":
            iconImageView.image = stormIconImage
        default:
            iconImageView.image = UIImage()
        }
        
        timeLabel.font = .boldSystemFont(ofSize: Constants.timeLabelFontSize)
        
        timeZone = TimeZone(secondsFromGMT: viewModel.timeZoneSeconds)
        
        if let timeZone {
            updateTimeLabel(with: timeZone)
        }
        
        timer = Timer.scheduledTimer(timeInterval: 1,
                                     target: self,
                                     selector: #selector(didTimerUpdated),
                                     userInfo: nil,
                                     repeats: true)
    }
    
}
