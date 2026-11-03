# swift-async-fanout

Use this package when you have an array of independent items and want to run the same work over each of them concurrently, with a fixed cap on how many run at once, and get the results back as an array. Start from `Async.Fanout`: build it with the cap as `jobs`, then call `map` for synchronous work or `mapAsync` for async work.

## Laws

- The cap is never below one: asking for zero or a negative `jobs` gives one.
- At most `jobs` items are in flight at once. Items start in input order, and a new one starts only when a running one finishes.
- Every item is processed exactly once, and the result array is in input order whatever order the work finishes in.
- `completed` is called once per finished item, one call at a time, with the running count of finished items, so it sees exactly 1 through the item count in increasing order. It counts completions, not item positions.
- An empty input runs no work and never calls `completed`.
