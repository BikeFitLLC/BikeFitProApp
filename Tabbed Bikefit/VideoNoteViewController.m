//
//  VideoNoteViewController.m
//  bikefit
//
//  Created by Alfonso Lopez on 2/17/14.
//  Copyright (c) 2014 Alfonso Lopez. All rights reserved.
///Users/alfonsol/Dropbox/Apps/Tabbed Bikefit/Tabbed Bikefit/VideoNoteViewController.m

#import "VideoNoteViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import "KneeDrawingView.h"

@interface VideoNoteViewController ()
{
    bool capture;
    bool takingPhoto;
    NSTimer *timer;
    NSTimeInterval interval;
}

@end

@implementation VideoNoteViewController
@synthesize videoUrl;
@synthesize overlayPath;
@synthesize assetWriter;
@synthesize assetInput;
@synthesize previewLayer;
@synthesize videoEnabled;
@synthesize photo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [saveButton setHidden:true];
    [nextImageButton setHidden:true];
    [previousImageButton setHidden:true];
    [playButton setHidden:true];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //
    //setup video views
    //
    previewView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.view addSubview:previewView];


    //
    //Setup the buttons and other stuff
    //
    recordButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    recordButton.frame = CGRectMake(self.view.frame.size.width * .8,
                                    self.view.frame.size.height * .9,
                                    self.view.frame.size.width * .2,
                                    self.view.frame.size.width * .1);
    recordButton.titleLabel.font = [UIFont systemFontOfSize:24];
    recordButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    recordButton.backgroundColor = [UIColor blackColor];
    recordButton.alpha = .5;
    [recordButton setTitle:@"Record 5 Seconds" forState:UIControlStateNormal];
    [recordButton setCenter:CGPointMake(self.view.bounds.size.width * .85,
                                      self.view.bounds.size.height *.75)];
    [recordButton addTarget:self action:@selector(capture) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:recordButton];
    
    saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    saveButton.frame = CGRectMake(0,0,150,75);
    saveButton.titleLabel.font = [UIFont systemFontOfSize:24];
    saveButton.backgroundColor = [UIColor blackColor];
    saveButton.alpha = .5;
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveButton setCenter:CGPointMake(self.view.bounds.size.width * .8,
                                      self.view.bounds.size.height *.15)];
    [self.view addSubview:saveButton];
    
    previousImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    previousImageButton.frame = CGRectMake(0,0,100,100);
    [previousImageButton setCenter:CGPointMake(self.view.bounds.size.width *.1, CGRectGetMidY(self.view.bounds))];
    [previousImageButton setBackgroundImage:[UIImage imageNamed:@"arrowleft.png"] forState:UIControlStateNormal];
    [previousImageButton addTarget:self action:@selector(prevImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:previousImageButton];
    
    nextImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextImageButton.frame = CGRectMake(0,0,100,100);
    [nextImageButton setCenter:CGPointMake(self.view.bounds.size.width *.9, CGRectGetMidY(self.view.bounds))];
    [nextImageButton setBackgroundImage:[UIImage imageNamed:@"arrowright.png"] forState:UIControlStateNormal];
    [nextImageButton addTarget:self action:@selector(nextImage) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextImageButton];
    
    playButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    playButton.frame = CGRectMake(self.view.frame.size.width * .1,
                                 self.view.frame.size.height * .8,
                                 self.view.frame.size.width * .2,
                                 self.view.frame.size.width * .1);
    playButton.titleLabel.font = [UIFont systemFontOfSize:24];
    playButton.backgroundColor = [UIColor blackColor];
    playButton.alpha = .5;
    [playButton setTitle:@"Play" forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(play) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playButton];

    
    reverseCameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    reverseCameraButton.frame = CGRectMake(self.view.frame.size.width * .8,
                                           self.view.frame.size.width * .95,
                                           self.view.frame.size.width * .1,
                                           self.view.frame.size.width * .1);
    reverseCameraButton.alpha = .5;
    [reverseCameraButton setBackgroundImage:[UIImage imageNamed:@"FrontCameraIcon.png"] forState:UIControlStateNormal];
    [reverseCameraButton setCenter:CGPointMake(self.view.bounds.size.width * .9,
                                        self.view.bounds.size.height *.85)];
    [reverseCameraButton addTarget:self action:@selector(switchCameraTapped:) forControlEvents:UIControlEventTouchUpInside];
    reverseCameraButton.hidden = false;
    [self.view addSubview:reverseCameraButton];
    
    takePhotoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    takePhotoButton.frame = CGRectMake(self.view.frame.size.width * .1,
                                  self.view.frame.size.height * .2,
                                  self.view.frame.size.width * .2,
                                  self.view.frame.size.width * .1);
    takePhotoButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    takePhotoButton.backgroundColor = [UIColor blackColor];
    takePhotoButton.alpha = .5;
    [takePhotoButton setTitle:@"Take Photo" forState:UIControlStateNormal];
    [takePhotoButton addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:takePhotoButton];
    
	interval = 1;
    videoEnabled = true;
    
    //CGRect bounds = CGRectMake(0,0,720, 1024);// self.view.layer.bounds;
    //[self.view setBounds:bounds];
    //[previewImage setBounds:bounds];
}

