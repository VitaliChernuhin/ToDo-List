import UIKit

// MARK: - View (Интерфейс отображения)
protocol ToDoListView: AnyObject {
    var presenter: (any ToDoListPresenter)? { get set }
    
    func display(_ items: [ToDoItemViewModel])
}

// MARK: - Presenter (Интерфейс управления модулем)
protocol ToDoListPresenter: AnyObject, ViewEvenHandable, ViewActionHandable where Action == ToDoListAction {
    var view: ToDoListView? { get set }
    var interactor: ToDoListInteractor? { get set }
    var router: ToDoListRouter? { get set }
}

// MARK: - Interactor (Интерфейс бизнес-логики)
protocol ToDoListInteractor: AnyObject {
    var presenter: ToDoListInteractorOutput? { get set }
    
    func fetchTasks()
    func toggleTaskCompletion(id: Int64)
}

// MARK: - Interactor Output (Обратный поток данных в Presenter)
protocol ToDoListInteractorOutput: AnyObject {
    func didUpdateTasksState(with result: Result<[ToDoItem], Error>)
}

// MARK: - Router (Интерфейс навигации)
protocol ToDoListRouter: AnyObject {}
