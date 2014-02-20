//
//  PauseViewController.h
//  noiseWarz
//
//  Created by Clay Ewing on 12/2/13.
//
//

#import <UIKit/UIKit.h>
#include "testApp.h"

@interface PauseViewController : UIViewController {
    testApp *noiseWarz;

}
- (IBAction)mainMenu:(id)sender;
- (IBAction)resumePlay:(id)sender;

@end
