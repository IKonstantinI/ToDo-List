import UIKit
import CoreData

enum TaskListAssembly {
    static func createModule(context: NSManagedObjectContext) -> TaskListViewController {
        let userDefaultsService = UserDefaultsService()
        let networkService = NetworkService()
        let taskService = TaskService(
            context: context,
            networkService: networkService,
            userDefaultsService: userDefaultsService
        )
        
        let view = TaskListViewController()
        let interactor = TaskListInteractor(taskService: taskService)
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