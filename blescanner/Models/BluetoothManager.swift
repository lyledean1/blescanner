//
//  BluetoothManager.swift
//  blescanner
//
//  Created by Lyle Dean on 23/11/2022.
//

import Combine
import CoreBluetooth

final class BluetoothManager: NSObject {
    
    static let shared: BluetoothManager = .init()
    
    var stateSubject: PassthroughSubject<CBManagerState, Never> = .init()
    var peripheralSubject: PassthroughSubject<CBPeripheral, Never> = .init()
    var servicesSubject: PassthroughSubject<[CBService], Never> = .init()
    var characteristicsSubject: PassthroughSubject<(CBService, [CBCharacteristic]), Never> = .init()
    var characteristicSubject: PassthroughSubject<CBCharacteristic, Never> = .init()

    private var centralManager: CBCentralManager!

    //MARK: - Lifecycle
    
    func start() {
        centralManager = .init(delegate: self, queue: .main)
    }
    
    func scan() {
        centralManager.scanForPeripherals(withServices: nil)
    }
    
    func connect(_ peripheral: CBPeripheral) {
        centralManager.stopScan()
        peripheral.delegate = self
        centralManager.connect(peripheral)
    }
}

extension BluetoothManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        stateSubject.send(central.state)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        peripheralSubject.send(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.discoverServices(nil)
    }
}

extension BluetoothManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else {
            return
        }
        servicesSubject.send(services)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        for characteristic in service.characteristics! {
            if characteristic.uuid.uuidString == "2A37" {
                peripheral.setNotifyValue(true, for: characteristic)
            }
        }
        characteristicsSubject.send((service, characteristics))
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        characteristicSubject.send(characteristic)
        if characteristic.uuid.uuidString == "2A37" {
             let heartRate = deriveBeatsPerMinute(using: characteristic)
        }
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
