//
//  PauseViewController.m
//  noiseWarz
//
//  Created by Clay Ewing on 12/2/13.
//
//

#import "PauseViewController.h"

@interface PauseViewController ()

@end

@implementation PauseViewController

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
    // Do any additional setup after loading the view from its nib.
    noiseWarz = (testApp*)ofGetAppPtr();

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)mainMenu:(id)sender {
    //noiseWarz->playing = false;
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];

    noiseWarz->endGame();
}

- (IBAction)resumePlay:(id)sender {
    noiseWarz->playing = true;
    [self.view setHidden:YES];
}
@end
