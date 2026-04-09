import Foundation

@MainActor
final class TodoListViewModel: ObservableObject {
    @Published private(set) var todos: [Todo] = []
    @Published var searchText: String = ""
    @Published var errorMessage: String?
    @Published var lastImportCount: Int = 0

    private let store: TodoStore

    init(store: TodoStore = TodoStore()) {
        self.store = store
        load()
    }

    var filteredTodos: [Todo] {
        todos.filter { $0.matchesSearchQuery(searchText) }
    }

    func load() {
        do {
            todos = try store.loadTodos()
            sortTodos()
        } catch {
            errorMessage = "Failed to load todos: \(error.localizedDescription)"
        }
    }

    func addTodo(title: String, notes: String) {
        do {
            let todo = try Todo.makeNew(title: title, notes: notes)
            todos.append(todo)
            sortTodos()
            try persist()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateTodo(id: UUID, title: String, notes: String) {
        guard let index = todos.firstIndex(where: { $0.id == id }) else { return }

        do {
            try todos[index].update(title: title, notes: notes)
            sortTodos()
            try persist()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleCompletion(id: UUID) {
        guard let index = todos.firstIndex(where: { $0.id == id }) else { return }
        let nowCompleted = !todos[index].isCompleted
        todos[index].setCompleted(nowCompleted)
        sortTodos()

        do {
            try persist()
        } catch {
            errorMessage = "Failed to save change: \(error.localizedDescription)"
        }
    }

    func deleteAllTodos() {
        todos.removeAll()
        do {
            try persist()
        } catch {
            errorMessage = "Failed to clear tasks: \(error.localizedDescription)"
        }
    }

    func deleteTodo(id: UUID) {
        todos.removeAll { $0.id == id }

        do {
            try persist()
        } catch {
            errorMessage = "Failed to delete task: \(error.localizedDescription)"
        }
    }

    func importTodosFromDisk() {
        guard let url = ImportExportService.chooseImportURL() else { return }

        do {
            let imported = try store.importTodos(from: url)
            mergeTodos(imported)
            sortTodos()
            try persist()
            lastImportCount = imported.count
        } catch {
            errorMessage = "Import failed: \(error.localizedDescription)"
        }
    }

    func exportTodosToDisk() {
        guard let url = ImportExportService.chooseExportURL() else { return }

        do {
            try store.exportTodos(todos, to: url)
        } catch {
            errorMessage = "Export failed: \(error.localizedDescription)"
        }
    }

    func clearError() {
        errorMessage = nil
    }

    private func mergeTodos(_ imported: [Todo]) {
        var existingByID = Dictionary(uniqueKeysWithValues: todos.map { ($0.id, $0) })

        for incoming in imported {
            if let existing = existingByID[incoming.id] {
                existingByID[incoming.id] = incoming.editedAt >= existing.editedAt ? incoming : existing
            } else {
                existingByID[incoming.id] = incoming
            }
        }

        todos = Array(existingByID.values)
    }

    private func sortTodos() {
        todos.sort { lhs, rhs in
            if lhs.isCompleted != rhs.isCompleted {
                return lhs.isCompleted == false
            }
            return lhs.editedAt > rhs.editedAt
        }
    }

    private func persist() throws {
        try store.saveTodos(todos)
    }
}
