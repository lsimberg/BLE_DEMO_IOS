//
//  BLEManager.h
//  BluetoothLeo1
//
//  Created by Leo Simberg on 9/10/14.
//  Copyright (c) 2014 Leo Simberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreBluetooth/CBService.h>

@protocol BLEManagerDelegate
@required
-(void) devStatusUpdated:(int)status;
-(void) readValueUpdated:(NSString *)characteristicID data:(NSData *)data;
@end

enum {
    BLEMngStatusStartScanning,
    BLEMngStatusStopScanning,
    BLEMngStatusDiscServChar,
    BLEMngStatusConnected,
    BLEMngStatusDisconnected,
    BLEMngStatusReady
};

@interface BLEManager : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate> {
}

@property (strong, nonatomic) CBCentralManager *cbCentralManager;
@property (strong, nonatomic) CBPeripheral *peripheral;
@property (strong, nonatomic) NSString *deviceName;
@property (strong, nonatomic) NSMutableDictionary *characteristicsMap;

@property (nonatomic) BOOL scanning;
@property (nonatomic) BOOL connected;

@property (nonatomic,assign) id <BLEManagerDelegate> delegate;

@property (nonatomic)   BOOL key1;
@property (nonatomic)   BOOL key2;
@property (nonatomic)   char x;
@property (nonatomic)   char y;
@property (nonatomic)   char z;


-(void)connectByProximity;
-(void)disconnect;
-(void)readCharacteristic:(NSString *)characteristicUUID;
-(void)writeCharacteristic:(NSString *)characteristicUUID data:(NSData *)data;
-(void)setNotification:(NSString *)characteristicUUID value:(BOOL)value;


@end