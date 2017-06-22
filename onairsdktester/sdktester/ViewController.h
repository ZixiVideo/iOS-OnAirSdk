//
//  ViewController.h
//  sdktester
//
//  Created by zixi on 6/22/17.
//  Copyright © 2017 zixi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIView *previewView;

- (IBAction)startStreaming:(id)sender;
- (IBAction)stopStreaming:(id)sender;
- (IBAction)registerFocusAndZoom:(id)sender;
- (IBAction)unregisterFocusAndZoom:(id)sender;
- (IBAction)onTorch:(id)sender;
- (IBAction)onSwitchCamera:(id)sender;
@end

