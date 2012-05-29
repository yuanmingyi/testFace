//
//  XYZMainViewController.m
//  testFace
//
//  Created by Mingyi Yuan on 12-5-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "XYZMainViewController.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "FaceDetector.h"

@interface XYZMainViewController () 

- (BOOL)startImagePickerController:(UIViewController *)viewController
                        sourceType:(UIImagePickerControllerSourceType)sourceType
                     usingDelegate:(id <UIImagePickerControllerDelegate, 
                                    UINavigationControllerDelegate>) delegate;
@end

@implementation XYZMainViewController
@synthesize flipsidePopoverController;
@synthesize imagePickerPopoverController;
//@synthesize workViewController;
@synthesize cameraButton;
@synthesize imageView;
@synthesize menuButton;
@synthesize originImage;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageView.image = self.originImage;
}

- (void)viewDidUnload
{
    //[self setNavigationBar:nil];
    [self setFlipsidePopoverController:nil];
    [self setImagePickerPopoverController:nil];
    //[self setWorkViewController:nil];
    [self setCameraButton:nil];
    [self setOriginImage:nil];
    [self setImageView:nil];
    [self setMenuButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
            (UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - work View Controller

- (void)workDetectFace:(BOOL)isDetect completion:(void (^)(void))completion{
    if (isDetect) {
        FaceDetector *detector = 
            [FaceDetector detectorWithSource:DetectorSourceCoreImage
                                    accuracy:DetectorAccuracyHigh
                                detectInGray:YES];
        [detector detectInImage:originImage];
        self.imageView.image = detector.imageWithFaces; 
    } else {
        self.imageView.image = originImage;
    }
    if (completion) {
        completion();
    }
}

- (void)workSaveImage {
    UIImage *markedImage = self.imageView.image;
    UIImageWriteToSavedPhotosAlbum(markedImage, nil, nil, nil);
}

- (void)workLoadImage {
    [self startImagePickerController:self
                          sourceType:UIImagePickerControllerSourceType\
SavedPhotosAlbum
                       usingDelegate:self];
}

- (void)popoverControllerDidDismissPopover:
(UIPopoverController *)popoverController {
    if (popoverController == self.imagePickerPopoverController) {
        self.imagePickerPopoverController = nil;
    } else {
        self.flipsidePopoverController = nil;
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
        UIPopoverController *popoverController = 
            [(UIStoryboardPopoverSegue *)segue popoverController];
        self.flipsidePopoverController = popoverController;
        popoverController.delegate = self;
    }
}

- (IBAction)togglePopover:(id)sender
{
    if (self.imagePickerPopoverController) {
        [self.imagePickerPopoverController dismissPopoverAnimated:YES];
        self.imagePickerPopoverController = nil;
    } else if (self.flipsidePopoverController) {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    } else {
        [self performSegueWithIdentifier:@"showAlternate" sender:sender];
    }
}

- (IBAction)startCameraResponder:(id)sender {
    if (sender == self.cameraButton) {
        // close the popover
        if (self.imagePickerPopoverController) {
            [self.imagePickerPopoverController dismissPopoverAnimated:YES];
            self.imagePickerPopoverController = nil;
        }
        if (self.flipsidePopoverController) {
            [self.flipsidePopoverController dismissPopoverAnimated:YES];
            self.flipsidePopoverController = nil;
        }
        [self startImagePickerController:self 
                              sourceType:UIImagePickerControllerSourceTypeCamera
                           usingDelegate:self];
    }
}

- (BOOL)startImagePickerController:(UIViewController*)viewController
                        sourceType:(UIImagePickerControllerSourceType)sourceType
                     usingDelegate:(id<UIImagePickerControllerDelegate,
                                    UINavigationControllerDelegate>)delegate {
    if ([UIImagePickerController isSourceTypeAvailable:sourceType] == NO 
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

# pragma mark -- UIImagePickerControllerDelegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker 
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!image) {
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    self.originImage = image;
    self.imageView.image = image;
    
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self.imagePickerPopoverController dismissPopoverAnimated:YES];
        self.imagePickerPopoverController = nil;
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self.imagePickerPopoverController dismissPopoverAnimated:YES];
        self.imagePickerPopoverController = nil;
    }
}

@end
