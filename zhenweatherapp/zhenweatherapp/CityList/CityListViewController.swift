import UIKit
import SnapKit

protocol CityListView: UIViewController {
    var viewDidLoadView: (() -> Void)? { get set }
    var didSearchCity: ((String) -> Void)? { get set }
    var didTapCell: ((Int) -> Void)? { get set }
    
    func display(viewModel: [CityNames])
}

class CityListViewController: UIViewController, ViewProtocol {
    
    // MARK: - Constants
    
    struct Constants {
        static let tableViewCellHeight: CGFloat = 50
        static let titleLabelFontSize: CGFloat = 36
        static let cityTableViewTopOffset: CGFloat = 200
        static let leftOffset: CGFloat = 12
    }
    
    // MARK: - Callbacks
    
    var retain: Any?
    var viewDidLoadView: (() -> Void)?
    var didSearchCity: ((String) -> Void)?
    var didTapCell: ((Int) -> Void)?
    
    
    // MARK: - Properties
    
    private lazy var titleLabel = UILabel()
    private lazy var citySearchBar = UISearchBar()
    private lazy var cityTableView = UITableView()
    private var cellIdentifier = "myCell"
    private var cityInfo: [CityNames]?
    
    
    // MARK: - Override methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        viewDidLoadView?()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        layoutSubviews()
    }
    
    
    // MARK: - Private methods
    
    private func setupViews() {
        view.backgroundColor = .white
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        view.addSubview(titleLabel)
        view.addSubview(citySearchBar)
        view.addSubview(cityTableView)
        
        titleLabel.text = "Поиск"
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: Constants.titleLabelFontSize)
        
        citySearchBar.placeholder = "Введите название города..."
        citySearchBar.showsSearchResultsButton = true
        citySearchBar.searchBarStyle = .minimal
        citySearchBar.delegate = self
        
        cityTableView.delegate = self
        cityTableView.dataSource = self
        cityTableView.register(CityListCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    private func layoutSubviews() {
        titleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(citySearchBar.snp.top)
            make.left.equalToSuperview().offset(Constants.leftOffset)
        }
        
        citySearchBar.snp.makeConstraints { make in
            make.bottom.equalTo(cityTableView.snp.top)
            make.left.right.equalToSuperview()
        }
        
        cityTableView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(Constants.cityTableViewTopOffset)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
}


// MARK: - Extension

extension CityListViewController: CityListView {
    
    // MARK: - CityListView
 
    func display(viewModel: [CityNames]) {
        cityInfo = viewModel
        cityTableView.reloadData()
    }
    
}

extension CityListViewController: UITableViewDelegate {
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.tableViewCellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        cityTableView.cellForRow(at: indexPath)?.selectionStyle = .none
        didTapCell?(indexPath.row)
        navigationController?.popViewController(animated: true)
    }
    
}

extension CityListViewController: UITableViewDataSource {
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let cityInfo else {
            return .zero
        }
        
        return cityInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = cityTableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CityListCell,
              let cityInfo = cityInfo?[indexPath.row] else {
            return UITableViewCell()
        }
        
        cell.config(viewModel: CityListCell.Model(name: cityInfo.name))
        return cell
    }
    
}

extension CityListViewController: UISearchBarDelegate {
    
    // MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        didSearchCity?(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        citySearchBar.endEditing(true)
    }
    
}
