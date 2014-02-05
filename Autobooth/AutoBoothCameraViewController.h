//
//  AutoBoothCameraViewController.h
//  Autobooth
//
//  Created by Paul Kim on 1/20/14.
//  Copyright (c) 2014 Paul Kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AutoBoothCameraDidFinishTakingPicturesDelegate <NSObject>

-(void) providePicturesArray:(NSArray *) picArray;

@end

@interface AutoBoothCameraViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (weak, nonatomic) id<AutoBoothCameraDidFinishTakingPicturesDelegate> delegate;


@end