- (void) viewDidAppear:(BOOL)animated
{
    if(videoEnabled)
    {
        if(videoUrl)
        {
            [previewImage setOverlayPath:overlayPath];
            [previewImage setNeedsDisplay];
            [self.view insertSubview:previewImage aboveSubview:previewView];
            
            //if the videourl is set,  view it.
            player = [AVPlayer playerWithURL:videoUrl];
            [player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
            playButton.hidden = NO;
            
            //Also, enable the next and previous frame buttons
            previousImageButton.hidden = NO;
            nextImageButton.hidden = NO;
            recordButton.hidden = YES;
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self initializeCamera];
            });
        }
    }
}

- (void) viewDidDisappear:(BOOL)animated
{
    if(player.currentItem)
    {
        [player.currentItem removeObserver:self forKeyPath:@"status"];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

////////////////////////////////////////////
//Video Capture methods
///////////////////////////////////////////

//AVCaptureSession to show live video feed in view
- (void) initializeCamera {
    NSError *error = nil;
	
	session = [AVCaptureSession new];
    [session setSessionPreset:AVCaptureSessionPreset1280x720];
	
    // Select a video device, make an input
	AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
	//require( error == nil, bail )
    
	if ( [session canAddInput:deviceInput] )
		[session addInput:deviceInput];
	
    // Make a video data output
	videoDataOutput = [AVCaptureVideoDataOutput new];
	
    // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
	NSDictionary *rgbOutputSettings = [NSDictionary dictionaryWithObject:
                                       [NSNumber numberWithInt:kCMPixelFormat_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey];
	[videoDataOutput setVideoSettings:rgbOutputSettings];
	[videoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked (as we process the still image)
    
    
    // create a serial dispatch queue used for the sample buffer delegate as well as when a still image is captured
    // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
    // see the header doc for setSampleBufferDelegate:queue: for more information
	videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
	[videoDataOutput setSampleBufferDelegate:self queue:videoDataOutputQueue];
	
    if ( [session canAddOutput:videoDataOutput] )
    {
		[session addOutput:videoDataOutput];
    }
	[[videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];
    [[videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:AVCaptureVideoOrientationPortrait];
	
	effectiveScale = 1.0;
   	previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];

    CGRect bounds = self.view.bounds;
	[previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [previewLayer setFrame:bounds];
    [previewLayer setPosition:CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))];
    [[previewLayer connection] setVideoOrientation:AVCaptureVideoOrientationPortrait];
    
	CALayer *rootLayer = [previewView layer];
	[rootLayer setMasksToBounds:YES];
    [rootLayer addSublayer:previewLayer];
	
	[session startRunning];
    
}

////////////////////////////////////////////////
//Called to process frames from the camera
////////////////////////////////////////////////
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    @try {
        
    if(capture)
    {
        if(assetWriter.status != AVAssetWriterStatusWriting)
        {
            [assetWriter startWriting];
            [assetWriter startSessionAtSourceTime:CMSampleBufferGetPresentationTimeStamp(sampleBuffer)];
        }
        
        if (!CMSampleBufferDataIsReady(sampleBuffer))
        {
            NSLog(@"sampleBuffer data is not ready");
            return;
        }
        else if([assetWriter.inputs count] != 1)
        {
            NSLog(@"AssetWriter has unexpected number of inputs: %d. Skipping Frame", [assetWriter.inputs count]);
        }
        else if(![assetWriter.inputs[0] isReadyForMoreMediaData])
        {
            NSLog(@"AssetInput not ready for data.  Skipping frame.");
            
        }
        else if(![assetWriter.inputs[0] appendSampleBuffer:sampleBuffer])
        {
            NSLog(@"Dropped Frame");
        }
        else
        {
            NSLog(@"Frame Loaded");
        };
    }
    else if(takingPhoto)
    {
        takingPhoto = false;
       
        //[previewLayer removeFromSuperlayer];
        [session stopRunning];
        //previewLayer = nil;
        //session = nil;
        
        // CGRect bounds = self.view.bounds;
        
        [saveButton setHidden:NO];
        [takePhotoButton setHidden:YES];
        
        [self setPhoto:[self imageFromSampleBuffer:sampleBuffer]];
        NSLog(@"imageView set");
        //[imageView setNeedsDisplay];
        
    }
        
    }
    @catch(NSException *e)
    {
        NSLog(@"Exception Loading Frame: %@", [e description]);
    }
    return;
}

/////////////////////////////////////////////////////////////////
//Switches between front and back camera
/////////////////////////////////////////////////////////////////
-(IBAction)switchCameraTapped:(id)sender
{
    //Change camera source
    if(session)
    {
        AVCaptureInput* currentCameraInput = [session.inputs objectAtIndex:0];
        
        //Get new input
        AVCaptureDevice *newCamera = nil;
        if(((AVCaptureDeviceInput*)currentCameraInput).device.position == AVCaptureDevicePositionBack)
        {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
            [[self previewLayer] setTransform:CATransform3DMakeRotation(M_PI, 0.0f, 1.0f, 0.0f)];
        }
        else
        {
            newCamera = [self cameraWithPosition:AVCaptureDevicePositionBack];
            [[self previewLayer] setTransform:CATransform3DMakeRotation(0, 0.0f, 1.0f, 0.0f)];
        }
        
        //Add input to session
        NSError *error;
        AVCaptureDeviceInput *newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:newCamera error:&error];
        if(error)
        {
            NSLog(@"Error creating new video input: %@", [error description]);
        }
        
        [session beginConfiguration];
        {
            [session removeInput:currentCameraInput];
            if([session canAddInput:newVideoInput])
            {
                [session addInput:newVideoInput];
                [[[session.outputs objectAtIndex:0] connectionWithMediaType:AVMediaTypeVideo]
                                                    setVideoOrientation:AVCaptureVideoOrientationPortrait];
            }
            else{
                //this happens if the front camera isn't going to work. so set the transform back to neutral
                [session addInput:currentCameraInput];
                [[self previewLayer] setTransform:CATransform3DMakeRotation(0, 0.0f, 1.0f, 0.0f)];
            }
        }
        [session commitConfiguration];
    }
}
// Find a camera with the specified AVCaptureDevicePosition, returning nil if one is not found
- (AVCaptureDevice *) cameraWithPosition:(AVCaptureDevicePosition) position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position) return device;
    }
    return nil;
}

