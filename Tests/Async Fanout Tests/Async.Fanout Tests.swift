import Async_Fanout
import Async
import Synchronization
import Testing

@Suite
struct `Async fanout bounds concurrent work and preserves result order` {
    @Suite struct `Fanout operations preserve their basic behavior` {}
    @Suite struct `Fanout operations preserve boundary behavior` {}
    @Suite struct `Fanout operations compose with their dependencies` {}
}

extension `Async fanout bounds concurrent work and preserves result order`.`Fanout operations preserve their basic behavior` {

    @Test
    func `Results come back in input order however the work completes`() async {
        let items = Array(0..<24)

        let results = await Async.Fanout(jobs: 24).mapAsync(items) { item in

            try? await Task.sleep(for: .milliseconds(5 * (24 - item)))
            return item
        }

        #expect(results == items)
    }

    @Test
    func `Every item is measured, and none twice, when the bound is below the population`() async {
        let items = Array(0..<200)

        let results = await Async.Fanout(jobs: 4).map(items) { $0 * 2 }

        #expect(results == items.map { $0 * 2 })
    }

    @Test
    func `Completion is reported once per item, counting up to the population`() async {
        let counts = Counts()

        _ = await Async.Fanout(jobs: 6).map(
            Array(0..<50),
            completed: { counts.record($0) },
            { $0 }
        )

        #expect(counts.observed == Array(1...50))
    }
}

extension `Async fanout bounds concurrent work and preserves result order`.`Fanout operations preserve boundary behavior` {

    @Test
    func `An empty population runs nothing and reports nothing`() async {
        let counts = Counts()

        let results = await Async.Fanout(jobs: 4).map(
            [Swift.Int](),
            completed: { counts.record($0) },
            { $0 }
        )

        #expect(results.isEmpty)
        #expect(counts.observed.isEmpty)
    }

    @Test
    func `The bound is at least one, whatever it is asked for`() {
        #expect(Async.Fanout(jobs: 0).jobs == 1)
        #expect(Async.Fanout(jobs: -8).jobs == 1)
        #expect(Async.Fanout(jobs: 3).jobs == 3)
    }
}

private final class Counts: Sendable {
    private let storage = Mutex([Swift.Int]())
}

extension Counts {
    func record(_ count: Swift.Int) {
        storage.withLock { $0.append(count) }
    }

    var observed: [Swift.Int] {
        storage.withLock { $0 }
    }
}
