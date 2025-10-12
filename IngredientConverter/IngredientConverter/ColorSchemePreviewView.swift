//
//  ColorSchemePreviewView.swift
//  IngredientConverter
//
//  Created by Dawn DeMeo on 10/12/25.
//

import SwiftUI

struct ColorSchemePreviewView: View {
    @AppStorage("appearanceMode") private var appearanceMode: AppearanceMode = .system
    @State private var selectedScheme: AppColorScheme = .classic

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Scheme selector
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(AppColorScheme.allSchemes) { scheme in
                                Button {
                                    selectedScheme = scheme
                                } label: {
                                    Text(scheme.name)
                                        .font(.headline)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(selectedScheme.id == scheme.id ? scheme.primary : Color.gray.opacity(0.2))
                                        .foregroundColor(selectedScheme.id == scheme.id ? .white : .primary)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    Divider()

                    // Preview components
                    VStack(spacing: 20) {
                        ColorSwatchesSection(scheme: selectedScheme)
                        ButtonPreviewSection(scheme: selectedScheme)
                        CardPreviewSection(scheme: selectedScheme)
                        ListPreviewSection(scheme: selectedScheme)
                        TextStylesSection(scheme: selectedScheme)
                    }
                    .padding()
                }
            }
            .background(selectedScheme.background)
            .navigationTitle("Color Scheme Preview")
            .navigationBarTitleDisplayMode(.inline)
        }
        .preferredColorScheme(appearanceMode.colorScheme)
    }
}

// MARK: - Preview Sections

struct ColorSwatchesSection: View {
    let scheme: AppColorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Color Palette")
                .font(.title2)
                .bold()
                .foregroundColor(scheme.primaryText)

            VStack(spacing: 12) {
                ColorSwatch(name: "Primary", color: scheme.primary)
                ColorSwatch(name: "Secondary", color: scheme.secondary)
                ColorSwatch(name: "Accent", color: scheme.accent)
                ColorSwatch(name: "Success", color: scheme.success)
                ColorSwatch(name: "Warning", color: scheme.warning)
                ColorSwatch(name: "Error", color: scheme.error)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(scheme.cardBackground)
        .cornerRadius(12)
        .shadow(color: scheme.shadow, radius: 8, x: 0, y: 2)
    }
}

struct ColorSwatch: View {
    let name: String
    let color: Color

    var body: some View {
        HStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 60, height: 40)

            Text(name)
                .font(.body)

            Spacer()
        }
    }
}

struct ButtonPreviewSection: View {
    let scheme: AppColorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Buttons")
                .font(.title2)
                .bold()
                .foregroundColor(scheme.primaryText)

            VStack(spacing: 12) {
                Button("Primary Button") { }
                    .font(.headline)
                    .foregroundColor(scheme.buttonText)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(scheme.primary)
                    .cornerRadius(10)

                Button("Secondary Button") { }
                    .font(.headline)
                    .foregroundColor(scheme.buttonText)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(scheme.secondary)
                    .cornerRadius(10)

                Button("Accent Button") { }
                    .font(.headline)
                    .foregroundColor(scheme.buttonText)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(scheme.accent)
                    .cornerRadius(10)

                Button("Destructive Button") { }
                    .font(.headline)
                    .foregroundColor(scheme.buttonText)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(scheme.error)
                    .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(scheme.cardBackground)
        .cornerRadius(12)
        .shadow(color: scheme.shadow, radius: 8, x: 0, y: 2)
    }
}

struct CardPreviewSection: View {
    let scheme: AppColorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Cards & Content")
                .font(.title2)
                .bold()
                .foregroundColor(scheme.primaryText)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("All-purpose flour")
                            .font(.headline)
                            .foregroundColor(scheme.primaryText)

                        Text("King Arthur")
                            .font(.caption)
                            .foregroundColor(scheme.secondaryText)
                    }

                    Spacer()

                    Image(systemName: "star.fill")
                        .foregroundColor(scheme.accent)
                }
                .padding()
                .background(scheme.cardBackground)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(scheme.divider, lineWidth: 1)
                )

                HStack {
                    Text("1")
                        .font(.title2)
                        .foregroundColor(scheme.primary)

                    Text("cup")
                        .font(.body)
                        .foregroundColor(scheme.secondaryText)

                    Spacer()

                    Image(systemName: "equal")
                        .foregroundColor(scheme.secondary)

                    Spacer()

                    Text("120")
                        .font(.title2)
                        .bold()
                        .foregroundColor(scheme.accent)

                    Text("g")
                        .font(.body)
                        .foregroundColor(scheme.secondaryText)
                }
                .padding()
                .background(scheme.secondaryBackground)
                .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(scheme.cardBackground)
        .cornerRadius(12)
        .shadow(color: scheme.shadow, radius: 8, x: 0, y: 2)
    }
}

struct ListPreviewSection: View {
    let scheme: AppColorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("List Items")
                .font(.title2)
                .bold()
                .foregroundColor(scheme.primaryText)

            VStack(spacing: 0) {
                ForEach(["Flour", "Sugar", "Butter"], id: \.self) { item in
                    HStack {
                        Image(systemName: "circle.fill")
                            .foregroundColor(scheme.primary)
                            .font(.caption)

                        Text(item)
                            .foregroundColor(scheme.primaryText)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(scheme.secondaryText)
                            .font(.caption)
                    }
                    .padding()
                    .background(scheme.cardBackground)

                    if item != "Butter" {
                        Divider()
                            .background(scheme.divider)
                    }
                }
            }
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(scheme.divider, lineWidth: 1)
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(scheme.cardBackground)
        .cornerRadius(12)
        .shadow(color: scheme.shadow, radius: 8, x: 0, y: 2)
    }
}

struct TextStylesSection: View {
    let scheme: AppColorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Typography")
                .font(.title2)
                .bold()
                .foregroundColor(scheme.primaryText)

            VStack(alignment: .leading, spacing: 8) {
                Text("Large Title")
                    .font(.largeTitle)
                    .foregroundColor(scheme.primaryText)

                Text("Title")
                    .font(.title)
                    .foregroundColor(scheme.primaryText)

                Text("Headline")
                    .font(.headline)
                    .foregroundColor(scheme.primaryText)

                Text("Body text with primary color")
                    .font(.body)
                    .foregroundColor(scheme.primaryText)

                Text("Secondary text for less emphasis")
                    .font(.body)
                    .foregroundColor(scheme.secondaryText)

                Text("Caption text for small details")
                    .font(.caption)
                    .foregroundColor(scheme.secondaryText)

                HStack(spacing: 16) {
                    Label("Success", systemImage: "checkmark.circle.fill")
                        .foregroundColor(scheme.success)

                    Label("Warning", systemImage: "exclamationmark.triangle.fill")
                        .foregroundColor(scheme.warning)

                    Label("Error", systemImage: "xmark.circle.fill")
                        .foregroundColor(scheme.error)
                }
                .font(.caption)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(scheme.cardBackground)
        .cornerRadius(12)
        .shadow(color: scheme.shadow, radius: 8, x: 0, y: 2)
    }
}

#Preview {
    ColorSchemePreviewView()
}
