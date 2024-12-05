import Foundation

struct TaskDTO: Codable {
    let id: Int
    let todo: String
    let completed: Bool
    let userId: Int
    
    func toEntity() -> TaskEntity {
        TaskEntity(
            id: UUID(),
            title: todo,
            description: "",
            createdAt: Date(),
            isCompleted: completed
        )
    }
}

struct TasksResponse: Codable {
    let todos: [TaskDTO]
    let total: Int
    let skip: Int
    let limit: Int
} 