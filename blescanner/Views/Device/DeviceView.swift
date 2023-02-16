//
//  DeviceView.swift
//  blescanner
//
//  Created by Lyle Dean on 23/11/2022.
//

import SwiftUI
import CoreBluetooth

struct DeviceView: View {
    
    @StateObject private var viewModel: DeviceViewModel
    @State private var modeSelectionIsPresented = false
    @State private var didAppear = false

    //MARK: - Lifecycle
    
    init(peripheral: CBPeripheral) {
        let viewModel = DeviceViewModel(peripheral: peripheral)
        _viewModel = .init(wrappedValue: viewModel)
    }
    
    var body: some View {
        content()
            .onAppear {
                guard didAppear == false else {
                    return
                }
                didAppear = true
                viewModel.connect()
            }
            .actionSheet(isPresented: $modeSelectionIsPresented) {
                var buttons: [ActionSheet.Button] = []
                buttons.append(.cancel())
                return ActionSheet(title: Text("Select Mode"), message: nil, buttons: buttons)
            }
    }

    //MARK: - Private
    
    @ViewBuilder
    private func content() -> some View {
        if viewModel.isReady {
            VStack {
                ZStack{
                    Rectangle()
                        .frame(width: 100, height: 100, alignment: .center)
                        .foregroundColor(.red)
                        .cornerRadius(5)
                    
                    Circle()
                        .frame(width: 100, height: 100, alignment: .center)
                        .foregroundColor(.red)
                        .padding(.top, -100)
                    
                    Circle()
                        .frame(width: 100, height: 100, alignment: .center)
                        .foregroundColor(.red)
                        .padding(.trailing, -100)
                }.rotationEffect(Angle(degrees: -45))
                VStack(alignment: .leading, spacing: 16) {
                    Text(String(viewModel.state.heartRate))
                        .font(.system(size: 36))
                }
            }
        }
        else {
            Text("Connecting...")
        }
    }
}
