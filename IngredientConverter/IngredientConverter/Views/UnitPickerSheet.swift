//
//  UnitPickerSheet.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/19/25.
//

import SwiftUI

struct UnitPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appColorScheme) private var colorScheme

    let availableUnits: [MeasurementUnit]
    @Binding var selectedUnit: MeasurementUnit?
    let title: String

    @State private var selectedFilter: UnitType? = nil

    private var filteredUnits: [MeasurementUnit] {
        guard let filter = selectedFilter else {
            return availableUnits
        }
        return availableUnits.filter { $0.type == filter }
    }

    // Get unique unit types from available units
    private var availableUnitTypes: [UnitType] {
        let types = Set(availableUnits.map { $0.type })
        return [.volume, .weight, .count, .other].filter { types.contains($0) }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Filter buttons
                if availableUnitTypes.count > 1 {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterButton(
                                title: "All",
                                isSelected: selectedFilter == nil,
                                colorScheme: colorScheme
                            ) {
                                selectedFilter = nil
                            }

                            ForEach(availableUnitTypes, id: \.self) { type in
                                FilterButton(
                                    title: type.displayName,
                                    isSelected: selectedFilter == type,
                                    colorScheme: colorScheme
                                ) {
                                    selectedFilter = type
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 12)
                    .background(colorScheme.background)
                }

                Divider()
                    .background(colorScheme.divider)

                // Unit buttons in grid
                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.adaptive(minimum: 90), spacing: 12)
                        ],
                        spacing: 16
                    ) {
                        ForEach(filteredUnits, id: \.self) { unit in
                            UnitButton(
                                unit: unit,
                                isSelected: selectedUnit == unit,
                                colorScheme: colorScheme
                            ) {
                                selectedUnit = unit
                                dismiss()
                            }
                        }
                    }
                    .padding()
                }
                .background(colorScheme.background)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(colorScheme.primary)
                }
            }
        }
    }
}

struct UnitButton: View {
    let unit: MeasurementUnit
    let isSelected: Bool
    let colorScheme: AppColorScheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                // Icon or abbreviation
                if let symbol = unit.sfSymbol {
                    // Custom symbol from Assets.xcassets
                    Image(symbol)
                        .font(.largeTitle)
                        .foregroundColor(isSelected ? colorScheme.accent : colorScheme.primary)
                } else {
                    Text(unit.displayName)
                        .font(.title3.weight(.medium))
                        .foregroundColor(isSelected ? colorScheme.accent : colorScheme.primary)
                }

                // Unit name
                Text(unit.fullDisplayName)
                    .font(.callout)
                    .foregroundColor(colorScheme.secondaryText)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 90)
            .background(
                isSelected
                    ? colorScheme.accent.opacity(0.1)
                    : colorScheme.cardBackground
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(
                        isSelected
                            ? colorScheme.accent.opacity(0.5)
                            : colorScheme.divider.opacity(0.3),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let colorScheme: AppColorScheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(isSelected ? .semibold : .regular))
                .foregroundColor(isSelected ? .white : colorScheme.primaryText)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    isSelected
                        ? colorScheme.accent
                        : colorScheme.cardBackground
                )
                .cornerRadius(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            isSelected
                                ? colorScheme.accent
                                : colorScheme.divider,
                            lineWidth: 1
                        )
                )
        }
    }
}

// Extension to get display name for UnitType
extension UnitType {
    var displayName: String {
        switch self {
        case .volume: return "Volume"
        case .weight: return "Weight"
        case .count: return "Count"
        case .other: return "Other"
        }
    }
}

// Extension to provide SF Symbols for units
extension MeasurementUnit {
    var sfSymbol: String? {
        switch self {
        // Smaller weight units - use custom weight symbol
        case .ounce:
            return "3.weights.l"
        
        case .gram:
            return "3.weights.m"
            
        case .milligram:
            return "3.weights.s"

        // Larger weight units - use filled scale symbol
        case .pound:
            return "weight.lb"
            
        case .kilogram:
            return "weight.kg"

        // Smaller liquid volume units - use liquid measuring cup symbol
        case .pint:
            return "liquid.measure.4"
            
        case .fluidOunce:
            return "liquid.measure.3"
            
        case .centiliter:
            return "liquid.measure.2"
            
        case .milliliter:
            return "liquid.measure.1"
            
        // Larger volume containers
        case .liter:
            return "liter.bottle"
            
        case .quart:
            return "quart.bottle"
        
        // Common cooking measurements - use measuring cup and spoon symbols
        case .cup:
            return "measure.cup.dry.fill"

        case .tablespoon:
            return "spoons.large.fill"
            
        case .teaspoon:
            return "spoons.small.fill"

        // Larger volume containers
        case .gallon:
            return "jug.fill"

        // Count - use number symbol
        case .count:
            return "count.circle.fill"

        // For .other, use the abbreviation
        case .other:
            return nil
        }
    }
}

#Preview {
    let units: [MeasurementUnit] = [
        .teaspoon, .tablespoon, .fluidOunce, .cup,
        .pint, .quart, .gallon, .milliliter, .centiliter,
        .liter, .ounce, .pound, .milligram, .gram, .kilogram,
        .count(singular: "item", plural: "items"),
    ]

    return UnitPickerSheet(
        availableUnits: units,
        selectedUnit: .constant(.cup),
        title: "From Unit"
    )
}