////////////////////////////////////////////////
//Setup and begin video capture to quicktime
////////////////////////////////////////////////
- (IBAction)capture
{
    [recordButton setEnabled:false];
    timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(stopCapturing)
                                           userInfo:nil repeats:NO];
    NSError *error;

    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    videoUrl = [NSURL fileURLWithPath:[documentsDirectory stringByAppendingPathComponent:
                                       [NSString stringWithFormat:@"%@.mov", [[NSUUID UUID] UUIDString]]]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[videoUrl path] error:NULL];
    
    assetWriter = [AVAssetWriter assetWriterWithURL:videoUrl fileType:AVFileTypeQuickTimeMovie error:&error];
    if(error)
    {
        NSLog(@"Error creating AssetWriter: %@", [error description]);
    }
    
    NSDictionary* settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              AVVideoCodecH264, AVVideoCodecKey,
                              //[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:2],AVVideoAverageBitRateKey ,
                               //AVVideoProfileLevelH264Main31, AVVideoProfileLevelKey,
                               //[NSNumber numberWithInt: 640], AVVideoMaxKeyFrameIntervalKey,nil],
                              //AVVideoCompressionPropertiesKey,
                              [NSNumber numberWithInt:720], AVVideoWidthKey,
                              [NSNumber numberWithInt:1280], AVVideoHeightKey,
                              nil];
    
    AVAssetWriterInput *assInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:settings];
    assetInput.expectsMediaDataInRealTime = YES;
    [assetWriter addInput:assInput];
    NSLog(@"Asset Input added. AssetWriter now has %d inputs", [assetWriter.inputs count]);
    
    capture = true;
}

