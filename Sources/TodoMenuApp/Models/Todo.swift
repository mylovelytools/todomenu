import Foundation

struct Todo: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var notes: String
    var isCompleted: Bool
    let createdAt: Date
    var editedAt: Date
    var contentEditedAt: Date?
    var completedAt: Date?

    static func makeNew(title: String, notes: String, now: Date = Date()) throws -> Todo {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw TodoValidationError.emptyTitle
        }
        
        guard trimmed.count <= 255 else {
            throw TodoValidationError.titleTooLong
        }
        
        guard notes.count <= 255 else {
            throw TodoValidationError.notesTooLong
        }

        return Todo(
            id: UUID(),
            title: trimmed,
            notes: notes,
            isCompleted: false,
            createdAt: now,
            editedAt: now,
            contentEditedAt: nil,
            completedAt: nil
        )
    }

    mutating func update(title: String, notes: String, now: Date = Date()) throws {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw TodoValidationError.emptyTitle
        }
        
        guard trimmed.count <= 255 else {
            throw TodoValidationError.titleTooLong
        }
        
        guard notes.count <= 255 else {
            throw TodoValidationError.notesTooLong
        }

        if trimmed != self.title || notes != self.notes {
            self.title = trimmed
            self.notes = notes
            self.editedAt = now
            self.contentEditedAt = now
        }
    }

    mutating func setCompleted(_ completed: Bool, now: Date = Date()) {
        isCompleted = completed
        editedAt = now
        completedAt = completed ? now : nil
    }

    func validate() -> [TodoValidationError] {
        var errors: [TodoValidationError] = []

        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errors.append(.emptyTitle)
        }
        
        if title.count > 255 {
            errors.append(.titleTooLong)
        }
        
        if notes.count > 255 {
            errors.append(.notesTooLong)
        }

        if editedAt < createdAt {
            errors.append(.editedBeforeCreated)
        }

        if let completedAt, completedAt < createdAt {
            errors.append(.completedBeforeCreated)
        }

        return errors
    }
}

enum TodoValidationError: LocalizedError, Equatable {
    case emptyTitle
    case titleTooLong
    case notesTooLong
    case editedBeforeCreated
    case completedBeforeCreated

    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "Task cannot be empty."
        case .titleTooLong:
            return "Task description cannot exceed 255 characters."
        case .notesTooLong:
            return "Notes cannot exceed 255 characters."
        case .editedBeforeCreated:
            return "Edited timestamp cannot be older than created timestamp."
        case .completedBeforeCreated:
            return "Completed timestamp cannot be older than created timestamp."
        }
    }
}
