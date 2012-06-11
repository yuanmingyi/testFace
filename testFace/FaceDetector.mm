//
//  FaceDetector.m
//  testFace
//
//  Created by Mingyi Yuan on 12-5-29.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "FaceDetector.h"
#import <Utilities/Utilities.h>

class CascadeData {
public:
    static cv::CascadeClassifier faceCascade;
    static cv::CascadeClassifier eyesCascade;
    static NSString *faceCascadeName; //= @"haarcascade_frontalface_alt";
    static NSString *eyesCascadeName; //= @"haarcascade_eye_tree_eyeglasses";
};
NSString * CascadeData::faceCascadeName = @"haarcascade_frontalface_alt";
NSString * CascadeData::eyesCascadeName = @"haarcascade_eye_tree_eyeglasses";

cv::CascadeClassifier CascadeData::faceCascade; 
cv::CascadeClassifier CascadeData::eyesCascade;

@interface FaceDetector ()
- (void)detectFaceWithOpenCV:(CGImageRef)cgImage;
- (void)detectFaceWithCoreImage:(CGImageRef)cgImage;
@end

@implementation FaceDetector

@synthesize imageWithFaces = imageWithFaces_;
@synthesize faceRegions = faceRegions_;
@synthesize faceCount = faceCount_;

@synthesize source;
@synthesize accuracy;
@synthesize detectorOptions, contextOptions;
@synthesize detectInGray;

+ (void)loadCascadeData {
    NSString *faceCascadePath = [[NSBundle mainBundle] pathForResource:CascadeData::faceCascadeName ofType:@"xml"];
    if (!faceCascadePath || !CascadeData::faceCascade.load([faceCascadePath UTF8String])) {
        NSLog(@"failed loading face cascade classifier!");
    }  
    NSString *eyesCascadePath = [[NSBundle mainBundle] pathForResource:CascadeData::eyesCascadeName ofType:@"xml"];
    if (!eyesCascadePath || !CascadeData::eyesCascade.load([eyesCascadePath UTF8String])) {
        NSLog(@"failed loading eyes cascade classifier!");
    }
}

+ (id)detectorWithSource:(DetectorSource)source 
                accuracy:(DetectorAccuracy)accuracy
            detectInGray:(BOOL)detectInGray {
    FaceDetector *detector = [[FaceDetector alloc] init];
    detector.source = source;
    detector.accuracy = accuracy;
    detector.detectorOptions = 
    [NSDictionary dictionaryWithObject:(accuracy == DetectorAccuracyLow)?
                                        CIDetectorAccuracyLow:
                                        CIDetectorAccuracyHigh
                                forKey:CIDetectorAccuracy];
    detector.contextOptions = 
    [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithBool:NO],
                    kCIContextUseSoftwareRenderer,
                    (__bridge_transfer id)(detectInGray?
                                           CGColorSpaceCreateDeviceGray():
                                           CGColorSpaceCreateDeviceRGB()),
                    kCIContextWorkingColorSpace,
                    nil];
    detector.detectInGray = detectInGray;
    return detector;
}

