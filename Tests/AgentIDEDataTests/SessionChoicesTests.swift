@testable import AgentIDEData
import Foundation
import Testing

/// What the app publishes for the `agentide` command, which cannot
/// read Settings and so trusts this file for where things live.
struct SessionChoicesTests {
    // MARK: Internal

    @Test
    func `publishing the default directories replaces an override that was cleared`() async throws {
        let world = try await World.make()
        defer { world.tearDown() }
        world.service.publishSessionChoices([
            ("repositories-directory", "/Users/Shared/custom/projects"),
            ("worktrees-directory", "/Users/Shared/custom/trees"),
            ("agent", "codex"),
        ])

        world.service.publishSessionChoices(world.service.locationChoices)

        let published = try Self.published(world)
        #expect(published.contains("repositories-directory=" + world.paths.sharedWorkspace + "/repositories"))
        #expect(published.contains("worktrees-directory=" + world.paths.sharedWorkspace + "/worktrees"))
        #expect(published.contains("custom") == false)
        #expect(published.contains("agent=codex"))
    }

    @Test
    func `a directory holding a newline is left out rather than split`() async throws {
        let world = try await World.make()
        defer { world.tearDown() }
        world.service.publishSessionChoices([("repositories-directory", "/Users/Shared/old")])

        world.service.publishSessionChoices([("repositories-directory", "/Users/Shared/two\nlines")])

        let published = try Self.published(world)
        #expect(published.contains("repositories-directory") == false)
        #expect(published.contains("lines") == false)
    }

    // MARK: Private

    private static func published(_ world: World) throws -> String {
        try String(contentsOfFile: world.paths.agentideDirectory + "/session-defaults", encoding: .utf8)
    }
}