////////////////////////////////////////
// Finish and write the captured video
// called after the timer for capture runs out
////////////////////////////////////////
- (void) stopCapturing
{
    capture = false;
    recordButton.hidden = YES;
    reverseCameraButton.hidden = YES;
    previousImageButton.hidden = NO;
    nextImageButton.hidden = NO;
    [assetInput markAsFinished];
    
    //[assetWriter endSessionAtSourceTime:CMTimeMakeWithSeconds(5, 1)];
    
    [assetWriter finishWritingWithCompletionHandler:^{
        if (assetWriter.status == AVAssetWriterStatusCompleted)
        {
            if(assetWriter.error)
            {
                NSLog(@"AssetWriterError: %@", assetWriter.error.description);
            };
            assetWriter = nil;
            
            player = [AVPlayer playerWithURL:videoUrl];
            [player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];

            
        }
    }];
}

/////////////////////////////////////////////////
//Plays the video at the url in videoUrl
////////////////////////////////////////////////
- (void) playVideoSample
{
    NSLog(@"Setting Up Player Video");
    [session stopRunning];
    [previewLayer removeFromSuperlayer];
    previewLayer = nil;
    
    
    if(player.error)
    {
        NSLog(@"AVPlayer error opening file: %@", player.error.description);
    }
    playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    

    CGRect bounds = self.view.bounds;
    [playerLayer setFrame:bounds];
    //[playerLayer setBounds:bounds];
    [playerLayer setPosition:CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))];
    [playerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
   
    CALayer *rootLayer = [previewView layer];
    [rootLayer setMasksToBounds:YES];
    [rootLayer insertSublayer:playerLayer atIndex:0];
    [player seekToTime:CMTimeMakeWithSeconds(0,1)];
    
   
}

////////////////////////////////////////
//Value observer for the AVPlayer used to play video files.
//watches for the AVPlayer status to be "ready"
////////////////////////////////////////
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (object == player.currentItem && [keyPath isEqualToString:@"status"]) {
        switch(player.currentItem.status)
        {
            case AVPlayerItemStatusReadyToPlay:
            {
                if([change objectForKey:@"old"] != [change objectForKey:@"new"])
                {
                    NSLog(@"Playing Video");
                    [self playVideoSample];
                }
                break;
            };
            case AVPlayerItemStatusUnknown:
            {
                NSLog(@"AVPlayerItemStatus is Uknown");
                break;
            }
            case AVPlayerItemStatusFailed:
            {
                NSLog(@"AVPlayerItem Error:%@", player.currentItem.error.description);
                break;
            }
        }
    }
}

-(UIImage*) imageFromCurrentTime
{
    AVAsset *asset = player.currentItem.asset;
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imageGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    imageGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    
    CMTime time = [player currentTime];
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return thumbnail;
}


- (IBAction)takePhoto
{
    //this will be checked in captureOutput method
    [saveButton setHidden:NO];
    takingPhoto = true;
}


- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    
    NSLog(@"imageFromSampleBuffer: called");
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef newImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);

    
    UIImage *imageToReturn = [UIImage imageWithCGImage:
                            newImage
                            scale: 1.0
                            orientation:UIImageOrientationUp
                            ];
    NSData *jpegImage = UIImageJPEGRepresentation(imageToReturn, .1);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(newImage);
    
    return [UIImage imageWithData:jpegImage];
}

//////////////////////////////////////////
//Frame Navigation Methods
//////////////////////////////////////////
- (IBAction)nextImage
{
    CMTime newTime = CMTimeConvertScale([player currentTime], 1200,  kCMTimeRoundingMethod_QuickTime);
    newTime.value = newTime.value + 50;
    [player seekToTime:newTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

- (IBAction)prevImage
{
    CMTime newTime = CMTimeConvertScale([player currentTime], 1200,  kCMTimeRoundingMethod_QuickTime);
    newTime.value = newTime.value - 50;
    [player seekToTime:newTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
}

- (IBAction)play
{
    [player seekToTime:kCMTimeZero toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    [player play];
}

@end
