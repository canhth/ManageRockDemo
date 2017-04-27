//
//  AppDelegate.h
//  ImageDownloader
//
//  Created by thcanh on 4/25/17.
//  Copyright © 2017 CanhTran. All rights reserved.
//

#import <UIKit/UIKit.h> 

typedef void(^BackgroundSessionCompletionHandler)();

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic) BackgroundSessionCompletionHandler backgroundSessionCompletion;

@end

