//
//  ViewController.m
//  onairsdktester
//
//  Created by zixi on 11/22/16.
//  Copyright © 2016 zixi. All rights reserved.
//

#import "ViewController.h"
#import <ZixiOnAirSDK/ZixiOnAirSDK.h>
#import <UIKit/UIKit.h>

@interface ViewController () <ZixiOnAirStatusDelegate, ZixiOnAirRawFramesDelegate, ZixiOnAirEncodedFramesDelegate>
@property (nonatomic, nonnull, strong) ZixiOnAir* onair;
@property (nonatomic, nonnull, strong) appSettings* onAirSettings;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

	_onAirSettings = [[ appSettings alloc ] init];
	
    _onair = [ZixiOnAir sharedInstance];
	_sdkVersion.text = _onair.version;
    _onair.statusDelegate = self;
    //    _onair.rawFramesDelegate = self;
    //    _onair.encodedFramesDelegate = self;

	NSLog(@"Available Presets:");
	for (ZixiCameraPreset* preset in _onair.presets)
	{
		NSLog(@"%lux%lu @ %lu kbps", (unsigned long)preset.width, (unsigned long)preset.height, (preset.highFrameRateBitrate/1000));
	}
}

-(void) viewDidAppear:(BOOL)animated
{
    _onair.cameraView = _previewView;
    ZixiCameraPreview* p = _onair.cameraPreview;
    
    if (p)
    {
        p.previewGravity = ZixiCameraPreviewGravityResizeAspectFill;
        p.activaCamera.enableLowLightBoostWhenAvailable = YES;
    }
}

-(void) viewDidLayoutSubviews
{
	[super viewWillLayoutSubviews];

	if (_onair && _onair.cameraPreview)
	{
		[_onair.cameraPreview updatePreviewLayerSize];
	}
}

-(BOOL) shouldAutorotate{
	return YES;
	
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
	if (_onAirSettings)
	{
		switch (_onAirSettings.advanced.videoOrientation) {
			case ZixiVideoOrientationPortrait:
				return UIInterfaceOrientationPortrait;
				break;
				
			case ZixiVideoOrientationPortraitUpsideDown:
				return UIInterfaceOrientationPortraitUpsideDown;
				break;
				
			case ZixiVideoOrientationLandscapeRight:
				return UIInterfaceOrientationLandscapeRight;
				break;
				
			case ZixiVideoOrientationLandscapeLeft:
				return UIInterfaceOrientationLandscapeLeft;
				break;
				
			default:
				break;
		}
	}
		return UIInterfaceOrientationLandscapeRight;
}

-(UIInterfaceOrientationMask) supportedInterfaceOrientations
{
	if (_onAirSettings)
	{
		switch (_onAirSettings.advanced.videoOrientation) {
			case ZixiVideoOrientationPortrait:
				return UIInterfaceOrientationMaskPortrait;
				break;

			case ZixiVideoOrientationPortraitUpsideDown:
				return UIInterfaceOrientationMaskPortraitUpsideDown;
				break;

			case ZixiVideoOrientationLandscapeRight:
				return UIInterfaceOrientationMaskLandscapeRight;
				break;

			case ZixiVideoOrientationLandscapeLeft:
				return UIInterfaceOrientationMaskLandscapeLeft;
				break;

			default:
				break;
		}
	}
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)switchCam:(id)sender {

    NSMutableDictionary* tmp = [NSMutableDictionary dictionary];
    
    void (^handler)(UIAlertAction*) = ^void(UIAlertAction* action)
    {
        if (tmp && tmp.count > 0)
        {
            ZixiCamera* cam = [tmp objectForKey:action.title];
            if (_onair)
                [_onair setActivaCamera:cam];
        }
    };
    
    UIAlertController* camSelection = [UIAlertController alertControllerWithTitle:@"Select Camera" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    NSArray<ZixiCamera*>* cams = [ZixiCameraPreview devicesCameras];
    if (cams && cams.count)
    {
        for (ZixiCamera* c in cams)
        {
            if (c)
            {
                if ([c isFront])
                {
                    UIAlertAction* frontCamera = [UIAlertAction actionWithTitle:@"Front" style:UIAlertActionStyleDefault handler:handler];
                    [camSelection addAction:frontCamera];
                    [tmp setObject:c forKey:@"Front"];
                }
                else if ([c isBack])
                {
                    if ([c isTelephoto])
                    {
                        UIAlertAction* telePhotoCamera = [UIAlertAction actionWithTitle:@"Telephoto" style:UIAlertActionStyleDefault handler:handler];
                        [camSelection addAction:telePhotoCamera];
                        [tmp setObject:c forKey:@"Telephoto"];
                    }
                    else
                    {
                        UIAlertAction* backCamera = [UIAlertAction actionWithTitle:@"Back" style:UIAlertActionStyleDefault handler:handler];
                        [camSelection addAction:backCamera];
                        [tmp setObject:c forKey:@"Back"];
                    }
                }
            }
        }
    }
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction* action){
        
    }];
    [camSelection addAction:cancel];
    
    if (camSelection.popoverPresentationController)
    {
        camSelection.popoverPresentationController.sourceView = _orientationButton;
        
        CGRect r = _orientationButton.bounds;
        r.origin.y -= 50;
        camSelection.popoverPresentationController.sourceRect = r;
        camSelection.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
    }
    
    [self presentViewController:camSelection animated:YES completion:nil];
}

