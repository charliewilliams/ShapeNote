//
//  FBSharingHelper.h
//  ShapeNote
//
//  Created by Charlie Williams on 01/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Minutes;

@interface FBSharingHelper : NSObject

+ (instancetype)instance;
- (void)postMinutesToFacebook:(Minutes *)minutes;
- (void)activateApp;
- (BOOL)openURL:(NSURL *)url application:(NSString *)app;

@end
