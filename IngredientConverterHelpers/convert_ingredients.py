#!/usr/bin/env python3
"""
Convert an Excel or CSV file of ingredients to the JSON format for IngredientConverter.

Excel/CSV Format:
- Column A: ID (stable identifier, recommended: UUID)
- Column B: Ingredient Name
- Column C: Category (optional)
- Column D: Brand (optional, can be empty)
- Column E: From Amount
- Column F: From Unit
- Column G: From Unit Singular (only for count units, otherwise empty)
- Column H: From Unit Plural (only for count units, otherwise empty)
- Column I: To Amount
- Column J: To Unit
- Column K: To Unit Singular (only for count units, otherwise empty)
- Column L: To Unit Plural (only for count units, otherwise empty)

Each row represents one conversion. Multiple rows with the same ID/name
will be grouped together. The ID allows tracking ingredients across name changes.
"""

import pandas as pd
import json
import sys
from pathlib import Path


def get_current_version(output_file):
    """Get the current version from an existing JSON file, or 0 if not present."""
    output_path = Path(output_file)

    if not output_path.exists():
        return 0

    try:
        with open(output_path, 'r') as f:
            data = json.load(f)
            # Check if version exists in the JSON
            if 'version' in data:
                return data['version']
            else:
                # No version found, treat as version 0
                return 0
    except (json.JSONDecodeError, IOError):
        # If file can't be read or parsed, start from version 0
        return 0


def parse_unit(unit_str, singular=None, plural=None):
    """Parse a unit string into the appropriate JSON format."""
    unit_str = str(unit_str).strip() if pd.notna(unit_str) else ""

    # Check if it's a count unit
    if pd.notna(singular) and pd.notna(plural):
        return {
            "count": {
                "singular": str(singular).strip(),
                "plural": str(plural).strip()
            }
        }

    # Return simple unit string
    return unit_str.lower()


def convert_to_json(input_file, output_file=None):
    """Convert Excel/CSV file to JSON format."""

    # Determine output filename early (so we can check for existing version)
    if output_file is None:
        output_file = Path(input_file).stem + '.json'

    # Get current version and increment it
    current_version = get_current_version(output_file)
    new_version = current_version + 1

    print(f"📊 Version: {current_version} → {new_version}")

    # Read the file
    if input_file.endswith('.csv'):
        df = pd.read_csv(input_file)
    else:
        df = pd.read_excel(input_file)

    # Expected columns
    expected_cols = [
        'ID', 'Name', 'Category', 'Brand',
        'From Amount', 'From Unit', 'From Unit Singular', 'From Unit Plural',
        'To Amount', 'To Unit', 'To Unit Singular', 'To Unit Plural'
    ]

    # Rename columns if they don't match (case-insensitive)
    df.columns = df.columns.str.strip()

    # Group by ingredient ID (or name if no ID)
    ingredients = {}

    for _, row in df.iterrows():
        # Get ID if present, otherwise use name as fallback
        ingredient_id = str(row['ID']).strip() if pd.notna(row.get('ID')) and row.get('ID') else None
        name = str(row['Name']).strip()
        category = str(row['Category']).strip() if pd.notna(row.get('Category')) and row.get('Category') else None
        brand = str(row['Brand']).strip() if pd.notna(row['Brand']) and row['Brand'] else None

        # Use ID as key if available, otherwise use name
        key = ingredient_id if ingredient_id else name

        # Create conversion
        from_unit = parse_unit(
            row['From Unit'],
            row.get('From Unit Singular'),
            row.get('From Unit Plural')
        )

        to_unit = parse_unit(
            row['To Unit'],
            row.get('To Unit Singular'),
            row.get('To Unit Plural')
        )

        conversion = {
            "fromAmount": float(row['From Amount']),
            "fromUnit": from_unit,
            "toAmount": float(row['To Amount']),
            "toUnit": to_unit
        }

        # Add to ingredients dict
        if key not in ingredients:
            ingredient_data = {
                "name": name,
                "conversions": []
            }
            # Add ID if present
            if ingredient_id:
                ingredient_data["id"] = ingredient_id
            if category:
                ingredient_data["category"] = category
            if brand:
                ingredient_data["brand"] = brand
            ingredients[key] = ingredient_data

        ingredients[key]["conversions"].append(conversion)

    # Convert to list
    ingredients_list = list(ingredients.values())

    # Create output JSON with version
    output = {
        "version": new_version,
        "ingredients": ingredients_list
    }

    # Write to file
    with open(output_file, 'w') as f:
        json.dump(output, f, indent=2)

    print(f"✓ Converted {len(ingredients_list)} ingredients")
    print(f"✓ Output written to: {output_file}")

    return output_file


def create_sample_excel():
    """Create a sample Excel file showing the expected format."""
    import uuid

    data = {
        'ID': [
            str(uuid.uuid4()),  # Unique ID for all-purpose flour
            str(uuid.uuid4()),  # Unique ID for all-purpose flour (same ingredient, different conversion)
            str(uuid.uuid4()),  # Unique ID for sugar
            str(uuid.uuid4()),  # Unique ID for eggs
            str(uuid.uuid4())   # Unique ID for graham crackers
        ],
        'Name': [
            'Flour, all-purpose, sifted',
            'Flour, all-purpose, sifted',
            'Sugar, granulated',
            'Eggs, large',
            'Graham crackers'
        ],
        'Category': ['Flour', 'Flour', 'Sugar', 'Egg', 'Baking'],
        'Brand': [None, None, None, None, None],
        'From Amount': [1, 1, 1, 1, 8],
        'From Unit': ['cup', 'tablespoon', 'cup', '', ''],
        'From Unit Singular': ['', '', '', 'egg', 'cracker'],
        'From Unit Plural': ['', '', '', 'eggs', 'crackers'],
        'To Amount': [120, 7.5, 200, 50, 30],
        'To Unit': ['gram', 'gram', 'gram', 'gram', 'gram'],
        'To Unit Singular': ['', '', '', '', ''],
        'To Unit Plural': ['', '', '', '', '']
    }

    # Use same ID for flour conversions (they're the same ingredient)
    data['ID'][1] = data['ID'][0]

    df = pd.DataFrame(data)
    df.to_excel('sample_ingredients.xlsx', index=False)
    print("✓ Created sample_ingredients.xlsx")
    print("  Note: Rows with the same ID will be grouped as one ingredient")
    print("  Edit this file and run: python convert_ingredients.py sample_ingredients.xlsx")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage:")
        print("  python convert_ingredients.py <input_file.xlsx|csv> [output_file.json]")
        print("  python convert_ingredients.py --sample  (creates sample Excel file)")
        sys.exit(1)

    if sys.argv[1] == '--sample':
        create_sample_excel()
    else:
        input_file = sys.argv[1]
        output_file = sys.argv[2] if len(sys.argv) > 2 else None
        convert_to_json(input_file, output_file)