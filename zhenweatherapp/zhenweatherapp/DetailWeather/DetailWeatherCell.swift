import UIKit
import PinLayout

class DetailWeatherCell: UICollectionViewCell {
    
    // MARK: - Constants
    
    struct Constants {
        static let offset: CGFloat = 12
        static let iconImageViewSize: CGSize = CGSize(width: 35, height: 35)
        static let labelSize: CGSize = CGSize(width: 35, height: 25)
        static let temperatureFontSize: CGFloat = 18
        static let dayOfWeekFontSize: CGFloat = 16
    }
    
    
    // MARK: - Properties
    
    private lazy var temperatureLabel = UILabel()
    private lazy var dayOfWeekLabel = UILabel()
    private lazy var iconImageView = UIImageView()
    private lazy var sunIconImage = UIImage(named: "sunIcon")
    private lazy var cloudIconImage = UIImage(named: "cloudIcon")
    private lazy var rainIconImage = UIImage(named: "rainIcon")
    private lazy var snowIconImage = UIImage(named: "snowIcon")
    private lazy var fogIconImage = UIImage(named: "fogIcon")
    private lazy var stormIconImage = UIImage(named: "stormIcon")
    
    
    // MARK: - Model
    
    struct Model {
        let date: String
        let temperature: Double
        let weatherState: String
    }
    
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
     
        addSubview(temperatureLabel)
        addSubview(dayOfWeekLabel)
        addSubview(iconImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Override methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        temperatureLabel.pin
            .hCenter()
            .bottom(Constants.offset)
            .size(Constants.labelSize)
        
        dayOfWeekLabel.pin
            .hCenter()
            .top(Constants.offset)
            .size(Constants.labelSize)
        
        iconImageView.pin
            .center()
            .size(Constants.iconImageViewSize)
    }
    
    private func getDayOfWeek(date: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = formatter.date(from: date) {
            let myCalendar = Calendar(identifier: .gregorian)
            let weekDay = myCalendar.component(.weekday, from: date)
            
            switch weekDay {
            case 1:
                dayOfWeekLabel.text = "ПН"
            case 2:
                dayOfWeekLabel.text = "ВТ"
            case 3:
                dayOfWeekLabel.text = "СР"
            case 4:
                dayOfWeekLabel.text = "ЧТ"
            case 5:
                dayOfWeekLabel.text = "ПТ"
            case 6:
                dayOfWeekLabel.text = "СБ"
            case 7:
                dayOfWeekLabel.text = "ВС"
            default:
                break
            }
        }
    }
    
    
    // MARK: - Methods
    
    func config(viewModel: DetailWeatherCell.Model) {
        temperatureLabel.text = "\(Int(viewModel.temperature))°"
        temperatureLabel.font = UIFont(name: "HelveticaNeue-Bold", size: Constants.temperatureFontSize)
        temperatureLabel.textAlignment = .center
        
        switch viewModel.weatherState {
        case "Clear":
            iconImageView.image = sunIconImage
        case "Clouds":
            iconImageView.image = cloudIconImage
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
        
        dayOfWeekLabel.font = UIFont(name: "HelveticaNeue-Bold", size: Constants.dayOfWeekFontSize)
        dayOfWeekLabel.textAlignment = .center
        getDayOfWeek(date: viewModel.date)
    }
    
}
