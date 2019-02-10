//
//  ViewController.h
//  onairsdktester
//
//  Created by zixi on 11/22/16.
//  Copyright © 2016 zixi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

- (IBAction)switchCam:(id)sender;
- (IBAction)registerFocusAndZoom:(id)sender;
- (IBAction)unregisterFocusAndZoom:(id)sender;
- (IBAction)startStreaming:(id)sender;
- (IBAction)stopStreaming:(id)sender;
- (IBAction)onOrientation:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet UIButton *orientationButton;
@property (weak, nonatomic) IBOutlet UILabel *sdkVersion;

@end

