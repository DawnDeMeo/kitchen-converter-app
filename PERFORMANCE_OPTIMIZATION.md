# Performance Optimization Guide

This document outlines performance characteristics and optimization opportunities for the IngredientConverter app.

## Current Performance Status

### Good Aspects ✅
- Default ingredients loaded only once on first launch
- SwiftData handles persistence efficiently
- BFS graph search uses visited set to prevent infinite loops
- Foundation's `Measurement` API used for standard conversions (highly optimized)

### Areas for Optimization

---

## 1. List View Filtering/Sorting

**Location**: `IngredientListView.swift:52-95`

**Issue**: `filteredAndSortedIngredients` is a computed property that runs on every render.

```swift
var filteredAndSortedIngredients: [Ingredient] {
    var ingredients = allIngredients  // Copies entire array
    // Then filters, searches, and sorts...
}
```

**Performance Impact**:
- For 100 ingredients: minimal (< 1ms)
- For 1000+ ingredients: noticeable lag during typing in search

**Optimization Option 1**: Use @Query with predicates
```swift
// Instead of filtering in Swift, let SwiftData do it
@Query(filter: #Predicate<Ingredient> { ingredient in
    ingredient.isFavorite == true
}, sort: \Ingredient.name)
private var filteredIngredients: [Ingredient]
```

**Optimization Option 2**: Add memoization
```swift
@State private var cachedSortedIngredients: [Ingredient] = []

// Only recompute when dependencies change
```

---

## 2. Available Units Calculation

**Location**: `ConversionView.swift:202-219`

**Issue**: `availableUnits(for:)` is called in the view body and rebuilds the unit set every time.

```swift
private func availableUnits(for ingredient: Ingredient) -> [MeasurementUnit] {
    var units = Set<MeasurementUnit>()
    // Iterates through all conversions...
    // Adds all same-type units...
    return Array(units).sorted { ... }
}
```

**Performance Impact**: With 10+ conversions per ingredient, creates unnecessary overhead on every render.

**Optimization**:
```swift
// Add state variable to cache units
@State private var cachedAvailableUnits: [MeasurementUnit] = []

// Compute only when ingredient changes
.onChange(of: selectedIngredient) { _, newValue in
    if let ingredient = newValue {
        cachedAvailableUnits = computeAvailableUnits(for: ingredient)
    }
    // Reset other state...
    selectedFromUnit = nil
    selectedToUnit = nil
    conversionResult = nil
}

// Then use cachedAvailableUnits in the Picker instead of calling availableUnits(for:)
```

**Steps**:
1. Add `@State private var cachedAvailableUnits: [MeasurementUnit] = []`
2. Rename `availableUnits(for:)` to `computeAvailableUnits(for:)`
3. Call it in `.onChange(of: selectedIngredient)` and store result
4. Update Pickers to use `cachedAvailableUnits`

---

## 3. ConversionEngine Graph Search

**Location**: `ConversionEngine.swift:71-145`

**Issue**: BFS search is recursive and explores the entire conversion graph.

**Current Complexity**: O(V + E) where V = unique units, E = conversions
- With 10 conversions: ~10-20 operations
- Worst case (no path found): explores entire graph

**Performance Impact**: Generally fast (< 1ms), but could slow down with:
- Ingredients having 50+ conversions
- Deep conversion chains (5+ hops)

**Optimization**: Add conversion path caching
```swift
class ConversionEngine {
    // Add cache dictionary
    private var conversionCache: [String: Double] = [:]

    func convert(amount: Double, from: MeasurementUnit, to: MeasurementUnit,
                 for ingredient: Ingredient) -> Double? {

        // Create cache key (note: only cache if amount-independent)
        let cacheKey = "\(ingredient.id)-\(from)-\(to)"

        // For conversions that scale linearly, we can cache the ratio
        if let cachedRatio = conversionCache[cacheKey] {
            return amount * cachedRatio
        }

        // Existing logic...
        let result = /* existing conversion logic */

        // Cache the ratio for next time
        if let result = result {
            conversionCache[cacheKey] = result / amount
        }

        return result
    }

    // Add method to clear cache if needed
    func clearCache() {
        conversionCache.removeAll()
    }
}
```

**Alternative**: Convert recursive BFS to iterative with a queue (more memory efficient).

---

## 4. SwiftData Query Optimization

**Location**: `Ingredient.swift`, `IngredientListView.swift`

