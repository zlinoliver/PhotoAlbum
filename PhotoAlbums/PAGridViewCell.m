//
//  PAGridViewCell.m
//  PhotoAlbums
//
//  Created by Oliver Oliver on 12-7-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PAGridViewCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation PAGridViewCell 
@synthesize cellID = _cellID;
@synthesize row = _row;
@synthesize column = _column;
@synthesize lastCenter = _lastCenter;
@synthesize originalDistance = _originalDistance;
@synthesize lastDistance = _lastDistance;
@synthesize deltaDistance = _deltaDistance;

- (void)dealloc
{
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
