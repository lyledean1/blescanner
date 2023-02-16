# Bluetooth Scanner with Swift UI

Example blescanner using SwiftUI with a Whoop heart rate monitor

Uses:
- `Core Bluetooth` for BLE connection
- `Combine` for state management 

Aim was to reverse engineer a whoop band https://www.whoop.com/, then build a SwiftUI that updated on each new reading of the heart rate from the band.

## Overview

Very simple UI that updates based off heart rate from the Whoop device

https://user-images.githubusercontent.com/20296911/219461364-f9e5e814-cf19-4c43-87a4-c1408fa3a4e7.mov

## Whoop instructions

Can be found in /blescanner/Views/Device/DeviceViewModel.swift
