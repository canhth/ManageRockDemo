//
//  FileContent.m
//  ImageDownloader
//
//  Created by thcanh on 4/25/17.
//  Copyright © 2017 CanhTran. All rights reserved.
//

#import "FileContent.h"

@implementation FileContent

- (id) initWithURL:(NSString *)urlString {
    
    self = [super init];
    
    self.status = queuering;
    self.isDownloading = false;
    self.progress = false;
    self.name = @"";
    self.path = @"";
    
    NSURL *url = [[NSURL alloc] initWithString:urlString];
    if (url != nil) {
        self.url = url;
        self.name = url.lastPathComponent;
    }
    
    return self;
}



- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.url forKey:@"url"];
    [encoder encodeBool:self.isDownloading forKey:@"isDownloading"];
    [encoder encodeFloat:self.progress forKey:@"progress"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.path forKey:@"path"];
    [encoder encodeInteger:self.status forKey:@"status"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.url            = [decoder decodeObjectForKey:@"url"];
        self.isDownloading  = [decoder decodeBoolForKey:@"isDownloading"];
        self.progress       = [decoder decodeFloatForKey:@"progress"];
        self.name           = [decoder decodeObjectForKey:@"name"];
        self.path           = [decoder decodeObjectForKey:@"path"];
        self.status         = [decoder decodeIntegerForKey:@"status"];
    }
    return self;
}

@end
