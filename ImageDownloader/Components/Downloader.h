//
//  Downloader.h
//  ImageDownloader
//
//  Created by thcanh on 4/25/17.
//  Copyright © 2017 CanhTran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Downloader : NSObject <NSCoding>

@property (nonatomic, strong) NSString          *url;
@property (nonatomic, assign) BOOL              isDownloading;
@property (nonatomic, assign) float             progress;
@property (nonatomic) NSURLSessionDownloadTask  *downloadTask;
@property (nonatomic, strong) NSData            *resumeData;

- (id) initWithURL:(NSString *)url;

@end
