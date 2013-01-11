//
//  RootViewController.m
//  PhotoAlbums
//
//  Created by zaker-7 zaker-7 on 12-7-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "RootViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PAGridViewCell.h"
#import "PAGridView.h"
#import "PhotoViewController.h"

#define EdgeWidthHR 15.68
#define EdgeHeightHR 25.6
#define EdgeWidthVR 21.33
#define EdgeHeightVR 51.485
#define IconWidthHR 125.5
#define IconHeightHR 128.0
#define IconWidthVR 128.0
#define IconHeightVR 102.97
#define MinimumScale 0.7
#define NUMBER_ITEMS_ON_LOAD 50
#define TotalColumnHR 7
#define TotalColumnVR 5
#define MinimumScale 0.7

static const CGFloat kDefaultAnimationDuration = 0.3;
static const UIViewAnimationOptions kDefaultAnimationOptions = UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction;

@interface RootViewController()

//**************监听设备的旋转信息**********************//
- (void)willRotate:(NSNotification *)notification;

//***************监听内存不足警告***********************//
- (void)receivedMemoryWarningNotification:(NSNotification *)notification;

@end

@implementation RootViewController
@synthesize paGridView = _paGridView;
@synthesize orientationIsPortrait = _orientationIsPortrait;
@synthesize imageArray = _imageArray;
@synthesize panGesture = _panGesture;
@synthesize pinchGesture = _pinchGesture;
@synthesize tapGesture = _tapGesture;
@synthesize snapShotMode = _snapShotMode;
@synthesize photoViewController = _photoViewController;
@synthesize oriFrame = _oriFrame;
@synthesize preScale = _preScale;
@synthesize lastScale = _lastScale;

#pragma mark - ======================Dealloc===============================
- (void)dealloc
{
    
    if (_paGridView) {
        [_paGridView release];
        _paGridView = nil;
    }
    
    if (_imageArray) {
        [_imageArray release];
        _imageArray = nil;
    }
    
    if (_pinchGesture) {
        [_pinchGesture release];
        _pinchGesture = nil;
    }
    
    if (_panGesture) {
        [_panGesture release];
        _panGesture = nil;
    }
    
    if (_tapGesture) {
        [_tapGesture release];
        _tapGesture = nil;
    }
    
    if (_photoViewController) {
        [_photoViewController release];
        _photoViewController = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
    
    [super dealloc];
}

#pragma mark - ======================ClassMethods==========================

- (void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.snapShotMode = NO;
    
    //******************初始化imageArray***************//
    self.imageArray = [[[NSMutableArray alloc]init] autorelease];
    
    //******************初始化PhotoViewController，设置delegate***********//
    self.photoViewController = [[[PhotoViewController alloc]init] autorelease];
    [self.photoViewController.view setFrame:self.view.frame];
    self.photoViewController.photoDelegate = self;

    //*****************初始化PAGridView，设置dataSource************//
    self.paGridView = [[[PAGridView alloc]initWithFrame:self.view.bounds] autorelease];
    self.paGridView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.paGridView.backgroundColor = [UIColor clearColor];
    self.paGridView.dataSource = self;
    self.paGridView.clipsToBounds = NO;
    [self.paGridView.scrollView setCanCancelContentTouches:YES];
    [self.view addSubview:self.paGridView];
    
    //****************为PAGridView添加手势识别*******************//
    [self addGestureRecognizersWithView:self.paGridView];
    
}

//**********************添加拖动，捏合和点击的手势识别*****************//
- (void)addGestureRecognizersWithView:(UIView *)view
{

    self.panGesture = [[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureUpdated:)] autorelease];
    self.panGesture.delegate = self;
    [self.panGesture setCancelsTouchesInView:YES];
    [self.panGesture setMaximumNumberOfTouches:2];
    [self.panGesture setMinimumNumberOfTouches:2];
    [view addGestureRecognizer:self.panGesture];
    
    self.pinchGesture = [[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchGestureUpdated:)] autorelease];
    self.pinchGesture.delegate = self;
    [self.pinchGesture setCancelsTouchesInView:YES];
    [view addGestureRecognizer:self.pinchGesture];
    
    self.tapGesture = [[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureUpdated:)] autorelease];
    self.tapGesture.delegate = self;
    [self.tapGesture setCancelsTouchesInView:YES];
    [self.tapGesture setNumberOfTapsRequired:2];
    [self.tapGesture setNumberOfTouchesRequired:1];
    [view addGestureRecognizer:self.tapGesture];

}

