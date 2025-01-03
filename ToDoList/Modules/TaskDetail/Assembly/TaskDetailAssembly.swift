import UIKit
import CoreData

enum TaskDetailAssembly {
    static func createModule(
        context: NSManagedObjectContext,
        editingTask: TaskEntity? = nil,
        delegate: TaskDetailDelegate? = nil
    ) -> UIViewController {
        let taskService = TaskService(context: context)
        let interactor = TaskDetailInteractor(taskService: taskService)
        let view = TaskDetailViewController()
        let router = TaskDetailRouter(viewController: view)
        let presenter = TaskDetailPresenter(
            view: view,
            interactor: interactor,
            router: router,
            editingTask: editingTask,
            delegate: delegate
        )
        
        view.configure(with: presenter)
        
        return view
    }
} 