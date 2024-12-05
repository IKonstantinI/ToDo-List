import UIKit

protocol TaskDetailRouterProtocol: AnyObject {
    func dismiss()
}

final class TaskDetailRouter: TaskDetailRouterProtocol {
    weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func dismiss() {
        viewController?.dismiss(animated: true)
    }
} 