import UIKit
import CoreData

protocol TaskListRouterProtocol: AnyObject {
    func showTaskDetail(for task: TaskEntity?)
    func showCreateTask()
}

final class TaskListRouter: TaskListRouterProtocol {
    weak var viewController: UIViewController?
    private let context: NSManagedObjectContext
    
    init(viewController: UIViewController, context: NSManagedObjectContext) {
        self.viewController = viewController
        self.context = context
    }
    
    func showTaskDetail(for task: TaskEntity?) {
        let taskDetailVC = TaskDetailAssembly.createModule(
            task: task,
            context: context
        )
        viewController?.present(taskDetailVC, animated: true)
    }
    
    func showCreateTask() {
        let taskDetailVC = TaskDetailAssembly.createModule(context: context)
        viewController?.present(taskDetailVC, animated: true)
    }
} 