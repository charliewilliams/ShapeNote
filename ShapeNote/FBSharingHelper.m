//
//  FBSharingHelper.m
//  ShapeNote
//
//  Created by Charlie Williams on 01/02/2015.
//  Copyright (c) 2015 Charlie Williams. All rights reserved.
//

#import "FBSharingHelper.h"
#import <FacebookSDK/FacebookSDK.h>
#import "ShapeNote-Swift.h"

@implementation FBSharingHelper

static FBSharingHelper *staticHelper = nil;
+ (instancetype)instance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        staticHelper = [[FBSharingHelper alloc] init];
    });
    return staticHelper;
}

- (void)postMinutesToFacebook:(Minutes *)minutes {
    
    AppDelegate *app = [UIApplication sharedApplication].delegate;
    UIViewController *rootVC = app.window.rootViewController;
    
    [FBDialogs presentOSIntegratedShareDialogModallyFrom:rootVC initialText:[minutes stringForSocialMedia] image:nil url:nil handler:^(FBOSIntegratedShareDialogResult result, NSError *error) {
       
        if (error) {
            NSLog(@"%@", error);
        }
        
        NSLog(@"Result: %lu", result);
    }];
}

#pragma mark -

- (void)activateApp {
    [FBAppEvents activateApp];
}

- (BOOL)openURL:(NSURL *)url application:(NSString *)app {
    return [FBAppCall handleOpenURL:url sourceApplication:app];
}

@end