- (void)reloadDataBaseOnOrientationMode
{
    //*******************根据设备旋转方向，更新OrientationIsPortrait布尔值***************//
    if ([[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeLeft){
        
        [self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
        self.orientationIsPortrait = NO;
        self.photoViewController.orientationIsPortrait = NO;
        
    }else if ([[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeRight){
        
        [self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight];
        self.orientationIsPortrait = NO;
        self.photoViewController.orientationIsPortrait = NO;
        
    }else if ([[UIDevice currentDevice]orientation] == UIInterfaceOrientationPortrait){
        
        [self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait];
        self.orientationIsPortrait = YES;
        self.photoViewController.orientationIsPortrait = YES;
        
    }else if ([[UIDevice currentDevice]orientation] == UIInterfaceOrientationPortraitUpsideDown)
    {
        [self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown];
        self.orientationIsPortrait = YES;
        self.photoViewController.orientationIsPortrait = YES;

    }
    
    //*************初始化PAGridView的数据****************//
    [self.paGridView setFrame:self.view.bounds];
    [self.paGridView reloadData];

}

//****************************Orientation Management********************//

- (void)willRotate:(NSNotification *)notification
{
    
    [self reloadDataBaseOnOrientationMode];
    //***********************传递设备旋转的Notification消息给PhotoViewController************************//
    [[NSNotificationCenter defaultCenter] postNotificationName:@"RotatingDevice" object:nil];
    
}

//*****************Receive Memory Warning***************************//
- (void)receivedMemoryWarningNotification:(NSNotification *)notification
{
    
}

#pragma mark - ====================PAGridViewDataSource Methods=========================

-(NSInteger)numberOfItemsInGridView:(PAGridView *)gridView
{
    return NUMBER_ITEMS_ON_LOAD;
}

-(CGSize)sizeForItemsInGridView:(PAGridView *)gridView
{
    CGSize size = CGSizeMake(146.285721, 117.333336);
    return size;
}

-(NSInteger)numberOfPageRow
{
    int totalRow;
    
    if (self.orientationIsPortrait) {
        
        if (NUMBER_ITEMS_ON_LOAD%TotalColumnVR == 0) {
            
            totalRow = NUMBER_ITEMS_ON_LOAD/TotalColumnVR;
            
        }else
        {
            totalRow = NUMBER_ITEMS_ON_LOAD/TotalColumnVR +1;
        }
        
    }else
    {
        if (NUMBER_ITEMS_ON_LOAD%TotalColumnHR == 0) {
            
            totalRow = NUMBER_ITEMS_ON_LOAD/TotalColumnHR;
            
        }else
        {
            totalRow = NUMBER_ITEMS_ON_LOAD/TotalColumnHR +1;
        }
        
    }
    
    return totalRow;
}

-(NSInteger)numberOfPageColumn
{
    int totalColumn;
    
    if (self.orientationIsPortrait) {
        
        totalColumn = TotalColumnVR;
        
    }else
    {
        
        totalColumn = TotalColumnHR;
    }
    
    return totalColumn;
}

-(float)paddingForCell
{
    return 10.0;
}

-(PAGridViewCell *)PAGridView:(PAGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    NSString *fileName;
    
    if (index + 1 <= 9 ) {
        
        fileName = [NSString stringWithFormat:@"image00%d.jpg",index+1];
        
    }else {
        
        fileName = [NSString stringWithFormat:@"image0%d.jpg",index+1];
    }
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:fileName]];
    
    PAGridViewCell *cell = [[[PAGridViewCell alloc]initWithFrame:CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, imageView.frame.size.width/8, imageView.frame.size.height/8)] autorelease];
    
    cell.tag = index;
    
    [cell setImage:imageView.image];
    
    //*****************给cell图片添加白色边框和阴影****************//
    [cell.layer setBorderWidth:5.0f];
    [cell.layer setBorderColor:[UIColor whiteColor].CGColor];
    [cell.layer setShadowOffset:CGSizeMake(-3.0, 3.0)];
    [cell.layer setShadowRadius:3.0];
    
    [imageView release];
    
    return cell;
}

-(BOOL)updateOrientationState
{
    return self.orientationIsPortrait;
}

- (void)presentPhotoView:(PAGridViewCell *)cell andPhotoArray:(NSMutableArray *)array
{
    
    [self.photoViewController setImageArray:array];
    [self.photoViewController setCurrentIndex:cell.tag];
    [self.photoViewController setOrientationIsPortrait:self.orientationIsPortrait];
    
    [self.photoViewController updateContentViewSize];
    
    //**********重置 ScrollView 的 Scale 和 Rotate值,以及 ToolBar 的 alpha值*******************//
    self.photoViewController.scrollView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    self.photoViewController.scrollView.transform = CGAffineTransformRotate(self.photoViewController.scrollView.transform, 0.0);
    self.photoViewController.toolBar.alpha = 1.0;
    
    [self.photoViewController.view setFrame:self.view.frame];
    self.photoViewController.scrollView.contentSize = CGSizeMake(self.photoViewController.scrollView.frame.size.width * [array count], self.photoViewController.scrollView.frame.size.height-44);
    
    //***********根据选取的小图片初始化scrollView的contentView内容*************//
    if (cell.tag != 0) {
        
        CGPoint offset = CGPointMake(self.photoViewController.scrollView.frame.size.width *cell.tag, 0);
        
        [self.photoViewController.scrollView scrollRectToVisible:CGRectMake(offset.x, offset.y, self.photoViewController.scrollView.frame.size.width, self.photoViewController.scrollView.frame.size.height) animated:NO];
        
    }else{
        
        [self.photoViewController tilePages];
    }
    
    //**********刷新ThumbnailPickerView************//
    [self.photoViewController.thumbnailPickerView setSelectedIndex:cell.tag];
    [self.photoViewController.thumbnailPickerView _updateBigThumbnailPositionVerbose:YES animated:NO];
    
    [self.view addSubview:self.photoViewController.view];
    
}

- (void)PhotoViewDisappear:(BOOL)value
{
    
    //****************当PhotoView消失时，更新PAGridView的数据*****************//
    if (value) {
        [self.paGridView reloadData];
        [self.paGridView setFrame:self.view.bounds];
    }
    
}

- (void)AnimateCellImageBackToNormalWithCell:(PAGridViewCell *)cell WithPosition:(CGPoint)point
{
    //*************将PAGridViewCell调整到视图最前面**************//
    [self.paGridView.scrollView bringSubviewToFront:cell];
    //************结束拖动后，显示小图片*******************//
    [cell setHidden:NO];
    [cell setCenter:point];
}

- (void)MoveCellImageWithCell:(PAGridViewCell *)cell andPosition:(CGPoint)point{

    //*************根据拖动图片的位置数据，更新Cell的位置*********//
    [cell setHidden:YES];
    [cell setCenter:point];
}

-(float)getFingureDistanceWithLocation1:(CGPoint)location1 andLocation2:(CGPoint)location2
{
    
    float deltaX = fabs(location1.x - location2.x);
    float deltaY = fabs(location1.y - location2.y);
    float distance = sqrtf(deltaX*deltaX + deltaY*deltaY);
    
    return distance;
}

#pragma mark - ======================UIGestureRecognizerDelegate====================

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    
    if (gestureRecognizer.view == otherGestureRecognizer.view) {
        
        return YES;
    }
    
    return NO;
    
}

-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    
    return YES;
}

