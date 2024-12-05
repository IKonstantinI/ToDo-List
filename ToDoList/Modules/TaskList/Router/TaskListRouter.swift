import UIKit
import CoreData

protocol TaskListRouterProtocol: AnyObject {
    func showCreateTask()
    func showTaskDetail(for task: TaskEntity)
}

final class TaskListRouter: TaskListRouterProtocol {
    private weak var viewController: UIViewController?
    private let context: NSManagedObjectContext
    
    init(viewController: UIViewController, context: NSManagedObjectContext) {
        self.viewController = viewController
        self.context = context
    }
    
    func showCreateTask() {
        let detailVC = TaskDetailAssembly.createModule(context: context)
        let navigationController = UINavigationController(rootViewController: detailVC)
        viewController?.present(navigationController, animated: true)
    }
    
    func showTaskDetail(for task: TaskEntity) {
        let detailVC = TaskDetailAssembly.createModule(
            context: context,
            editingTask: task
        )
        let navigationController = UINavigationController(rootViewController: detailVC)
        viewController?.present(navigationController, animated: true)
    }
} 