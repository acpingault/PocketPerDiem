//
//  ContentView.swift
//  TravelTally
//
//  Created by Alex on 2/23/24.
//

import SwiftUI
import SwiftData

enum MealType: String, CaseIterable, Identifiable {
    case breakfast, lunch, dinner, snack, other
    var id: Self { self }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [FundItem]
    
    @AppStorage("total_days", store: .standard) var totalDays: Int = 0
    
    @AppStorage("total_per_day", store: .standard) var totalDailyAmount: Int = 0
    
    @AppStorage("total_for_period", store: .standard) var totalForPeriod: Int = 0

    

    @State private var showDialog = false
    @State private var showTotal = false
    
    @State private var nameField = ""
    @State private var isNameEmpty = true
    @State private var moneyField = ""
    @State private var notesField = ""
    @State private var type: MealType = .breakfast
    
    @State private var dayCountField = ""
    @State private var totalPerDay = ""
    
    
    
    var body: some View {
        NavigationSplitView {
            
            List {
                Section {
                    ForEach(items) { item in
        
                        NavigationLink {
                            VStack{
                                Text("Name: " + item.name)
                                Text("Amount: " + String(item.amount))
                            }
                        } label: {
                            Text(item.name)
                        }
                    }
                    .onDelete(perform: deleteItems)
                } footer: {
                    CardView(total: calcDailyTotal(), perDiemTotal: totalForPeriod)
                }
                
            }
            .navigationTitle(Text("PocketPerDiem"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: {showDialog = !showDialog}) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
                
                ToolbarItem {
                    Button(action: {showTotal = !showTotal}) {
                        Label("Set Total", systemImage: "dollarsign.square")
                    }
                }
            }
        
        } detail: {
            Text("Select an item")
        }
        
        if showDialog {
            VStack {
                
                Form {
                    TextField(text: $nameField, prompt: Text("Name")) {
                        Text("Name")
                    }
                    
                    Picker("Food Type", selection: $type) {
                        Text("Breakfast").tag(MealType.breakfast)
                        Text("Lunch").tag(MealType.lunch)
                        Text("Dinner").tag(MealType.dinner)
                        Text("Snack").tag(MealType.snack)
                        Text("Other").tag(MealType.other)
                    }
                    
                    TextField(text: $moneyField, prompt: Text("Amount ($)")) {
                        Text("Amount ($)")
                    }.keyboardType(.decimalPad)
                    TextField(text: $notesField, prompt: Text("Notes")) {
                        Text("Notes")
                    }
                }
            
                HStack {
                    Button {
                        showDialog = false
                    } label: {
                        Label("Cancel", systemImage: "xmark.circle")
                    }
                    Spacer()
                    Button {
                        addItem()
                    } label: {
                        Label("Done", systemImage: "flag.checkered")
                    }.disabled(nameField.isEmpty)
                    
                    
                }
                

            }
            .padding(10)
        }
        
        if(showTotal){
            VStack {
                
                Form {
                    TextField(text: $totalPerDay, prompt: Text("Daily Per Diem ($)")) {
                        Text("Daily Per Diem ($)")
                    }.keyboardType(.decimalPad)
                    TextField(text: $dayCountField, prompt: Text("Number of Days")) {
                        Text("Number of Days")
                    }.keyboardType(.numberPad)
                }
            
                HStack {
                    Button {
                        showTotal = false
                    } label: {
                        Label("Cancel", systemImage: "xmark.circle")
                    }
                    Spacer()
                    Button {
                        upsertPerDiem(perDiem: UserPerDiem(id: UUID(), totalDays: Int(dayCountField) ?? 0, perDayTotal: Int(totalPerDay) ?? 0) )
                    } label: {
                        Label("Done", systemImage: "flag.checkered")
                    }
                    
                    
                }
                

            }
            .padding(10)
            
        }
        
    }
    

    
    private func addItem() {
        showDialog = false
        withAnimation {
            let newItem = FundItem(id: UUID(), dateAdded: Date(), name: nameField, amount: Float(moneyField) ?? 0, note: notesField)
            modelContext.insert(newItem)
            
            nameField = ""
            moneyField = ""
            notesField = ""
            type = .breakfast
        }
    }
    
    private func upsertPerDiem(perDiem: UserPerDiem) {
        showTotal = false
        withAnimation {
            totalDays = perDiem.totalDays
            totalDailyAmount = perDiem.perDayTotal
            totalForPeriod = perDiem.dateRangeTotal
        }
    }
    
    private func calcDailyTotal() -> Double {
        var total: Float = 0
        
        items.forEach{item in
            total = total + item.amount
        }
        
        return Double(total)
    }
    
    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
    
    
}

struct CardView: View {
    var total: Double
    var perDiemTotal: Int
        
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Total: $" + String(total))
                    .font(.headline)
                Spacer()
                Label("Today", systemImage: "clock")
                    .padding(.trailing, 20)
            }
            .font(.caption)
        }
        .padding()
        .foregroundColor(figureOutColor(total: total, perDiemTotal: perDiemTotal))
    }
}

func figureOutColor(total: Double, perDiemTotal: Int ) -> Color {
    
    let percentageOfTotal = ((total / Double(perDiemTotal)) as Double)
    

    
   
   if(percentageOfTotal <= 0.25){
       return Color.green
   }else if (percentageOfTotal > 0.25 && percentageOfTotal <= 0.75){
       return Color.yellow
   }else{
       return Color.red
   }
}

#Preview {
    ContentView()
        .modelContainer(for: FundItem.self, inMemory: true)
}
