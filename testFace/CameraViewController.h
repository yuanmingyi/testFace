//
//  CameraViewController.h
//  testFace
//
//  Created by Mingyi Yuan on 12-5-31.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CameraViewDelegate;

@interface CameraViewController : UIViewController <UIImagePickerControllerDelegate,
                                    UINavigationControllerDelegate>
@property (weak, nonatomic) id <CameraViewDelegate> delegate;

@property (strong, nonatomic) UIImagePickerController * imagePickerController;

- (IBAction)shotTouchUp:(id)sender;
- (IBAction)backTouchUp:(id)sender;
- (IBAction)optionsTouchUp:(id)sender;

//- (BOOL)setupImagePicker:(UIImagePickerController*)cameraUI;
@end

@protocol CameraViewDelegate
- (void)cameraDidCancel;
- (void)cameraDidTakeAPhoto:(UIImage*)image;
@end