- (IBAction)registerFocusAndZoom:(id)sender {
    ZixiCameraPreview* p = _onair.cameraPreview;
    
    if (p)
    {
        [p registerFocusGestureRecognizers];
        [p registerZoomGestureRecognizer];
    }
}

- (IBAction)unregisterFocusAndZoom:(id)sender {
    
    ZixiCameraPreview* p = _onair.cameraPreview;
    
    if (p)
    {
        [p unregisterZoomGestureRecognizer];
        [p unregisterFocusGestureRecognizers];
    }
    
}

- (IBAction)startStreaming:(id)sender {
	
    _onAirSettings.protocol.protocol     = PROTOCOL_ZIXI;
    _onAirSettings.server.hostName       = @"10.0.0.100";
    _onAirSettings.server.channelName    = @"ios";
    _onAirSettings.server.bonding        = NO;
    _onAirSettings.server.latency        = 500;  //ms
	
	_onAirSettings.advanced.audioCodec	= ZixiAudioCodecAAC;
	_onAirSettings.advanced.audioBitRate	= 96000;
	
//    _onAirSettings.protocol.protocol     = PROTOCOL_RTMP;
//    _onAirSettings.rtmp.URL              = @"rtmp://10.0.0.100/live";
//    _onAirSettings.rtmp.streamName       = @"rtmp_test";
//    
	_onAirSettings.video.frameSizePresetIndex	= 0;
	_onAirSettings.video.aspectRatio	= ZixiVideoAspectRatio_16_9;
	_onAirSettings.video.frameRate		= 60;
	_onAirSettings.video.adaptiveBitrate= NO;
	_onAirSettings.video.adaptiveFramerate = NO;
	
/*
//	custom resolution
	_onAirSettings.video.aspectRatio		= ZixiVideoAspectRatio_Custom;
	_onAirSettings.video.videoWidth		= 400;
	_onAirSettings.video.videoHeight		= 300;
*/
    //    _onAirSettings.advanced.videoRateControl = RC_CBR;
    _onAirSettings.advanced.videoBitRate = 3000;
    [_onair startStreamingWithSettings:_onAirSettings];
	
}

- (IBAction)stopStreaming:(id)sender {
    
    [_onair endStreaming];
}

#pragma mark -
#pragma mark ZixiOnAirStatusDelegate
#pragma mark -

- (void) zixiOnAirWillStart:(nonnull ZixiOnAir*)recorder
{
    NSLog(@"recordWillStart");
}

- (void) zixiOnAirDidStart:(nonnull ZixiOnAir*)recorder
{
    NSLog(@"zixiOnAirDidStart");
}

- (void) zixiOnAirFailedToStart:(nonnull ZixiOnAir*)recorder error:(nullable NSError*)error;
{
    NSLog(@"zixiOnAirFailedToStart");
    if (error)
        NSLog(@"%@", error.description);
}

- (void) zixiOnAirDidFinish:(nonnull ZixiOnAir*)recorder error:(nullable NSError*)error
{
    NSLog(@"zixiOnAirDidFinish");
    if (error)
        NSLog(@"%@", error.description);
}

- (void) zixiOnAirStatistics:(nonnull ZixiOnAir*)recorder statistics:(nonnull NSDictionary*) stats
{
    NSLog(@"recorderStatistics");
}

- (void) zixiOnAirCaptureInfo:(nonnull ZixiOnAir*)recorder width:(NSUInteger) width height:(NSUInteger)height frameRate:(Float32) fps zoom:(Float32) zoom
{
    NSLog(@"recorderCaptureInfo %lux%lu @ %f FPS", (unsigned long)width, (unsigned long)height, fps);
}

- (void) zixiOnAirCaptureZoomInfo:(nonnull ZixiOnAir*)recorder zoom:(Float32) zoom
{
	NSLog(@"zixiOnAirCaptureZoomInfo zoom=%f", zoom);
}

