//
//  ContentView.swift
//  mealplanner
//
//  Created by Roshan Ramankutty on 11/22/23.
//

import SwiftUI
import Foundation


struct Ingredient: Identifiable, Decodable {
    var id = UUID()  // This is for Identifiable
    var name: String
    var quantity: Int
    var unit: String

    // Define CodingKeys if the JSON keys don't match your struct's property names
    enum CodingKeys: String, CodingKey {
        case name
        case quantity
        case unit
    }
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

struct APIResponse: Decodable {
    let id: String
    let object: String
    let created: Int
    let model: String
    let choices: [Choice]
}

struct Choice: Decodable {
    let index: Int
    let message: Message
    let finish_reason: String
}

struct Message: Decodable {
    let role: String
    let content: String  // This contains the JSON string of ingredients
}

struct IngredientsResponse: Decodable {
    let ingredients: [Ingredient]
}
struct BackgroundTapModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                hideKeyboard()
            }
    }

    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

extension View {
    func dismissKeyboardOnBackgroundTap() -> some View {
        self.modifier(BackgroundTapModifier())
    }
}





struct DayListView: View {
    @Binding var days: [Day] // Your days data
    @State private var showSelectedMeals = false

    var body: some View {
        NavigationView {
            ZStack {
                List($days) { $day in
                    NavigationLink(destination: MealListView(meals: $day.meals)) {
                        Text($day.name.wrappedValue)
                    }
                }
                .navigationTitle("Meal Planner")

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

struct RecipeAddView: View {
    @Binding var meals: [Meal]
    @State private var recipeName: String = ""
    @State private var recipeDetails: String = ""
    @State private var selectedMealType: MealType = .breakfast

    var onSave: (Meal) -> Void

    var body: some View {
        VStack {
            TextField("Recipe Name", text: $recipeName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            TextEditor(text: $recipeDetails)
                .border(Color.gray, width: 1)
                .padding()

            Picker("Meal Type", selection: $selectedMealType) {
                Text(MealType.breakfast.rawValue).tag(MealType.breakfast)
                Text(MealType.lunch.rawValue).tag(MealType.lunch)
                Text(MealType.dinner.rawValue).tag(MealType.dinner)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            Button("Save") {
                        parseIngredients(from: recipeDetails) { ingredients in
                            let newMeal = Meal(name: recipeName, ingredients: ingredients, selectedItem: false, type: selectedMealType)
                            onSave(newMeal)  // This now happens after the ingredients are fetched
                        }
                    }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .background(Color.red.opacity(0.1).edgesIgnoringSafeArea(.all)
            .dismissKeyboardOnBackgroundTap())
        .padding()
        

        
    }

    func parseIngredients(from details: String, completion: @escaping ([Ingredient]) -> Void) {
        let requestBody: [String: Any] = [
                "model": "gpt-3.5-turbo-1106",
                "response_format": ["type": "json_object"],
                "messages": [
                    ["role": "system", "content": "You are a recipe and ingredient transcriber. You transcribe recipe text or ingredient lists into JSON. The JSON has the attributes of name (the name of the ingredient), quantity, and unit. Quantities are always integers, never strings. When no unit type is provided by the specified text, use the ingredient name in the relevant singular or plural form to associate with the attribute 'unit'. An example JSON object looks like the following: {'ingredients':[{'name':'onion','quantity':'2','unit':'onions'}]}. Do not provide any special characters, no '\n' or other escape characters. You may use Emojis in the name or the unit only. When no recipe is detected, you return an empty JSON object."],
                    ["role": "user", "content": details]
                ]
            ]

        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("Bearer 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", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
            }

            if let data = data, let responseText = String(data: data, encoding: .utf8) {
                print("Response Text: \(responseText)")
            } else {
                print("No response text.")
            }

            if let error = error {
                print("Error: \(error.localizedDescription)")
                completion([])
            } else {
                // Attempt to decode the response
                if let response = try? JSONDecoder().decode(APIResponse.self, from: data ?? Data()) {
                    if let firstChoice = response.choices.first {
                        let content = firstChoice.message.content

                        if let contentData = content.data(using: .utf8),
                           let ingredientsResponse = try? JSONDecoder().decode(IngredientsResponse.self, from: contentData) {
                            let ingredients = ingredientsResponse.ingredients
                            DispatchQueue.main.async {
                                completion(ingredients)
                                print("Success!")
                            }
                        } else {
                            print("Failed to decode the ingredients from content.")
                            completion([])
                        }
                    } else {
                        print("No choices available in the response.")
                        completion([])
                    }
                } else {
                    print("Failed to decode APIResponse. Response Text: \(String(describing: String(data: data ?? Data(), encoding: .utf8)))")
                    completion([])
                }
            }
        }.resume()
    }

    func parseResponseIntoIngredients(_ text: String) -> [Ingredient] {
        // Implement your parsing logic based on the expected structure of the response
        var ingredients = [Ingredient]()
        print("Ingredients: \(ingredients)")
        return ingredients
    }
}

struct ContentView: View {
    @State var days = sampleDays
    @State var meals = [Meal]() // Assuming this is your meals array
    
    var body: some View {
        TabView {
            DayListView(days: $days)
                .tabItem {
                    Label("Week", systemImage: "calendar")
                }
            RecipeAddView(meals: $meals) { newMeal in
                meals.append(newMeal)
                addMealToDays(newMeal)
            }
            .tabItem {
                Label("Add Recipe", systemImage: "plus")
            }
            SelectedMealsView(days: days)
                .tabItem {
                    Label("Shopping List", systemImage: "cart")
                }
            
            
        }
    }
    
    func addMealToDays(_ meal: Meal) {
        for index in days.indices {
            days[index].meals.append(meal)
        }
    }
}


let meals = [
    Meal(name: "Pancakes", ingredients: [Ingredient(name: "Flour", quantity: 1, unit: "cup"), Ingredient(name: "Eggs", quantity: 2, unit: "items")], selectedItem: false, type: .breakfast),
    Meal(name: "Omelette", ingredients: [Ingredient(name: "Eggs", quantity: 2, unit: "items"), Ingredient(name: "Cheese", quantity: 1, unit: "slice")], selectedItem: false, type: .breakfast),
    Meal(name: "Sandwich", ingredients: [Ingredient(name: "Bread", quantity: 2, unit: "slices"), Ingredient(name: "Cheese", quantity: 1, unit: "slice")], selectedItem: false, type: .lunch),
    Meal(name: "Salad", ingredients: [Ingredient(name: "Lettuce", quantity: 1, unit: "cup"), Ingredient(name: "Tomato", quantity: 1, unit: "item")], selectedItem: false, type: .lunch),
    // Add more lunch meals
    Meal(name: "Pizza", ingredients: [Ingredient(name: "Pizza Dough", quantity: 1, unit: "piece"), Ingredient(name: "Cheese", quantity: 100, unit: "g")], selectedItem: false, type: .dinner),
    Meal(name: "Pasta", ingredients: [Ingredient(name: "Pasta", quantity: 200, unit: "g"), Ingredient(name: "Tomato Sauce", quantity: 1, unit: "cup")], selectedItem: false, type: .dinner)
    // Add more dinner meals
]

// Sample data for testing
let sampleDays: [Day] = [
    Day(name: "Monday", meals: meals),
    Day(name: "Tuesday", meals: meals),
    Day(name: "Wednesday", meals: meals),
    Day(name: "Thursday", meals: meals),
    Day(name: "Friday", meals: meals),
    Day(name: "Saturday", meals: meals),
    Day(name: "Sunday", meals: meals)
]


#Preview {
    ContentView()
}