- (void)tapGestureUpdated:(UITapGestureRecognizer *)tapGesture
{
    switch (tapGesture.state) {
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            
            //****************延迟0.2秒执行transformingGestureDidFinishWithGesture函数***************//
            [self performSelector:@selector(transformingGestureDidFinishWithGesture:) withObject:tapGesture afterDelay:0.2];
            
            [self.paGridView.scrollView setContentSize:[self.paGridView setScrollViewContentSizeWithWidth:self.paGridView.gridViewCellSize.width andHeight:self.paGridView.gridViewCellSize.height + self.paGridView.padding]];
            
            //***************添加结束动画********************//
            [UIView animateWithDuration:kDefaultAnimationDuration
                                  delay:0
                                options:kDefaultAnimationOptions
                             animations:^{
                                 
                                 //*************恢复scrollView接收触控事件，允许滚动操作******************//
                                 [self.paGridView.scrollView setScrollEnabled:YES];

                             }
             
                             completion:nil
             ];
            
            break;
        }
            
        case UIGestureRecognizerStateBegan:
        {
            [self.paGridView.scrollView setScrollEnabled:NO];
            break;
        }
            
        default:
            break;
    }
    
}

- (void)panGestureUpdated:(UIPanGestureRecognizer *)panGesture
{
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {

            [self.paGridView.scrollView setScrollEnabled:YES];

            break;
        }
            
        case UIGestureRecognizerStateBegan:
        {
            CGPoint currentLocation = [panGesture locationInView:self.view];
            self.paGridView.center = currentLocation;
        }
            
        case UIGestureRecognizerStateChanged:
        {
            
            CGPoint currentLocation = [panGesture locationInView:self.view];
            self.paGridView.center = currentLocation;
            
            
            break;
        }
            
        default:
            break;
    }
    
}

