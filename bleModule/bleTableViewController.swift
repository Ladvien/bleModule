//
//  bleTableViewController.swift
//  bleModule
//
//  Created by Casey Brittain on 4/12/15.
//  Copyright (c) 2015 Casey Brittain. All rights reserved.
//

import UIKit
import CoreBluetooth

var activeCentralManager: CBCentralManager?
var peripheralDevice: CBPeripheral?
var devices: Dictionary<NSUUID, CBPeripheral> = [:]
var deviceName: String?
var deviceCharacteristics: CBCharacteristic!

class bleTableViewController: UITableViewController, CBCentralManagerDelegate, CBPeripheralDelegate, UITableViewDelegate, UITableViewDataSource {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // Initialize central manager on load
        devices.removeAll(keepCapacity: false)
        println(devices)
        activeCentralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: BLE
    
    func centralManagerDidUpdateState(central: CBCentralManager?) {
        if let central = central{
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
        
    }
    
    // Check out the discovered peripherals to find Sensor Tag
    func centralManager(central: CBCentralManager?, didDiscoverPeripheral peripheral: CBPeripheral?, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
        
        if let central = central{
            if let peripheral = peripheral{
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
        }
        

    }
    
    // Discover services of the peripheral
    func centralManager(central: CBCentralManager?, didConnectPeripheral peripheral: CBPeripheral?) {
        if let central = central{
            if let peripheral = peripheral{
                // Discover services for the device.
                if let peripheralDevice = peripheralDevice{
                    peripheralDevice.discoverServices(nil)
                    if let navigationController = navigationController{
                        navigationItem.title = "Connected to \(deviceName)"
                    }
                }
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral?, didDiscoverServices error: NSError!) {

        if let peripheral = peripheral{
        // Iterate through the services of a particular peripheral.
            for service in peripheral.services {
                let thisService = service as? CBService
                // Let's see what characteristics this service has.
                if let thisService = thisService{
                    peripheral.discoverCharacteristics(nil, forService: thisService)
                    if let navigationController = navigationController{
                    navigationItem.title = "Discovered Service for \(deviceName)"
                    }
                }
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral?, didDiscoverCharacteristicsForService service: CBService?, error: NSError?) {
       
        if let peripheral = peripheral{
            if let service = service{
                // Check out her characteristics!
                
                // 0x01 data byte to enable sensor
                var enableValue = 1
                let enablyBytes = NSData(bytes: &enableValue, length: sizeof(UInt8))
                
                
                
                // check the uuid of each characteristic to find config and data characteristics
                for charateristic in service.characteristics {
                    let thisCharacteristic = charateristic as! CBCharacteristic
                        // Set notify for characteristics here.
                
                    peripheral.setNotifyValue(true, forCharacteristic: thisCharacteristic)
                    println(thisCharacteristic)
                    
            
                    if let navigationController = navigationController{
                        navigationItem.title = "Discovered Characteristic for \(deviceName)"
                    }
                    deviceCharacteristics = thisCharacteristic
                }
                
                writeValue("Blh")
                // Now that we are setup, return to main view.
                if let navigationController = navigationController{
                    //navigationController.popViewControllerAnimated(true)
                }
            }
        }
    }
    
    // Get data values when they are updated
    func peripheral(peripheral: CBPeripheral?, didUpdateValueForCharacteristic characteristic: CBCharacteristic?, error: NSError!) {
        println("Got some!")
    }
    
    func cancelConnection(){
        if let activeCentralManager = activeCentralManager{
            println("Died!")
            if let peripheralDevice = peripheralDevice{
                //println(peripheralDevice)
                activeCentralManager.cancelPeripheralConnection(peripheralDevice)
            }
        }
    }
    
    // If disconnected, start searching again
    func centralManager(central: CBCentralManager?, didDisconnectPeripheral peripheral: CBPeripheral?, error: NSError?) {
        if let central = central{
            if let peripheral = peripheral{
                println("Disconnected")
                central.scanForPeripheralsWithServices(nil, options: nil)
            }
        }
    }
    
// MARK: TableView
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Let's get a cell.
        let cell = tableView.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell
        // Turn the device dictionary into an array.
        let discoveredPeripheralArray = devices.values.array
        // Set the main label of the cell to the name of the corresponding peripheral.
        if let cell = cell{
            cell.textLabel?.text = discoveredPeripheralArray[indexPath.row].name
        }

        
        return cell!
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        
        if (devices.count > 0){
            // Get an array of peripherals.
            let discoveredPeripheralArray = devices.values.array
            
            println(discoveredPeripheralArray[indexPath.row].name)
            
            // Set the peripheralDevice to the corresponding row selected.
            //activeCentralManager.cancelPeripheralConnection(peripheralDevice)
            peripheralDevice = discoveredPeripheralArray[indexPath.row]
            
            
            // Attach the peripheral delegate.
            if let peripheralDevice = peripheralDevice{
                peripheralDevice.delegate = self
                deviceName = peripheralDevice.name!
            }
            else
            {
                deviceName = " "
            }
            
            if let activeCentralManager = activeCentralManager{
                // Stop looking for more peripherals.
                activeCentralManager.stopScan()
                // Connect to this peripheral.
                activeCentralManager.connectPeripheral(peripheralDevice, options: nil)
                if let navigationController = navigationController{
                    navigationItem.title = "Connecting \(deviceName)"
                }
            }
        }
    }
    
    func writeValue(data: String){
        let data = (data as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        if let peripheralDevice = peripheralDevice{
            if let deviceCharacteristics = deviceCharacteristics{
                peripheralDevice.writeValue(data, forCharacteristic: deviceCharacteristics, type: CBCharacteristicWriteType.WithoutResponse)
                println("Wrote 2")
            }
            
        }
    }
    
    class func writeValue(data: String){
        let data = (data as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        if let peripheralDevice = peripheralDevice{
            if let deviceCharacteristics = deviceCharacteristics{
                peripheralDevice.writeValue(data, forCharacteristic: deviceCharacteristics, type: CBCharacteristicWriteType.WithoutResponse)
                println("Wrote 2")
            }
            
        }
    }
    
}
