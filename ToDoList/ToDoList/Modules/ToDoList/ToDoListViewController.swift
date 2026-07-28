import UIKit
import SnapKit

final class ToDoListViewController: UIViewController, ToDoListView {
    
    var presenter: ToDoListPresenter?
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

private extension ToDoListViewController {
    func setupUI() {
        self.view.backgroundColor = .green
    }
}
