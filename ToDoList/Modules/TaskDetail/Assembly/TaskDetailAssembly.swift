import UIKit
import CoreData

enum TaskDetailAssembly {
    static func createModule(
        task: TaskEntity? = nil,
        context: NSManagedObjectContext
    ) -> UIViewController {
        let taskService = TaskService(context: context)
        let interactor = TaskDetailInteractor(taskService: taskService)
        
        let view = TaskDetailViewController()
        let router = TaskDetailRouter(viewController: view)
        let presenter = TaskDetailPresenter(
            view: view,
            router: router,
            interactor: interactor,
            task: task
        )
        view.presenter = presenter
        
        let navigationController = UINavigationController(rootViewController: view)
        return navigationController
    }
} 