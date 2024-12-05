protocol TaskDetailPresenterProtocol: AnyObject {
    var isEditMode: Bool { get }
    func viewDidLoad()
    func saveTask(title: String, description: String)
    func cancelEditing()
}

final class TaskDetailPresenter: TaskDetailPresenterProtocol {
    weak var view: TaskDetailViewProtocol?
    private let interactor: TaskDetailInteractorProtocol
    private let router: TaskDetailRouterProtocol
    private let editingTask: TaskEntity?
    
    var isEditMode: Bool { editingTask != nil }
    
    init(
        view: TaskDetailViewProtocol,
        interactor: TaskDetailInteractorProtocol,
        router: TaskDetailRouterProtocol,
        editingTask: TaskEntity? = nil
    ) {
        self.view = view
        self.interactor = interactor
        self.router = router
        self.editingTask = editingTask
    }
    
    func viewDidLoad() {
        view?.updateView(with: editingTask)
    }
    
    func saveTask(title: String, description: String) {
        Task {
            do {
                if let editingTask = editingTask {
                    var updatedTask = editingTask
                    updatedTask.title = title
                    updatedTask.description = description
                    try await interactor.updateTask(updatedTask)
                } else {
                    try await interactor.createTask(title: title, description: description)
                }
                await MainActor.run {
                    router.closeModule()
                }
            } catch {
                await MainActor.run {
                    view?.showError(error)
                }
            }
        }
    }
    
    func cancelEditing() {
        router.closeModule()
    }
} 