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
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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

	NSLog(@"Available 4:3 Presets:");
	for (ZixiCameraPreset* preset in _onair.fourByThreePrestes)
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
        p.previewGravity = ZixiCameraPreviewGravityResizeAspect;
        p.activaCamera.enableLowLightBoostWhenAvailable = YES;
    }
}

-(BOOL) shouldAutorotate{
    return NO;
    
}

-(UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)switchCam:(id)sender {
    
	if (_onair)
	{
		[_onair switchCamera];
	}
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
    
    appSettings* s = [[appSettings alloc] init];
    
    s.protocol.protocol     = PROTOCOL_ZIXI;
    s.server.hostName       = @"10.0.0.100";
    s.server.channelName    = @"ios";
    s.server.bonding        = NO;
    s.server.latency        = 500;  //ms
	
	s.advanced.audioCodec	= ZixiAudioCodecAAC;
	s.advanced.audioBitRate	= 96;
	
//    s.protocol.protocol     = PROTOCOL_RTMP;
//    s.rtmp.URL              = @"rtmp://10.0.0.100/live";
//    s.rtmp.streamName       = @"rtmp_test";
//    
	s.video.frameSizePreset	= 2;
    s.video.frameRate       = 60;
    s.video.adaptive        = NO;
    
    //    s.advanced.videoRateControl = RC_CBR;
    s.advanced.videoBitRate = 3000;
    [_onair startStreamingWithSettings:s];
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
@end