#pragma mark -
#pragma mark ZixiOnAirRawFramesDelegate
#pragma mark -

-(void) onRawAudio:(nonnull CMSampleBufferRef) sampleBuffer
{
    NSLog(@"onRawAudio");
}

-(void) onRawVideo:(nonnull CMSampleBufferRef) sampleBuffer
{
    NSLog(@"onRawVideo");
}

#pragma mark -
#pragma mark ZixiOnAirEncodedFramesDelegate
#pragma mark -


-(void) onEncodedAudio:(nonnull CMSampleBufferRef) sampleBuffer
{
    NSLog(@"onEncodedAudio");
}

-(void) onEncodedVideo:(nonnull CMSampleBufferRef) sampleBuffer
{
    NSLog(@"onEncodedVideo");
}
- (IBAction)onOrientation:(id)sender
{
	if (_onair && _onair.connected)
		return;
	
	void (^handler)(UIAlertAction*) = ^void(UIAlertAction* action)
	{
		
		if ([action.title isEqualToString:@"Landscape Right"])
		{
			if (_onAirSettings)
				_onAirSettings.advanced.videoOrientation = ZixiVideoOrientationLandscapeRight;

			if (_onair)
				_onair.videoOrientation = ZixiVideoOrientationLandscapeRight;
		}
		else if ([action.title isEqualToString:@"Landscape Left"])
		{
			if (_onAirSettings)
				_onAirSettings.advanced.videoOrientation = ZixiVideoOrientationLandscapeLeft;
			
			if (_onair)
				_onair.videoOrientation = ZixiVideoOrientationLandscapeLeft;
		}
		else if ([action.title isEqualToString:@"Portrait"])
		{
			if (_onAirSettings)
				_onAirSettings.advanced.videoOrientation = ZixiVideoOrientationPortrait;
			
			if (_onair)
				_onair.videoOrientation = ZixiVideoOrientationPortrait;
		}
		else if ([action.title isEqualToString:@"Portrait Upside Down"])
		{
			if (_onAirSettings)
				_onAirSettings.advanced.videoOrientation = ZixiVideoOrientationPortraitUpsideDown;
			
			if (_onair)
				_onair.videoOrientation = ZixiVideoOrientationPortraitUpsideDown;
		}

		// force orientation
		UIInterfaceOrientation o;
		switch (_onAirSettings.advanced.videoOrientation)
		{
			case ZixiVideoOrientationPortrait:
				o = UIInterfaceOrientationPortrait;
				break;
			case ZixiVideoOrientationPortraitUpsideDown:
				o = UIInterfaceOrientationPortraitUpsideDown;
				break;
			case ZixiVideoOrientationLandscapeLeft:
				o = UIInterfaceOrientationLandscapeLeft;
				break;
			default:
			case ZixiVideoOrientationLandscapeRight:
				o = UIInterfaceOrientationLandscapeRight;
				break;
		}
		[UIDevice.currentDevice setValue:@(o) forKey:@"orientation"];

		[UIViewController attemptRotationToDeviceOrientation];
	};
	
	UIAlertController* orientationAC = [UIAlertController alertControllerWithTitle:@"Orientation" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

	UIAlertAction* portraitAction = [UIAlertAction actionWithTitle:@"Portrait" style:UIAlertActionStyleDefault handler:handler];
	[orientationAC addAction:portraitAction];

	UIAlertAction* portraitUpsideDownAction = [UIAlertAction actionWithTitle:@"Portrait Upside Down" style:UIAlertActionStyleDefault handler:handler];
	[orientationAC addAction:portraitUpsideDownAction];

	UIAlertAction* landscapeRightAction = [UIAlertAction actionWithTitle:@"Landscape Right" style:UIAlertActionStyleDefault handler:handler];
	[orientationAC addAction:landscapeRightAction];

	UIAlertAction* landscapeLeftAction = [UIAlertAction actionWithTitle:@"Landscape Left" style:UIAlertActionStyleDefault handler:handler];
	[orientationAC addAction:landscapeLeftAction];

	
	UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction* action){
		
	}];
	[orientationAC addAction:cancel];
	
	if (orientationAC.popoverPresentationController)
	{
		orientationAC.popoverPresentationController.sourceView = _orientationButton;

		CGRect r = _orientationButton.bounds;
		r.origin.y -= 50;
		orientationAC.popoverPresentationController.sourceRect = r;
		orientationAC.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionDown;
	}
	
	[self presentViewController:orientationAC animated:YES completion:nil];
}
@end
