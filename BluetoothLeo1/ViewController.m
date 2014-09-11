//
//  ViewController.m
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

#import "ViewController.h"
#import "BLEManager.h"

@interface ViewController (){
    BLEManager *manager;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    manager = [[BLEManager alloc] init];
    manager.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)BleTstConnect:(id)sender{
    NSLog(@"Connect button pressed");
    if (manager.connected) {
        [manager disconnect];
    } else {
        [manager connectByProximity];
    }
}


//***********************************//
// BLEManagerDelegate methods
//***********************************//
-(void) devStatusUpdated:(int)status{
    NSLog(@"Status: %i", status);
    NSString *msg = @"";
    switch (status){
        case BLEMngStatusStartScanning:
            msg = @"Approximate your device";
            break;
        case BLEMngStatusDiscServChar:
            msg = @"Discovering services and characteristics";
            break;
        case BLEMngStatusConnected:
            msg = @"Connected";
            break;
        case BLEMngStatusDisconnected:
            msg = @"";
            [self disableData];
            [self.BleUIConnectButton setTitle:@"Connect by proximity" forState:UIControlStateNormal];
            break;
        case BLEMngStatusReady:
            msg = manager.deviceName;
            [self.BleUIConnectButton setTitle:@"Disconnect" forState:UIControlStateNormal];
            [self enableData];
            break;
        case BLEMngStatusStopScanning:
            msg = @"Stop Scan";
            break;
        default:
            msg = @"Unknown status";
    }
    [self.BleUIStatusText setText:msg];
}

-(void)enableData{
    [manager readCharacteristic:TI_KEYFOB_TX_POWER_LEVEL];
    NSInteger n_one = 1;
    NSData *payload = [NSData dataWithBytes:&n_one length:1];
    NSLog(@"aa: %@",payload);
    [manager writeCharacteristic:TI_KEYFOB_ACC_ACTIVATE data:payload];
    [manager setNotification:TI_KEYFOB_ACC_X_NOTIFY value:YES];
    [manager setNotification:TI_KEYFOB_ACC_Y_NOTIFY value:YES];
    [manager setNotification:TI_KEYFOB_ACC_Z_NOTIFY value:YES];
}

-(void)disableData{
    [self.BleUITxPowerText setText:@""];
    [self.BleUIAccXText setText:@""];
    [self.BleUIAccYText setText:@""];
    [self.BleUIAccZText setText:@""];
}


-(void) readValueUpdated:(NSString *)characteristicID data:(NSData *)data{
    char  value = *(char*)([data bytes]);
    if ([characteristicID isEqualToString:TI_KEYFOB_TX_POWER_LEVEL]){
        [self.BleUITxPowerText setText:[NSString stringWithFormat:@" %i dBm", value]];
    } else if ([characteristicID isEqualToString:TI_KEYFOB_ACC_X_NOTIFY]){
        [self.BleUIAccXText setText:[NSString stringWithFormat:@" %i", value]];
    } else if ([characteristicID isEqualToString:TI_KEYFOB_ACC_Y_NOTIFY]){
        [self.BleUIAccYText setText:[NSString stringWithFormat:@" %i", value]];
    } else if ([characteristicID isEqualToString:TI_KEYFOB_ACC_Z_NOTIFY]){
        [self.BleUIAccZText setText:[NSString stringWithFormat:@" %i", value]];
    }
}


@end
