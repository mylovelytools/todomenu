# todomenu

A sleek, lightweight macOS menu bar application for managing your personal tasks. Built with SwiftUI and AppKit, **todomenu** lives in your menu bar, providing instant access to your to-do list without cluttering your workspace.

## Features

- **Always Accessible**: Resides in your macOS menu bar for quick task entry and management.
- **Rich Tasks**: Supports titles and optional notes for each task.
- **Fast Search**: Filter tasks by description or notes from the menu bar.
- **In-Place Editing**: Edit your tasks directly within the menu bar view without losing focus.
- **Robust Local Storage**: Your tasks are securely persisted in the macOS Application Support directory using atomic JSON writes.
- **Import/Export**: Easily backup or sync your tasks via JSON files.
- **Safe Clear**: "Clear All" functionality with a safety confirmation to prevent accidental data loss.
- **Task Metadata**: Track when tasks were created, edited, and completed.
- **Smart Validation**: Real-time character limit warnings and inline error messaging.

## Installation 🛠️

### Prerequisites
- macOS 13.0 or later
- Xcode 15.0+ or Swift 5.9+

### Build from Source
1. Clone the repository:
   ```bash
   git clone https://github.com/mylovelytools/todomenu.git
   cd todomenu
   ```
2. Build the project:
   ```bash
   swift build -c release
   ```
3. Run the application:
   ```bash
   ./.build/release/TodoMenuApp
   ```

## Development

The project follows a clean architecture with:
- **Models**: `Todo` structure with Codable support.
- **Views**: SwiftUI views leveraging `NSViewRepresentable` for optimized menu bar interactions.
- **Store**: `TodoStore` using `UserDefaults` or File System for persistence.
- **Services**: `ImportExportService` for handling data serialization.

## License

This project is licensed under the GNU Affero General Public License v3.0 - see the [LICENSE](LICENSE) file for details.
