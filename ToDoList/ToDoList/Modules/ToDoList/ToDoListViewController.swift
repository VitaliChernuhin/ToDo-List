import UIKit
import SnapKit

final class ToDoListViewController: UIViewController, ToDoListView, Logable {
    
    var presenter: ToDoListPresenter?
    
    // MARK: - UI Elements
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Задачи"
        label.textColor = AppColors.primaryText
        label.font = AppFonts.largeTitle
        return label
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = AppColors.appBackground
        tableView.separatorColor = AppColors.separatorTint
        tableView.register(ToDoListCell.self, forCellReuseIdentifier: ToDoListCell.reuseIdentifier)
        return tableView
    }()
    
    private let searchView: ToDoSearchView = {
        ToDoSearchView()
    }()
    
    private var dataSource: UITableViewDiffableDataSource<ToDoListSection, ToDoItemViewModel>?
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupUI()
        setupConstraints()
        setupDataSource()
        
        //        presenter?.viewDidLoad()
    }
}

// MARK: - Public methods
extension ToDoListViewController {
    func display(_ items: [ToDoItemViewModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<ToDoListSection, ToDoItemViewModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource?.apply(snapshot, animatingDifferences: true)
        log(message: "Отображено элементов на экране: \(items.count)")
    }
}

// MARK: - Private methods
private extension ToDoListViewController {
    
    func setupNavigation() {
        navigationController?.isNavigationBarHidden = true
        navigationController?.navigationBar.tintColor = AppColors.goldTint
        let backButton = UIBarButtonItem()
        backButton.title = "Назад"
        navigationItem.backBarButtonItem = backButton
    }
    
    func setupUI() {
        view.backgroundColor = AppColors.appBackground
        
        view.addSubview(headerLabel)
        view.addSubview(searchView)
        view.addSubview(tableView)
    }
    
    func setupConstraints() {
        headerLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(15)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        searchView.snp.makeConstraints { make in
            make.top.equalTo(headerLabel.snp.bottom).offset(10)
            make.leading.equalTo(headerLabel.snp.leading)
            make.trailing.equalTo(headerLabel.snp.trailing)
            make.height.equalTo(36)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchView.snp.bottom).offset(16)
            make.leading.equalTo(searchView.snp.leading)
            make.trailing.equalTo(searchView.snp.trailing)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<ToDoListSection, ToDoItemViewModel>(tableView: tableView) { (tableView, indexPath, itemViewModel) -> UITableViewCell? in
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ToDoListCell.reuseIdentifier, for: indexPath) as? ToDoListCell else {
                return UITableViewCell()
            }
            
            cell.configure(with: itemViewModel)
            return cell
        }
    }
}
