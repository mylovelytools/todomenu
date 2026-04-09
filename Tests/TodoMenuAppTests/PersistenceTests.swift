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

@MainActor
@Test func searchMatchesTitleAndNotes() throws {
    let fm = FileManager.default
    let uniqueFolder = "TodoMenuSearchTests-\(UUID().uuidString)"
    let store = TodoStore(fileManager: fm, appSupportDirectoryName: uniqueFolder)

    let now = Date(timeIntervalSince1970: 1_700_000_000)
    let titleMatch = try Todo.makeNew(title: "Buy milk", notes: "", now: now)
    let notesMatch = try Todo.makeNew(title: "Plan trip", notes: "Pack charger and socks", now: now)
    let noMatch = try Todo.makeNew(title: "Read book", notes: "fiction", now: now)

    try store.saveTodos([titleMatch, notesMatch, noMatch])

    let viewModel = TodoListViewModel(store: store)

    viewModel.searchText = "milk"
    #expect(viewModel.filteredTodos.map(\.id) == [titleMatch.id])

    viewModel.searchText = "charger"
    #expect(viewModel.filteredTodos.map(\.id) == [notesMatch.id])

    viewModel.searchText = ""
    #expect(viewModel.filteredTodos.count == 3)
}
