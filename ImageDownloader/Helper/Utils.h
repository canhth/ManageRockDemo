//
//  Utils.h
//  ImageDownloader
//
//  Created by thcanh on 4/25/17.
//  Copyright © 2017 CanhTran. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FileContent.h"

@interface Utils : NSObject

+ (Utils *)sharedUtils;

/**
 Function to load the image form PDF file

 @param path PFD path
 @return Image
 */
+ (UIImage *) loadImageFromPDFatPath:(NSString *) path;


/**
 Function to unzip image at Path

 @param path path
 @return Image
 */
+ (UIImage *) unZipImageAtPath:(NSString *)path;


/**
 Support to get name of Download status by enum

 @param status DownloadingStatus
 @return String name
 */
+ (NSString*) nameForDownloadStatus:(DownloadingStatus) status;


// NSUserDefault

- (void) saveJsonFiles:(NSMutableArray *) jsonFiles ;
- (NSMutableArray *) getJsonFiles;

- (void) saveQueue:(NSMutableArray *) queue;
- (NSMutableArray *) getQueue;

- (void) saveActiveDownloads:(NSMutableDictionary *) activeDownloads;
- (NSMutableDictionary *) getActiveDownloads;
@end
