//
//  DialViewController.m
//  ObjectiveCTwilioClientQuickstart
//
//  Created by Jeffrey Linwood on 8/29/16.
//  Copyright © 2016 Twilio, Inc. All rights reserved.
//

#import "DialViewController.h"

#define TOKEN_URL @"TOKEN_URL"

@interface DialViewController ()
@property (nonatomic, strong) TCDevice *device;
@property (nonatomic, strong) TCConnection *connection;

@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UITextField *dialTextField;
@property (weak, nonatomic) IBOutlet UIButton *hangUpButton;
@property (weak, nonatomic) IBOutlet UIButton *dialButton;

@end

@implementation DialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self retrieveToken];
    self.navigationItem.title = @"Quickstart";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Initialization methods
- (void) initializeTwilioDevice:(NSString*)token {
    self.device = [[TCDevice alloc] initWithCapabilityToken:token delegate:self];
    self.dialButton.enabled = true;
}

- (void) retrieveToken {
    // Create a GET request to the capability token endpoint
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSURL *url = [NSURL URLWithString:TOKEN_URL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable responseData, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (responseData) {
            NSError *error = nil;
            NSDictionary *responseObject = [NSJSONSerialization JSONObjectWithData:responseData options:0 error:&error];
            if (responseObject) {
                if (responseObject[@"identity"]) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.navigationItem.title = responseObject[@"identity"];
                    });
                }
                if (responseObject[@"token"]) {
                    [self initializeTwilioDevice:responseObject[@"token"]];
                }
            } else {
                [self displayError:[error localizedDescription]];
            }
        } else {
            [self displayError:[error localizedDescription]];
        }
    }];
    [task resume];
}

#pragma mark Utility Methods
- (void) displayError:(NSString*)errorMessage {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Error" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark TCDeviceDelegate

- (void)device:(TCDevice *)device didStopListeningForIncomingConnections:(NSError *)error {
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
    }
}

- (void)deviceDidStartListeningForIncomingConnections:(TCDevice *)device {
    self.statusLabel.text = @"Started listening for incoming connections";
}

- (void)device:(TCDevice *)device didReceiveIncomingConnection:(TCConnection *)connection {
    if (connection.parameters) {
        NSString *from = connection.parameters[@"From"];
        NSString *message = [NSString stringWithFormat:@"Incoming call from %@",from];
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Incoming Call" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *acceptAction = [UIAlertAction actionWithTitle:@"Accept" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            connection.delegate = self;
            [connection accept];
            self.connection = connection;
        }];
        UIAlertAction *declineAction = [UIAlertAction actionWithTitle:@"Decline" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [connection reject];
        }];

        [alertController addAction:acceptAction];
        [alertController addAction:declineAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
}



#pragma mark TCConnectionDelegate
- (void)connection:(TCConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"%@",[error localizedDescription]);
}

- (void)connectionDidStartConnecting:(TCConnection *)connection {
    self.statusLabel.text = @"Started connecting....";
}

- (void)connectionDidConnect:(TCConnection *)connection {
    self.statusLabel.text = @"Connected";
    self.hangUpButton.enabled = true;
}

- (void)connectionDidDisconnect:(TCConnection *)connection {
    self.statusLabel.text = @"Disconnected";
    self.dialButton.enabled = true;
    self.hangUpButton.enabled = false;
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self dial:self.dialTextField];
    [self.dialTextField resignFirstResponder];
    return YES;
}

#pragma mark IB Actions
- (IBAction)hangUp:(id)sender {
    if (self.connection) {
        [self.connection disconnect];
    }
}

- (IBAction)dial:(id)sender {
    if (self.device) {
        [self.device connect:@{@"To":self.dialTextField.text} delegate:self];
        self.dialButton.enabled = NO;
        [self.dialTextField resignFirstResponder];
    }
}



@end
