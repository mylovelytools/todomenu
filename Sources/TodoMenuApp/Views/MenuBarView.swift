import AppKit
import SwiftUI

struct MenuBarView: View {
    @StateObject private var viewModel = TodoListViewModel()

    @State private var newTitle: String = ""
    @State private var newNotes: String = ""
    @State private var editingTodo: Todo?
    @State private var showingClearAllConfirmation = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header with Error Capsule
            HStack {
                Text("todomenu")
                    .font(.headline)
                
                Spacer()
                
                if viewModel.errorMessage != nil {
                    Button(action: { viewModel.clearError() }) {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                            Text(viewModel.errorMessage ?? "")
                                .lineLimit(1)
                            Image(systemName: "xmark.circle.fill")
                        }
                        .font(.caption2)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.red.opacity(0.15))
                        .foregroundStyle(.red)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }

            Divider()

            if let todoToEdit = editingTodo {
                EditTodoView(todo: todoToEdit, onCancel: { editingTodo = nil }) { updatedTitle, updatedNotes in
                    viewModel.updateTodo(id: todoToEdit.id, title: updatedTitle, notes: updatedNotes)
                    editingTodo = nil
                }
            } else {
                if viewModel.todos.isEmpty {
                    Text("No tasks yet")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(height: 60)
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(viewModel.todos) { todo in
                                TodoRowView(
                                    todo: todo,
                                    onToggle: { viewModel.toggleCompletion(id: todo.id) },
                                    onEdit: { editingTodo = todo },
                                    onDelete: { viewModel.deleteTodo(id: todo.id) }
                                )
                            }
                        }
                        .padding(.trailing, 14)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(minHeight: CGFloat(min(viewModel.todos.count, 3) * 80), maxHeight: 300)
                    .layoutPriority(1)
                }

                Divider()

                if showingClearAllConfirmation {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Clear all tasks?")
                            .font(.caption)
                            .fontWeight(.semibold)

                        Text("This will permanently delete all tasks.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 8) {
                            Button("Clear All") {
                                viewModel.deleteAllTodos()
                                showingClearAllConfirmation = false
                            }
                            .foregroundStyle(.red)

                            Button("Cancel") {
                                showingClearAllConfirmation = false
                            }
                        }
                        .font(.caption)
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(.quaternary.opacity(0.25), in: RoundedRectangle(cornerRadius: 8))
                }
                
                AddTaskInputView(title: $newTitle, notes: $newNotes, onAdd: addTodo)

                Divider()

                HStack {
                    Button(action: addTodo) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.18))
                                .frame(width: 40, height: 40)

                            Circle()
                                .fill(Color.blue)
                                .frame(width: 28, height: 28)

                            Image(systemName: "plus")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    .buttonStyle(.plain)
                    .frame(width: 40, height: 40)
                    .keyboardShortcut(.defaultAction)

                    Spacer()

                    HStack(spacing: 12) {
                        if !viewModel.todos.isEmpty {
                            Button("Clear All") {
                                showingClearAllConfirmation = true
                            }
                            .foregroundStyle(.red.opacity(0.8))
                        }

                        Button("Import") {
                            viewModel.importTodosFromDisk()
                        }
                        Button("Export") {
                            viewModel.exportTodosToDisk()
                        }
                        Button("Quit") {
                            NSApplication.shared.terminate(nil)
                        }
                    }
                    .font(.caption)
                }
            }
        }
        .padding(10)
        .frame(width: 400)
    }

    private func addTodo() {
        let originalTitle = newTitle
        viewModel.addTodo(title: newTitle, notes: newNotes)

        if !originalTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            newTitle = ""
            newNotes = ""
        }
    }
}

struct AddTaskInputView: View {
    @Binding var title: String
    @Binding var notes: String
    let onAdd: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .trailing, spacing: 4) {
                TextField("Add a new task...", text: $title, axis: .vertical)
                    .lineLimit(2...4)
                    .textFieldStyle(.plain)
                    .padding(8)
                    .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(title.count > 255 ? Color.red.opacity(0.5) : Color.blue.opacity(0.3), lineWidth: 1)
                    )
                
                if title.count > 255 {
                    Text("\(title.count)/255 - Max length reached")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.red)
                        .padding(.trailing, 4)
                }
            }

            VStack(alignment: .trailing, spacing: 7) {
                NSTextFieldWrapper(text: $notes, placeholder: "Notes (optional)", isMultiline: false, onSubmit: onAdd)
                    .frame(height: 22)
                    .padding(.bottom, notes.count > 255 ? 3 : 0)
                
                if notes.count > 255 {
                    Text("\(notes.count)/255 - Max length reached")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundStyle(.red)
                        .padding(.top, 2)
                        .padding(.trailing, 4)
                        .padding(.bottom, 2)
                }
            }
        }
        .padding(.top, 4)
        .padding(.bottom, 8)
    }
}

