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
- (BOOL)startCamera;
- (void)endCamera;
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
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    self.imagePickerController = cameraUI;
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"test" message:@"load" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
//    [alert show];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.imagePickerController) {
        if (![self startCamera]) {
            // camera is unavailable
            [UIAlertView alertWithTitle:@"Error" message:@"Camera unavailable"];
        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

# pragma mark -- helper methods
//- (BOOL)setupImagePicker:(UIImagePickerController *)cameraUI {
//    if (![UIImagePickerController isSourceTypeAvailable:
//          UIImagePickerControllerSourceTypeCamera]) {
//        return NO;
//    }
//    self.imagePickerController = cameraUI;
//    cameraUI.delegate = self;
//    cameraUI.cameraOverlayView = self.view;
//    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
//    cameraUI.mediaTypes = [NSArray arrayWithObjects:(NSString*)kUTTypeImage, nil];
//    cameraUI.showsCameraControls = NO;
//    cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceRear;
//    cameraUI.videoQuality = UIImagePickerControllerQualityTypeHigh;
//    
//    return YES;
//}
- (BOOL)startCamera {
    UIImagePickerController *cameraUI = self.imagePickerController;

    if (![UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeCamera]) {
        return NO;
    }
    cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    cameraUI.mediaTypes = 
    [NSArray arrayWithObjects:(NSString*)kUTTypeImage, nil];
    cameraUI.allowsEditing = NO;
    cameraUI.delegate = self;  
    cameraUI.showsCameraControls = NO;
    cameraUI.videoQuality = UIImagePickerControllerQualityTypeHigh;
    cameraUI.cameraOverlayView = self.view;
    //if ([UIImagePickerController isCameraDeviceAvailable:
    cameraUI.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    //cameraUI.cameraViewTransform = CGAffineTransformMake(-1,0,0,1,0,0);
    
    [self presentViewController:cameraUI animated:NO completion:nil];
        
    return YES;
}
- (void)endCamera {
    // UIImagePickerController *cameraUI = self.imagePickerController;
    // dismiss |self.imagePickerController|
    self.imagePickerController = nil;
    [self dismissViewControllerAnimated:YES completion:^{
        // dismiss itself
        id <CameraViewDelegate> _delegate = self.delegate;
        [self dismissViewControllerAnimated:YES completion:nil];
        [_delegate cameraDidCancel];
    }];
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
}

- (IBAction)optionsTouchUp:(id)sender {

}

@end
