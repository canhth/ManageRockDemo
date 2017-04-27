//
//  NSFileManager+ImageDownloader.h
//  ImageDownloader
//
//  Created by thcanh on 4/25/17.
//  Copyright © 2017 CanhTran. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSFileManager (ImageDownloader)


/**
 Extension(category) of NSFileManager to get list file json after unzip

 @param path Path
 @param ext "json"
 @return Array of URL
 */
- (NSArray<NSURL*> *) listFiles:(NSString *)path ext:(NSString *) ext;

@end
