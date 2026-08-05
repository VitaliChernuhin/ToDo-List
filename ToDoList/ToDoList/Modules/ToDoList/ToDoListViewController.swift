import UIKit
import SnapKit

final class ToDoListViewController: UIViewController, ToDoListView, Logable {
    
    var presenter: (any ToDoListPresenter)?
    
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
        tableView.separatorInset = .zero
        return tableView
    }()
    
    private let searchView: ToDoSearchView = {
        ToDoSearchView()
    }()
    
    private let footerView: ToDoFooterView = {
        let footerView = ToDoFooterView()
        footerView.updateTaskCount(0)
        return footerView
    }()
    
    private var dataSource: UITableViewDiffableDataSource<ToDoListSection, ToDoItemViewModel>?
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigation()
        setupUI()
        setupConstraints()
        tableView.delegate = self
        setupDataSource()
        
//        setupTestMocks()
        
        presenter?.handleEvent(.viewDidLoad)
    }
}

// MARK: - ToDoListView (implementation)
extension ToDoListViewController {
    
    func display(_ items: [ToDoItemViewModel]) {
        var snapshot = NSDiffableDataSourceSnapshot<ToDoListSection, ToDoItemViewModel>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items, toSection: .main)
        dataSource?.apply(snapshot, animatingDifferences: true)
        footerView.updateTaskCount(items.count)
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
        view.addSubview(footerView)
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
            make.bottom.equalTo(footerView.snp.top)
        }
        
        footerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(UIDevice.isSmallScreen ? -49 : -74)
        }
    }
    
    private func setupDataSource() {
        dataSource = UITableViewDiffableDataSource<ToDoListSection, ToDoItemViewModel>(tableView: tableView) { [weak self] tableView, indexPath, viewModel in
            guard let self = self else { return UITableViewCell() }
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoListCell", for: indexPath) as? ToDoListCell else {
                return UITableViewCell()
            }
            
            cell.configure(with: viewModel)
            cell.onCheckboxTap = {
                self.presenter?.handleAction(.didTapCheckbox(item: viewModel))
            }
            return cell
        }
    }
}

// MARK: - UITableViewDelegate (implementation)
extension ToDoListViewController: UITableViewDelegate {
    
    func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        
        // Это на 100% страхует от крэшей «Index out of range» при параллельном поиске!
        guard let viewModelItem = dataSource?.itemIdentifier(for: indexPath) else {
            return nil
        }
        
        // Создаем нативное системное действие удаления
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { [weak self] _, _, completionHandler in
            guard let self = self else {
                completionHandler(false)
                return
            }
            
            self.presenter?.handleAction(.didSwipeToDelete(item: viewModelItem))
            completionHandler(true)
        }
        
        deleteAction.backgroundColor = .systemRed
        deleteAction.image = UIImage(systemName: "trash.fill")
        
        // Собираем и возвращаем конфигурацию свайпа
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
    }
}


private extension ToDoListViewController {
    func setupTestMocks() {
        let mockTasks: [ToDoItemViewModel] = [
            ToDoItemViewModel(
                id: 1,
                title: "Купить молоко",
                description: "В магазине у дома, жирность 3.2%, желательно Простоквашино",
                dateString: "28.07.26",
                isCompleted: false
            ),
            ToDoItemViewModel(
                id: 2,
                title: "Позвонить маме",
                description: "Узнать как дела, спросить про выходные и здоровье",
                dateString: "27.07.26",
                isCompleted: true // Проверим зачеркивание и приглушенный цвет!
            ),
            ToDoItemViewModel(
                id: 3,
                title: "Подготовить проект ToDoList",
                description: "Разбить ячейки на extensions, настроить Diffable Data Source и запечатать кастомный футер на SnapKit",
                dateString: "29.07.26",
                isCompleted: false
            ),
            ToDoItemViewModel(
                id: 4,
                title: "ЛФК для спины",
                description: "Сделать комплекс упражнений на 15 минут, чтобы шея не затекала от Xcode",
                dateString: "25.07.26",
                isCompleted: false
            )
        ]
        
        display(mockTasks)
        footerView.updateTaskCount(mockTasks.count)
    }
}
