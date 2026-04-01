import AppKit
import Foundation

enum ImportExportService {
    static func chooseImportURL() -> URL? {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        panel.allowedContentTypes = [.json]
        panel.title = "Import Todos"

        return panel.runModal() == .OK ? panel.url : nil
    }

    static func chooseExportURL(defaultFileName: String = "todos-export.json") -> URL? {
        let panel = NSSavePanel()
        panel.canCreateDirectories = true
        panel.allowedContentTypes = [.json]
        panel.nameFieldStringValue = defaultFileName
        panel.title = "Export Todos"

        return panel.runModal() == .OK ? panel.url : nil
    }
}
