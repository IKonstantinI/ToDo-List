import Foundation

struct TaskDTO: Decodable {
    let id: Int
    let todo: String
    let completed: Bool
}

struct TasksResponse: Decodable {
    let todos: [TaskDTO]
} 