- (void)pinchGestureUpdated:(UIPinchGestureRecognizer *)pinchGesture
{
    
    switch (pinchGesture.state) {
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            
            if (self.lastScale >= MinimumScale) {
                
                //**************进入小图片集模式****************//
                self.snapShotMode = NO;
                self.paGridView.ifSnapShotMode = NO;

                [self performSelector:@selector(transformingGestureDidFinishWithGesture:) withObject:pinchGesture afterDelay:0.2];
                
                //*************恢复scrollView接收触控事件，允许滚动操作******************//
                [self.paGridView.scrollView setContentSize:[self.paGridView setScrollViewContentSizeWithWidth:self.paGridView.gridViewCellSize.width andHeight:self.paGridView.gridViewCellSize.height + self.paGridView.padding]];
                    
                for (PAGridViewCell *cell in self.paGridView.cellArray) {
                        [cell setUserInteractionEnabled:YES];
                }
                    
                }else
                {
                    //*************进入图片集叠加模式****************//
                    self.snapShotMode = YES;
                    self.paGridView.ifSnapShotMode = YES;

                    [UIView animateWithDuration:kDefaultAnimationDuration
                                          delay:0
                                        options:kDefaultAnimationOptions
                                     animations:^{
                                         
                                         [self.paGridView setFrame:CGRectMake(self.paGridView.frame.origin.x, self.paGridView.frame.origin.y, self.paGridView.gridViewCellSize.width, self.paGridView.gridViewCellSize.height)];
                                         [self.paGridView.scrollView setContentSize:CGSizeMake(self.paGridView.gridViewCellSize.width, self.paGridView.gridViewCellSize.height)];
                                         [self.paGridView.scrollView setFrame:CGRectMake(self.paGridView.scrollView.frame.origin.x, self.paGridView.scrollView.frame.origin.y, self.paGridView.gridViewCellSize.width, self.paGridView.gridViewCellSize.height)];
                                         [self.paGridView setCenter:CGPointMake(self.view.center.x, self.view.center.y)];
                                                                                                                                              
                                         for (PAGridViewCell *cell in self.paGridView.cellArray) {
                                             [cell setUserInteractionEnabled:NO];
                                         }
                                         
                
                for (PAGridViewCell *cell in self.paGridView.cellArray) {
                    [cell setUserInteractionEnabled:YES];
                }
                
            }else
            {
                //*************进入图片集叠加模式****************//
                self.snapShotMode = YES;
                self.paGridView.ifSnapShotMode = YES;
                
                [UIView animateWithDuration:kDefaultAnimationDuration
                                      delay:0
                                    options:kDefaultAnimationOptions
                                 animations:^{
                                     
                                     [self.paGridView setFrame:CGRectMake(self.paGridView.frame.origin.x, self.paGridView.frame.origin.y, self.paGridView.gridViewCellSize.width, self.paGridView.gridViewCellSize.height)];
                                     [self.paGridView.scrollView setContentSize:CGSizeMake(self.paGridView.gridViewCellSize.width, self.paGridView.gridViewCellSize.height)];
                                     [self.paGridView.scrollView setFrame:CGRectMake(self.paGridView.scrollView.frame.origin.x, self.paGridView.scrollView.frame.origin.y, self.paGridView.gridViewCellSize.width, self.paGridView.gridViewCellSize.height)];
                                     [self.paGridView setCenter:CGPointMake(self.view.center.x, self.view.center.y)];
                                     
                                     for (PAGridViewCell *cell in self.paGridView.cellArray) {
                                         [cell setUserInteractionEnabled:NO];
                                     }
                                     
                                 }
                 
                                 completion:nil
                 ];
                
            }
            
        }
            
        case UIGestureRecognizerStateBegan:
        {
            self.lastScale = pinchGesture.scale;
            self.preScale = pinchGesture.scale;
            
            self.oriFrame = self.paGridView.frame;

            if (self.snapShotMode) {
                
                //************添加动画，设置PAGridView的中心坐标图片集叠加位置*******************//
                [UIView animateWithDuration:0.6
                                      delay:0
                                    options:kDefaultAnimationOptions
                                 animations:^{

                                     [self.paGridView setUpCellViewFrame];
                                     
                                 }
                                 completion:nil
                 ];
                
            }else
            {
                //************添加动画，设置PAGridView的中心坐标图片集叠加位置*******************//
                [UIView animateWithDuration:0.6
                                      delay:0
                                    options:kDefaultAnimationOptions
                                 animations:^{
                                     
                                     //    [_paGridView setFrame:CGRectMake(_paGridView.frame.origin.x, _paGridView.frame.origin.y, _paGridView.gridViewCellSize.width*2, _paGridView.gridViewCellSize.height*2)];
                                     
                                 }
                 
                                 completion:nil
                 ];
                
            }
            
            break;
        }
            
        case UIGestureRecognizerStateChanged:
        {
            
            self.snapShotMode = NO;
            self.paGridView.ifSnapShotMode = NO;
            self.lastScale = [pinchGesture scale];

            //        NSLog(@"The PAGridView's scrollView's frame is %@", NSStringFromCGRect(self.paGridView.scrollView.frame));

            CGRect newFrame = self.oriFrame;
            newFrame.size.width *= self.lastScale;
            newFrame.size.height *= self.lastScale;
            
            //**************限制newFrame的缩放最大最小值***********************//
            if (newFrame.size.width > self.view.bounds.size.width*1.2) {
                newFrame.size.width = self.view.bounds.size.width*1.2;
            }
            
            if (newFrame.size.height > self.view.bounds.size.height*1.2) {
                newFrame.size.height = self.view.bounds.size.height*1.2;
            }
                        
            newFrame.origin.x = self.paGridView.frame.origin.x;
            newFrame.origin.y = self.paGridView.frame.origin.y;

            [self.paGridView setFrame:newFrame];
            [self.paGridView.scrollView setContentSize:newFrame.size];
            
            self.preScale = [pinchGesture scale];
            
            break;
        }
            
        default:
            break;
    }
    
}

- (void)transformingGestureDidFinishWithGesture:(UIGestureRecognizer *)recognizer
{
    
    if([recognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        
        [UIView animateWithDuration:0.3
                              delay:0
                            options:kDefaultAnimationOptions
                         animations:^{
                             
                             [self.paGridView setFrame:self.view.bounds];

                         }
                         completion:nil
         ];
        
    }else if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        
        [UIView animateWithDuration:0.3
                              delay:0
                            options:kDefaultAnimationOptions
                         animations:^{
                             
                             [self.paGridView setFrame:self.view.bounds];
                             
                         }
                         completion:nil
         ];
        
    }else if ([recognizer isKindOfClass:[UITapGestureRecognizer class]])
    {
        //***********对PAGridView复位动作添加动画********************//
        
        [UIView animateWithDuration:kDefaultAnimationDuration
                              delay:0
                            options:kDefaultAnimationOptions
                         animations:^{
                             
                             [self.paGridView setFrame:self.view.bounds];
                         }
                         completion:nil
         ];
        
    }
    
}

#pragma mark - ======================InheritMethods========================
-(id)init
{
    if ((self = [super init]))
    {
        self.title = @"Demo";
        
        //************Initialize StatusBar Orientation*******************//
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willRotate:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedMemoryWarningNotification:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //*************对PAGridView进行数据初始化**************//
    [self.paGridView reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.paGridView = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //*************根据设备旋转方向，更新PAGridView的cell数据*********//
    [self reloadDataBaseOnOrientationMode];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

@end
