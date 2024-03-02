//
//  ContentView.swift
//  BetterRest
//
//  Created by Connor Hill on 2/7/24.
//

import CoreML
import SwiftUI

struct ContentView: View {
    //user input
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var numberOfCups = 0
    //alert
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    //challenge 3
    var bedTime: String {
        do {
            let config = MLModelConfiguration()
            let model = try YupperPupper(configuration: config)

            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Int64(Double(hour + minute)), estimatedSleep: sleepAmount, coffee: Int64(Double(numberOfCups)))
            let sleepTime = wakeUp - prediction.actualSleep
            
            let bedTimez = sleepTime.formatted(date: .omitted, time: .shortened)
            return bedTimez
        } catch {
            let bedTimez = "Sorry, there was a problem calculating your bedtime."
            return bedTimez
        }
    }
    
    //current day 7am instead of current time for default time to wake up
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("When do you want to wake up?") {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        
                }
                /*VStack(alignment: .trailing, spacing: -10) {
                    Text("When do you want to wake up?\t\t\t\t\t\t\t\t\t ")
                        .font(.headline)
                    
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }*/
                Section("Desired amount of sleep") {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                        
                }
                /*VStack(alignment: .leading, spacing: 0) {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                }*/
                Section("Daily coffee intake") {
                    Picker("^[\(numberOfCups + 1) cup](inflect: true)", selection: $numberOfCups) {
                        ForEach(1..<11) {
                            Text("^[\($0) cup](inflect: true)")
                        }
                    }
                    
                    /*Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 1...20)*/
                }
                /*VStack(alignment: .leading, spacing: 0) {
                    Text("Daily coffee intake")
                        .font(.headline)
                    
                    Stepper("^[\(coffeeAmount) cup](inflect: true)", value: $coffeeAmount, in: 1...20)
                }*/
                
                VStack {
                    Spacer()
                    Text("Your ideal bedtime is...")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.headline)
                        .padding()
                    Text(bedTime)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                    Spacer()
                    Spacer()
                }
            }.navigationTitle("BetterRest")
                /*.toolbar {
                    Button("Calculate", action: calculateBedtime)
                }
                .alert(alertTitle, isPresented: $showingAlert) {
                    Button("OK") { }
                } message: {
                    Text(bedTime)
                }*/
        }
    }
    
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try YupperPupper(configuration: config)

            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Int64(Double(hour + minute)), estimatedSleep: sleepAmount, coffee: Int64(Double(coffeeAmount)))
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your ideal bedtime is…"
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        
        showingAlert = true
    }
}

#Preview {
    ContentView()
}
