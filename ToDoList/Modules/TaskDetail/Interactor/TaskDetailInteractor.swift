protocol TaskDetailInteractorProtocol: AnyObject {
    func createTask(title: String, description: String) async throws -> TaskEntity
    func updateTask(_ task: TaskEntity) async throws
}

final class TaskDetailInteractor: TaskDetailInteractorProtocol {
    private let taskService: TaskServiceProtocol
    
    init(taskService: TaskServiceProtocol) {
        self.taskService = taskService
    }
    
    func createTask(title: String, description: String) async throws -> TaskEntity {
        return try await taskService.createTask(title: title, description: description)
    }
    
    func updateTask(_ task: TaskEntity) async throws {
        try await taskService.updateTask(task)
    }
} 