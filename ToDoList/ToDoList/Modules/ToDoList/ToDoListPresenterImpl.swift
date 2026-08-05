import Foundation

final class ToDoListPresenterImpl: ToDoListPresenter, Logable {
    weak var view: ToDoListView?
    var interactor: ToDoListInteractor?
    var router: ToDoListRouter?
}

// MARK: - ViewEvenHandable (implementation))
extension ToDoListPresenterImpl {
       func handleEvent(_ event: ViewEvent) {
           switch event {
           case .viewDidLoad:
               interactor?.fetchTasks()
           }
       }
}

// MARK: - ViewActionHandable (implementation)
extension ToDoListPresenterImpl: ViewActionHandable {
    typealias Action = ToDoListAction
    
    func handleAction(_ action: ToDoListAction) {
        switch action {
        case .didTapCheckbox(item: let viewModelItem):
            interactor?.toggleTaskCompletion(id: viewModelItem.id)
            
        case .didUpdateSearchQuery(let query):
            interactor?.searchTasks(query: query)
            
        case .didSwipeToDelete(item: let viewModelItem):
            interactor?.deleteTask(id: viewModelItem.id)
        }
    }
}

// MARK: - ToDoListInteractorOutput (implementation)
extension ToDoListPresenterImpl: ToDoListInteractorOutput {
    func didUpdateTasksState(with result: Result<[ToDoItem], any Error>) {
        switch result {
        case .success(let domainItems):
            let dateFormatter = DateFormatterProvider.formatter(for: .shortUIDate)
            let viewModels = domainItems.map { item in
                ToDoItemViewModel(
                    id: item.id,
                    title: item.title,
                    description: item.description,
                    dateString: dateFormatter.string(from: item.date),
                    isCompleted: item.isCompleted
                )
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.view?.display(viewModels)
            }
        case .failure(let error):
            log(message: "🛑 Ошибка при получении задач из Интерактора: \(error.localizedDescription)")
        }
    }
}
