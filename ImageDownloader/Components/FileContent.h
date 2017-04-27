//
//  FileContent.h
//  ImageDownloader
//
//  Created by thcanh on 4/25/17.
//  Copyright © 2017 CanhTran. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM (NSInteger, DownloadingStatus) {
    downloading = 0,
    queuering = 1,
    finished = 2,
    error = 3,
    unzip = 4
};

@interface FileContent : NSObject <NSCoding>

@property (nonatomic, strong) NSString  *name;
@property (nonatomic, strong) NSString  *path;
@property (nonatomic, strong) NSURL     *url;
@property (nonatomic) DownloadingStatus status;
@property (nonatomic, assign) BOOL isDownloading;
@property (nonatomic, assign) float progress;

- (id) initWithURL:(NSString *)urlString;

@end
