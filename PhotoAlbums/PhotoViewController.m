//
//  PhotoViewController.m
//  PhotoAlbums
//
//  Created by zaker-7 zaker-7 on 12-7-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PhotoViewController.h"
#import <QuartzCore/QuartzCore.h>

static const CGFloat kDefaultAnimationDuration = 0.3;
static const UIViewAnimationOptions kDefaultAnimationOptions = UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction;

@interface PhotoViewController ()

-(void)transformingGestureDidFinishWithGesture:(UIGestureRecognizer *)recognizer;

@end

@implementation PhotoViewController
@synthesize photoDelegate = _photoDelegate;
@synthesize imageArray = _imageArray;
@synthesize orientationIsPortrait = _orientationIsPortrait;
@synthesize lastScale = _lastScale;
@synthesize preScale = _preScale;
@synthesize deltaScale = _deltaScale;
@synthesize lastRotation = _lastRotation;
@synthesize lastPosition = _lastPosition;
@synthesize scrollView = _scrollView;
@synthesize currentPageNum = _currentPageNum;
@synthesize totalPageNum = _totalPageNum;
@synthesize recycledPages = _recycledPages;
@synthesize visiblePages = _visiblePages;
@synthesize selectedCellOriginalPos = _selectedCellOriginalPos;
@synthesize thumbnailPickerView = _thumbnailPickerView;
@synthesize toolBar = _toolBar;
@synthesize currentIndex = _currentIndex;


#pragma mark - ======================Dealloc===============================
-(void)dealloc
{

    if (_imageArray) {
        [_imageArray release];
        _imageArray = nil;
    }

    if (_scrollView) {
        [_scrollView release];
        _scrollView = nil;
    }
    
    if (_recycledPages) {
        [_recycledPages release];
        _recycledPages = nil;
    }
    
    if (_visiblePages) {
        [_visiblePages release];
        _visiblePages = nil;
    }
    
    if (_thumbnailPickerView) {
        [_thumbnailPickerView release];
        _thumbnailPickerView = nil;
    }
    
    if (_toolBar) {
        [_toolBar release];
        _toolBar = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:nil object:nil];
        
    [super dealloc];
}


#pragma mark - ======================ClassMethods==========================
-(void)addGestureRecognizers
{
    //*************添加UIRotateGestreRecognizer*******************//
    UIRotationGestureRecognizer *rotateGesture = [[UIRotationGestureRecognizer alloc]initWithTarget:self action:@selector(rotateGestureUpdated:)];
    rotateGesture.delegate = self;
    [_scrollView addGestureRecognizer:rotateGesture];
    [rotateGesture release];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinchGestureUpdated:)];
    pinchGesture.delegate = self;
    [_scrollView addGestureRecognizer:pinchGesture];
    [pinchGesture release];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureUpdated:)];
    panGesture.delegate = self;
    [panGesture setMaximumNumberOfTouches:2];
    [panGesture setMinimumNumberOfTouches:2];
    [_scrollView addGestureRecognizer:panGesture];
    [panGesture release];
    
}


