#!/usr/bin/env python3
"""
Generate a curated ingredient database for IngredientConverter app.
Creates an Excel file with the 100 most essential cooking ingredients.

IMPORTANT: These conversions should be verified against authoritative sources
such as King Arthur Baking (kingarthurbaking.com/learn/ingredient-weight-chart)
or USDA FoodData Central before use in production.
"""

import pandas as pd


def create_ingredient_database():
    """Create a database with the 100 most essential cooking ingredients."""

    data = []

    # FLOURS (10 ingredients, 10 conversions)
    flours = [
        ("All-purpose flour", "Flour", None, 1, "cup", None, None, 120, "gram", None, None),
        ("All-purpose flour", "Flour", None, 1, "tablespoon", None, None, 8, "gram", None, None),
        ("Bread flour", "Flour", None, 1, "cup", None, None, 127, "gram", None, None),
        ("Cake flour", "Flour", None, 1, "cup", None, None, 114, "gram", None, None),
        ("Whole wheat flour", "Flour", None, 1, "cup", None, None, 120, "gram", None, None),
        ("Self-rising flour", "Flour", None, 1, "cup", None, None, 125, "gram", None, None),
        ("Almond flour", "Flour", None, 1, "cup", None, None, 96, "gram", None, None),
        ("Coconut flour", "Flour", None, 1, "cup", None, None, 112, "gram", None, None),
        ("Rice flour", "Flour", None, 1, "cup", None, None, 158, "gram", None, None),
        ("Cornmeal", "Flour", None, 1, "cup", None, None, 138, "gram", None, None),
    ]

    # SUGARS & SWEETENERS (10 ingredients, 14 conversions)
    sugars = [
        ("Granulated sugar", "Sugar", None, 1, "cup", None, None, 200, "gram", None, None),
        ("Granulated sugar", "Sugar", None, 1, "tablespoon", None, None, 12.5, "gram", None, None),
        ("Granulated sugar", "Sugar", None, 1, "teaspoon", None, None, 4, "gram", None, None),
        ("Brown sugar, packed", "Sugar", None, 1, "cup", None, None, 220, "gram", None, None),
        ("Brown sugar, packed", "Sugar", None, 1, "tablespoon", None, None, 14, "gram", None, None),
        ("Powdered sugar", "Sugar", None, 1, "cup", None, None, 120, "gram", None, None),
        ("Powdered sugar", "Sugar", None, 1, "tablespoon", None, None, 8, "gram", None, None),
        ("Honey", "Sugar", None, 1, "cup", None, None, 340, "gram", None, None),
        ("Honey", "Sugar", None, 1, "tablespoon", None, None, 21, "gram", None, None),
        ("Maple syrup", "Sugar", None, 1, "cup", None, None, 322, "gram", None, None),
        ("Maple syrup", "Sugar", None, 1, "tablespoon", None, None, 20, "gram", None, None),
        ("Corn syrup", "Sugar", None, 1, "cup", None, None, 328, "gram", None, None),
        ("Molasses", "Sugar", None, 1, "cup", None, None, 337, "gram", None, None),
        ("Molasses", "Sugar", None, 1, "tablespoon", None, None, 21, "gram", None, None),
    ]

    # FATS (8 ingredients, 11 conversions)
    fats = [
        ("Butter", "Fat", None, 1, "cup", None, None, 227, "gram", None, None),
        ("Butter", "Fat", None, 1, "tablespoon", None, None, 14, "gram", None, None),
        ("Butter", "Fat", None, 1, "teaspoon", None, None, 5, "gram", None, None),
        ("Butter", "Fat", None, 1, None, "stick", "sticks", 113, "gram", None, None),
        ("Vegetable oil", "Fat", None, 1, "cup", None, None, 218, "gram", None, None),
        ("Vegetable oil", "Fat", None, 1, "tablespoon", None, None, 14, "gram", None, None),
        ("Olive oil", "Fat", None, 1, "cup", None, None, 216, "gram", None, None),
        ("Olive oil", "Fat", None, 1, "tablespoon", None, None, 14, "gram", None, None),
        ("Coconut oil", "Fat", None, 1, "cup", None, None, 218, "gram", None, None),
        ("Shortening", "Fat", None, 1, "cup", None, None, 191, "gram", None, None),
        ("Lard", "Fat", None, 1, "cup", None, None, 205, "gram", None, None),
    ]

    # DAIRY (14 ingredients, 14 conversions)
    dairy = [
        ("Whole milk", "Dairy", None, 1, "cup", None, None, 244, "gram", None, None),
        ("Whole milk", "Dairy", None, 1, "tablespoon", None, None, 15, "gram", None, None),
        ("Heavy cream", "Dairy", None, 1, "cup", None, None, 238, "gram", None, None),
        ("Heavy cream", "Dairy", None, 1, "tablespoon", None, None, 15, "gram", None, None),
        ("Sour cream", "Dairy", None, 1, "cup", None, None, 230, "gram", None, None),
        ("Plain yogurt", "Dairy", None, 1, "cup", None, None, 245, "gram", None, None),
        ("Greek yogurt", "Dairy", None, 1, "cup", None, None, 280, "gram", None, None),
        ("Buttermilk", "Dairy", None, 1, "cup", None, None, 245, "gram", None, None),
        ("Cream cheese", "Dairy", None, 1, "cup", None, None, 232, "gram", None, None),
        ("Cream cheese", "Dairy", None, 1, "tablespoon", None, None, 14.5, "gram", None, None),
        ("Ricotta cheese", "Dairy", None, 1, "cup", None, None, 246, "gram", None, None),
        ("Grated parmesan", "Dairy", None, 1, "cup", None, None, 100, "gram", None, None),
        ("Shredded cheddar", "Dairy", None, 1, "cup", None, None, 113, "gram", None, None),
        ("Shredded mozzarella", "Dairy", None, 1, "cup", None, None, 112, "gram", None, None),
    ]

    # BAKING ESSENTIALS (8 ingredients, 10 conversions)
    baking = [
        ("Baking powder", "Baking", None, 1, "tablespoon", None, None, 14, "gram", None, None),
        ("Baking powder", "Baking", None, 1, "teaspoon", None, None, 5, "gram", None, None),
        ("Baking soda", "Baking", None, 1, "tablespoon", None, None, 18, "gram", None, None),
        ("Baking soda", "Baking", None, 1, "teaspoon", None, None, 6, "gram", None, None),
        ("Active dry yeast", "Baking", None, 1, "tablespoon", None, None, 9, "gram", None, None),
        ("Cornstarch", "Baking", None, 1, "cup", None, None, 128, "gram", None, None),
        ("Cornstarch", "Baking", None, 1, "tablespoon", None, None, 8, "gram", None, None),
        ("Vanilla extract", "Baking", None, 1, "teaspoon", None, None, 4, "gram", None, None),
        ("Cream of tartar", "Baking", None, 1, "teaspoon", None, None, 3, "gram", None, None),
        ("Powdered gelatin", "Baking", None, 1, "tablespoon", None, None, 10, "gram", None, None),
    ]

    # CHOCOLATE & COCOA (3 ingredients, 3 conversions)
    chocolate = [
        ("Cocoa powder", "Chocolate", None, 1, "cup", None, None, 100, "gram", None, None),
        ("Cocoa powder", "Chocolate", None, 1, "tablespoon", None, None, 6, "gram", None, None),
        ("Chocolate chips", "Chocolate", None, 1, "cup", None, None, 170, "gram", None, None),
        ("Chopped chocolate", "Chocolate", None, 1, "cup", None, None, 150, "gram", None, None),
    ]

    # NUTS (10 ingredients, 10 conversions)
    nuts = [
        ("Whole almonds", "Nut", None, 1, "cup", None, None, 143, "gram", None, None),
        ("Sliced almonds", "Nut", None, 1, "cup", None, None, 92, "gram", None, None),
        ("Chopped walnuts", "Nut", None, 1, "cup", None, None, 120, "gram", None, None),
        ("Walnut halves", "Nut", None, 1, "cup", None, None, 100, "gram", None, None),
        ("Chopped pecans", "Nut", None, 1, "cup", None, None, 120, "gram", None, None),
        ("Cashews", "Nut", None, 1, "cup", None, None, 130, "gram", None, None),
        ("Peanuts", "Nut", None, 1, "cup", None, None, 146, "gram", None, None),
        ("Peanut butter", "Nut", None, 1, "cup", None, None, 258, "gram", None, None),
        ("Peanut butter", "Nut", None, 1, "tablespoon", None, None, 16, "gram", None, None),
        ("Sunflower seeds", "Nut", None, 1, "cup", None, None, 140, "gram", None, None),
    ]

    # GRAINS & PASTA (7 ingredients, 7 conversions)
    grains = [
        ("White rice, uncooked", "Grain", None, 1, "cup", None, None, 185, "gram", None, None),
        ("Brown rice, uncooked", "Grain", None, 1, "cup", None, None, 190, "gram", None, None),
        ("Rolled oats", "Grain", None, 1, "cup", None, None, 90, "gram", None, None),
        ("Quinoa, uncooked", "Grain", None, 1, "cup", None, None, 170, "gram", None, None),
        ("Dry breadcrumbs", "Grain", None, 1, "cup", None, None, 108, "gram", None, None),
        ("Fresh breadcrumbs", "Grain", None, 1, "cup", None, None, 45, "gram", None, None),
        ("Panko breadcrumbs", "Grain", None, 1, "cup", None, None, 50, "gram", None, None),
    ]

    # DRIED FRUITS (4 ingredients, 4 conversions)
    dried_fruits = [
        ("Raisins", "Dried Fruit", None, 1, "cup", None, None, 165, "gram", None, None),
        ("Chopped dates", "Dried Fruit", None, 1, "cup", None, None, 147, "gram", None, None),
        ("Dried cranberries", "Dried Fruit", None, 1, "cup", None, None, 120, "gram", None, None),
        ("Dried apricots", "Dried Fruit", None, 1, "cup", None, None, 130, "gram", None, None),
    ]

    # VEGETABLES (9 ingredients, 9 conversions)
    vegetables = [
        ("Chopped onion", "Vegetable", None, 1, "cup", None, None, 160, "gram", None, None),
        ("Minced garlic", "Vegetable", None, 1, "tablespoon", None, None, 10, "gram", None, None),
        ("Garlic", "Vegetable", None, 1, None, "clove", "cloves", 3, "gram", None, None),
        ("Chopped tomato", "Vegetable", None, 1, "cup", None, None, 180, "gram", None, None),
        ("Diced potato", "Vegetable", None, 1, "cup", None, None, 150, "gram", None, None),
        ("Chopped carrot", "Vegetable", None, 1, "cup", None, None, 128, "gram", None, None),
        ("Chopped bell pepper", "Vegetable", None, 1, "cup", None, None, 149, "gram", None, None),
        ("Sliced mushrooms", "Vegetable", None, 1, "cup", None, None, 70, "gram", None, None),
        ("Fresh spinach", "Vegetable", None, 1, "cup", None, None, 30, "gram", None, None),
    ]

    # FRESH FRUITS (5 ingredients, 5 conversions)
    fresh_fruits = [
        ("Medium apple", "Fruit", None, 1, None, "apple", "apples", 182, "gram", None, None),
        ("Medium banana", "Fruit", None, 1, None, "banana", "bananas", 118, "gram", None, None),
        ("Medium lemon", "Fruit", None, 1, None, "lemon", "lemons", 58, "gram", None, None),
        ("Blueberries", "Fruit", None, 1, "cup", None, None, 148, "gram", None, None),
        ("Sliced strawberries", "Fruit", None, 1, "cup", None, None, 166, "gram", None, None),
    ]

    # SPICES (10 ingredients, 10 conversions)
    spices = [
        ("Table salt", "Spice", None, 1, "teaspoon", None, None, 6, "gram", None, None),
        ("Kosher salt", "Spice", None, 1, "teaspoon", None, None, 5, "gram", None, None),
        ("Ground black pepper", "Spice", None, 1, "teaspoon", None, None, 2, "gram", None, None),
        ("Ground cinnamon", "Spice", None, 1, "teaspoon", None, None, 3, "gram", None, None),
        ("Ground ginger", "Spice", None, 1, "teaspoon", None, None, 2, "gram", None, None),
        ("Ground cumin", "Spice", None, 1, "teaspoon", None, None, 2, "gram", None, None),
        ("Paprika", "Spice", None, 1, "teaspoon", None, None, 2, "gram", None, None),
        ("Garlic powder", "Spice", None, 1, "teaspoon", None, None, 3, "gram", None, None),
        ("Onion powder", "Spice", None, 1, "teaspoon", None, None, 2, "gram", None, None),
        ("Chili powder", "Spice", None, 1, "teaspoon", None, None, 3, "gram", None, None),
    ]

    # EGGS (5 ingredients, 5 conversions)
    eggs = [
        ("Large egg, whole", "Egg", None, 1, None, "egg", "eggs", 50, "gram", None, None),
        ("Medium egg, whole", "Egg", None, 1, None, "egg", "eggs", 44, "gram", None, None),
        ("Extra large egg, whole", "Egg", None, 1, None, "egg", "eggs", 56, "gram", None, None),
        ("Large egg white", "Egg", None, 1, None, "white", "whites", 33, "gram", None, None),
        ("Large egg yolk", "Egg", None, 1, None, "yolk", "yolks", 17, "gram", None, None),
    ]

    # MISCELLANEOUS (3 ingredients, 3 conversions)
    misc = [
        ("Water", "Other", None, 1, "cup", None, None, 237, "gram", None, None),
        ("Graham crackers", "Other", None, 8, None, "cracker", "crackers", 28, "gram", None, None),
        ("Crushed graham crackers", "Other", None, 1, "cup", None, None, 84, "gram", None, None),
    ]

    # Combine all categories
    all_ingredients = (
            flours + sugars + fats + dairy + baking + chocolate +
            nuts + grains + dried_fruits + vegetables + fresh_fruits +
            spices + eggs + misc
    )

    # Convert to DataFrame
    df = pd.DataFrame(all_ingredients, columns=[
        'Name', 'Category', 'Brand',
        'From Amount', 'From Unit', 'From Unit Singular', 'From Unit Plural',
        'To Amount', 'To Unit', 'To Unit Singular', 'To Unit Plural'
    ])

    # Add verification columns for manual review
    df['Verified'] = ''
    df['Notes'] = ''

    return df


def main():
    print("Generating curated ingredient database (100 essential ingredients)...")
    print("=" * 70)
    print("IMPORTANT: Please verify these conversions against authoritative sources:")
    print("  - King Arthur Baking: kingarthurbaking.com/learn/ingredient-weight-chart")
    print("  - USDA FoodData Central: fdc.nal.usda.gov")
    print("=" * 70)
    print()

    df = create_ingredient_database()

    # Save to Excel
    output_file = 'ingredient_database.xlsx'
    df.to_excel(output_file, index=False)

    print(f"✓ Created {output_file}")
    print(f"✓ Total conversions: {len(df)}")
    print(f"✓ Unique ingredients: {df['Name'].nunique()}")
    print()
    print("Category breakdown:")
    categories = df['Category'].value_counts()
    for category, count in categories.items():
        print(f"  - {category}: {count} conversions")
    print()
    print("To convert to JSON:")
    print(f"  python convert_ingredients.py {output_file} default_ingredients.json")


if __name__ == "__main__":
    main()
