//
//  DeviceViewModel.swift
//  blescanner
//
//  Created by Lyle Dean on 23/11/2022.
//

import CoreBluetooth
import Combine

final class DeviceViewModel: ObservableObject {

    @Published var isReady = false
    @Published var state: WhoopState = .init()

    private enum Constants {
        static let readCharacteristicUUID: CBUUID = .init(string: "2A37")
    }

    private lazy var manager: BluetoothManager = .shared
    private lazy var cancellables: Set<AnyCancellable> = .init()

    private let peripheral: CBPeripheral
    private var readCharacteristic: CBCharacteristic?
    private var writeCharacteristic: CBCharacteristic?

    //MARK: - Lifecycle
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
    }

    deinit {
        cancellables.removeAll()
    }

    func connect() {
        manager.servicesSubject
            .sink { [weak self] services in
                services.forEach { service in
                    // uuid = "Heart Rate" -> String
                    if service.uuid.uuidString == "180D" {
                        self?.peripheral.discoverCharacteristics(nil, for: service)
                    }
                }
            }
            .store(in: &cancellables)

        manager.characteristicsSubject
            .filter {
                return $0.0.uuid.uuidString == "180D"
            }
           .compactMap {
               return $0.1.first(where: \.uuid == Constants.readCharacteristicUUID)
           }
            .sink { [weak self] characteristic in
                self?.update()
            }
            .store(in: &cancellables)
        
        manager.characteristicSubject.sink {
            self.state.heartRate = self.deriveBeatsPerMinute(using: $0)
            self.update()
            
        }.store(in: &cancellables)

        manager.connect(peripheral)
    }

    private func update() {
        self.state = state
        self.isReady = true
    }
    
    func deriveBeatsPerMinute(using heartRateMeasurementCharacteristic: CBCharacteristic) -> Int {
        
        let heartRateValue = heartRateMeasurementCharacteristic.value!
        // convert to an array of unsigned 8-bit integers
        let buffer = [UInt8](heartRateValue)
 
        // UInt8: "An 8-bit unsigned integer value type."
        
        // the first byte (8 bits) in the buffer is flags
        // (meta data governing the rest of the packet);
        // if the least significant bit (LSB) is 0,
        // the heart rate (bpm) is UInt8, if LSB is 1, BPM is UInt16
        if ((buffer[0] & 0x01) == 0) {
            // second byte: "Heart Rate Value Format is set to UINT8."
            return Int(buffer[1])
        } else { // I've never seen this use case, so I'll
                 // leave it to theoreticians to argue
            // 2nd and 3rd bytes: "Heart Rate Value Format is set to UINT16."
            return -1
        }
    }
}

func ==<Root, Value: Equatable>(lhs: KeyPath<Root, Value>, rhs: Value) -> (Root) -> Bool {
    { $0[keyPath: lhs] == rhs }
}

func ==<Root, Value: Equatable>(lhs: KeyPath<Root, Value>, rhs: Value?) -> (Root) -> Bool {
    { $0[keyPath: lhs] == rhs }
}
