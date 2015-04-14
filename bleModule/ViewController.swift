//
//  ViewController.swift
//  bleModule
//
//  Created by Casey Brittain on 4/12/15.
//  Copyright (c) 2015 Casey Brittain. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    @IBAction func sendButton(sender: AnyObject) {
        if let text = sendTextField{
            writeValue(sendTextField.text)
        }
    }
    
    @IBOutlet weak var sendTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        if let activeCentralManager = activeCentralManager{
            activeCentralManager.delegate = self
        }
        if let peripheralDevice = peripheralDevice{
            peripheralDevice.delegate = self
        }
        
        var timer = NSTimer.scheduledTimerWithTimeInterval(0.4, target: self, selector: Selector("update"), userInfo: nil, repeats: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager?) {
        if let central = central{
            if central.state == CBCentralManagerState.PoweredOn {
                println("Bluetooth ON")
            }
            else {
                // Can have different conditions for all states if needed - print generic message for now
                println("Bluetooth switched off or not initialized")
            }
        }
        
    }
    
    func update(){
        if let peripheralDevice = peripheralDevice{
            peripheralDevice.readRSSI()
        }
        
    }
    
    func peripheral(peripheral: CBPeripheral!, didReadRSSI RSSI: NSNumber!, error: NSError!) {
        if(RSSI != nil){
            println(RSSI)
        }
        
    }
    
    // Get data values when they are updated
    func peripheral(peripheral: CBPeripheral?, didUpdateValueForCharacteristic characteristic: CBCharacteristic?, error: NSError!) {
        
        if let characteristicValue = characteristic?.value{
            var datastring = NSString(data: characteristicValue, encoding: NSUTF8StringEncoding)
            if let datastring = datastring{
                navigationItem.title = datastring as String
            }
        }
    }
    
    // Write function
    func writeValue(data: String){
        let data = (data as NSString).dataUsingEncoding(NSUTF8StringEncoding)
        if let peripheralDevice = peripheralDevice{
            if let deviceCharacteristics = deviceCharacteristics{
                peripheralDevice.writeValue(data, forCharacteristic: deviceCharacteristics, type: CBCharacteristicWriteType.WithoutResponse)
            }
        }
    }
    
    
}



