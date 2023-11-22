//
//  ContentView.swift
//  mealplanner
//
//  Created by Roshan Ramankutty on 11/22/23.
//

import SwiftUI
struct Day: Identifiable {
    var id = UUID()
    var name: String
    var meals: [Meal]
}

struct Meal: Identifiable {
    var id = UUID()
    var type: MealType
    var items: [String]
    var selectedItem: String?
}


enum MealType: String {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
}
struct DayListView: View {
    @State var days: [Day] // Your days data
    @State private var showingModal = false // New state for showing the modal

    var body: some View {
        NavigationView {
            List($days) { $day in
                NavigationLink(destination: MealListView(meals: $day.meals)) {
                    Text(day.name)
                }
            }
            .navigationTitle("Days of the Week")
            .navigationBarItems(trailing: Button("Selected Meals") {
                showingModal = true
            })
            .sheet(isPresented: $showingModal) {
                SelectedMealsView(days: days)
            }
        }
    }
}
struct SelectedMealsView: View {
    @Environment(\.presentationMode) var presentationMode
    var days: [Day]

    var body: some View {
        NavigationView {
            List {
                ForEach(days) { day in
                    Section(header: Text(day.name)) {
                        ForEach(day.meals.filter { $0.selectedItem != nil }) { meal in
                            if let selectedItem = meal.selectedItem {
                                Text("\(meal.type.rawValue): \(selectedItem)")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Selected Meals")
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}


struct MealListView: View {
    @Binding var meals: [Meal]

    var body: some View {
        List {
            ForEach($meals.indices, id: \.self) { index in
                Section(header: Text(meals[index].type.rawValue)) {
                    ForEach(meals[index].items, id: \.self) { item in
                        HStack {
                            Text(item)
                            Spacer()
                            if meals[index].selectedItem == item {
                                Image(systemName: "checkmark")
                            }
                        }
                        .onTapGesture {
                            meals[index].selectedItem = item
                        }
                        .frame(maxWidth: .infinity, alignment: .leading) // Ensures the HStack fills the width of the row
                    }
                }
            }
        }
    }
}


struct ContentView: View {
    var body: some View {
        DayListView(days: sampleDays)
    }
}

// Sample data for testing
let sampleDays: [Day] = [
    Day(name: "Monday", meals: [
        Meal(type: .breakfast, items: ["Pancakes", "Cereal"]),
        Meal(type: .lunch, items: ["Sandwich", "Salad"]),
        Meal(type: .dinner, items: ["Pizza", "Pasta"])
    ]),
    Day(name: "Tuesday", meals: [
        Meal(type: .breakfast, items: ["Omelette", "Fruit Salad"]),
        Meal(type: .lunch, items: ["Soup", "Grilled Cheese"]),
        Meal(type: .dinner, items: ["Stir Fry", "Burger"])
    ]),
    Day(name: "Wednesday", meals: [
        Meal(type: .breakfast, items: ["Bagel", "Smoothie"]),
        Meal(type: .lunch, items: ["Tacos", "Burrito"]),
        Meal(type: .dinner, items: ["Spaghetti", "Meatloaf"])
    ]),
    Day(name: "Thursday", meals: [
        Meal(type: .breakfast, items: ["French Toast", "Yogurt"]),
        Meal(type: .lunch, items: ["Salmon Salad", "Quiche"]),
        Meal(type: .dinner, items: ["Steak", "Veggie Stir Fry"])
    ]),
    Day(name: "Friday", meals: [
        Meal(type: .breakfast, items: ["Waffles", "Granola"]),
        Meal(type: .lunch, items: ["Pizza", "Caesar Salad"]),
        Meal(type: .dinner, items: ["Sushi", "Ramen"])
    ]),
    Day(name: "Saturday", meals: [
        Meal(type: .breakfast, items: ["Pancakes", "Bacon"]),
        Meal(type: .lunch, items: ["BLT Sandwich", "Chicken Salad"]),
        Meal(type: .dinner, items: ["Barbecue Ribs", "Mashed Potatoes"])
    ]),
    Day(name: "Sunday", meals: [
        Meal(type: .breakfast, items: ["Eggs Benedict", "Porridge"]),
        Meal(type: .lunch, items: ["Fish and Chips", "Pasta Salad"]),
        Meal(type: .dinner, items: ["Roast Chicken", "Vegetable Lasagna"])
    ])

]
#Preview {
    ContentView()
}
