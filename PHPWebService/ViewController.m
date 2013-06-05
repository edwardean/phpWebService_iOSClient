//
//  ViewController.m
//  PHPWebService
//
//  Created by Edward on 13-6-4.
//  Copyright (c) 2013年 Lihang. All rights reserved.
//

#import "ViewController.h"
#import "MBProgressHUD.h"
@interface ViewController ()<ASIHTTPRequestDelegate>

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSLog(@"Want to redeem: %@",textField.text);
    
    // Get device unique ID
    UIDevice *device = [UIDevice currentDevice];
    NSString *uniqueIdentifier = [device uniqueIdentifier];
    
    // Start request
    NSString *code = textField.text;
    NSURL *url = [NSURL URLWithString:@"http://localhost/learnphp/index.php"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    [request setPostValue:@"1" forKey:@"rw_app_id"];
    [request setPostValue:code forKey:@"code"];
    [request setPostValue:@"test" forKey:@"device_id"];
    [request setDelegate:self];
    [request startAsynchronous];
    
    // Hide keyboard
    [textField resignFirstResponder];
    
    // Clear textfield's text
    textField.text = @"";
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Redeeming code...";
    
    return YES;
}

#pragma mark - ASIDelegate
- (void)requestFinished:(ASIHTTPRequest *)request {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSLog(@"request:%@ code:%d",request.responseString,request.responseStatusCode);
    if (request.responseStatusCode == 400) {
        _textView.text = @"Invalid code";
    } else if (request.responseStatusCode == 403) {
        _textView.text = @"Code already used";
    } else if (request.responseStatusCode == 200) {
        NSString *responseString = [request responseString];
        NSDictionary *responseDict = [responseString JSONValue];
        NSString *unlockCode = [responseDict objectForKey:@"unlock_code"];
        
        if ([unlockCode compare:@"com.razeware.test.unlock.cake"] == NSOrderedSame) {
            _textView.text = @"The cake is a lie!";
        } else {
            _textView.text = [NSString stringWithFormat:@"Received unexcepted unlock code: %@",unlockCode];
        }
    } else {
        _textView.text = @"Unexpected error";
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request {
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    NSError *error = [request error];
    _textView.text = error.localizedDescription;
}
- (void)dealloc {
    [_textView release];
    [super dealloc];
}
@end
