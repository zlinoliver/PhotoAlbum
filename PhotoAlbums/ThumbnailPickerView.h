//
//  ThumbnailPickerView.h
//  PhotoAlbums
//
//  Created by zaker-7 zaker-7 on 12-7-27.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ThumbnailPickerView;

@protocol ThumbnailPickerViewDelegate <NSObject>
@optional
- (void)thumbnailPickerView:(ThumbnailPickerView *)thumbnailPickerView didSelectImageWithIndex:(NSUInteger)index;
@end


@protocol ThumbnailPickerViewDataSource <NSObject>
- (NSUInteger)numberOfImagesForThumbnailPickerView:(ThumbnailPickerView *)thumbnailPickerView;
- (UIImage *)thumbnailPickerView:(ThumbnailPickerView *)thumbnailPickerView imageAtIndex:(NSUInteger)index;
@end


@interface ThumbnailPickerView : UIControl
{

}

- (void)reloadData;
- (void)reloadThumbnailAtIndex:(NSUInteger)index;
- (void)setSelectedIndex:(NSUInteger)selectedIndex animated:(BOOL)animated;
- (void)_updateBigThumbnailPositionVerbose:(BOOL)verbose animated:(BOOL)animated;

// NSNotFound if nothing is selected
@property (nonatomic, assign) NSUInteger selectedIndex;
@property (nonatomic, assign) id<ThumbnailPickerViewDataSource> dataSource;
@property (nonatomic, assign) id<ThumbnailPickerViewDelegate> delegate;
@end