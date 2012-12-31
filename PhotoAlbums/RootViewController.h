//
//  RootViewController.h
//  PhotoAlbums
//
//  Created by zaker-7 zaker-7 on 12-7-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAGridView.h"
#import "PhotoViewController.h"

@interface RootViewController : UIViewController<PAGridViewDataSource, UIGestureRecognizerDelegate,PhotoViewDelegate>
{
    
    PAGridView *_paGridView;
    BOOL _orientationIsPortrait;
    NSMutableArray *_imageArray;
    UIPanGestureRecognizer *_panGesture;
    UIPinchGestureRecognizer *_pinchGesture;
    UITapGestureRecognizer *_tapGesture;
    BOOL _snapShotMode;
    PhotoViewController *_photoViewController;
    CGRect _oriFrame;
    float _preScale;
    float _lastScale;
}

@property (nonatomic,retain)PAGridView *paGridView;
@property (nonatomic,readwrite)BOOL orientationIsPortrait;
@property (nonatomic,retain)NSMutableArray *imageArray;
@property (nonatomic,retain)UIPanGestureRecognizer *panGesture;
@property (nonatomic,retain)UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic,retain)UITapGestureRecognizer *tapGesture;
@property (nonatomic,readwrite)BOOL snapShotMode;
@property (nonatomic,retain)PhotoViewController *photoViewController;
@property (nonatomic,readwrite)CGRect oriFrame;
@property (nonatomic,readwrite)float preScale;
@property (nonatomic,readwrite)float lastScale;

-(void)transformingGestureDidFinishWithGesture:(UIGestureRecognizer *)recognizer;
-(void)addGestureRecognizersWithView:(UIView *)view;
-(void)reloadDataBaseOnOrientationMode;
-(float)getFingureDistanceWithLocation1:(CGPoint)location1 andLocation2:(CGPoint)location2;

@end
