import Foundation

final class ToDoListPresenterImpl: ToDoListPresenter {
   
    weak var view: ToDoListView?
    var interactor: ToDoListInteractor?
    var router: ToDoListRouter?
    
    func didUpdateSearchQuery(_ query: String) {
        
    }
}

extension ToDoListPresenterImpl: ToDoListInteractorOutput {
    
}
