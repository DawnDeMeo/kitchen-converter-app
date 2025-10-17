# VoiceOver Usage Guide for Ingredient Converter

## Enabling VoiceOver

### On iPhone/iPad:
- **Settings > Accessibility > VoiceOver** → Toggle ON
- **Shortcut**: Triple-click Side/Home button (configure in Settings > Accessibility > Accessibility Shortcut)

### In iOS Simulator:
- **Settings > Accessibility > VoiceOver** → Toggle ON
- **Keyboard shortcut**: `Cmd + F5` to toggle VoiceOver on/off

## Basic VoiceOver Gestures

### Navigation
- **Swipe right**: Move to next element
- **Swipe left**: Move to previous element
- **Touch and drag**: Explore by touch (reads what's under your finger)
- **Double-tap**: Activate the selected element (like a normal tap)
- **Two-finger tap**: Pause/resume VoiceOver speech

### Reading Content
- **Two-finger swipe down**: Read all content from current position
- **Two-finger swipe up**: Read all content from top
- **Three-finger swipe left/right**: Navigate between pages/screens

### Scrolling
- **Three-finger swipe up**: Scroll down
- **Three-finger swipe down**: Scroll up

### Custom Actions
- **Swipe up or down** (while an element is focused): Cycle through available custom actions
- **Double-tap** after selecting an action: Perform that action

## Using the App with VoiceOver

### Ingredient List Screen

**When you focus on an ingredient**, VoiceOver will announce:
- Ingredient name
- Brand (e.g., "Brand: King Arthur")
- Category (e.g., "Category: Flour")
- "Custom ingredient" if it's user-created
- "Favorite" if it's marked as favorite

**Example**:
> "All-purpose flour, Brand: King Arthur, Category: Flour, Custom ingredient, Favorite. Double tap to convert this ingredient."

**To toggle favorite status:**
1. **Focus** on the ingredient (swipe right/left until you hear it)
2. **Swipe up or down** once to hear "Add to favorites" or "Remove from favorites"
3. **Double-tap** to toggle the favorite status

**Alternative method:**
1. Swipe right past the ingredient name until you hear "Add to favorites" or "Remove from favorites"
2. Double-tap the star button

### Conversion Screen

**Amount input field:**
- Announces: "Amount to convert"
- Current value is read naturally (e.g., "one and one half" for "1 1/2")
- Double-tap to open custom keyboard

**Custom Keyboard:**
- **Fractions** are announced naturally: "one eighth", "one quarter", "one half", etc.
- **Numbers** are announced individually: "one", "two", "three"
- **Decimal point** is announced as "decimal point"
- **Slash** is announced as "fraction slash"
- **Delete** button: "Delete, removes the last character from the input"
- **Done** button: "Done, closes the keyboard"

**From/To Unit Pickers:**
- Announce current selection
- Double-tap to open picker menu
- Swipe right/left to navigate options
- Double-tap to select

**Swap Button:**
- Announces: "Swap units, swaps the from and to units"
- Double-tap to swap

**Result Display:**
- Reads the complete conversion naturally
- Example: "one and one half cups equals one hundred twenty point five grams"

### Settings Screen

**All pickers and buttons** have clear labels and hints:
- **Appearance picker**: "Appearance mode, [current value], choose between system, light, or dark mode"
- **Theme picker**: "Color scheme, [current theme], choose a color theme for the app"
- **iCloud status**: "iCloud Sync: Available" or "iCloud Sync: Unavailable"

### Editing Ingredients

**Text fields:**
- "Ingredient name, enter the name of the ingredient"
- "Brand name, enter the brand name, if applicable"

**Conversion fields:**
- "From amount" with current value
- "To amount" with current value
- Unit displays announce "From unit: [unit name]" and "To unit: [unit name]"

## Tips for Testing

1. **Navigate slowly**: Swipe deliberately to hear each element
2. **Use the Rotor**: Twist two fingers on screen to access different navigation modes (headings, links, form controls)
3. **Listen to hints**: Hints provide context about what an action will do
4. **Practice custom actions**: Swipe up/down on focused elements to discover available actions
5. **Adjust speech rate**: Settings > Accessibility > VoiceOver > Speaking Rate

## Common Issues

**If VoiceOver reads "dot" instead of "point" for decimals:**
- This should be fixed in the latest version
- Try restarting the app

**If favorite button is hard to find:**
- Use the custom action instead (swipe up/down on the ingredient)
- Much faster than navigating to the star button

**If you get lost:**
- Two-finger swipe down to read from current position
- Three-finger triple-tap to turn off screen curtain (if enabled)

## Accessibility Best Practices

This app follows iOS accessibility guidelines:
- ✅ All interactive elements have clear labels
- ✅ Hints explain what actions do
- ✅ Natural language for fractions and decimals
- ✅ Custom actions for common tasks
- ✅ Logical navigation order
- ✅ Combined elements for natural reading flow

## Need Help?

- **VoiceOver Practice**: Settings > Accessibility > VoiceOver > VoiceOver Practice
- **Apple's VoiceOver Guide**: https://support.apple.com/guide/iphone/turn-on-and-practice-voiceover-iph3e2e415f/ios
