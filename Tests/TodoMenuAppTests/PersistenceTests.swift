import Foundation
import Testing
@testable import TodoMenuApp

@Test func saveAndLoadRoundTrip() throws {
    let fm = FileManager.default
    let uniqueFolder = "TodoMenuTests-\(UUID().uuidString)"
    let store = TodoStore(fileManager: fm, appSupportDirectoryName: uniqueFolder)

    let now = Date(timeIntervalSince1970: 1_700_000_000)
    var todo = try Todo.makeNew(title: "Persist me", notes: "details", now: now)
    todo.setCompleted(true, now: now.addingTimeInterval(60))

    try store.saveTodos([todo])
    let loaded = try store.loadTodos()

    #expect(loaded.count == 1)
    #expect(loaded.first?.id == todo.id)
    #expect(loaded.first?.title == "Persist me")
    #expect(loaded.first?.isCompleted == true)
    #expect(loaded.first?.createdAt == now)
    #expect(loaded.first?.editedAt == now.addingTimeInterval(60))
    #expect(loaded.first?.completedAt == now.addingTimeInterval(60))
}
