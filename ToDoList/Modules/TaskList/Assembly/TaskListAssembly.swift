import UIKit
import CoreData

enum TaskListAssembly {
    static func createModule(context: NSManagedObjectContext) -> TaskListViewController {
        let taskService = TaskService(context: context)
        let interactor = TaskListInteractor(taskService: taskService)
        
        let dummyView = TaskListViewController(presenter: DummyPresenter())
        let router = TaskListRouter(viewController: dummyView, context: context)
        
        let presenter = TaskListPresenter(
            view: dummyView,
            interactor: interactor,
            router: router
        )
        
        let view = TaskListViewController(presenter: presenter)
        
        router.viewController = view
        presenter.view = view
        
        return view
    }
}

private class DummyPresenter: TaskListPresenterProtocol {
    func viewDidLoad() {}
    func addNewTask() {}
    func didSelectTask(_ task: TaskEntity) {}
    func deleteTask(_ task: TaskEntity) {}
    func updateTaskStatus(_ task: TaskEntity) {}
    func searchTasks(query: String) {}
    func refreshTasks() {}
} 