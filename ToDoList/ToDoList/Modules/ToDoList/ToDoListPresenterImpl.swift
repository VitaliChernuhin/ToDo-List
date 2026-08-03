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

// MARK: - ToDoListPresenter (implementaion)
extension ToDoListPresenterImpl {
    func didUpdateSearchQuery(_ query: String) {
        
    }
}

// MARK: - ToDoListInteractorOutput (implementation)
extension ToDoListPresenterImpl: ToDoListInteractorOutput {
    
    func didFetchTasks(with result: Result<[ToDoItem], Error>) {
        switch result {
        case .success(let domainItems):
            let viewModels = domainItems.map { item in
                ToDoItemViewModel(
                    id: item.id,
                    title: item.title,
                    description: item.description,
                    dateString: "03.08.2026", // Здесь Презентер b2b-безопасно форматирует дату для UI
                    isCompleted: item.isCompleted
                )
            }
            view?.display(viewModels)
            
        case .failure(let error):
            log(message: "🛑 Ошибка при получении задач из Интерактора: \(error.localizedDescription)")
        }
    }
}
