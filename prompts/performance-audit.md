# Performance Audit -- Thinking Framework

Apply this framework to investigate and resolve performance problems. Measure first, optimize second.

## 1. Baseline Metrics

Establish what you are measuring before changing anything:
- Define the specific metric: response time (p50, p95, p99), Time to Interactive, Largest Contentful Paint, memory usage, query count, or throughput?
- Measure under realistic conditions: production-like data volume, concurrent users, cold vs warm cache
- Record the current numbers. Without a baseline, you cannot prove improvement.
- Identify the target: what number would make this "fast enough"? Define the SLA.

Do not optimize without a measurable goal.

## 2. Profiling

Identify where time and resources are actually spent:
- **Server:** Use profiling tools (flame graphs, query analyzers, APM traces) to find the slowest operations
- **Client:** Use browser DevTools Performance tab, Lighthouse, or React Profiler to find rendering bottlenecks
- **Network:** Inspect the waterfall in DevTools Network tab -- sequential requests, large payloads, missing compression
- **Database:** Run EXPLAIN on slow queries, check for sequential scans, missing indexes, lock contention

Profile the actual slow path. Do not guess based on code reading alone.

## 3. Bottleneck Identification

From profiling data, identify the top 3 bottlenecks by impact:

For each bottleneck, document:
- What operation is slow and where in the code it occurs
- How much of total time/resources it consumes (percentage)
- Why it is slow (algorithmic complexity, I/O wait, contention, payload size)
- Whether it is on the critical path or can be deferred

Focus on the critical path. A slow background job may not matter.

## 4. Optimization Options

For each bottleneck, enumerate approaches with effort-vs-impact analysis:

Consider these categories:
- **Eliminate:** Can the work be avoided entirely? (unnecessary queries, redundant computations, dead code paths)
- **Cache:** Can the result be reused? (HTTP caching, memoization, materialized views, CDN)
- **Defer:** Can it happen later? (lazy loading, background processing, streaming)
- **Parallelize:** Can it happen concurrently? (Promise.all, worker threads, concurrent queries)
- **Reduce:** Can the amount of work be reduced? (pagination, projection, compression, smaller payloads)
- **Optimize:** Can the algorithm be improved? (better data structure, index, batch operation)

Rate each option: effort (hours/days/weeks) vs expected improvement (percentage).

## 5. Implementation Priority

Order optimizations by value:
1. Quick wins: low effort, meaningful impact (caching, removing N+1, adding an index)
2. High-impact investments: significant effort, large improvement (architectural change, new caching layer)
3. Diminishing returns: skip unless the target SLA demands it

Implement one optimization at a time. Measure after each change.

## 6. Verification

After each optimization:
- Re-measure using the same methodology as the baseline
- Compare against the target SLA
- Check for regressions in correctness (does the optimization change behavior?)
- Check for regressions in other performance dimensions (faster response but higher memory?)
- Load test to verify the improvement holds under realistic concurrency
- Document the before/after numbers for future reference
