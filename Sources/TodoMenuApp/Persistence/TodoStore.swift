import Foundation

final class TodoStore {
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let fileManager: FileManager
    private let appSupportDirectoryName: String

    init(
        fileManager: FileManager = .default,
        appSupportDirectoryName: String = "TodoMenu"
    ) {
        self.fileManager = fileManager
        self.appSupportDirectoryName = appSupportDirectoryName

        encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    func loadTodos() throws -> [Todo] {
        let url = try dataFileURL()

        guard fileManager.fileExists(atPath: url.path) else {
            return []
        }

        let data = try Data(contentsOf: url)
        var todos = try decoder.decode([Todo].self, from: data)
        todos.removeAll { !$0.validate().isEmpty }
        return todos
    }

    func saveTodos(_ todos: [Todo]) throws {
        let url = try dataFileURL()
        let backupURL = url.deletingPathExtension().appendingPathExtension("backup.json")

        if fileManager.fileExists(atPath: url.path) {
            if fileManager.fileExists(atPath: backupURL.path) {
                try fileManager.removeItem(at: backupURL)
            }
            try fileManager.copyItem(at: url, to: backupURL)
        }

        let data = try encoder.encode(todos)
        try data.write(to: url, options: .atomic)
    }

    func importTodos(from importURL: URL) throws -> [Todo] {
        let data = try Data(contentsOf: importURL)
        let imported = try decoder.decode([Todo].self, from: data)
        return imported.filter { $0.validate().isEmpty }
    }

    func exportTodos(_ todos: [Todo], to exportURL: URL) throws {
        let data = try encoder.encode(todos)
        try data.write(to: exportURL, options: .atomic)
    }

    private func dataFileURL() throws -> URL {
        let base = try fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        let directory = base.appendingPathComponent(appSupportDirectoryName, isDirectory: true)

        if !fileManager.fileExists(atPath: directory.path) {
            try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }

        return directory.appendingPathComponent("todos.json")
    }
}
