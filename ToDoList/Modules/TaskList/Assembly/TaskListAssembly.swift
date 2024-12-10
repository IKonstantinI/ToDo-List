import UIKit
import CoreData

enum TaskListAssembly {
    static func createModule(
        context: NSManagedObjectContext,
        taskService: TaskServiceProtocol? = nil
    ) -> TaskListViewController {
        let service = taskService ?? TaskService(
            context: context,
            networkService: NetworkService(),
            userDefaultsService: UserDefaultsService()
        )
        
        let view = TaskListViewController()
        let interactor = TaskListInteractor(taskService: service)
        let router = TaskListRouter(viewController: view, context: context)
        let presenter = TaskListPresenter(
            view: view,
            interactor: interactor,
            router: router
        )
        
        view.configure(with: presenter)
        
        return view
    }
} 