// MARK: - NSTextField wrapper for better menu bar input
struct NSTextFieldWrapper: NSViewRepresentable {
    @Binding var text: String
    let placeholder: String
    var isMultiline: Bool = false
    var onSubmit: (() -> Void)?

    func makeNSView(context: Context) -> NSTextField {
        let textField = NSTextField()
        textField.placeholderString = placeholder
        textField.stringValue = text
        textField.delegate = context.coordinator
        
        if isMultiline {
            textField.cell?.usesSingleLineMode = false
            textField.cell?.wraps = true
            textField.cell?.isScrollable = false
        }
        
        textField.target = context.coordinator
        textField.action = #selector(Coordinator.textDidChange(_:))
        textField.bezelStyle = .roundedBezel
        return textField
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, onSubmit: onSubmit)
    }

    class Coordinator: NSObject, NSTextFieldDelegate {
        @Binding var text: String
        let onSubmit: (() -> Void)?

        init(text: Binding<String>, onSubmit: (() -> Void)?) {
            _text = text
            self.onSubmit = onSubmit
        }

        @objc func textDidChange(_ sender: NSTextField) {
            text = sender.stringValue
        }

        func controlTextDidChange(_ obj: Notification) {
            guard let textField = obj.object as? NSTextField else { return }
            text = textField.stringValue
        }

        func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
            if commandSelector == #selector(NSResponder.insertNewline(_:)) {
                // For multiline text fields, allow Shift+Enter for new line? 
                // Or just keep the onSubmit behavior if that's what was intended.
                onSubmit?()
                return true
            }
            return false
        }
    }
}

struct TodoRowView: View {
    let todo: Todo
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    private var timestampText: String {
        var components: [String] = ["Created \(todo.createdAt.formatted(date: .abbreviated, time: .shortened))"]

        if let contentEditedAt = todo.contentEditedAt {
            components.append("Edited \(contentEditedAt.formatted(date: .abbreviated, time: .shortened))")
        }

        if todo.isCompleted, let completedAt = todo.completedAt {
            components.append("Completed \(completedAt.formatted(date: .abbreviated, time: .shortened))")
        }

        return components.joined(separator: " | ")
    }

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Button(action: onToggle) {
                Image(systemName: todo.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(todo.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                Text(todo.title)
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .strikethrough(todo.isCompleted)

                if !todo.notes.isEmpty {
                    Text(todo.notes)
                        .font(.system(size: 11))
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                Text(timestampText)
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
                    .lineLimit(2)
            }

            Spacer()

            HStack(spacing: 8) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.body)
                        .foregroundStyle(.red)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(.quaternary.opacity(0.35), in: RoundedRectangle(cornerRadius: 6))
    }
}

struct EditTodoView: View {
    let todo: Todo
    let onCancel: () -> Void
    let onSave: (String, String) -> Void

    @State private var title: String
    @State private var notes: String

    init(todo: Todo, onCancel: @escaping () -> Void, onSave: @escaping (String, String) -> Void) {
        self.todo = todo
        self.onCancel = onCancel
        self.onSave = onSave
        _title = State(initialValue: todo.title)
        _notes = State(initialValue: todo.notes)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Edit Task")
                .font(.headline)

            VStack(alignment: .trailing, spacing: 2) {
                TextField("Task description", text: $title, axis: .vertical)
                    .lineLimit(2...4)
                    .textFieldStyle(.plain)
                    .padding(8)
                    .background(.quaternary.opacity(0.35), in: RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(title.count > 255 ? Color.red.opacity(0.5) : Color.blue.opacity(0.3), lineWidth: 1)
                    )
                
                if title.count > 255 {
                    Text("\(title.count)/255")
                        .font(.caption2)
                        .foregroundStyle(.red)
                }
            }

            VStack(alignment: .trailing, spacing: 2) {
                TextField("Notes (Optional)", text: $notes)
                    .textFieldStyle(.plain)
                    .padding(8)
                    .background(.quaternary.opacity(0.2), in: RoundedRectangle(cornerRadius: 8))
                
                if notes.count > 255 {
                    Text("\(notes.count)/255")
                        .font(.caption2)
                        .foregroundStyle(.red)
                }
            }

            HStack {
                Spacer()
                Button("Cancel") {
                    onCancel()
                }
                Button("Save") {
                    onSave(title, notes)
                }
                .keyboardShortcut(.defaultAction)
            }
        }
        .padding(6)
        .background(.quaternary.opacity(0.15), in: RoundedRectangle(cornerRadius: 8))
    }
}
