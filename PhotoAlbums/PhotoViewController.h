//
//  PhotoViewController.h
//  PhotoAlbums
//
//  Created by zaker-7 zaker-7 on 12-7-24.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PAGridViewCell.h"
#import "ThumbnailPickerView.h"

@protocol PhotoViewDelegate;

@interface PhotoViewController : UIViewController<UIGestureRecognizerDelegate, UIScrollViewDelegate, ThumbnailPickerViewDelegate, ThumbnailPickerViewDataSource>
{
    id<PhotoViewDelegate>_photoDelegate;
    
    NSMutableArray *_imageArray;
    BOOL _orientationIsPortrait;
    CGFloat _lastScale;
    CGFloat _preScale;
    CGFloat _deltaScale;
    CGFloat _lastRotation;
    CGPoint _lastPosition;
    int _currentPageNum;
    int _totalPageNum;
    NSInteger _currentIndex;
    NSMutableSet *_recycledPages;
    NSMutableSet *_visiblePages;
    CGPoint _selectedCellOriginalPos;
    
    UIScrollView *_scrollView;
    ThumbnailPickerView *_thumbnailPickerView;
    UIToolbar *_toolBar;
    
}

@property(nonatomic,assign)id<PhotoViewDelegate>photoDelegate;
@property(nonatomic,retain)ThumbnailPickerView *thumbnailPickerView;
@property(nonatomic,retain)UIScrollView *scrollView;
@property(nonatomic,retain)NSMutableArray *imageArray;
@property(nonatomic,readwrite)BOOL orientationIsPortrait;
@property(nonatomic,readwrite)CGFloat lastScale;
@property(nonatomic,readwrite)CGFloat preScale;
@property(nonatomic,readwrite)CGFloat deltaScale;
@property(nonatomic,readwrite)CGFloat lastRotation;
@property(nonatomic,readwrite)CGPoint lastPosition;
@property(nonatomic,readwrite)int currentPageNum;
@property(nonatomic,readwrite)int totalPageNum;
@property(nonatomic,readwrite)NSInteger currentIndex;
@property(nonatomic,readwrite)CGPoint selectedCellOriginalPos;
@property(nonatomic,retain)NSMutableSet *recycledPages;
@property(nonatomic,retain)NSMutableSet *visiblePages;
@property(nonatomic,retain)UIToolbar *toolBar;

/**
   添加手势识别
 */
- (void)addGestureRecognizers;

/**
 返回重用的UIImageView
 */
-(PAGridViewCell *)dequeueRecycledPage;

/**
 更新scrollView的图片数据
 */
- (void)tilePages;

/**
 判断是否为当前显示页面
 @param NSUInteger 判断页数
 @returns 返回判断布尔值
 */
- (BOOL)isDisplayingPageForIndex:(NSUInteger)index;

/**
 刷新PAGridViewCell的页面数据
 */
- (void)configurePage:(PAGridViewCell *)cell forIndex:(NSUInteger)index;

/**
 返回当前页面的frame值
 */
- (CGRect)frameForPageAtIndex:(NSUInteger)index;

- (void)updateContentViewSize;

@end

@protocol PhotoViewDelegate <NSObject>
- (void)PhotoViewDisappear:(BOOL)value;
- (void)AnimateCellImageBackToNormalWithCell:(PAGridViewCell *)cell WithPosition:(CGPoint)point;
- (void)MoveCellImageWithCell:(PAGridViewCell *)cell andPosition:(CGPoint)point;

@end


