import XCTest
@testable import TodoMenuApp

final class PersistenceTests: XCTestCase {
    func testSaveAndLoadRoundTrip() throws {
        let fm = FileManager.default
        let uniqueFolder = "TodoMenuTests-\(UUID().uuidString)"
        let store = TodoStore(fileManager: fm, appSupportDirectoryName: uniqueFolder)

        let now = Date(timeIntervalSince1970: 1_700_000_000)
        var todo = try Todo.makeNew(title: "Persist me", notes: "details", now: now)
        todo.setCompleted(true, now: now.addingTimeInterval(60))

        try store.saveTodos([todo])
        let loaded = try store.loadTodos()

        XCTAssertEqual(loaded.count, 1)
        XCTAssertEqual(loaded.first?.id, todo.id)
        XCTAssertEqual(loaded.first?.title, "Persist me")
        XCTAssertEqual(loaded.first?.isCompleted, true)
        XCTAssertEqual(loaded.first?.createdAt, now)
        XCTAssertEqual(loaded.first?.editedAt, now.addingTimeInterval(60))
        XCTAssertEqual(loaded.first?.completedAt, now.addingTimeInterval(60))
    }
}
