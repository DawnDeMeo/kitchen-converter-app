# Kitchen Converter App

A native iOS app for converting cooking measurements and ingredient quantities, built with SwiftUI and SwiftData.

**Key Differentiators**: Ingredient-specific conversions with intelligent chained pathfinding, custom fraction keyboard, 5 beautiful themes with full accessibility support, and a curated database of 95+ verified conversions.

## Features

### Core Functionality
- **Unit Conversions**: Convert between volume (cups, tablespoons, teaspoons, liters, etc.) and weight (grams, ounces, pounds, etc.)
- **Ingredient-Specific Conversions**: Accurate conversions based on ingredient density and properties
- **Chained Conversions**: Automatically finds conversion paths between units using graph-based pathfinding
- **Fraction Support**: Natural input of fractions (e.g., "1/2", "2 1/4") with intelligent parsing

### Ingredient Management
- **95 Curated Ingredients**: Pre-loaded database with verified conversions for common baking and cooking ingredients
- **Custom Ingredients**: Create and save your own ingredients with custom conversions
- **14 Categories**: Organized by type (Flour, Sugar, Dairy, Fat, Baking, Spices, etc.)
- **Favorites**: Mark frequently used ingredients for quick access
- **Search**: Fast, fuzzy search across ingredient names and brands

### Filtering & Sorting
- Filter by: All, Favorites, Custom, or Default ingredients
- Filter by Category: Baking, Chocolate, Dairy, Dried Fruit, Egg, Fat, Flour, Fruit, Grain, Nut, Other, Spice, Sugar, Vegetable
- Sort by: Alphabetical or Last Used
- Real-time search with combined filtering

### User Experience
- **Custom Numeric Keyboard**: Specialized keyboard with quick-insert fraction buttons (1/8, 1/4, 1/3, 1/2, 2/3, 3/4)
- **Theming System**: 5 beautiful color schemes (Blue Crab, Cayenne, Lavender, Salt & Pepper, Sage)
- **Light/Dark Mode**: Full adaptive color support with automatic or manual appearance switching
- **Natural Language**: Ingredient names use natural phrasing (e.g., "All-purpose flour" instead of "Flour, all-purpose")
- SwiftUI native interface with smooth animations
- SwiftData persistence with optimized database queries
- Conversion result caching for improved performance
- Comprehensive unit tests and UI tests

### Accessibility
- **Enhanced VoiceOver**: Natural-sounding labels for all interactive elements
- **Fraction Announcements**: Smooth reading of fractions (e.g., "one and one half cups equals one hundred eighty grams")
- **Accessibility Hints**: Context-aware hints throughout the interface
- Full keyboard navigation support
- Dynamic type support for text scaling

## Tech Stack

- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Persistence**: SwiftData (iOS 17+)
- **Architecture**: MVVM with reactive state management
- **Testing**: XCTest
- **Data Pipeline**: Python 3.x (pandas, openpyxl)

## Project Structure

```
kitchen-converter-app/
├── IngredientConverter/              # iOS app
│   ├── IngredientConverter.xcodeproj
│   ├── IngredientConverter/          # Source code
│   │   ├── Models/
│   │   │   ├── Ingredient.swift          # SwiftData ingredient model
│   │   │   ├── UnitConversion.swift      # Conversion data model
│   │   │   ├── MeasurementUnit.swift     # Unit type definitions
│   │   │   └── IngredientJSONModels.swift # JSON parsing models
│   │   ├── Views/
│   │   │   ├── ContentView.swift         # Main tab navigation
│   │   │   ├── IngredientListView.swift  # Searchable ingredient list
│   │   │   ├── IngredientRowView.swift   # Reusable list row
│   │   │   ├── ConversionView.swift      # Conversion interface
│   │   │   ├── IngredientEditorView.swift # Add/edit ingredients
│   │   │   ├── ConversionEditorSheet.swift # Conversion editor
│   │   │   ├── CustomNumericKeyboard.swift # Fraction-friendly keyboard
│   │   │   ├── UnitPickerSheet.swift     # Unit selection sheet
│   │   │   ├── SettingsView.swift        # App settings & themes
│   │   │   ├── HelpView.swift            # In-app help
│   │   │   └── ColorSchemePreviewView.swift # Theme testing (dev only)
│   │   ├── Services/
│   │   │   ├── ConversionEngine.swift    # BFS conversion logic
│   │   │   ├── DefaultIngredientDatabase.swift # JSON loader
│   │   │   └── CloudKitHelper.swift      # CloudKit integration
│   │   ├── Utilities/
│   │   │   ├── FractionParser.swift      # Fraction parsing & VoiceOver
│   │   │   ├── UnitConversionHelper.swift # Foundation Measurement wrapper
│   │   │   ├── AppColorScheme.swift      # Theme color definitions
│   │   │   ├── ThemeManager.swift        # Theme management
│   │   │   ├── FractionInputHelper.swift # Fraction input utilities
│   │   │   ├── DebugLogger.swift         # Debug logging
│   │   │   └── UtilitiesFormValidation.swift # Form validation
│   │   └── default_ingredients.json      # Pre-loaded data (95 ingredients)
│   ├── IngredientConverterTests/
│   │   ├── ConversionEngineTests.swift
│   │   ├── DefaultIngredientDatabaseTests.swift
│   │   ├── FractionParserTests.swift
│   │   ├── MeasurementUnitTests.swift
│   │   └── ConversionEdgeCaseTests.swift
│   └── IngredientConverterUITests/
├── IngredientConverterHelpers/       # Python data pipeline
│   ├── generate_ingredient_database.py  # Creates Excel template
│   ├── convert_ingredients.py           # Excel → JSON converter
│   ├── ingredient_database.xlsx         # Source data (editable)
│   └── default_ingredients.json         # Generated output
├── CLAUDE.md                         # Project documentation for AI
├── PERFORMANCE_OPTIMIZATION.md       # Optimization notes
└── README.md

```

