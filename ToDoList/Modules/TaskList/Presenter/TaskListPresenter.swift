protocol TaskListPresenterProtocol: AnyObject {
    func viewDidLoad()
    func addNewTask()
    func didSelectTask(_ task: TaskEntity)
    func deleteTask(_ task: TaskEntity)
    func updateTaskStatus(_ task: TaskEntity)
    func searchTasks(query: String)
    func refreshTasks()
    func viewWillAppear()
}

final class TaskListPresenter: TaskListPresenterProtocol {
    weak var view: TaskListViewProtocol?
    private let interactor: TaskListInteractorProtocol
    private let router: TaskListRouterProtocol
    private var searchTask: Task<Void, Never>?
    
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
        // Отменяем предыдущий поиск
        searchTask?.cancel()
        
        // Создаем новый поиск с задержкой
        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms задержка
            guard !Task.isCancelled else { return }
            
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
            do {
                let tasks = try await interactor.fetchTasks()
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
    
    func viewWillAppear() {
        refreshTasks()
    }
} 