//
//  ViewController.h
//  BluetoothLeo1
//
//  Created by Leo Simberg on 9/10/14.
//  Copyright (c) 2014 Leo Simberg. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BLEManager.h"

#define TI_KEYFOB_TX_POWER_LEVEL @"2A07"
#define TI_KEYFOB_ACC_ACTIVATE @"FFA1"
#define TI_KEYFOB_ACC_X_NOTIFY @"FFA3"
#define TI_KEYFOB_ACC_Z_NOTIFY @"FFA4"
#define TI_KEYFOB_ACC_Y_NOTIFY @"FFA5"

@interface ViewController : UIViewController <BLEManagerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *BleUIConnectButton;
@property (weak, nonatomic) IBOutlet UITextField *BleUIStatusText;
@property (weak, nonatomic) IBOutlet UITextField *BleUITxPowerText;
@property (weak, nonatomic) IBOutlet UITextField *BleUIAccXText;
@property (weak, nonatomic) IBOutlet UITextField *BleUIAccYText;
@property (weak, nonatomic) IBOutlet UITextField *BleUIAccZText;

- (IBAction)BleTstConnect:(id)sender;

@end

