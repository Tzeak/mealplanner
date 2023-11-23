//
//  ContentView.swift
//  mealplanner
//
//  Created by Roshan Ramankutty on 11/22/23.
//

import SwiftUI
struct Ingredient: Identifiable {
    var id = UUID()
    var name: String
    var quantity: Int // Changed to an integer
    var unit: String  // Added unit property
}


struct Meal: Identifiable {
    var id = UUID()
    var name: String
    var ingredients: [Ingredient]
    var selectedItem: Bool
    var type: MealType
}

struct Day: Identifiable {
    var id = UUID()
    var name: String
    var meals: [Meal]
//    var breakfastMeals: [Meal]
//    var lunchMeals: [Meal]
//    var dinnerMeals: [Meal]
}


enum MealType: String {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
}

struct DayListView: View {
    @State var days: [Day] // Your days data
    @State private var showSelectedMeals = false

    var body: some View {
        NavigationView {
            ZStack {
                List($days) { $day in
                    NavigationLink(destination: MealListView(meals: $day.meals)) {
                        Text($day.name.wrappedValue)
                    }
                }
                .navigationTitle("Days of the Week")

                VStack {
                    Spacer() // Pushes the button to the bottom
                    HStack {
                        Spacer() // Pushes the button to the right
                        Button(action: {
                            showSelectedMeals = true
                        }) {
                            Image(systemName: "checklist")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .clipShape(Circle())
                                .shadow(radius: 10)
                        }
                        .padding()
                    }
                }
            }
            .navigationBarItems(trailing: NavigationLink(
                destination: SelectedMealsView(days: days),
                isActive: $showSelectedMeals
            ) {
                EmptyView()
            })
        }
    }
}


struct SelectedMealsView: View {
    var days: [Day]

    var body: some View {
        List(combineIngredients(), id: \.name) { ingredient in
            Text("\(ingredient.totalQuantity) of \(ingredient.name)")
        }
        .navigationTitle("Ingredients to Buy")
    }


    func combineIngredients() -> [(name: String, totalQuantity: String)] {
        // Struct to hold combined quantities and units
        struct IngredientQuantity {
            var quantity: Int
            var unit: String
        }

        var combinedIngredients = [String: IngredientQuantity]()

        for day in days {
            for meal in day.meals where meal.selectedItem {
                for ingredient in meal.ingredients {
                    let key = "\(ingredient.name)-\(ingredient.unit)" // Unique key for each ingredient and unit combination
                    let existing = combinedIngredients[key, default: IngredientQuantity(quantity: 0, unit: ingredient.unit)]
                    combinedIngredients[key] = IngredientQuantity(quantity: existing.quantity + ingredient.quantity, unit: ingredient.unit)
                }
            }
        }

        // Convert to the desired return format
        return combinedIngredients.map { (name: $0.key.components(separatedBy: "-").first!, totalQuantity: "\($0.value.quantity) \($0.value.unit)") }
    }


}

struct MealListView: View {
    @Binding var meals: [Meal]

    var body: some View {
        List {
            MealSectionView(category: .breakfast, meals: Binding(get: {
                meals.filter { $0.type == .breakfast }
            }, set: { updatedMeals in
                for updatedMeal in updatedMeals {
                    if let index = meals.firstIndex(where: { $0.id == updatedMeal.id }) {
                        meals[index] = updatedMeal
                    }
                }
            }))
            MealSectionView(category: .lunch, meals: Binding(get: {
                meals.filter { $0.type == .lunch }
            }, set: { updatedMeals in
                for updatedMeal in updatedMeals {
                    if let index = meals.firstIndex(where: { $0.id == updatedMeal.id }) {
                        meals[index] = updatedMeal
                    }
                }
            }))
            MealSectionView(category: .dinner, meals: Binding(get: {
                meals.filter { $0.type == .dinner }
            }, set: { updatedMeals in
                for updatedMeal in updatedMeals {
                    if let index = meals.firstIndex(where: { $0.id == updatedMeal.id }) {
                        meals[index] = updatedMeal
                    }
                }
            }))
        }
    }
}


struct MealSectionView: View {
    var category: MealType
    @Binding var meals: [Meal]

    var body: some View {
        Section(header: Text(category.rawValue)) {
            ForEach($meals) { $meal in
                HStack {
                    Text(meal.name)
                    Spacer()
                    if meal.selectedItem {
                        Image(systemName: "checkmark")
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    meal.selectedItem.toggle()
                }
            }
        }
    }
}



struct MealItemView: View {
    var ingredient: Ingredient
    var isSelected: Bool
    var onTap: () -> Void

    var body: some View {
        HStack {
            Text(ingredient.name)
            Spacer()
            if isSelected {
                Image(systemName: "checkmark")
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}



struct ContentView: View {
    var body: some View {
        DayListView(days: sampleDays)
    }
}


let breakfastMeals = [
    Meal(name: "Pancakes", ingredients: [Ingredient(name: "Flour", quantity: 1, unit: "cup"), Ingredient(name: "Eggs", quantity: 2, unit: "items")], selectedItem: false, type: .breakfast),
    Meal(name: "Omelette", ingredients: [Ingredient(name: "Eggs", quantity: 2, unit: "items"), Ingredient(name: "Cheese", quantity: 1, unit: "slice")], selectedItem: false, type: .breakfast)
    // Add more breakfast meals
]


let lunchMeals = [
    Meal(name: "Sandwich", ingredients: [Ingredient(name: "Bread", quantity: 2, unit: "slices"), Ingredient(name: "Cheese", quantity: 1, unit: "slice")], selectedItem: false, type: .lunch),
    Meal(name: "Salad", ingredients: [Ingredient(name: "Lettuce", quantity: 1, unit: "cup"), Ingredient(name: "Tomato", quantity: 1, unit: "item")], selectedItem: false, type: .lunch)
    // Add more lunch meals
]


let dinnerMeals = [
    Meal(name: "Pizza", ingredients: [Ingredient(name: "Pizza Dough", quantity: 1, unit: "piece"), Ingredient(name: "Cheese", quantity: 100, unit: "g")], selectedItem: false, type: .dinner),
    Meal(name: "Pasta", ingredients: [Ingredient(name: "Pasta", quantity: 200, unit: "g"), Ingredient(name: "Tomato Sauce", quantity: 1, unit: "cup")], selectedItem: false, type: .dinner)
    // Add more dinner meals
]

// Sample data for testing
let sampleDays: [Day] = [
    Day(name: "Monday", meals: breakfastMeals + lunchMeals + dinnerMeals),
    Day(name: "Tuesday", meals: breakfastMeals + lunchMeals + dinnerMeals),
    // ... Repeat for other days
]
//
//// Sample data for testing
//let sampleDays: [Day] = [
//
//    
//    Day(name: "Monday", meals: [breakfastMeals[0], lunchMeals[0], dinnerMeals[0]]),
//        Day(name: "Tuesday", meals: [breakfastMeals[1], lunchMeals[1], dinnerMeals[1]]),
//        Day(name: "Wednesday", meals: [breakfastMeals[1], lunchMeals[1], dinnerMeals[1]]),
//        Day(name: "Thursday", meals: [breakfastMeals[1], lunchMeals[1], dinnerMeals[1]]),
//        Day(name: "Friday", meals: [breakfastMeals[1], lunchMeals[1], dinnerMeals[1]]),
//        Day(name: "Saturday", meals: [breakfastMeals[1], lunchMeals[1], dinnerMeals[1]]),
//        Day(name: "Sunday", meals: [breakfastMeals[1], lunchMeals[1], dinnerMeals[1]]),
//        
//    ]


#Preview {
    ContentView()
}
