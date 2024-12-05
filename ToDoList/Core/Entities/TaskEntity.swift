import Foundation

struct TaskEntity: Identifiable {
    let id: UUID
    var title: String
    var description: String
    var createdAt: Date
    var isCompleted: Bool
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        createdAt: Date = Date(),
        isCompleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.createdAt = createdAt
        self.isCompleted = isCompleted
    }
} 