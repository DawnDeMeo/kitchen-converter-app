#!/usr/bin/env python3
"""
Convert an Excel or CSV file of ingredients to the JSON format for IngredientConverter.

Excel/CSV Format:
- Column A: Ingredient Name
- Column B: Brand (optional, can be empty)
- Column C: From Amount
- Column D: From Unit
- Column E: From Unit Singular (only for count units, otherwise empty)
- Column F: From Unit Plural (only for count units, otherwise empty)
- Column G: To Amount
- Column H: To Unit
- Column I: To Unit Singular (only for count units, otherwise empty)
- Column J: To Unit Plural (only for count units, otherwise empty)

Each row represents one conversion. Multiple rows with the same ingredient name
will be grouped together.
"""

import pandas as pd
import json
import sys
from pathlib import Path


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

    # Read the file
    if input_file.endswith('.csv'):
        df = pd.read_csv(input_file)
    else:
        df = pd.read_excel(input_file)

    # Expected columns
    expected_cols = [
        'Name', 'Category', 'Brand',
        'From Amount', 'From Unit', 'From Unit Singular', 'From Unit Plural',
        'To Amount', 'To Unit', 'To Unit Singular', 'To Unit Plural'
    ]

    # Rename columns if they don't match (case-insensitive)
    df.columns = df.columns.str.strip()

    # Group by ingredient name
    ingredients = {}

    for _, row in df.iterrows():
        name = str(row['Name']).strip()
        category = str(row['Category']).strip() if pd.notna(row.get('Category')) and row.get('Category') else None
        brand = str(row['Brand']).strip() if pd.notna(row['Brand']) and row['Brand'] else None

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
        if name not in ingredients:
            ingredient_data = {
                "name": name,
                "conversions": []
            }
            if category:
                ingredient_data["category"] = category
            if brand:
                ingredient_data["brand"] = brand
            ingredients[name] = ingredient_data

        ingredients[name]["conversions"].append(conversion)

    # Convert to list
    ingredients_list = list(ingredients.values())

    # Create output JSON
    output = {
        "ingredients": ingredients_list
    }

    # Determine output filename
    if output_file is None:
        output_file = Path(input_file).stem + '.json'

    # Write to file
    with open(output_file, 'w') as f:
        json.dump(output, f, indent=2)

    print(f"✓ Converted {len(ingredients_list)} ingredients")
    print(f"✓ Output written to: {output_file}")

    return output_file


def create_sample_excel():
    """Create a sample Excel file showing the expected format."""
    data = {
        'Name': [
            'Flour, all-purpose, sifted',
            'Flour, all-purpose, sifted',
            'Sugar, granulated',
            'Eggs, large',
            'Graham crackers'
        ],
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

    df = pd.DataFrame(data)
    df.to_excel('sample_ingredients.xlsx', index=False)
    print("✓ Created sample_ingredients.xlsx")
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