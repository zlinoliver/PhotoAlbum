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
#import "PAGridView2.h"
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
@synthesize paGridView2 = _paGridView2;
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
-(void)dealloc
{
    
    if (_paGridView2) {
        [_paGridView2 release];
        _paGridView2 = nil;
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

-(void)loadView
{
    [super loadView];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.snapShotMode = NO;

    //******************初始化imageArray***************//
    _imageArray = [[NSMutableArray alloc]init];
    
    //******************初始化PhotoViewController，设置delegate***********//
    _photoViewController = [[PhotoViewController alloc]init];
    [_photoViewController.view setFrame:self.view.frame];
    _photoViewController.photoDelegate = self;

    //*****************初始化PAGridView，设置dataSource************//
    _paGridView2 = [[PAGridView2 alloc]initWithFrame:self.view.bounds];
    _paGridView2.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _paGridView2.backgroundColor = [UIColor clearColor];
    _paGridView2.dataSource = self;
    _paGridView2.clipsToBounds = NO;
    [_paGridView2.scrollView setCanCancelContentTouches:YES];
    [self.view addSubview:_paGridView2];
    [_paGridView2 release];
    
    //****************为PAGridView添加手势识别*******************//
    [self addGestureRecognizersWithView:_paGridView2];
    
}

//**********************添加拖动，捏合和点击的手势识别*****************//
-(void)addGestureRecognizersWithView:(UIView *)view
{

    _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureUpdated:)];
    _panGesture.delegate = self;
    [_panGesture setCancelsTouchesInView:YES];
    [_panGesture setMaximumNumberOfTouches:2];
    [_panGesture setMinimumNumberOfTouches:2];
    [view addGestureRecognizer:_panGesture];
    [_panGesture release];
    
    _pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchGestureUpdated:)];
    _pinchGesture.delegate = self;
    [_pinchGesture setCancelsTouchesInView:YES];
    [view addGestureRecognizer:_pinchGesture];
    [_pinchGesture release];
    
    _tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGestureUpdated:)];
    _tapGesture.delegate = self;
    [_tapGesture setCancelsTouchesInView:YES];
    [_tapGesture setNumberOfTapsRequired:2];
    [_tapGesture setNumberOfTouchesRequired:1];
    [view addGestureRecognizer:_tapGesture];
    [_tapGesture release];

}