- (id)init {
    self = [super init];
    return self;
}
- (void)detectInImage:(UIImage *)inImage {
    if (inImage == nil 
        || inImage.size.width <= 0
        || inImage.size.height <= 0) {
        return;
    }
    //UIImage *normalizedImage = [inImage normalizedImage];
    
    if (self.detectInGray) {
        
    }
    if (self.source == DetectorSourceCoreImage) {
        [self detectFaceWithCoreImage:inImage.CGImage];
    } else {
        [self detectFaceWithOpenCV:inImage.CGImage];
    }
}
- (void)detectFaceWithOpenCV:(CGImageRef)cgImage {
    std::vector<cv::Rect> faces;
    cv::Mat mat = CGImageCreateMat(cgImage, IplImageTypeBGR), gray;
    cv::cvtColor(mat, gray, CV_BGR2GRAY);
    equalizeHist(gray, gray);
    
    CascadeData::faceCascade.detectMultiScale(gray, faces, 1.1, 2, 0|CV_HAAR_SCALE_IMAGE, cv::Size(30, 30));
    
    // draw faces
    for (int i = 0; i < faces.size(); i++) {
        float halfWidth = faces[i].width*0.5;
        float halfHeight = faces[i].height*0.5;
        cv::Point center(faces[i].x + halfWidth, faces[i].y + halfHeight);
        cv::ellipse(mat, center, cv::Size(halfWidth, halfHeight), 0, 0, 360, cv::Scalar(255, 0, 255), 4, 8, 0);
        
        cv::Mat faceROI = gray(faces[i]);
        std::vector<cv::Rect> eyes;
        //-- In each face, detect eyes
        CascadeData::eyesCascade.detectMultiScale(faceROI, eyes, 1.1, 2, 0 |CV_HAAR_SCALE_IMAGE, cv::Size(30, 30));
        for (int j = 0; j < eyes.size(); j++) {
            cv::Point center(faces[i].x + eyes[j].x + eyes[j].width*0.5, faces[i].y + eyes[j].y + eyes[j].height*0.5); 
            int radius = cvRound((eyes[j].width + eyes[j].height)*0.25);
            cv::circle(mat, center, radius, cv::Scalar(255, 0, 0), 4, 8, 0);
        }
    }
    
    imageWithFaces_ = [UIImage imageWithMat:mat];
    faceCount_ = faces.size();
    NSMutableArray *facesArray = [[NSMutableArray alloc] init];
    for (int i = 0; i < faceCount_; i++) {
        CGRect bounds = CGRectMake(faces[i].x, faces[i].y, faces[i].width, faces[i].height);
        [facesArray addObject:[NSData dataWithBytes:&bounds length:sizeof(bounds)]];
    }
    faceRegions_ = facesArray;
}
- (void)detectFaceWithCoreImage:(CGImageRef)cgImage {
    CIImage *ciImage = [CIImage imageWithCGImage:cgImage];    

    CIContext *ciContext = [CIContext contextWithOptions:self.contextOptions];
             
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:ciContext
                                              options:self.detectorOptions];
    NSArray *featuresArray = [detector featuresInImage:ciImage];
    
    // prepare painting context
    size_t height = CGImageGetHeight(cgImage);
    size_t width = CGImageGetWidth(cgImage);
    size_t bitsPerComponent = CGImageGetBitsPerComponent(cgImage);
    size_t bytesPerRow = 
                CGImageGetBitsPerPixel(cgImage) / bitsPerComponent * width;
    CGColorSpaceRef space = CGImageGetColorSpace(cgImage);
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(cgImage);
    
    CGContextRef cgContext = CGBitmapContextCreate(NULL, 
                                                   width, 
                                                   height, 
                                                   bitsPerComponent, 
                                                   bytesPerRow,
                                                   space, 
                                                   bitmapInfo);
    CGContextDrawImage(cgContext, CGRectMake(0, 0, width, height), cgImage);
    CGContextSetBlendMode(cgContext, kCGBlendModeXOR);
    
    // enumarate the detected features and draw them in the image
    NSMutableArray * faces = [[NSMutableArray alloc] init];
    for (CIFaceFeature *feature in featuresArray) {
        CGRect bounds = feature.bounds;
        // draw face bounds in the image
        CGContextSetRGBFillColor(cgContext, 1.0, 0.0, 0.0, 1.0);
        CGContextStrokeRectWithWidth(cgContext, bounds, 3.0);
        // add bounds to array
        [faces addObject:[NSData dataWithBytes:&bounds length:sizeof(bounds)]];
        // if details in the face are avaliable, draw them in the image too
        /*if ([feature.type isEqualToString: CIDetectorTypeFace]) {
            CIFaceFeature *faceFeature = (CIFaceFeature*)feature;
            if (faceFeature.hasLeftEyePosition) {
                CGPoint eyePos = faceFeature.leftEyePosition;
                CGRect eyeRect = CGRectMake(eyePos.x-1, eyePos.y-1, 3, 3);
                CGContextSetRGBFillColor(cgContext, 1.0, 0.0, 0.0, 1.0);
                CGContextFillEllipseInRect(cgContext, eyeRect);
            }
            if (faceFeature.hasRightEyePosition) {
                CGPoint eyePos = faceFeature.rightEyePosition;
                CGRect eyeRect = CGRectMake(eyePos.x-1, eyePos.y-1, 3, 3);
                CGContextSetRGBFillColor(cgContext, 1.0, 1.0, 0.0, 1.0);
                CGContextFillEllipseInRect(cgContext, eyeRect);
            }
            if (faceFeature.hasMouthPosition) {
                CGPoint mousePos = faceFeature.mouthPosition;
                CGRect mouseRect = CGRectMake(mousePos.x-3, mousePos.y-1, 7, 3);
                CGContextSetRGBFillColor(cgContext, 0.0, 1.0, 0.0, 1.0);
                CGContextStrokeRectWithWidth(cgContext, mouseRect, 1.0);
            }
        }*/
    }
    CGImageRef markedImage = CGBitmapContextCreateImage(cgContext);
    UIImage *outImage = [UIImage imageWithCGImage:markedImage];
    imageWithFaces_ = outImage;
    faceRegions_ = faces;
    faceCount_ = [faces count];
    
    // clean up
    CGContextRelease(cgContext);
    CGImageRelease(markedImage);
}
- (void)clearResult {
    imageWithFaces_ = nil;
    faceRegions_ = nil;
    faceCount_ = 0;
}
@end
