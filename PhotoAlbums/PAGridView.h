//
//  PAGridView.h
//  PhotoAlbums
//
//  Created by Oliver on 12-8-17.
//
//

#import <UIKit/UIKit.h>
#import "PAGridViewCell.h"

@protocol PAGridViewDataSource;

@interface PAGridView : UIView <UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    int _pageRow;
    int _pageCol;
    float _padding;
    float _contentHeight;
    float _contentWidth;
    NSMutableArray* _cellArray;
    BOOL _orientationIsPortrait;
    id<PAGridViewDataSource>_dataSource;
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
@property(nonatomic,assign)id<PAGridViewDataSource>dataSource;
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

- (void)reloadData;
-(CGSize)setScrollViewContentSizeWithWidth:(float)width andHeight:(float)height;
- (void) setUpCellViewFrame;

@end

//************PAGridViewDataSource Protocol**************//
@protocol PAGridViewDataSource <NSObject>

-(NSInteger)numberOfItemsInGridView:(PAGridView *)gridView;
-(CGSize)sizeForItemsInGridView:(PAGridView *)gridView;
-(NSInteger)numberOfPageRow;
-(NSInteger)numberOfPageColumn;
-(float)paddingForCell;
-(PAGridViewCell *)PAGridView:(PAGridView *)gridView cellForItemAtIndex:(NSInteger)index;
-(BOOL)updateOrientationState;
- (void)presentPhotoView:(PAGridViewCell *)cell andPhotoArray:(NSMutableArray *)array;

@end