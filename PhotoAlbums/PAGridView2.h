//
//  PAGridView2.h
//  PhotoAlbums
//
//  Created by zaker-7 on 12-8-17.
//
//

#import <UIKit/UIKit.h>
#import "PAGridViewCell.h"

@protocol PAGridView2DataSource;

@interface PAGridView2 : UIView <UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    int _pageRow;
    int _pageCol;
    float _padding;
    float _contentHeight;
    float _contentWidth;
    NSMutableArray* _cellArray;
    BOOL _orientationIsPortrait;
    id<PAGridView2DataSource>_dataSource;
    UIScrollView *_scrollView;
    CGSize _gridViewCellSize;
    NSInteger _gridViewCellNumber;
    CGPoint _lastPosition;
    CGFloat _lastScale;
    CGFloat _preScale;
    CGFloat _deltaScale;
    CGFloat _lastRotation;
    BOOL _ifSnapShotMode;
}

@property(nonatomic,retain) NSMutableArray* cellArray;
@property(nonatomic,readwrite)int pageRow;
@property(nonatomic,readwrite)int pageCol;
@property(nonatomic,readwrite)float padding;
@property(nonatomic,readwrite)float contentHeight;
@property(nonatomic,readwrite)float contentWidth;
@property(nonatomic,assign)id<PAGridView2DataSource>dataSource;
@property(nonatomic,readwrite)CGSize gridViewCellSize;
@property(nonatomic,readwrite)NSInteger gridViewCellNumber;
@property(nonatomic,retain)UIScrollView *scrollView;
@property(nonatomic,readwrite)CGPoint lastPosition;
@property(nonatomic,readwrite)CGFloat lastScale;
@property(nonatomic,readwrite)CGFloat preScale;
@property(nonatomic,readwrite)CGFloat deltaScale;
@property(nonatomic,readwrite)CGFloat lastRotation;
@property(nonatomic,readwrite)BOOL orientationIsPortrait;
@property(nonatomic,readwrite)BOOL ifSnapShotMode;

-(void)reloadData;
-(CGSize)setScrollViewContentSizeWithWidth:(float)width andHeight:(float)height;
-(void) setUpCellViewFrame;

@end

//************PAGridViewDataSource Protocol**************//
@protocol PAGridView2DataSource <NSObject>

-(NSInteger)numberOfItemsInGridView:(PAGridView2 *)gridView;
-(CGSize)sizeForItemsInGridView:(PAGridView2 *)gridView;
-(NSInteger)numberOfPageRow;
-(NSInteger)numberOfPageColumn;
-(float)paddingForCell;
-(PAGridViewCell *)PAGridView:(PAGridView2 *)gridView cellForItemAtIndex:(NSInteger)index;
-(BOOL)updateOrientationState;
-(void)presentPhotoView:(PAGridViewCell *)cell andPhotoArray:(NSMutableArray *)array;

@end