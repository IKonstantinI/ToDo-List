protocol TaskDetailPresenterProtocol: AnyObject {
    var isEditMode: Bool { get }
    func viewDidLoad()
    func saveTask(title: String, description: String)
    func cancelEditing()
}

final class TaskDetailPresenter: TaskDetailPresenterProtocol {
    weak var view: TaskDetailViewProtocol?
    private let router: TaskDetailRouterProtocol
    private let interactor: TaskDetailInteractorProtocol
    private let task: TaskEntity?
    
    var isEditMode: Bool {
        task != nil
    }
    
    init(
        view: TaskDetailViewProtocol,
        router: TaskDetailRouterProtocol,
        interactor: TaskDetailInteractorProtocol,
        task: TaskEntity? = nil
    ) {
        self.view = view
        self.router = router
        self.interactor = interactor
        self.task = task
    }
    
    func viewDidLoad() {
        view?.updateView(with: task)
    }
    
    func saveTask(title: String, description: String) {
        Task {
            do {
                if let existingTask = task {
                    var updatedTask = existingTask
                    updatedTask.title = title
                    updatedTask.description = description
                    try await interactor.updateTask(updatedTask)
                } else {
                    _ = try await interactor.createTask(title: title, description: description)
                }
                await MainActor.run {
                    router.dismiss()
                }
            } catch {
                await MainActor.run {
                    view?.showError(error)
                }
            }
        }
    }
    
    func cancelEditing() {
        router.dismiss()
    }
} 