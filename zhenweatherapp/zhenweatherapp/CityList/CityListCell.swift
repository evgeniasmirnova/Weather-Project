import UIKit
import PinLayout

class CityListCell: UITableViewCell {
    
    // MARK: - Constants
    
    struct Constants {
        static let offset: CGFloat = 12
        static let nameLabelFontSize: CGFloat = 20
    }
    
    
    // MARK: - Properties
    
    private lazy var nameLabel = UILabel()
    
    
    // MARK: - Model
    
    struct Model {
        let name: String
    }
    
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(nameLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Override methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        nameLabel.pin
            .left(Constants.offset)
            .vCenter()
            .sizeToFit()
    }
    
    
    // MARK: - Methods
    
    func config(viewModel: CityListCell.Model) {
        nameLabel.text = viewModel.name
        nameLabel.font = UIFont(name: "HelveticaNeue", size: Constants.nameLabelFontSize)
    }
    
}
