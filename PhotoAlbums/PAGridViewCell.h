//
//  PAGridViewCell.h
//  PhotoAlbums
//
//  Created by Oliver Oliver on 12-7-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PAGridViewCell : UIImageView
{
    NSInteger _cellID;
    NSInteger _row;
    NSInteger _column;
    CGPoint _lastCenter;
    CGFloat _originalDistance;
    CGFloat _lastDistance;
    CGFloat _deltaDistance;

}

@property(nonatomic,readwrite)NSInteger cellID;
@property(nonatomic,readwrite)NSInteger row;
@property(nonatomic,readwrite)NSInteger column;
@property(nonatomic,readwrite)CGPoint lastCenter;
@property(nonatomic,readwrite)CGFloat originalDistance;
@property(nonatomic,readwrite)CGFloat lastDistance;
@property(nonatomic,readwrite)CGFloat deltaDistance;

@end