-(void)updateContentViewSize
{
    
    self.totalPageNum = [_imageArray count];
    
    //******************根据屏幕旋转方向，更新toolBar的frame***************//
    if (_orientationIsPortrait) {
        
        [_toolBar setFrame:CGRectMake(0, self.view.bounds.size.height - 44, 768.0, 44)];
        [_thumbnailPickerView setFrame:CGRectMake(0, 0, _toolBar.bounds.size.width, _toolBar.bounds.size.height)];
        
    }else
    {
        [_toolBar setFrame:CGRectMake(0, self.view.bounds.size.height - 44, 1024.0, 44)];
        [_thumbnailPickerView setFrame:CGRectMake(0, 0, _toolBar.bounds.size.width, _toolBar.bounds.size.height)];
        
    }
        
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index
{
    BOOL foundPage = NO;
    for (PAGridViewCell *cell in _visiblePages) {
        if (cell.cellID == index) {
            foundPage = YES;
            break;
        }
    }
    return foundPage;
}

//****************重用PAGridViewCell**************//
-(PAGridViewCell *)dequeueRecycledPage
{
    PAGridViewCell *cell = [_recycledPages anyObject];
    
    if (cell) {
        [[cell retain] autorelease];
        [_recycledPages removeObject:cell];
    }
    
    return cell;
}

- (void)configurePage:(PAGridViewCell *)cell forIndex:(NSUInteger)index
{
    cell.cellID = index;
    cell.frame = [self frameForPageAtIndex:index];
    
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    
    CGRect bounds = _scrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width = bounds.size.width + 10;
    pageFrame.origin.x = bounds.size.width * index;
    return pageFrame;
}


-(void)tilePages
{
    //***********计算哪页是当前显示页面******************//
    CGRect visibleBounds = _scrollView.bounds;
    int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
    firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
    lastNeededPageIndex  = MIN(lastNeededPageIndex, _totalPageNum - 1);
    
    //**********重用非当前显示页面*****************//
    for (PAGridViewCell *cell in _visiblePages) {
        
        if (cell.cellID < firstNeededPageIndex || cell.cellID > lastNeededPageIndex) {
            [_recycledPages addObject:cell];
            [cell removeFromSuperview];
        }
    }
    
    [_visiblePages minusSet:_recycledPages];
    
    //***************添加未显示页面*****************//
    for (int index = firstNeededPageIndex; index <= lastNeededPageIndex; index++) {
        
        if (![self isDisplayingPageForIndex:index]) {
            
            NSString *fileName;
            
            if (index + 1 <= 9 ) {
                
                fileName = [NSString stringWithFormat:@"image00%d.jpg",index+1];
                
            }else {
                
                fileName = [NSString stringWithFormat:@"image0%d.jpg",index+1];
            }
            
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:fileName]];
            
            PAGridViewCell *cell = [self dequeueRecycledPage];
            [cell setImage:imageView.image];
            
            if (cell == nil) {
                
                cell = [[[PAGridViewCell alloc] initWithFrame:self.view.bounds] autorelease];
                cell.cellID = index;
                [cell setImage:imageView.image];
                [cell setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
                [self addGestureRecognizers];
                
            }
            
            [self configurePage:cell forIndex:index];
            [imageView release];
            
            [_scrollView addSubview:cell];
            [_visiblePages addObject:cell];
        }
        
    }
}

#pragma mark - ==========================ScrollView Delegate========================================

- (void)scrollViewDidScroll:(UIScrollView *)sender {
                    
    CGFloat pageWidth;
    
    if (_orientationIsPortrait) {

        pageWidth = 768.0;
    }
    else{
        pageWidth = 1024.0;
    }
        
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;

    //////////////Set CurrentPageNum///////////////////
    self.currentPageNum = page;
        
    ///////////////////更新当前可视页面的文章信息//////////////////////
    [self tilePages];
        
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //*************当结束滚动操作后，更新BigThumbnailPosition******************//
    [_thumbnailPickerView setSelectedIndex:_currentPageNum];
    [_thumbnailPickerView _updateBigThumbnailPositionVerbose:YES animated:NO];

}


#pragma mark - ======================ThumbnailPickerView data source===================

- (NSUInteger)numberOfImagesForThumbnailPickerView:(ThumbnailPickerView *)thumbnailPickerView
{
    return [_imageArray count];
}

- (UIImage *)thumbnailPickerView:(ThumbnailPickerView *)thumbnailPickerView imageAtIndex:(NSUInteger)index
{
    PAGridViewCell *cell;
    
    if ([_imageArray count] >= index) {
        cell  = [_imageArray objectAtIndex:index];
    }
    
    return cell.image;
}

#pragma mark - ======================ThumbnailPickerView delegate======================

- (void)thumbnailPickerView:(ThumbnailPickerView *)thumbnailPickerView didSelectImageWithIndex:(NSUInteger)index
{
    //////////////设置 CurrentPageNum///////////////////
    self.currentPageNum = index;
    
    ///////////////////更新当前可视页面的文章信息//////////////////////
    [self tilePages];
        
    CGPoint offset = CGPointMake(_scrollView.frame.size.width *index, 0);
    [_scrollView scrollRectToVisible:CGRectMake(offset.x, offset.y, _scrollView.frame.size.width, _scrollView.frame.size.height) animated:YES];
 
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
    [_scrollView setScrollEnabled:NO];
    return YES;
}


