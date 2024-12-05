protocol TaskListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func addNewTask()
    func didSelectTask(_ task: TaskEntity)
    func deleteTask(_ task: TaskEntity)
    func updateTaskStatus(_ task: TaskEntity)
    func searchTasks(query: String)
    func refreshTasks()
}

final class TaskListPresenter: TaskListPresenterProtocol {
    weak var view: TaskListViewProtocol?
    private let interactor: TaskListInteractorProtocol
    private let router: TaskListRouterProtocol
    
    init(
        view: TaskListViewProtocol,
        interactor: TaskListInteractorProtocol,
        router: TaskListRouterProtocol
    ) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }
    
    func viewDidLoad() {
        Task {
            await MainActor.run {
                view?.showLoading()
            }
            
            do {
                let tasks = try await interactor.fetchTasks()
                await MainActor.run {
                    view?.updateTasks(with: tasks)
                    view?.hideLoading()
                }
            } catch {
                await MainActor.run {
                    view?.showError(error)
                    view?.hideLoading()
                }
            }
        }
    }
    
    func addNewTask() {
        router.showCreateTask()
    }
    
    func didSelectTask(_ task: TaskEntity) {
        router.showTaskDetail(for: task)
    }
    
    func deleteTask(_ task: TaskEntity) {
        Task {
            do {
                try await interactor.deleteTask(task)
                await MainActor.run {
                    view?.removeTask(task)
                }
            } catch {
                await MainActor.run {
                    view?.showError(error)
                }
            }
        }
    }
    
    func updateTaskStatus(_ task: TaskEntity) {
        Task {
            do {
                try await interactor.updateTask(task)
            } catch {
                await MainActor.run {
                    view?.showError(error)
                }
            }
        }
    }
    
    func searchTasks(query: String) {
        Task {
            do {
                let tasks = try await interactor.searchTasks(query: query)
                await MainActor.run {
                    view?.updateTasks(with: tasks)
                }
            } catch {
                await MainActor.run {
                    view?.showError(error)
                }
            }
        }
    }
    
    func refreshTasks() {
        Task {
            await MainActor.run {
                view?.showLoading()
            }
            
            do {
                let tasks = try await interactor.fetchTasksWithRefresh()
                await MainActor.run {
                    view?.updateTasks(with: tasks)
                    view?.hideLoading()
                }
            } catch {
                await MainActor.run {
                    view?.showError(error)
                    view?.hideLoading()
                }
            }
        }
    }
} 