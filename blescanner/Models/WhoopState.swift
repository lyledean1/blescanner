//
//  WhoopState.swift
//  blescanner
//
//  Created by Lyle Dean on 23/11/2022.
//

import Foundation

final class WhoopState: ObservableObject {
    
    @Published var isOn = false
    @Published var heartRate: Int = 0
}
