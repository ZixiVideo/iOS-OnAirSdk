//
//  ViewController.m
//  sdktester
//
//  Created by zixi on 6/22/17.
//  Copyright © 2017 zixi. All rights reserved.
//

#import "ViewController.h"
#import <ZixiOnAirSDK/ZixiOnAirSDK.h>

@interface ViewController () <ZixiOnAirStatusDelegate, ZixiOnAirRawFramesDelegate, ZixiOnAirEncodedFramesDelegate>
@property (nonatomic, nonnull, strong) ZixiOnAir* onair;
@property (atomic, assign) BOOL connected;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}


-(void) viewDidAppear:(BOOL)animated
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _onair = [ZixiOnAir sharedInstance];
        _onair.statusDelegate       = self;
        _onair.rawFramesDelegate    = self;
        _onair.encodedFramesDelegate= self;
        
        _onair.cameraView = _previewView;
        ZixiCameraPreview* p = _onair.cameraPreview;
        
        NSString* v = _onair.version;
        NSLog(@"Zixi SDK version %@", v);
        
        if (p)
        {
            p.previewGravity = ZixiCameraPreviewGravityResizeAspectFill;
            p.activaCamera.enableLowLightBoostWhenAvailable = YES;
        }
        
    });
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

#pragma mark -
#pragma mark ZixiOnAirRecorderDelegate
#pragma mark -

- (void) zixiOnAirWillStart
{
    NSLog(@"zixiOnAirWillStart");
}

- (void) zixiOnAirDidStart
{
    NSLog(@"zixiOnAirDidStart");
    _connected = TRUE;
}

- (void) zixiOnAirFailedToStart:(nullable NSError*)error
{
    NSLog(@"zixiOnAirFailedToStart");
    _connected = FALSE;
}

- (void) zixiOnAirDidFinish:(nullable NSError*)error
{
    NSLog(@"zixiOnAirDidFinish");
    _connected = FALSE;
}

- (void) zixiOnAirStatistics:(nonnull NSDictionary*) stats
{
    
}

- (void) zixiOnAirCaptureInfo:(NSUInteger) width height:(NSUInteger)height frameRate:(Float32) fps
{
    
}

#pragma mark -
#pragma mark ZixiOnAirRecorderDelegate
#pragma mark -

- (void) recordWillStart:(nonnull ZixiOnAir*)recorder error:(nullable NSError*)error
{
    NSLog(@"recordWillStart");
    if (error)
        NSLog(@"%@", error.description);
}

- (void) recorderFailedStartRecording:(nonnull ZixiOnAir*)recorder error:(nullable NSError*)error
{
    NSLog(@"recorderFailedStartRecording");
    if (error)
        NSLog(@"%@", error.description);
}

- (void) recorderDidStartRecording:(nonnull ZixiOnAir*)recorder error:(nullable NSError*)error
{
    NSLog(@"recorderDidStartRecording");
    if (error)
        NSLog(@"%@", error.description);
}

- (void) recorderDidFinishRecording:(nonnull ZixiOnAir*)recorder error:(nullable NSError*)error
{
    NSLog(@"recorderDidFinishRecording");
    if (error)
        NSLog(@"%@", error.description);
}

- (void) recorderStatistics:(nonnull NSDictionary*) stats
{
    NSLog(@"recorderStatistics");
}

- (void) recorderCaptureInfo:(NSUInteger) width height:(NSUInteger)height frameRate:(Float32) fps;
{
    NSLog(@"recorderCaptureInfo %lux%lu @ %f FPS", (unsigned long)width, (unsigned long)height, fps);
}

#pragma mark -
#pragma mark ZixiOnAirRawFramesDelegate
#pragma mark -

-(void) onRawAudio:(nonnull CMSampleBufferRef) sampleBuffer
{
    //    NSLog(@"onRawAudio");
}

-(void) onRawVideo:(nonnull CMSampleBufferRef) sampleBuffer
{
    //    NSLog(@"onRawVideo");
}

#pragma mark -
#pragma mark ZixiOnAirEncodedFramesDelegate
#pragma mark -


-(void) onEncodedAudio:(nonnull CMSampleBufferRef) sampleBuffer
{
    NSLog(@"onEncodedAudio");
}

-(void) onEncodedVideo1:(nonnull CMSampleBufferRef) sampleBuffer
{
    NSLog(@"onEncodedVideo");
}

- (IBAction)onSwitchCamera:(id)sender
{
    if (_onair)
    {
        ZixiCameraPreview* p = _onair.cameraPreview;
        [p switchCamera];
    }
}

- (IBAction)onTorch:(id)sender
{
    if (_onair)
    {
        ZixiCameraPreview* p = _onair.cameraPreview;
        if (p.activaCamera.hasTorch)
        {
            if (p.activaCamera.isTorchOn)
                p.activaCamera.torchOn = FALSE;
            else
                p.activaCamera.torchOn = TRUE;
        }
    }
}

- (IBAction)registerFocusAndZoom:(id)sender
{
    ZixiCameraPreview* p = _onair.cameraPreview;
    
    if (p)
    {
        [p registerFocusGestureRecognizers];
        [p registerZoomGestureRecognizer];
    }
}

- (IBAction)unregisterFocusAndZoom:(id)sender
{
    
    ZixiCameraPreview* p = _onair.cameraPreview;
    
    if (p)
    {
        [p unregisterZoomGestureRecognizer];
        [p unregisterFocusGestureRecognizers];
    }
    
}

- (IBAction)startStreaming:(id)sender {
    
    ZixiSettings* s = [[ZixiSettings alloc] init];
    
    s.protocol.protocol     = PROTOCOL_ZIXI;
    s.server.hostName       = @"10.0.0.1";  // zixi broadcaster
    s.server.channelName    = @"ios";
    s.server.bonding        = YES;
    s.server.latency        = 500;  //ms
    
    s.protocol.protocol     = PROTOCOL_RTMP;
    s.rtmp.URL              = @"rtmp://10.0.0.1/live"; // rtmp server
    s.rtmp.streamName       = @"rtmp_test";
    
    s.video.frameSizePreset = ZixiFrameSizePreset1280x720;
    s.video.frameRate       = 60;
    s.video.adaptive        = NO;
    
    //    s.advanced.videoRateControl = RC_CBR;
    s.advanced.videoBitRate = 3000;
    [_onair startStreamingWithSettings:s];
}

- (IBAction)stopStreaming:(id)sender
{
    
    [_onair endStreaming];
}
@end
