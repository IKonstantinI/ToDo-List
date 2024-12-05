import UIKit

protocol TaskDetailRouterProtocol: AnyObject {
    func closeModule()
}

final class TaskDetailRouter: TaskDetailRouterProtocol {
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func closeModule() {
        viewController?.dismiss(animated: true)
    }
} 