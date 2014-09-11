//
//  BLEManager.m
//  BluetoothLeo1
//
//  Created by Leo Simberg on 9/10/14.
//  Copyright (c) 2014 Leo Simberg. All rights reserved.
//
//  * These code is a Proof of concept and it does not verify all ble fail conditions, for instance
//  when the bluetooth is disable
//
//  * To connect, you just need to approximate the device and the phone
//
//

#import "BLEManager.h"
#import "BLEHelper.h"

@implementation BLEManager

@synthesize cbCentralManager;

int const RSSI_CONNECT = -45;
int const TIME_STOP_SCAN = 10;

-(id)init{
    NSLog(@"BLE -> Init BLEManager");
    self.scanning = false;
    cbCentralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:nil];
    return self;
}


/*****************************************************************************/
// Central Manager Events
/*****************************************************************************/

- (void)centralManager:(CBCentralManager *)central
 didDiscoverPeripheral:(CBPeripheral *)peripheral
     advertisementData:(NSDictionary *)advertisementData
                  RSSI:(NSNumber *)RSSI {
    //NSLog(@"Discovered %@ - RSSI: %@", peripheral.name, RSSI);
    int rssi = [RSSI intValue];
    if ( rssi > RSSI_CONNECT && rssi < 0) { // < 0 because sometimes the IPhone find a ghost device with RSSI = 127
        self.peripheral = peripheral;
        [self stopScan];
        NSLog(@"BLE -> Discovered %@ - RSSI: %@ - advertisementData: %@", peripheral.name, RSSI, advertisementData);
        self.deviceName = peripheral.name;
        self.peripheral.delegate = self;
        [cbCentralManager connectPeripheral:peripheral options:nil];
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"BLE -> CBCentralManager status changed: %li - %@", central.state, [BLEHelper centralManagerStateToString:central.state]);
}

- (void)centralManager:(CBCentralManager *)central
        didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"BLE -> Peripheral connected - peripheral name");
    self.connected = true;
    [[self delegate] devStatusUpdated:BLEMngStatusConnected];
    [self.peripheral discoverServices:nil];
}


- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    self.connected = false;
    [[self delegate] devStatusUpdated:BLEMngStatusDisconnected];
}




/*****************************************************************************/
// Peripheral Events
/*****************************************************************************/

- (void)peripheral:(CBPeripheral *)peripheral
        didDiscoverServices:(NSError *)error {
    self.characteristicsMap = [[NSMutableDictionary alloc]init];
    if (!error) {
        [[self delegate] devStatusUpdated:BLEMngStatusDiscServChar];
        [self getAllCharacteristics];
    } else {
        NSLog(@"BLE -> Service discovery was unsuccessfull !");
    }
}

- (void) getAllCharacteristics{
    for (int i=0; i < self.peripheral.services.count; i++) {
        CBService *service = [self.peripheral.services objectAtIndex:i];
        //NSLog(@"BLE -> Fetching characteristics for service with UUID : %@", service.UUID);
        [self.peripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (!error) {
        NSLog(@"BLE -> Characteristics of service with UUID : %@ found",service.UUID.UUIDString);
        for(int i=0; i < service.characteristics.count; i++) {
            CBCharacteristic *charac = [service.characteristics objectAtIndex:i];
            [self.characteristicsMap setObject:charac forKey:charac.UUID.UUIDString];
            NSLog(@"BLE -> Found characteristic %@ - %@", charac.UUID.UUIDString, charac.UUID);
            CBService *serv = [peripheral.services objectAtIndex:(peripheral.services.count - 1)];
            if([BLEHelper compareCBUUID:service.UUID UUID2:serv.UUID]) {
                NSLog(@"BLE -> Finished discovering characteristics");
                [[self delegate] devStatusUpdated:BLEMngStatusReady];
            }
        }
    }
    else {
        NSLog(@"BLE -> Characteristic discovery was unsuccessfull !");
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!error) {
        NSLog(@"BLE -> Changing notification for: %@", characteristic.UUID);
    } else {
        NSLog(@"BLE -> Error changing notification state: %@",
              [error localizedDescription]);
    }
}

//UpdateValue
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!error) {
        NSData *data = characteristic.value;
        NSLog(@"BLE -> data received: %@", data);
        [[self delegate] readValueUpdated:characteristic.UUID.UUIDString data:data];
    } else {
        NSLog(@"BLE -> Read characteristic %@ was unsuccessfull !", characteristic.UUID);
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    
}


/*****************************************************************************/
// Ble Manager Methods
/*****************************************************************************/

- (void)startScan{
    if (self.scanning == true || self.connected == true) return;
    self.scanning = true;
    NSLog(@"BLE -> Starting Scan");
    [[self delegate] devStatusUpdated:BLEMngStatusStartScanning];
    [cbCentralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey : @YES}];
    
    //Stop scan after TIME_SCAN
    [NSTimer scheduledTimerWithTimeInterval:TIME_STOP_SCAN target:self selector:@selector(stopScan) userInfo:nil repeats:NO];
}

- (void)stopScan{
    if (self.scanning == false) return;
    self.scanning = false;
    NSLog(@"BLE -> Stopping Scan");
    [[self delegate] devStatusUpdated:BLEMngStatusStopScanning];
    [cbCentralManager stopScan];
}

- (void)disconnect{
    [cbCentralManager cancelPeripheralConnection:self.peripheral];
}

/*
   Connect with the first device found with RSSI bigger than the RSSI_CONNECT
*/
- (void)connectByProximity{
    [self startScan];
}

-(void)readCharacteristic:(NSString *)characteristicUUID{
    CBCharacteristic *charac = [self.characteristicsMap valueForKey:characteristicUUID];
    if (charac == nil){
        NSLog(@"BLE -> Error: Characteristic with uuid %@ not found!", characteristicUUID);
        return;
    }
    [self.peripheral readValueForCharacteristic:charac];
}


-(void)writeCharacteristic:(NSString *)characteristicUUID data:(NSData *)data{
    CBCharacteristic *charac = [self.characteristicsMap valueForKey:characteristicUUID];
    [self.peripheral writeValue:data forCharacteristic:charac type:CBCharacteristicWriteWithResponse];
}


-(void)setNotification:(NSString *)characteristicUUID value:(BOOL)value{
    CBCharacteristic *charac = [self.characteristicsMap valueForKey:characteristicUUID];
    [self.peripheral setNotifyValue:value forCharacteristic:charac];
}


@end