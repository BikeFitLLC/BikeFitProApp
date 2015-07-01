//
//  VideoNoteViewController.h
//  bikefit
//
//  Created by Alfonso Lopez on 2/17/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>
#import "NoteImageView.h"

#import "GoniometerDrawingView.h"
#import "NoteViewController.h"

@interface VideoNoteViewController : NoteViewController<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    UIBezierPath *overlayPath;
    
    //User Interface
    IBOutlet UIView *cameraPreviewView; //view that shows the camera video
    UIButton *recordButton;
    UIButton *nextImageButton;
    UIButton *previousImageButton;
    UIButton *saveButton;
    UIButton *reverseCameraButton;
    UIButton *playButton;
    IBOutlet UIButton *takePhotoButton;
    
    //AVCapture
    AVAssetWriter *assetWriter;
    AVAssetWriterInput *assetInput;
    
    AVCaptureVideoPreviewLayer *previewLayer;
    AVCaptureStillImageOutput *stillImageOutput;
    AVCaptureVideoDataOutput *videoDataOutput;
    dispatch_queue_t videoDataOutputQueue;
    CGFloat effectiveScale;
    bool isUsingFrontFacingCamera;
    AVCaptureSession *session;
    bool videoEnabled;
    
    //AVPlayback
    AVPlayerLayer *playerLayer;
    AVPlayer *player;
    NSURL *videoUrl;
    
    IBOutlet NoteImageView *previewImage;
    DrawingView *drawingView;
    IBOutlet UIImage *photo;
}

@property UIBezierPath *overlayPath;
@property BikeFitViewController *bikeInfo;
@property (nonatomic, retain) AVAssetWriter *assetWriter;
@property (nonatomic, retain) AVAssetWriterInput *assetInput;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, retain) NSURL *videoUrl;
@property (nonatomic, retain) UIImage *photo;
@property bool videoEnabled;

- (void) stopCapturing;
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection;

- (void) playVideoSample;
-(UIImage*) imageFromCurrentTime;

/*- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer;*/

//- (IBAction) showImage;
- (IBAction)capture;
- (IBAction)nextImage;
- (IBAction)prevImage;
- (IBAction)play;


@end
