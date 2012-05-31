//
//  CameraViewController.m
//  testFace
//
//  Created by Mingyi Yuan on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CameraViewController.h"
#import "MobileCoreServices/UTCoreTypes.h"

@interface CameraViewController ()

@end

@implementation CameraViewController

@synthesize delegate;
@synthesize imagePickerController;

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
//	if (![self startCamera]) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
//                                                        message:@"No camera device detected"
//                                                       delegate:nil cancelButtonTitle:@"back"
//                                              otherButtonTitles:nil];
//        [alert show];
//    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;//(interfaceOrientation == UIInterfaceOrientationPortrait);
}

# pragma mark -- helper methods
- (BOOL)startCamera {
    if (![UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera]) {
        return NO;
    }
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraUI.mediaTypes = 
        [NSArray arrayWithObjects:(NSString*)kUTTypeImage, nil];
    
    cameraUI.allowsEditing = NO;
    cameraUI.delegate = self;  
    //cameraUI.showsCameraControls = NO;
    //cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    
    //[cameraUI.cameraOverlayView addSubview:self.view];
     
    //cameraUI.videoQuality = UIImagePickerControllerQualityTypeHigh;
    //cameraUI.cameraViewTransform = CGAffineTransformMake(-1,0,0,1,0,0);
    
    self.imagePickerController = cameraUI;
    
    [self presentModalViewController:cameraUI animated:YES];
        
    return YES;
}
- (void)endCamera {
    [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

# pragma mark -- UIImagePickerControllerDelegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    [self.delegate cameraDidTakeAPhoto:image];
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
//    [self.delegate cameraDidCancel];
}

# pragma mark -- actions
// take a photo
- (IBAction)shotTouchUp:(id)sender {
    [self.imagePickerController takePicture];
    [self endCamera];
}
// cancel camera
- (IBAction)backTouchUp:(id)sender {
    [self endCamera];
    //[self.delegate cameraDidCancel];
}

- (IBAction)optionsTouchUp:(id)sender {
}

@end
