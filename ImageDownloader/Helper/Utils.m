//
//  Utils.m
//  ImageDownloader
//
//  Created by thcanh on 4/25/17.
//  Copyright © 2017 CanhTran. All rights reserved.
//

#import "Utils.h"
#import "SSZipArchive.h"

@implementation Utils

+ (Utils *)sharedUtils {
    static Utils* sharedUtils = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedUtils = [[Utils alloc] init];
    });
    
    return sharedUtils;
}

// NOTE: For now we just support image with one page
#define PAGE_NO  1

+ (UIImage *) loadImageFromPDFatPath:(NSString *) path {
    
    NSURL *url = [NSURL fileURLWithPath: path];
    CGPDFDocumentRef pdf = CGPDFDocumentCreateWithURL((CFURLRef)url);
    CGPDFPageRef page = CGPDFDocumentGetPage(pdf, PAGE_NO);
    CGRect rect = CGPDFPageGetBoxRect(page, kCGPDFCropBox);
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, 0.0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    CGContextSetGrayFillColor(context, 1.0, 1.0);
    CGContextFillRect(context, rect);
    
    CGAffineTransform transform = CGPDFPageGetDrawingTransform(page, kCGPDFCropBox, rect, 0, true);
    CGContextConcatCTM(context, transform);
    CGContextDrawPDFPage(context, page);
    
    UIImage *image= UIGraphicsGetImageFromCurrentImageContext();
    CGContextRestoreGState(context);
    UIGraphicsEndImageContext();
    CGPDFDocumentRelease(pdf);
    
    return image;
}

+ (UIImage *) unZipImageAtPath:(NSString *)path {
    NSURL *zipURL = [NSURL fileURLWithPath:path];
    NSURL *imageURL = [NSURL fileURLWithPath:path];
    
    [imageURL URLByDeletingPathExtension];
    [imageURL URLByAppendingPathExtension:@"jpg"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:imageURL.path]) {
        UIImage *image = [UIImage imageWithContentsOfFile:imageURL.path];
        return image;
    }
    
    NSURL *destination = [zipURL URLByDeletingLastPathComponent];
    [SSZipArchive unzipFileAtPath:zipURL.path toDestination:destination.path];
    
    if ([fileManager fileExistsAtPath:imageURL.path]) {
        UIImage *image = [UIImage imageWithContentsOfFile:imageURL.path];
        return image;
    }
    
    return nil;
}

+ (NSString*) nameForDownloadStatus:(DownloadingStatus)status {
    switch (status) {
        case downloading:
            return @"downloading";
            break;
        case queuering:
            return @"queuering";
            break;
        case finished:
            return @"finished";
            break;
        case error:
            return @"error";
            break;
        case unzip:
            return @"unzip";
            break;
        default:
            return nil;
            break;
    };
    
    return nil;
}

#pragma mark - UserDefault
- (void) saveJsonFiles:(NSMutableArray *) jsonFiles {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *array = [jsonFiles copy];
    [defaults setValue:[NSKeyedArchiver archivedDataWithRootObject:array] forKey:@"jsonFiles"];
    [defaults synchronize];
}

- (NSMutableArray *) getJsonFiles {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"jsonFiles"];
    NSMutableArray *getJsonFiles = [[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
    if (!getJsonFiles) {
        return [NSMutableArray array];
    }
    return getJsonFiles;
}

- (void) saveQueue:(NSMutableArray *) queue {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *array = [queue copy];
    [defaults setValue:[NSKeyedArchiver archivedDataWithRootObject:array] forKey:@"queue"];
    [defaults synchronize];
}

- (NSMutableArray *) getQueue {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"queue"];
    NSMutableArray *queue = [[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
    if (!queue) {
        return [NSMutableArray array];
    }
    return queue;
}

- (void) saveActiveDownloads:(NSMutableDictionary *) activeDownloads {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:[NSKeyedArchiver archivedDataWithRootObject:activeDownloads] forKey:@"activeDownloads"];
    [defaults synchronize];
}

- (NSMutableDictionary *) getActiveDownloads {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSData *data = [defaults objectForKey:@"activeDownloads"];
    NSMutableDictionary *activeDownloads = [[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
    if (!activeDownloads) {
        return [NSMutableDictionary dictionary];
    }
    return activeDownloads;
}

@end
