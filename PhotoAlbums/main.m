//
//  main.m
//  PhotoAlbums
//
//  Created by Oliver Oliver on 12-7-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char *argv[])
{
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc]init];
    int retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    [pool release];
    return retVal;
}
