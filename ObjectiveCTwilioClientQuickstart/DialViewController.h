//
//  DialViewController.h
//  ObjectiveCTwilioClientQuickstart
//
//  Created by Jeffrey Linwood on 8/29/16.
//  Copyright © 2016 Twilio, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <TwilioClient/TwilioClient.h>


@interface DialViewController : UIViewController <TCDeviceDelegate,
    TCConnectionDelegate, UITextFieldDelegate>

@end
