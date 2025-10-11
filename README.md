# Kitchen Converter App

A native iOS app for converting cooking measurements and ingredient quantities, built with SwiftUI and SwiftData.

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
- Natural language ingredient names (e.g., "All-purpose flour" instead of "Flour, all-purpose")
- SwiftUI native interface with smooth animations
- SwiftData persistence with optimized database queries
- Conversion result caching for improved performance
- Comprehensive unit tests and UI tests

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
│   │   │   ├── Ingredient.swift      # SwiftData model
│   │   │   ├── UnitConversion.swift  # Conversion data model
│   │   │   └── MeasurementUnit.swift # Unit type definitions
│   │   ├── Views/
│   │   │   ├── IngredientListView.swift
│   │   │   ├── ConversionView.swift
│   │   │   └── IngredientEditorView.swift
│   │   ├── Services/
│   │   │   ├── ConversionEngine.swift          # BFS conversion logic
│   │   │   └── DefaultIngredientDatabase.swift # JSON loader
│   │   ├── Utilities/
│   │   │   └── FractionParser.swift            # Fraction input parsing
│   │   └── default_ingredients.json            # Pre-loaded data (95 ingredients)
│   ├── IngredientConverterTests/
│   └── IngredientConverterUITests/
├── IngredientConverterHelpers/       # Python data pipeline
│   ├── generate_ingredient_database.py  # Creates Excel template
│   ├── convert_ingredients.py           # Excel → JSON converter
│   ├── ingredient_database.xlsx         # Source data (editable)
│   └── default_ingredients.json         # Generated output
├── CLAUDE.md                         # Project documentation
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

# Edit ingredient_database.xlsx manually to add/verify conversions

# Convert Excel to JSON
python convert_ingredients.py ingredient_database.xlsx default_ingredients.json

# Copy JSON to app bundle
cp default_ingredients.json ../IngredientConverter/IngredientConverter/
```

### Excel Format

| Name | Category | Brand | From Amount | From Unit | ... | To Amount | To Unit | Verified | Notes |
|------|----------|-------|-------------|-----------|-----|-----------|---------|----------|-------|
| All-purpose flour | Flour | | 1 | cup | ... | 120 | gram | ✓ | King Arthur |

## Performance Optimizations

The app implements several performance optimizations:

1. **Database-level filtering**: Uses SwiftData predicates instead of in-memory filtering
2. **Unit caching**: Caches available units for selected ingredients
3. **Conversion caching**: Stores computed conversion ratios to avoid redundant calculations
4. **Efficient queries**: Minimizes database fetches with optimized FetchDescriptors

See [PERFORMANCE_OPTIMIZATION.md](PERFORMANCE_OPTIMIZATION.md) for detailed analysis.

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

- [ ] Add metric/imperial unit preferences
- [ ] Recipe scaling functionality
- [ ] Import/export custom ingredients
- [ ] iCloud sync for custom ingredients
- [ ] Ingredient photos/images
- [ ] Nutritional information integration
- [ ] Apple Watch companion app

## License

This project is private and not licensed for public use.

## Acknowledgments

- Conversion data verified against [King Arthur Baking](https://www.kingarthurbaking.com/learn/ingredient-weight-chart)
- USDA FoodData Central for ingredient reference data
- Built with assistance from [Claude Code](https://claude.com/claude-code)

---

**Version**: 1.0.0
**Target**: iOS 17.0+
**Swift**: 5.9+
