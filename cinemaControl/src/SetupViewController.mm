//
//  SetupViewController.m
//  noiseWarz
//
//  Created by Clay Ewing on 12/2/13.
//
//

#import "SetupViewController.h"

@interface SetupViewController ()
@end
@implementation SetupViewController
@synthesize joinButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{


     [super viewDidLoad];
    noiseWarz = (testApp*)ofGetAppPtr();
    [joinButton.layer setBorderWidth:1.0f];
    bonjourList = [[NSMutableArray alloc] init];

    [bonjourList addObject:@"192.168.1.1"];
    [bonjourList addObject:@"192.168.1.12"];
  
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)joinGameSelected:(id)sender {
    NSString *actionSheetTitle = @"Select a NERDLab Server"; //Action Sheet Title
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:actionSheetTitle
                                  delegate:self
                                  cancelButtonTitle:nil
                                  destructiveButtonTitle:nil
                                  otherButtonTitles: nil];
    for (int i = 0; i < [bonjourList count]; i++) {
        [actionSheet addButtonWithTitle:[bonjourList objectAtIndex:i]];
    }
    [actionSheet addButtonWithTitle:@"Manually Enter IP"];

    actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancel"];
    [actionSheet showInView:self.view];
    
    
    /*
    noiseWarz->playerNumber = 1;
    int selectedRow = [bonjourPicker selectedRowInComponent:0];
    noiseWarz->host = ofxNSStringToString([bonjourList objectAtIndex:selectedRow]);
    //        noiseWarz->host = ofxNSStringToString([hostAddressTextField text]);
    noiseWarz->play();
*/
 /*
    if ([hostAddressTextField.text length] > 0) {
        [hostAddressTextField resignFirstResponder];
        [nameTextField resignFirstResponder];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];

    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Host Required" message: @"You need to enter the network address for the NERDLab server" delegate: nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
*/
 }
- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
  //  int manualButtonIndex = [bonjourList count] + 1;
    if (buttonIndex == [bonjourList count]) {
        //manual entry
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Manual Entry" message:@"Enter the IP address of the NERDLab Server" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField * alertTextField = [alertView textFieldAtIndex:0];
        alertTextField.keyboardType = UIKeyboardTypeDecimalPad;
        alertTextField.placeholder = @"IP Address";
        alertView.tag = 200;
        [alertView show];
    }
    else if (buttonIndex != [bonjourList count] + 1){
        //use discovered IP
        noiseWarz->host = ofxNSStringToString([bonjourList objectAtIndex:buttonIndex]);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Player Name" message:@"What's your name?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Play", nil];
        alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField * alertTextField = [alertView textFieldAtIndex:0];
        alertTextField.placeholder = @"Name";
        alertView.tag = 100;
        [alertView show];

    }
    else {
        NSLog(@"canceled?");
    }

}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case 100:
            //player name
            noiseWarz->play([[alertView textFieldAtIndex:0] text]);
            break;
        case 200:
            if (buttonIndex != 0)  // 0 == the cancel button
            {
                noiseWarz->host = ofxNSStringToString([[alertView textFieldAtIndex:0] text]);
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Player Name" message:@"What's your name?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Play", nil];
                alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
                UITextField * alertTextField = [alertView textFieldAtIndex:0];
                alertTextField.placeholder = @"Name";
                alertView.tag = 100;
                [alertView show];
            }

            break;
        default:
            break;
    }
}


- (IBAction)touchDown:(id)sender {
    //  [nameTextField resignFirstResponder];
}

-(void) updateBonjourList :(NSString *)bonjourAddress{
    [bonjourList addObject:bonjourAddress];
    //[bonjourPicker reloadAllComponents];
}



- (void)dealloc {
    // [bonjourPicker release];
    [super dealloc];
}
- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
