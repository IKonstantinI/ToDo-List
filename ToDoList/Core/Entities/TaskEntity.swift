import Foundation

struct TaskEntity: Identifiable {
    let id: UUID
    var title: String
    var description: String
    let createdAt: Date
    var isCompleted: Bool
} 