**Issue**: `@Query private var allIngredients: [Ingredient]` loads ALL ingredients into memory.

**Current State**: Fine for 100-500 ingredients, inefficient for larger databases.

**Optimization 1**: Add database indexes
```swift
// Note: @Attribute(.indexed) is NOT available in current SwiftData/iOS versions
// This optimization must wait for a future iOS update
// For now, rely on predicate-based filtering (Optimization 2)
```

**Optimization 2**: Use predicates in @Query (✅ IMPLEMENTED)
```swift
// Instead of filtering all ingredients in Swift
@Query private var allIngredients: [Ingredient]

// Use SwiftData predicates (when search text is known)
@Query(filter: #Predicate<Ingredient> { ingredient in
    ingredient.name.localizedStandardContains(searchText)
})
private var searchResults: [Ingredient]
```

**Note**: Dynamic predicates with search text require more complex setup. Start with indexes first.

---

## 5. FractionParser Performance (Minor)

**Location**: `ConversionView.swift:236-257`, `FractionParser.swift`

**Issue**: Parser is called on every keystroke during conversion.

**Performance Impact**: Negligible for typical usage (parser is fast).

**Optimization** (only if needed):
```swift
// Add debouncing to performConversion()
@State private var conversionTask: Task<Void, Never>?

private func performConversion() {
    // Cancel previous task
    conversionTask?.cancel()

    // Debounce by 200ms
    conversionTask = Task {
        try? await Task.sleep(nanoseconds: 200_000_000)
        guard !Task.isCancelled else { return }

        // Actual conversion logic...
    }
}
```

---

## Recommended Implementation Order

### High Priority (Do These First)
1. **✅ Use @Query predicates for filtering** (COMPLETED)
   - Moves filtering/sorting to database level
   - Estimated time: 30 minutes
   - Impact: Better performance with large datasets
   - Note: SwiftData indexes (`.indexed` attribute) are not available in current iOS version

2. **Cache available units in ConversionView**
   - Easy win, eliminates repeated computation
   - Estimated time: 10 minutes
   - Impact: Immediate UI responsiveness improvement

### Medium Priority
3. **Add conversion result caching**
   - Helps if users repeatedly convert same values
   - Estimated time: 20 minutes
   - Impact: Faster repeated conversions

### Low Priority (Only If Issues Arise)
5. **Debounce search input**
   - Only needed if lag is noticeable
   - Estimated time: 15 minutes
   - Impact: Smoother typing during search

6. **Lazy loading for very large lists**
   - Not needed for < 1000 ingredients
   - Estimated time: 1-2 hours
   - Impact: Handles massive datasets

---

## Performance Testing

Add these benchmarks to verify improvements:

### Test 1: Conversion Engine Speed
```swift
// In ConversionEngineTests.swift
func testConversionPerformance() {
    let ingredient = createTestIngredient()
    let engine = ConversionEngine()

    measure {
        _ = engine.convert(amount: 1, from: .cup, to: .gram, for: ingredient)
    }
}
```

### Test 2: List Filtering Speed
```swift
// In IngredientFilterTests.swift
func testFilterPerformance() {
    let ingredients = createLargeIngredientList(count: 1000)

    measure {
        let filtered = ingredients.filter { $0.name.contains("flour") }
    }
}
```

### Test 3: Available Units Calculation
```swift
// In ConversionView, temporary test
let start = Date()
let units = availableUnits(for: ingredient)
print("Available units took: \(Date().timeIntervalSince(start) * 1000)ms")
```

---

## Current Assessment

For the current scope (~100 default ingredients + user additions), **performance is likely already excellent**. The app should feel instant on modern iPhones.

The optimizations above become valuable when:
- You expand to 500+ ingredients
- Users experience any lag during search/conversion
- You want to prepare for scale
- You add more complex features (like search autocomplete)

---

## Monitoring Performance

Signs you need optimization:
- 🔴 Search typing feels laggy
- 🔴 List scrolling drops frames
- 🔴 Conversions take > 100ms
- 🔴 App launch takes > 2 seconds

You can use Xcode Instruments to profile:
- **Time Profiler**: Find hot spots in code
- **Allocations**: Track memory usage
- **Core Data** (SwiftData): Monitor fetch performance

---

## Questions to Consider

Before optimizing, ask:
1. Have users reported performance issues?
2. Does profiling show actual bottlenecks?
3. Will the optimization add complexity?

**Remember**: Premature optimization is the root of all evil. Start with measurements, then optimize what matters.
