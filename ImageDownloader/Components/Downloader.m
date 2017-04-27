//
//  Downloader.m
//  ImageDownloader
//
//  Created by thcanh on 4/25/17.
//  Copyright © 2017 CanhTran. All rights reserved.
//

#import "Downloader.h"

@implementation Downloader

- (id) initWithURL:(NSString *)url {
    
    self = [super init];
    self.url = url;
    self.isDownloading = false;
    self.progress = 0.0;
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.url forKey:@"url"];
    [encoder encodeBool:self.isDownloading forKey:@"isDownloading"];
    [encoder encodeFloat:self.progress forKey:@"progress"];
    //[encoder encodeObject:self.downloadTask forKey:@"downloadTask"];
    [encoder encodeObject:self.resumeData forKey:@"resumeData"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.url            = [decoder decodeObjectForKey:@"url"];
        self.isDownloading  = [decoder decodeBoolForKey:@"isDownloading"];
        self.progress       = [decoder decodeFloatForKey:@"progress"];
        //self.downloadTask   = [decoder decodeObjectForKey:@"downloadTask"];
        self.resumeData     = [decoder decodeObjectForKey:@"resumeData"];
    }
    return self;
}


@end
