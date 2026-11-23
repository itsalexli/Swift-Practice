//
//  ViewChallenges.swift
//  Countdowntimer1
//
//  Created by Alexander Li on 2026-11-23.
//

//Challenge 1: Ticker search box (TextField)

//Build a screen with:
//
//a TextField with the placeholder "Enter ticker", bound to a @State string
//a Text underneath that shows "Searching for: HOOD" (whatever's typed), updating live as you type
//if the field is empty, the Text says "Type a ticker" instead
//
//The format you need (from the reference):
//
//swift
//TextField(PLACEHOLDER, text: $STRING)
//
//Check that: typing updates the text instantly, and deleting everything shows "Type a ticker."
//
//Send me your code when it's done.

import SwiftUI
struct TickerView: View {
    @State private var searchTicker: String = ""
    var body: some View {
        VStack {
            TextField("Enter ticker", text: $searchTicker)
                .padding()
                .textFieldStyle(.roundedBorder)
                
            Text(searchTicker.isEmpty ? "Type a ticker": "Searching for: \(searchTicker)")
                .padding()
        }
        
    }
}



//Challenge 2: Buy confirmation (Stepper + .alert)
//
//Build a screen with:
//
//a Stepper for quantity, from 1 to 10, starting at 1, labelled "Shares: 3" (showing the current value)
//a Buy button that shows an alert:
//title: "Order placed"
//message: "Bought 3 shares of HOOD" (using the current quantity)
//one OK button
//
//The formats you need:
//
//swift
//Stepper(TITLE, value: $NUMBER, in: MIN...MAX)
//
//.alert(TITLE, isPresented: $BOOL) {
//    BUTTONS
//} message: {
//    TEXT
//}
//
//Remember: the alert needs its own @State Bool. The Buy button sets it to true, and SwiftUI sets it back to false when you tap OK.
//
//Check that: you change the quantity to 7 → tap Buy → the alert says "Bought 7 shares of HOOD" → tap OK → it closes.

struct Confirmation: View {
    @State private var val: Int = 0
    @State private var showAlert: Bool = false
    var body: some View {
        VStack {
            Stepper("Shares: ", value: $val, in: 1...10)
            Button("Buy") { showAlert = true }
        }
        .alert("Ordered placed!", isPresented: $showAlert) {
            Button("Ok") { showAlert = false }
        } message: {
            Text("Bought \(val) shares of HOOD")
        }
        
    }
}



struct Watchlist: View {
    @State private var showAlert: Bool = false
    @State private var count: Int = 5
    var body: some View {
        VStack {
            Text("Watchlist: \(count) stocks")
            Button("Clear watchlist") { showAlert = true }
        }
        .alert("Clear watchlist?", isPresented: $showAlert) {
            Button("Cancel", role: .cancel) { showAlert = false }
            Button("Clear", role: .destructive) { count = 0 }
        } message: {
            Text("This will remove \(count) stocks")
        }

    }
}


//Challenge 3: Time-range picker (Picker, segmented)
//
//Build a screen with:
//
//a segmented Picker with the options 1D, 1W, 1M, 1Y
//a Text underneath showing "Showing 1W chart", matching whichever option is selected
//1D selected at the start
//
//Format:
//
//swift
//Picker(TITLE, selection: $VALUE) {
//    VIEW.tag(VALUE_1)
//    VIEW.tag(VALUE_2)
//}
//.pickerStyle(.segmented)
//
//Hint: make the selection a String (@State private var range = "1D"), so each option's .tag is just its own text, like .tag("1W"). The tag type must match the selection type.
//
//Bonus (optional): instead of writing 4 options by hand, keep the options in an array, let ranges = ["1D", "1W", "1M", "1Y"], and build them with a ForEach.
//
//Check that: tapping each segment updates the text.


struct PickPrac: View {
    let pickedOptions = ["1D", "1W", "1M", "1Y"]
    @State private var selected = "1D"
    
    var body: some View {
        VStack {
            Picker("Selected", selection: $selected) {
                ForEach (pickedOptions, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(.segmented)
            Text("Selected \(selected)")
        }
    }
}


//Challenge 3b: Buy / Sell switcher
//
//Build a screen with:
//
//a segmented Picker with the options Buy and Sell, built from an array with ForEach
//Buy selected at the start
//a button underneath whose title matches the selection: "Buy HOOD" or "Sell HOOD"
//the button is green for Buy and red for Sell (.buttonStyle(.borderedProminent) + .tint with a ternary)
//everything inside a VStack
//
//Check that: switching the segment changes both the button's text and its color.
//
//Watch for: \.self (the backslash first), nothing extra after option in, and .pickerStyle(.segmented).


struct BuySell: View {
    @State private var selection: String = "BUY"
    let options: [String] = ["BUY", "SELL"]
    var body: some View {
        VStack {
            Picker("Pick option", selection: $selection) {
                ForEach(options, id: \.self) { option in
                    Text(option).tag(option)
                }
            }
            .pickerStyle(.segmented)
            Button("\(selection) HOOD") {

            }
            .tint(selection == "BUY" ? .green : .red)
            .buttonStyle(.borderedProminent)
        }
        
    }
}


//Challenge 4: Settings sheet (.sheet + @Binding + dismiss)
//
//Build:
//
//The main screen: a Text showing "Dark charts: On" or "Dark charts: Off", and a gear icon button (Image(systemName: "gear")) that opens a sheet
//The sheet's view (a separate struct, SettingsView): a Toggle "Dark charts", and a Done button that closes the sheet
//
//How the pieces connect (all from Part 3 and the views reference):
//
//The @State var darkCharts = false lives on the main screen, because it needs to show the value.
//SettingsView receives it as @Binding var darkCharts: Bool, and the main screen passes it in with $darkCharts. The toggle inside the sheet then changes the main screen's value.
//To show the sheet: a second @State Bool (showSettings) + .sheet(isPresented: $showSettings) { SettingsView(darkCharts: $darkCharts) }.
//To close it from inside: @Environment(\.dismiss) private var dismiss, then dismiss() in the Done button.
//
//Check that: you open the sheet → flip the toggle → tap Done → the main screen shows the new value. Swiping the sheet down should also close it.


#Preview {
   BuySell()
}
