//
//  XYZMainViewController.h
//  testFace
//
//  Created by Mingyi Yuan on 12-5-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "XYZFlipsideViewController.h"
#import "CameraViewController.h"
#import "FaceDetector.h"

@interface XYZMainViewController : UIViewController 
                                    <WorkDelegate, 
                                    UIImagePickerControllerDelegate,
                                    UINavigationControllerDelegate,
                                    UIPopoverControllerDelegate,
                                    UIAlertViewDelegate,
                                    CameraViewDelegate> 

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;
@property (strong, nonatomic) UIPopoverController *imagePickerPopoverController;
@property (strong, nonatomic) CameraViewController *cameraView;

@property (strong, nonatomic) FaceDetector *faceDetector;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;

@property (strong, nonatomic) UIImage *originImage;
@property (strong, nonatomic) NSURL *imageURL;

- (IBAction)startCameraResponder:(id)sender;

@end
