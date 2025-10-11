## User

I'm building an iOS app that will make use of SwiftData. The data will be a list of ingredients and their densities. The app will include a default list of ingredients, but the end user will also be able to add custom entries. If at some point I update the default list to include new or updated items, how can I ensure the end user's custom entries aren't overwritten when they update the app?

---

## Copilot

Great question! This is a common scenario when dealing with default data vs. user data in apps using Core Data or SwiftData. You want to **preserve user-added entries** while still being able to **update or add to the default list** when your app is updated.

Here's a best-practice approach for SwiftData or any local database-backed iOS app:

---

### **1. Identify Default vs. User Data**

Each `Ingredient` item should have a property such as `isCustom: Bool` or a similar marker to distinguish between **default** and **user-added** entries.

```swift
@Model
final class Ingredient {
    @Attribute(.unique) var name: String
    var density: Double
    var isCustom: Bool // true if added by user
    // ... other fields
}
```

---

### **2. On App Update: Merge Defaults, Don’t Overwrite**

When your app updates (e.g., bundled default data changes), you want to:

- **Add new default ingredients** not already present
- **Update existing default ingredients** (only if user hasn't modified them)
- **Never touch user-custom entries**

#### **How to do this:**

- **Bundle** your default ingredient list as a JSON or Plist file in your app.
- On app launch (or migration), load the default list and **compare** to the existing database.
- For each default ingredient:
    - **If not present** in the database, **insert** it (with `isCustom = false`)
    - **If present and not user-modified**, **update** its properties as needed
    - **If present and user-modified**, **leave it as-is**
- User-added (`isCustom = true`) entries are **never affected** by the update logic.

---

### **3. Sample Merge Logic (SwiftData-style pseudocode)**

```swift
func mergeDefaults(with context: ModelContext, defaults: [Ingredient]) {
    let existingIngredients = fetchAllIngredients(context)
    for defaultIngredient in defaults {
        if let existing = existingIngredients.first(where: { $0.name == defaultIngredient.name && !$0.isCustom }) {
            // Optionally update fields if you want to sync changes
            existing.density = defaultIngredient.density
            // ... update other fields as needed
        } else if existingIngredients.first(where: { $0.name == defaultIngredient.name && $0.isCustom }) == nil {
            // Add new default ingredient
            let newIngredient = Ingredient(name: defaultIngredient.name, density: defaultIngredient.density, isCustom: false)
            context.insert(newIngredient)
        }
        // If it's a user-custom entry, do nothing
    }
}
```

---

### **4. How to Avoid Overwriting**

- **Never delete or overwrite entries with `isCustom = true`.**
- When updating defaults, only modify entries marked as default (`isCustom = false`).

---

### **Summary Table**

| Action                  | Default Entry (isCustom: false) | User Entry (isCustom: true) |
|-------------------------|----------------------------------|-----------------------------|
| Add new default         | Insert if not present            | Do nothing                  |
| Update existing default | Update as needed                 | Do nothing                  |
| User custom entry       | Never modify/delete              | Never modify/delete         |

---

### **Tip**

If you let users **edit** default entries, you should consider marking those as "customized" (e.g., flip `isCustom` to true, or track another flag like `isModifiedByUser`), so future updates won’t overwrite user changes to default items.

---

**TL;DR:**  
**Mark user data vs. default data. On update, only update or add default entries, never overwrite user entries. Use an `isCustom` flag (or similar) to distinguish them.**

If you want a sample implementation or more details on any step, let me know!

---