-(void)rotateGestureUpdated: (UIRotationGestureRecognizer *)rotateGesture
{
    switch (rotateGesture.state) {
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            [_scrollView setScrollEnabled:YES];
            
            [self performSelector:@selector(transformingGestureDidFinishWithGesture:) withObject:rotateGesture afterDelay:0.2];
            
            break;
        }
            
        case UIGestureRecognizerStateBegan:
        {
            
            self.lastRotation = rotateGesture.rotation;
            
            break;
        }
            
        case UIGestureRecognizerStateChanged:
        {
            
            self.lastRotation = rotateGesture.rotation;
            
            CGAffineTransform transform = _scrollView.transform;
            transform = CGAffineTransformRotate(transform, self.lastRotation);
            _scrollView.transform = transform;
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
            [_scrollView setScrollEnabled:YES];

            const CGFloat kMaxScale = 3;
            const CGFloat kMinScale = 0.5;
            
            //*********************设置scrollView的边界颜色*************************//
            [_scrollView.layer setBorderColor:[UIColor colorWithWhite:1.0 alpha:0].CGColor];
            
            if ([pinchGesture scale] >= kMinScale && [pinchGesture scale] <= kMaxScale) 
            { 
                
                [self performSelector:@selector(transformingGestureDidFinishWithGesture:) withObject:pinchGesture afterDelay:0.2];

                //***********************设置布尔值，判断PhotoView是否消失*************//
                if ([_photoDelegate respondsToSelector:@selector(PhotoViewDisappear:)]) {
                    [_photoDelegate PhotoViewDisappear:NO];
                }
                
            }else {
                
                //***************移除PhotoView******************//
                [self.view removeFromSuperview];
                
                //***********设置复位动画延时********************//
                [UIView animateWithDuration:kDefaultAnimationDuration 
                                      delay:0
                                    options:kDefaultAnimationOptions
                                 animations:^{
                                     
                                     //***********************Pinch手势结束时，将选中的Cell图片使用动画复位***************************//
                                     if ([_photoDelegate respondsToSelector:@selector(AnimateCellImageBackToNormalWithCell:WithPosition:)]) {
                                         if ([_imageArray count] >= _currentPageNum) {
                                            [_photoDelegate AnimateCellImageBackToNormalWithCell:[_imageArray objectAtIndex:_currentPageNum] WithPosition:_selectedCellOriginalPos];
                                         }

                                     }
                                     
                                 }
                                 completion:nil
                 ];
            }
            
            break;
        }
       
        case UIGestureRecognizerStateBegan:
        {

            //*********************设置scrollView的边界宽度和颜色*************************//
            [_scrollView.layer setBorderWidth:15.0f];
            [_scrollView.layer setBorderColor:[UIColor colorWithWhite:1.0 alpha:0].CGColor];

            //*********更新当前缩放数值*************//
            self.lastScale = pinchGesture.scale;
            self.preScale = pinchGesture.scale;

            //***********************设置布尔值，判断PhotoView是否消失*************//
            if ([_photoDelegate respondsToSelector:@selector(PhotoViewDisappear:)]) {
                [_photoDelegate PhotoViewDisappear:YES];
            }

            //***************记录缩小的图片在图片集模式中的初始位置******************//
            if ([_imageArray count] >= _currentPageNum) {
                
                self.selectedCellOriginalPos = [[_imageArray objectAtIndex:_currentPageNum] center];

            }
            
            break;
        }
            
        case UIGestureRecognizerStateChanged:
        {
            
            //***********************Pinch手势进行时，根据当前拖动位置，更新选中的Cell图片的位置***************************//
            if ([_photoDelegate respondsToSelector:@selector(MoveCellImageWithCell:andPosition:)]) {
                
                if ([_imageArray count] >= _currentPageNum) {
                    
                    [_photoDelegate MoveCellImageWithCell:[_imageArray objectAtIndex:_currentPageNum] andPosition:_scrollView.center];                    
                }
                        
            }
            
            self.lastScale = [pinchGesture scale];
            
            //**************取差值的绝对值*********************//
            self.deltaScale = fabs(_lastScale - _preScale);
            
            //************进行缩小操作****************//
            if (_preScale > _lastScale) {
                
                //****************当进行缩小操作时，减少cell的白色边框的透明度*********//
                [_scrollView.layer setBorderColor:[UIColor colorWithWhite:1.0 alpha:1 - _scrollView.frame.size.width/1000].CGColor];
                
                //*********进行放大操作************//
            }else {
                
                //****************当进行放大操作时，增加cell的白色边框的透明度*********//
                [_scrollView.layer setBorderColor:[UIColor colorWithWhite:1.0 alpha:1 - _scrollView.frame.size.width/1000].CGColor];
                
            }
            
            self.preScale = [pinchGesture scale];
            
            //***************处理scrollView的缩放和旋转动画****************//
            _scrollView.transform = CGAffineTransformMakeScale(_lastScale, _lastScale);
            
            CGAffineTransform transform = _scrollView.transform;
            transform = CGAffineTransformRotate(transform, self.lastRotation);
            _scrollView.transform = transform;
            
            _toolBar.alpha = _lastScale;
            
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
            
            [self performSelector:@selector(transformingGestureDidFinishWithGesture:) withObject:panGesture afterDelay:0.2];
            
            //******************允许滚动操作***********************//
            [_scrollView setScrollEnabled:YES];
            
            break;
        }
            
        case UIGestureRecognizerStateBegan:
        {

            self.lastPosition = CGPointMake(_scrollView.center.x,_scrollView.center.y);
            
            break;
        }
            
        case UIGestureRecognizerStateChanged:
        {
            
            UIView *panView = [panGesture view];
            CGPoint translation = [panGesture translationInView:[panView superview]];
            
            [panView setCenter:CGPointMake([panView center].x + translation.x, [panView center].y + translation.y)];
            [panGesture setTranslation:CGPointZero inView:[panView superview]];
    
            break;
            
        }
        default:
            break;
    }
    
}

