//
//  bleTableViewController.swift
//  bleModule
//
//  Created by Casey Brittain on 4/12/15.
//  Copyright (c) 2015 Casey Brittain. All rights reserved.
//

import UIKit
import CoreBluetooth

var activeCentralManager: CBCentralManager!
var peripheralDevice: CBPeripheral!
var devices: Dictionary<NSUUID, CBPeripheral> = [:]


class bleTableViewController: UITableViewController, CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDelegate, UITableViewDataSource {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Initialize central manager on load
        activeCentralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: BLE
    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        if central.state == CBCentralManagerState.PoweredOn {
            // Scan for peripherals if BLE is turned on
            central.scanForPeripheralsWithServices(nil, options: nil)
            println("Searching for BLE Devices")
        }
        else {
            // Can have different conditions for all states if needed - print generic message for now
            println("Bluetooth switched off or not initialized")
        }
    }
    
    // Check out the discovered peripherals to find Sensor Tag
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        
        // Get this device's UUID.
        let uuid = peripheral.identifier
        // Add this discovered peripheral to the peripheral dictionary.
        devices[uuid] = peripheral
        
        // Could create another Dictionary here, based on RSSI
        // let devices[RSSI] = peripheral
        // Might have a problem if two peripheral's have the same RSSI.

        // Since we might have discovered another device, let's refresh the list.
        self.tableView.reloadData()
        
        
        //let deviceName = "HMSoft"
        //let nameOfDeviceFound = (advertisementData as NSDictionary).objectForKey(CBAdvertisementDataLocalNameKey) as? NSString
        //println(RSSI)
    }
    
    // Discover services of the peripheral
    func centralManager(central: CBCentralManager!, didConnectPeripheral peripheral: CBPeripheral!) {
        // Discover services for the device.
        peripheralDevice.discoverServices(nil)
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverServices error: NSError!) {
        // Iterate through the services of a particular peripheral.
        for service in peripheralDevice.services {
            let thisService = service as! CBService
                // Let's see what characteristics this service has.
                peripheralDevice.discoverCharacteristics(nil, forService: thisService)
        }
    }
    
    func peripheral(peripheral: CBPeripheral!, didDiscoverCharacteristicsForService service: CBService!, error: NSError!) {
        // Check out her characteristics!
        
        // 0x01 data byte to enable sensor
        var enableValue = 1
        let enablyBytes = NSData(bytes: &enableValue, length: sizeof(UInt8))
        
        // check the uuid of each characteristic to find config and data characteristics
        for charateristic in service.characteristics {
            let thisCharacteristic = charateristic as! CBCharacteristic
                // Set notify for characteristics here.
        }
    }
    
    // Get data values when they are updated
    func peripheral(peripheral: CBPeripheral!, didUpdateValueForCharacteristic characteristic: CBCharacteristic!, error: NSError!) {
        
        // This function is run when data is received on a characteristic.
        
    }
    
    // If disconnected, start searching again
    func centralManager(central: CBCentralManager!, didDisconnectPeripheral peripheral: CBPeripheral!, error: NSError!) {
        println("Disconnected")
        central.scanForPeripheralsWithServices(nil, options: nil)
    }
    
    
// MARK: TableView
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Let's get a cell.
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as! UITableViewCell
        // Turn the device dictionary into an array.
        let discoveredPeripheralArray = devices.values.array
        // Set the main label of the cell to the name of the corresponding peripheral.
        cell.textLabel!.text = discoveredPeripheralArray[indexPath.row].name
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // Get an array of peripherals.
        let discoveredPeripheralArray = devices.values.array
        
        println(discoveredPeripheralArray[indexPath.row].name)
        
        // Set the peripheralDevice to the corresponding row selected.
        peripheralDevice = discoveredPeripheralArray[indexPath.row]
        // Attach the peripheral delegate.
        peripheralDevice.delegate = self
        // Stop looking for more peripherals.
        activeCentralManager.stopScan()
        // Connect to this peripheral.
        activeCentralManager.connectPeripheral(peripheralDevice, options: nil)

        
        
    }
}
