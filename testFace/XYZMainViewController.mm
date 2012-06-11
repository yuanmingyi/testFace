//
//  XYZMainViewController.m
//  testFace
//
//  Created by Mingyi Yuan on 12-5-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "XYZMainViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import <Utilities/Utilities.h>

//NSString *createDateFileName() {
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init]; 
//    [dateFormatter setDateFormat:@"yyyyMMddHHmmss'.jpg'"];
//    NSString *fileName = [dateFormatter stringFromDate:[NSDate date]];
//    return fileName;
//}

@interface XYZMainViewController ()  {
    BOOL isDeleteImagePicker_;
}

@property (strong, nonatomic) XYZFlipsideViewController * workViewController;
- (BOOL)startImagePickerController:(UIViewController *)viewController
                        sourceType:(UIImagePickerControllerSourceType)sourceType
                     usingDelegate:(id <UIImagePickerControllerDelegate, 
                                    UINavigationControllerDelegate>) delegate;
- (void)deleteSelectedImage;
- (BOOL)dismissImagePickerPopover;
- (BOOL)dismissFlipsidePopover;
@end

@implementation XYZMainViewController
@synthesize flipsidePopoverController;
@synthesize imagePickerPopoverController;
@synthesize cameraView;
@synthesize faceDetector;
@synthesize workViewController;
@synthesize cameraButton;
@synthesize imageView;
@synthesize menuButton;
@synthesize originImage;
@synthesize imageURL;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageView.image = self.originImage;
    isDeleteImagePicker_ = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    //[self setNavigationBar:nil];
    [self setFlipsidePopoverController:nil];
    [self setImagePickerPopoverController:nil];
    [self setCameraView:nil];
    [self setFaceDetector:nil];
    [self setCameraButton:nil];
    [self setOriginImage:nil];
    [self setImageView:nil];
    [self setMenuButton:nil];
    [self setWorkViewController:nil];
    [self setImageURL:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
            (UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark -- helper methods
- (BOOL)startImagePickerController:(UIViewController*)viewController
                        sourceType:(UIImagePickerControllerSourceType)sourceType
                     usingDelegate:(id<UIImagePickerControllerDelegate,
                                    UINavigationControllerDelegate>)delegate {
    if (![UIImagePickerController isSourceTypeAvailable:sourceType] 
        || viewController == nil
        || delegate == nil) {
        return NO;
    }
    
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];
    
    cameraUI.sourceType = sourceType;
    cameraUI.mediaTypes = [NSArray arrayWithObjects:
                           (NSString*)kUTTypeImage, nil];
    
    cameraUI.allowsEditing = NO;
    cameraUI.delegate = delegate;  
   
    if (sourceType == UIImagePickerControllerSourceTypeCamera) {
        cameraUI.cameraOverlayView = self.view;
        cameraUI.showsCameraControls = NO;
        cameraUI.videoQuality = UIImagePickerControllerQualityTypeHigh;
        //cameraUI.cameraViewTransform = CGAffineTransformMake(-1,0,0,1,0,0);
        [viewController presentModalViewController:cameraUI animated:YES];
    } else {
        UIPopoverController *popover = [[UIPopoverController alloc] 
                                        initWithContentViewController:cameraUI];
        popover.delegate = self;
        [popover presentPopoverFromBarButtonItem:self.menuButton 
                        permittedArrowDirections:UIPopoverArrowDirectionUp
                                        animated:NO];
        self.imagePickerPopoverController = popover;
    }
    
    return YES;
}

- (void)deleteSelectedImage {
    NSError *error;
    if (![[NSFileManager defaultManager] removeItemAtURL:self.imageURL 
                                                   error:&error]) {
        // failed to delete
        [UIAlertView alertWithTitle:@"Failed" message:error.description];
    }
}

- (void)updateImage:(UIImage*)image {
    UIImage *normalizedImage = [image normalizedOrientationImage];
    self.originImage = normalizedImage;
    self.imageView.image = normalizedImage;
    [self.faceDetector clearResult];
}

- (BOOL)dismissFlipsidePopover {
    if (self.flipsidePopoverController) {
        self.workViewController = nil;
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
        return YES;
    }
    return NO;
}

- (BOOL)dismissImagePickerPopover {
    if (self.imagePickerPopoverController) {
        [self.imagePickerPopoverController dismissPopoverAnimated:YES];
        self.imagePickerPopoverController = nil;
        return YES;
    }
    return NO;
}

#pragma mark - workDelegate Methods
- (void)workDetectFace:(XYZFlipsideViewController*)controller
            WithSource:(DetectorSource)source
              accuracy:(DetectorAccuracy)accuracy {
    FaceDetector *detector = 
            [FaceDetector detectorWithSource:source
                                    accuracy:accuracy
                                detectInGray:YES];
        [detector detectInImage:self.originImage];
    self.imageView.image = detector.imageWithFaces;  
    self.faceDetector = detector;
    [controller updateSettings:detector];
}

- (void)workClearMark:(XYZFlipsideViewController *)controller {
    self.imageView.image = self.originImage;
    [self.faceDetector clearResult];
    [controller updateSettings:self.faceDetector];
}

- (void)workSaveImage:(XYZFlipsideViewController *)controller {
    UIImage *markedImage = self.imageView.image;
    UIImageWriteToSavedPhotosAlbum(markedImage, nil, nil, nil);
    //[controller updateSettings:self.faceDetector];
}

- (void)workDeleteImage:(XYZFlipsideViewController *)controller {
    isDeleteImagePicker_ = YES;
    [self startImagePickerController:self
                          sourceType:UIImagePickerControllerSourceType\
SavedPhotosAlbum
                       usingDelegate:self];
}

- (void)workLoadImage:(XYZFlipsideViewController *)controller {
    self.workViewController = controller;
    isDeleteImagePicker_ = NO;
    [self startImagePickerController:self
                          sourceType:UIImagePickerControllerSourceType\
SavedPhotosAlbum
                       usingDelegate:self];
}

#pragma mark -- UIPopoverControllerDelegate Methods
- (void)popoverControllerDidDismissPopover:
(UIPopoverController *)popoverController {
    if (popoverController == self.imagePickerPopoverController) {
        self.imagePickerPopoverController = nil;
    } else {
        self.workViewController = nil;
        self.flipsidePopoverController = nil;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSString *segueIdentifier = [segue identifier];
    if ([segueIdentifier isEqualToString:@"showMenu"]) {
        [[segue destinationViewController] setDelegate:self];
        UIPopoverController *popoverController = 
            [(UIStoryboardPopoverSegue *)segue popoverController];
        self.flipsidePopoverController = popoverController;
        popoverController.delegate = self;
        self.workViewController = (XYZFlipsideViewController*)
                                    [popoverController contentViewController];
        [self.workViewController updateSettings:self.faceDetector];        
    } else if ([segueIdentifier isEqualToString:@"showCamera"]) {
        self.cameraView = [segue destinationViewController]; 
        self.cameraView.delegate = self;
    }
}

# pragma mark -- UIImagePickerControllerDelegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker 
didFinishPickingMediaWithInfo:(NSDictionary *)info {    
    if (isDeleteImagePicker_) {
        self.imageURL = [info objectForKey:
                         UIImagePickerControllerReferenceURL];
        [UIAlertView alertWithTitle:@"Conform"
                            message:@"Delete?"
                           delegate:self
                  cancelButtonTitle:@"NO"
                 conformButtonTitle:@"YES"];
        return;
    }

    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }

    [self updateImage:image];
    
    if (self.workViewController) {
        [self.workViewController updateSettings:faceDetector];
        self.workViewController = nil;
    }
    
    [self dismissImagePickerPopover];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self dismissImagePickerPopover];
    }
}

# pragma mark -- UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView 
        clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ([alertView.message isEqualToString:@"Delete?"]) {
        if (buttonIndex == alertView.firstOtherButtonIndex) {
            // comform to delete
            [self deleteSelectedImage];
        }
    }
}

# pragma mark -- CameraViewDelegate Mehtods
- (void)cameraDidCancel {
    self.cameraView = nil;
}
- (void)cameraDidTakeAPhoto:(UIImage *)image {
    [self updateImage:image];
    //[UIAlertView alertWithMessage:@"Photo taken"];
}

# pragma mark -- actions responder
- (IBAction)togglePopover:(id)sender
{
    if (![self dismissImagePickerPopover] && ![self dismissFlipsidePopover]) {
        [self performSegueWithIdentifier:@"showMenu" sender:sender];
    }
}

- (IBAction)startCameraResponder:(id)sender {
    if (sender == self.cameraButton) {
        // close the popover
        [self dismissImagePickerPopover];
        [self dismissFlipsidePopover];
        [self performSegueWithIdentifier:@"showCamera" sender:sender];
//        [self startImagePickerController:self 
//                              sourceType:UIImagePickerControllerSourceTypeCamera
//                           usingDelegate:self];
    }
}

@end
