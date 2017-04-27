//
//  JSONObject.h
//  ImageDownloader
//
//  Created by thcanh on 4/25/17.
//  Copyright © 2017 CanhTran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FileContent.h"

@interface JSONObject : NSObject <NSCoding>

@property (nonatomic, strong) NSString  *name;
@property (nonatomic, strong) NSString  *path;
@property (nonatomic, strong) NSURL     *url;
@property (nonatomic) DownloadingStatus status;
@property (nonatomic, strong) NSMutableArray *contentFiles;
@property (nonatomic, assign) BOOL      isDownloading;
@property (nonatomic, assign) float     progress;

- (id) initWithURL:(NSURL *)url;


/**
 Function to get all content from file and remove duplicates object

 @param url Path of file
 */
- (void) getContentFiles:(NSURL *)url;


/**
 Function to update each content of array 'contentFiles'

 @param urlString urlOfFile
 @param status download status
 @param progress new progress
 */
- (void) updateContent:(NSString *)urlString withStatus:(DownloadingStatus) status progress:(float) progress;

@end
