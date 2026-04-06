import Foundation
import Testing
@testable import TodoMenuApp

@Test func addSetsCreatedAndEditedAndNilCompleted() throws {
    let now = Date(timeIntervalSince1970: 1_700_000_000)
    let todo = try Todo.makeNew(title: "Task", notes: "", now: now)

    #expect(todo.createdAt == now)
    #expect(todo.editedAt == now)
    #expect(todo.completedAt == nil)
    #expect(todo.isCompleted == false)
}

@Test func editUpdatesOnlyEditedTimestamp() throws {
    let created = Date(timeIntervalSince1970: 1_700_000_000)
    var todo = try Todo.makeNew(title: "Task", notes: "note", now: created)
    let editTime = created.addingTimeInterval(300)

    try todo.update(title: "Task 2", notes: "note 2", now: editTime)

    #expect(todo.title == "Task 2")
    #expect(todo.notes == "note 2")
    #expect(todo.createdAt == created)
    #expect(todo.editedAt == editTime)
    #expect(todo.completedAt == nil)
}

@Test func completeAndIncompleteTransitions() throws {
    let created = Date(timeIntervalSince1970: 1_700_000_000)
    var todo = try Todo.makeNew(title: "Task", notes: "", now: created)

    let completedAt = created.addingTimeInterval(120)
    todo.setCompleted(true, now: completedAt)

    #expect(todo.isCompleted == true)
    #expect(todo.completedAt == completedAt)
    #expect(todo.editedAt == completedAt)

    let incompleteAt = created.addingTimeInterval(240)
    todo.setCompleted(false, now: incompleteAt)

    #expect(todo.isCompleted == false)
    #expect(todo.completedAt == nil)
    #expect(todo.editedAt == incompleteAt)
}