-(void)reloadDataBaseOnOrientationMode
{
    //*******************根据设备旋转方向，更新OrientationIsPortrait布尔值***************//
    if ([[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeLeft){
        
        [self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
        self.orientationIsPortrait = NO;
        _photoViewController.orientationIsPortrait = NO;
        
    }else if ([[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeRight){
        
        [self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight];
        self.orientationIsPortrait = NO;
        _photoViewController.orientationIsPortrait = NO;
        
    }else if ([[UIDevice currentDevice]orientation] == UIInterfaceOrientationPortrait){
        
        [self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortrait];
        self.orientationIsPortrait = YES;
        _photoViewController.orientationIsPortrait = YES;
        
    }else if ([[UIDevice currentDevice]orientation] == UIInterfaceOrientationPortraitUpsideDown)
    {
        [self shouldAutorotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown];
        self.orientationIsPortrait = YES;
        _photoViewController.orientationIsPortrait = YES;

    }
    
    //*************初始化PAGridView的数据****************//
    [_paGridView2 setFrame:self.view.bounds];
    [_paGridView2 reloadData];

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

#pragma mark - ====================PAGridView2DataSource Methods=========================

-(NSInteger)numberOfItemsInGridView:(PAGridView2 *)gridView
{
    return NUMBER_ITEMS_ON_LOAD;
}

-(CGSize)sizeForItemsInGridView:(PAGridView2 *)gridView
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

-(PAGridViewCell *)PAGridView:(PAGridView2 *)gridView cellForItemAtIndex:(NSInteger)index
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

-(void)presentPhotoView:(PAGridViewCell *)cell andPhotoArray:(NSMutableArray *)array
{
    
    [_photoViewController setImageArray:array];
    [_photoViewController setCurrentIndex:cell.tag];
    [_photoViewController setOrientationIsPortrait:_orientationIsPortrait];
    
    [_photoViewController updateContentViewSize];
    
    //**********重置 ScrollView 的 Scale 和 Rotate值,以及 ToolBar 的 alpha值*******************//
    _photoViewController.scrollView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    _photoViewController.scrollView.transform = CGAffineTransformRotate(_photoViewController.scrollView.transform, 0.0);
    _photoViewController.toolBar.alpha = 1.0;
    
    [_photoViewController.view setFrame:self.view.frame];
    _photoViewController.scrollView.contentSize = CGSizeMake(_photoViewController.scrollView.frame.size.width * [array count], _photoViewController.scrollView.frame.size.height-44);
    
    //***********根据选取的小图片初始化scrollView的contentView内容*************//
    if (cell.tag != 0) {
        
        CGPoint offset = CGPointMake(_photoViewController.scrollView.frame.size.width *cell.tag, 0);
        
        [_photoViewController.scrollView scrollRectToVisible:CGRectMake(offset.x, offset.y, _photoViewController.scrollView.frame.size.width, _photoViewController.scrollView.frame.size.height) animated:NO];
        
    }else{
        
        [_photoViewController tilePages];
    }
    
    //**********刷新ThumbnailPickerView************//
    [_photoViewController.thumbnailPickerView setSelectedIndex:cell.tag];
    [_photoViewController.thumbnailPickerView _updateBigThumbnailPositionVerbose:YES animated:NO];
    
    [self.view addSubview:_photoViewController.view];
    
}

-(void)PhotoViewDisappear:(BOOL)value
{
    
    //****************当PhotoView消失时，更新PAGridView的数据*****************//
    if (value) {
        [_paGridView2 reloadData];
        [_paGridView2 setFrame:self.view.bounds];
    }
    
}

-(void)AnimateCellImageBackToNormalWithCell:(PAGridViewCell *)cell WithPosition:(CGPoint)point
{
    //*************将PAGridViewCell调整到视图最前面**************//
    [_paGridView2.scrollView bringSubviewToFront:cell];
    //************结束拖动后，显示小图片*******************//
    [cell setHidden:NO];
    [cell setCenter:point];
}

-(void)MoveCellImageWithCell:(PAGridViewCell *)cell andPosition:(CGPoint)point{
        
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

-(void)tapGestureUpdated:(UITapGestureRecognizer *)tapGesture
{
    switch (tapGesture.state) {
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            
            //****************延迟0.2秒执行transformingGestureDidFinishWithGesture函数***************//
            [self performSelector:@selector(transformingGestureDidFinishWithGesture:) withObject:tapGesture afterDelay:0.2];
            
            [_paGridView2.scrollView setContentSize:[_paGridView2 setScrollViewContentSizeWithWidth:_paGridView2.gridViewCellSize.width andHeight:_paGridView2.gridViewCellSize.height + _paGridView2.padding]];
            
            //***************添加结束动画********************//
            [UIView animateWithDuration:kDefaultAnimationDuration
                                  delay:0
                                options:kDefaultAnimationOptions
                             animations:^{
                                 
                                 //*************恢复scrollView接收触控事件，允许滚动操作******************//
                                 [_paGridView2.scrollView setScrollEnabled:YES];
                             
                             }
             
                             completion:nil
             ];
            
            break;
        }
            
        case UIGestureRecognizerStateBegan:
        {
            [_paGridView2.scrollView setScrollEnabled:NO];
            break;
        }
            
        default:
            break;
    }

}

-(void)panGestureUpdated:(UIPanGestureRecognizer *)panGesture
{
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {

            [_paGridView2.scrollView setScrollEnabled:YES];

            break;
        }
            
        case UIGestureRecognizerStateBegan:
        {
            CGPoint currentLocation = [panGesture locationInView:self.view];
            _paGridView2.center = currentLocation;
        }
            
        case UIGestureRecognizerStateChanged:
        {
            
            CGPoint currentLocation = [panGesture locationInView:self.view];
            _paGridView2.center = currentLocation;
            
            
            break;
        }
            
        default:
            break;
    }
    
}

-(void)pinchGestureUpdated:(UIPinchGestureRecognizer *)pinchGesture
{
    
    switch (pinchGesture.state) {
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
                            
            if (self.lastScale >= MinimumScale) {
                
                //**************进入小图片集模式****************//
                self.snapShotMode = NO;
                _paGridView2.ifSnapShotMode = NO;
                    
                [self performSelector:@selector(transformingGestureDidFinishWithGesture:) withObject:pinchGesture afterDelay:0.2];
                
                //*************恢复scrollView接收触控事件，允许滚动操作******************//
                [_paGridView2.scrollView setContentSize:[_paGridView2 setScrollViewContentSizeWithWidth:_paGridView2.gridViewCellSize.width andHeight:_paGridView2.gridViewCellSize.height + _paGridView2.padding]];
                    
                for (PAGridViewCell *cell in _paGridView2.cellArray) {
                        [cell setUserInteractionEnabled:YES];
                }
                    
                }else
                {
                    //*************进入图片集叠加模式****************//
                    self.snapShotMode = YES;
                    _paGridView2.ifSnapShotMode = YES;

                    [UIView animateWithDuration:kDefaultAnimationDuration
                                          delay:0
                                        options:kDefaultAnimationOptions
                                     animations:^{
                                         
                                         [_paGridView2 setFrame:CGRectMake(_paGridView2.frame.origin.x, _paGridView2.frame.origin.y, _paGridView2.gridViewCellSize.width, _paGridView2.gridViewCellSize.height)];
                                         [_paGridView2.scrollView setContentSize:CGSizeMake(_paGridView2.gridViewCellSize.width, _paGridView2.gridViewCellSize.height)];
                                         [_paGridView2.scrollView setFrame:CGRectMake(_paGridView2.scrollView.frame.origin.x, _paGridView2.scrollView.frame.origin.y, _paGridView2.gridViewCellSize.width, _paGridView2.gridViewCellSize.height)];
                                         [_paGridView2 setCenter:CGPointMake(self.view.center.x, self.view.center.y)];
                                                                                                                                              
                                         for (PAGridViewCell *cell in _paGridView2.cellArray) {
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
            
            _oriFrame = _paGridView2.frame;
                        
            if (_snapShotMode) {
                
                //************添加动画，设置PAGridView的中心坐标图片集叠加位置*******************//
                [UIView animateWithDuration:0.6
                                      delay:0
                                    options:kDefaultAnimationOptions
                                 animations:^{
       
                                     [_paGridView2 setUpCellViewFrame];
                                     
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
                                     
                                 //    [_paGridView2 setFrame:CGRectMake(_paGridView2.frame.origin.x, _paGridView2.frame.origin.y, _paGridView2.gridViewCellSize.width*2, _paGridView2.gridViewCellSize.height*2)];
                                     
                                 }
                 
                                 completion:nil
                 ];
            
            }
            
            break;
        }
            
        case UIGestureRecognizerStateChanged:
        {
         
            self.snapShotMode = NO;
            _paGridView2.ifSnapShotMode = NO;
            self.lastScale = [pinchGesture scale];
                        
    //        NSLog(@"The PAGridView's scrollView's frame is %@", NSStringFromCGRect(_paGridView2.scrollView.frame));
            
            CGRect newFrame = _oriFrame;
            newFrame.size.width *= _lastScale;
            newFrame.size.height *= _lastScale;
            
            //**************限制newFrame的缩放最大最小值***********************//
            if (newFrame.size.width > self.view.bounds.size.width*1.2) {
                newFrame.size.width = self.view.bounds.size.width*1.2;
            }
            
            if (newFrame.size.height > self.view.bounds.size.height*1.2) {
                newFrame.size.height = self.view.bounds.size.height*1.2;
            }
                        
            newFrame.origin.x = _paGridView2.frame.origin.x;
            newFrame.origin.y = _paGridView2.frame.origin.y;
            
            [_paGridView2 setFrame:newFrame];
            [_paGridView2.scrollView setContentSize:newFrame.size];
            
            self.preScale = [pinchGesture scale];
            
            break;
        }
            
        default:
            break;
    }
    
}

-(void)transformingGestureDidFinishWithGesture:(UIGestureRecognizer *)recognizer
{
     
    if([recognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        
        [UIView animateWithDuration:0.3
                              delay:0
                            options:kDefaultAnimationOptions
                         animations:^{
                             
                             [_paGridView2 setFrame:self.view.bounds];
                         
                         }
                         completion:nil
         ];
        
    }else if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        
        [UIView animateWithDuration:0.3
                              delay:0
                            options:kDefaultAnimationOptions
                         animations:^{
                             
                             [_paGridView2 setFrame:self.view.bounds];
                             
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
                             
                             [_paGridView2 setFrame:self.view.bounds];
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
    [_paGridView2 reloadData];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    _paGridView2 = nil;
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

-(void)viewWillAppear:(BOOL)animated
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
