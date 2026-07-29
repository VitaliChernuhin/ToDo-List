import UIKit

// MARK: - View (Интерфейс отображения)
protocol ToDoListView: AnyObject {
    var presenter: ToDoListPresenter? { get set }
    
    func display(_ items: [ToDoItemViewModel])
}

// MARK: - Presenter (Интерфейс управления модулем)
protocol ToDoListPresenter: AnyObject {
    var view: ToDoListView? { get set }
    var interactor: ToDoListInteractor? { get set }
    var router: ToDoListRouter? { get set }
    
    func didUpdateSearchQuery(_ query: String)
}

// MARK: - Interactor (Интерфейс бизнес-логики)
protocol ToDoListInteractor: AnyObject {
    var presenter: ToDoListInteractorOutput? { get set }
}

// MARK: - Interactor Output (Обратный поток данных в Presenter)
protocol ToDoListInteractorOutput: AnyObject {
}

// MARK: - Router (Интерфейс навигации)
protocol ToDoListRouter: AnyObject {
}