-(void)transformingGestureDidFinishWithGesture:(UIGestureRecognizer *)recognizer
{
    if ([recognizer isKindOfClass:[UIRotationGestureRecognizer class]]) {
        
        //*********************添加结束动画，重置旋转值********************//
        [UIView animateWithDuration:kDefaultAnimationDuration 
                              delay:0
                            options:kDefaultAnimationOptions
                         animations:^{
                             
                             _scrollView.transform = CGAffineTransformMakeRotation(0);
                             
                         }
                         completion:nil
         ];
        
    }else if([recognizer isKindOfClass:[UIPinchGestureRecognizer class]]) {
        
        
        //*********************添加结束动画，重置放大值********************//
        [UIView animateWithDuration:kDefaultAnimationDuration
                              delay:0
                            options:kDefaultAnimationOptions
                         animations:^{
                             
                             _scrollView.transform = CGAffineTransformMakeScale(1, 1);

                         }
                         completion:nil
         ];
        
    }else if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        
        //*********************添加结束动画，重置ScrollView的中心坐标值********************//
        
        [UIView animateWithDuration:kDefaultAnimationDuration 
                              delay:0
                            options:kDefaultAnimationOptions
                         animations:^{
                             
                             _scrollView.center = CGPointMake(self.lastPosition.x, self.lastPosition.y);
                         
                         }
                         completion:nil
         ];
        
    }
    
}

-(void)willRotateToInterfaceOrientation:(NSNotification *)notification
{
    if ([[notification name] isEqualToString:@"RotatingDevice"]) {
                        
        if (_orientationIsPortrait) {
            
        
            //******************根据设备的旋转方向，更新ToolBar和ThumbnailPickerView的frame**********************//
            [self.toolBar setFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width-256, 44)];
            [_thumbnailPickerView setFrame:CGRectMake(0, 0, _toolBar.bounds.size.width, _toolBar.bounds.size.height)];
            
        }else
        {
            //******************根据设备的旋转方向，更新ToolBar和ThumbnailPickerView的frame**********************//
            [self.toolBar setFrame:CGRectMake(0, self.view.frame.size.height - 44, self.view.frame.size.width+256, 44)];
            [_thumbnailPickerView setFrame:CGRectMake(0, 0, _toolBar.bounds.size.width, _toolBar.bounds.size.height)];

        }
        
        
    }   
    
}



#pragma mark - ======================InheritMethods========================
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nil bundle:nil]) {
        
        self.title = @"PhotoView";
        
        self.view.backgroundColor = [UIColor clearColor];
        
        //*****************初始化数组***************//
        _recycledPages = [[NSMutableSet alloc]init];
        _visiblePages = [[NSMutableSet alloc]init];
        _imageArray = [[NSMutableArray alloc]init];
        
        //***************初始化 ScrollView*******************//
        _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height - 44)];
        _scrollView.contentSize = CGSizeMake(_scrollView.frame.size.width, _scrollView.frame.size.height - 44);
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.scrollEnabled = YES;
        _scrollView.pagingEnabled = YES;
        _scrollView.scrollsToTop = NO;
        _scrollView.delegate = self;
        [_scrollView setUserInteractionEnabled:YES];
        [_scrollView setCanCancelContentTouches:YES];
        [self.view addSubview:_scrollView];
        [_scrollView release];
        
        
        //***************初始化ToolBar*****************//
        _toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - 22, self.view.frame.size.width, 44)];
        [_toolBar setBarStyle:UIBarStyleBlack];
        [_toolBar setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin];
        _thumbnailPickerView  = [[ThumbnailPickerView alloc]initWithFrame:CGRectMake(0, 0, _toolBar.bounds.size.width, _toolBar.bounds.size.height)];
        _thumbnailPickerView.delegate = self;
        _thumbnailPickerView.dataSource = self;
        [_toolBar addSubview:_thumbnailPickerView];
        [self.view addSubview:_toolBar];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willRotateToInterfaceOrientation:) name:nil object:nil];
        
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    _imageArray = nil;
    _scrollView = nil;
    _recycledPages = nil;
    _visiblePages = nil;
    _scrollView = nil;
    _toolBar = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


@end
