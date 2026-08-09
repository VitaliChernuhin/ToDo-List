import UIKit

final class ToDoListRouterImpl: ToDoListRouter {
    var onRouteAction: ((ToDoListRouteAction) -> Void)?
    
    weak var viewController: UIViewController?
}

