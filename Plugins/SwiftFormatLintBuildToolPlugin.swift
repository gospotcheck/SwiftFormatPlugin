import PackagePlugin
import Foundation

@main
struct SwiftFormatLintBuildToolPlugin: BuildToolPlugin {
    /// Entry point for creating build commands for targets in Swift packages.
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        guard let sourceFiles = target.sourceModule.flatMap(swiftFiles(in:)) else { return [] }

        let tool = try context.tool(named: "swiftformat")

        return try makeCommand(
            executable: tool,
            swiftFiles: sourceFiles,
            environment: [:],
            pluginWorkDirectory: context.pluginWorkDirectoryURL
        )
    }

    /// Collects the paths of the Swift files to be linted.
    private func swiftFiles(in target: SourceModuleTarget) -> [URL] {
        target
            .sourceFiles(withSuffix: "swift")
            .map(\.url)
    }

    private func makeCommand(
        executable: PluginContext.Tool,
        swiftFiles: [URL],
        environment: [String: String],
        pluginWorkDirectory path: URL
    ) throws -> [Command] {
        guard !swiftFiles.isEmpty else { return [] }

        let output = path.appending(path: "Output", directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: output, withIntermediateDirectories: true)

        let cache = output.appending(path: "Cache", directoryHint: .isDirectory)


        try FileManager.default.createDirectory(at: cache, withIntermediateDirectories: true)
        let arguments: [String] = [
            "--lint",
            "--lenient", // Do not fail the build, just warn
            "--cache",
            "\(cache.path(percentEncoded: false))"
        ]

        return [
            .prebuildCommand(
                displayName: "SwiftFormat Lint",
                executable: executable.url,
                arguments: arguments + swiftFiles.map { $0.path(percentEncoded: false) },
                environment: environment,
                outputFilesDirectory: output
            )
        ]
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension SwiftFormatLintBuildToolPlugin: XcodeBuildToolPlugin {
    /// Entry point for creating build commands for targets in Xcode projects.
    func createBuildCommands(context: XcodePluginContext, target: XcodeTarget) throws -> [Command] {
        let sourceFiles = swiftFiles(in: target)

        let tool = try context.tool(named: "swiftformat")

        // Construct a build command for each source file with a particular suffix.
        return try makeCommand(
            executable: tool,
            swiftFiles: sourceFiles,
            environment: [:],
            pluginWorkDirectory: context.pluginWorkDirectoryURL
        )
    }

    /// Collects the paths of the Swift files to be linted.
    private func swiftFiles(in target: XcodeTarget) -> [URL] {
        target
            .inputFiles
            .filter { $0.type == .source && $0.url.pathExtension == "swift" }
            .map(\.url)
    }
}

#endif
