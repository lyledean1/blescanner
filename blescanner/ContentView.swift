//
//  ContentView.swift
//  blescanner
//
//  Created by Lyle Dean on 23/11/2022.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject private var viewModel: MainViewModel = .init()
    @State private var devicesViewIsPresented = false

    var body: some View {
        NavigationView {
             content()
                 .navigationTitle(viewModel.peripheral?.name ?? "Main")
                 .toolbar {
                     ToolbarItem(placement: .navigationBarTrailing) {
                         Button(action: add) {
                             Image(systemName: "plus")
                         }
                         .disabled(viewModel.state != .poweredOn)
                     }
                 }
         }
        .onAppear {
            viewModel.start()
        }
        .sheet(isPresented: $devicesViewIsPresented) {
            DevicesView(peripheral: $viewModel.peripheral)
        }
    }
    
    @ViewBuilder
    private func content() -> some View {
        if viewModel.state != .poweredOn {
            Text("Enable Bluetooth to start scanning")
        }
        else if let peripheral = viewModel.peripheral {
            DeviceView(peripheral: peripheral)
        }
        else {
            Text("There are no connected devices")
        }
    }
    
    private func add() {
        devicesViewIsPresented = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
