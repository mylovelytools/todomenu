import XCTest
@testable import TodoMenuApp

final class TodoTimestampTests: XCTestCase {
    func testAddSetsCreatedAndEditedAndNilCompleted() throws {
        let now = Date(timeIntervalSince1970: 1_700_000_000)
        let todo = try Todo.makeNew(title: "Task", notes: "", now: now)

        XCTAssertEqual(todo.createdAt, now)
        XCTAssertEqual(todo.editedAt, now)
        XCTAssertNil(todo.completedAt)
        XCTAssertFalse(todo.isCompleted)
    }

    func testEditUpdatesOnlyEditedTimestamp() throws {
        let created = Date(timeIntervalSince1970: 1_700_000_000)
        var todo = try Todo.makeNew(title: "Task", notes: "note", now: created)
        let editTime = created.addingTimeInterval(300)

        try todo.update(title: "Task 2", notes: "note 2", now: editTime)

        XCTAssertEqual(todo.title, "Task 2")
        XCTAssertEqual(todo.notes, "note 2")
        XCTAssertEqual(todo.createdAt, created)
        XCTAssertEqual(todo.editedAt, editTime)
        XCTAssertNil(todo.completedAt)
    }

    func testCompleteAndIncompleteTransitions() throws {
        let created = Date(timeIntervalSince1970: 1_700_000_000)
        var todo = try Todo.makeNew(title: "Task", notes: "", now: created)

        let completedAt = created.addingTimeInterval(120)
        todo.setCompleted(true, now: completedAt)

        XCTAssertTrue(todo.isCompleted)
        XCTAssertEqual(todo.completedAt, completedAt)
        XCTAssertEqual(todo.editedAt, completedAt)

        let incompleteAt = created.addingTimeInterval(240)
        todo.setCompleted(false, now: incompleteAt)

        XCTAssertFalse(todo.isCompleted)
        XCTAssertNil(todo.completedAt)
        XCTAssertEqual(todo.editedAt, incompleteAt)
    }
}
