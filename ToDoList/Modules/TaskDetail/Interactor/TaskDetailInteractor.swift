import Foundation

protocol TaskDetailInteractorProtocol {
    func createTask(title: String, description: String) async throws -> TaskEntity
    func updateTask(_ task: TaskEntity) async throws
}

final class TaskDetailInteractor: TaskDetailInteractorProtocol {
    private let taskService: TaskServiceProtocol
    
    init(taskService: TaskServiceProtocol) {
        self.taskService = taskService
    }
    
    func createTask(title: String, description: String) async throws -> TaskEntity {
        let newTask = TaskEntity(
            id: UUID(),
            title: title,
            description: description,
            createdAt: Date(),
            isCompleted: false
        )
        return try await taskService.createTask(newTask)
    }
    
    func updateTask(_ task: TaskEntity) async throws {
        try await taskService.updateTask(task)
    }
} 