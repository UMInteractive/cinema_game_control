//
//  SetupViewController.h
//  noiseWarz
//
//  Created by Clay Ewing on 12/2/13.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include "testApp.h"

@interface SetupViewController : UIViewController <UIActionSheetDelegate, UIAlertViewDelegate> {
    testApp *noiseWarz;
    NSMutableArray *bonjourList;
}
-(void) updateBonjourList:(NSString *)bonjourAddress;
- (IBAction)joinGameSelected:(id)sender;
- (IBAction)touchDown:(id)sender;
- (IBAction)credits:(id)sender;

@end
