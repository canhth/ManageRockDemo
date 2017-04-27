//
//  NSFileManager+ImageDownloader.m
//  ImageDownloader
//
//  Created by thcanh on 4/25/17.
//  Copyright © 2017 CanhTran. All rights reserved.
//

#import "NSFileManager+ImageDownloader.h"

@implementation NSFileManager (ImageDownloader)

- (NSArray<NSURL*> *) listFiles:(NSString *)path ext:(NSString *) ext {
    NSURL *baseURL = [[NSURL alloc] initFileURLWithPath:path];
    NSMutableArray *urls = [NSMutableArray array];
    NSDirectoryEnumerator *dirEnum = [self enumeratorAtPath:path];
    
    NSString *file;
    while ((file = [dirEnum nextObject])) {
        if ([[file pathExtension] isEqualToString: ext]) {
            NSURL *relativeURL = [[NSURL alloc] initFileURLWithPath:file relativeToURL:baseURL];
            [urls addObject: relativeURL.absoluteString];
        }
    }
    
    return urls;
}

@end