## Getting Started

### Prerequisites

- Xcode 15.0 or later
- iOS 17.0+ (for SwiftData)
- Python 3.8+ (for data pipeline, optional)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/DawnDeMeo/kitchen-converter-app.git
   cd kitchen-converter-app
   ```

2. Open the Xcode project:
   ```bash
   open IngredientConverter/IngredientConverter.xcodeproj
   ```

3. Build and run:
   - Select a target device or simulator
   - Press `Cmd + R` to build and run

### Running Tests

```bash
# From command line
cd IngredientConverter
xcodebuild test -scheme IngredientConverter -destination 'platform=iOS Simulator,name=iPhone 15'

# Or in Xcode: Cmd + U
```

## Data Pipeline

The app includes a Python-based data pipeline for managing the ingredient database:

### Setup Python Environment

```bash
cd IngredientConverterHelpers
python3 -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate
pip install pandas openpyxl
```

### Generate Ingredient Database

```bash
# Create Excel template with sample ingredients
python generate_ingredient_database.py

# Edit ingredient_database.xlsx manually:
# - Add UUID to the ID column for each unique ingredient
# - Verify/adjust conversions
# - Add notes and verification marks

# Convert Excel to JSON
python convert_ingredients.py ingredient_database.xlsx default_ingredients.json

# Copy JSON to app bundle
cp default_ingredients.json ../IngredientConverter/IngredientConverter/
```

**Note**: The `generate_ingredient_database.py` script creates the basic structure without IDs. You'll need to add a UUID to the ID column for each unique ingredient before converting to JSON. Rows with the same ID will be grouped as one ingredient with multiple conversions.

**Tip**: To see a properly formatted example with IDs, run:
```bash
python convert_ingredients.py --sample
```
This creates `sample_ingredients.xlsx` showing the correct format with UUIDs.

### Excel Format

The Excel file uses the following column structure:

| ID | Name | Category | Brand | From Amount | From Unit | From Unit Singular | From Unit Plural | To Amount | To Unit | To Unit Singular | To Unit Plural | Verified | Notes |
|----|------|----------|-------|-------------|-----------|-------------------|-----------------|-----------|---------|-----------------|----------------|----------|-------|
| uuid-123... | All-purpose flour | Flour | | 1 | cup | | | 120 | gram | | | ✓ | King Arthur |
| uuid-123... | All-purpose flour | Flour | | 1 | tablespoon | | | 7.5 | gram | | | ✓ | |
| uuid-456... | Butter | Fat | | 1 | | stick | sticks | 113 | gram | | | ✓ | |

**Notes:**
- **ID**: UUID to track ingredients across name changes (rows with same ID are grouped)
- **Singular/Plural columns**: Only used for count-based units (eggs, sticks, cloves, etc.)
- **Verified/Notes**: Manual review columns (not imported to app)

## Performance Optimizations

The app implements several performance optimizations:

1. **Database-level filtering**: Uses SwiftData predicates instead of in-memory filtering
2. **Unit caching**: Caches available units for selected ingredients to avoid recomputation on every render
3. **Conversion caching**: Stores computed conversion ratios to avoid redundant calculations
4. **Efficient queries**: Minimizes database fetches with optimized FetchDescriptors
5. **Minimal logging**: Debug logging removed from production paths for faster execution
6. **Smart view updates**: Optimized state management to prevent unnecessary re-renders

See [PERFORMANCE_OPTIMIZATION.md](PERFORMANCE_OPTIMIZATION.md) for detailed analysis and benchmarks.

## Architecture Highlights

### Conversion Engine

Uses **Breadth-First Search (BFS)** to find conversion paths between units:
- Direct conversions: `1 cup flour = 120g`
- Chained conversions: `1 cup → 120g → 4.23oz`
- Supports complex ingredient-specific conversion graphs

### Data Model

```swift
@Model
class Ingredient {
    var id: UUID
    var name: String
    var category: String?
    var brand: String?
    var isFavorite: Bool
    var isCustom: Bool
    var lastUsedDate: Date?
    @Relationship(deleteRule: .cascade) var conversions: [UnitConversion]
}
```

## Contributing

This is a personal project, but suggestions and feedback are welcome! Please open an issue to discuss potential changes.

## Roadmap

### Completed ✅
- [x] Theming system with multiple color schemes
- [x] Light/Dark mode support
- [x] Custom numeric keyboard for fractions
- [x] Enhanced VoiceOver accessibility
- [x] Performance optimizations

### In Progress
- [ ] iCloud sync for custom ingredients (CloudKit integration in development)

### Planned
- [ ] Recipe scaling functionality
- [ ] Import/export custom ingredients
- [ ] Ingredient photos/images
- [ ] Nutritional information integration
- [ ] Apple Watch companion app
- [ ] Widget support for recent conversions

## License

This project is private and not licensed for public use.

## Acknowledgments

- Conversion data verified against [King Arthur Baking](https://www.kingarthurbaking.com/learn/ingredient-weight-chart)
- USDA FoodData Central for ingredient reference data
- Built with assistance from [Claude Code](https://claude.com/claude-code)

---

**Version**: 1.2.0
**Target**: iOS 17.0+
**Swift**: 5.9+
**Last Updated**: October 2025
