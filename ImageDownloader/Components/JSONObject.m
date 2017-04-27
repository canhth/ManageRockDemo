//
//  JSONObject.m
//  ImageDownloader
//
//  Created by thcanh on 4/25/17.
//  Copyright © 2017 CanhTran. All rights reserved.
//

#import "JSONObject.h"
#import "FileContent.h"

@implementation JSONObject

@synthesize contentFiles;

- (id) initWithURL:(NSURL *)url {
    
    self = [super init];
    
    self.contentFiles = [NSMutableArray array];
    self.isDownloading = false;
    self.progress = 0.0;
    self.status = queuering;
    self.path = @"";
    
    if (url != nil) {
        self.url = [NSURL URLWithString: [NSString stringWithFormat:@"%@", url]];
        self.name = [url.lastPathComponent stringByDeletingPathExtension];
        [self getContentFiles: self.url];
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
    [encoder encodeObject:self.contentFiles forKey:@"contentFiles"];
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
        self.contentFiles   = [decoder decodeObjectForKey:@"contentFiles"];
    }
    return self;
}

#pragma mark ----------------
- (void) getContentFiles:(NSURL *)url {
    
    NSString *path = [NSString stringWithString:url.path];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        @try {
            NSData *data = [[NSData alloc] initWithContentsOfURL:url];
            NSMutableArray *urlFiles = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error: nil];
            
            [self.contentFiles removeAllObjects];
            for (NSString *urlFile in urlFiles) {
                FileContent *contentFileObject = [[FileContent alloc] initWithURL:urlFile];
                [self.contentFiles addObject:contentFileObject];
            }
            
            // To remove duplicate data
            NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:self.contentFiles];
            self.contentFiles = [NSMutableArray arrayWithArray: [orderedSet array]];
            
        } @catch (NSException *exception) {
            NSLog(@"Exception when get content files: %@", exception.debugDescription);
        }
    }
    [self createDirectory];
}

- (void) createDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    self.path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:FolderName];
    self.path = [self.path stringByAppendingPathComponent:self.name];
    if (![fileManager fileExistsAtPath:self.path]) {
        @try {
            [fileManager createDirectoryAtPath:self.path withIntermediateDirectories:true attributes:nil error:nil];
        } @catch (NSException *exception) {
            NSLog(@"Excetion when create Directory: %@", exception.debugDescription);
        }
    } else {
        NSLog(@"This dictionary already created.");
    }
}


- (void) updateContent:(NSString *)urlString withStatus:(DownloadingStatus) status progress:(float) progress {
  
    BOOL isDone = YES;
    float sumProgress = 0.0;
    
    for (FileContent *file in self.contentFiles) {
        if ([file.url.absoluteString isEqualToString: urlString]) {
            file.isDownloading = YES;
            file.status = status;
            file.progress = progress;
            
            if (progress < 0) {
                file.status = error;
            }
        }
        
        if (file.status != finished) {
            isDone = false;
        }
        
        sumProgress += file.progress;
    }
    
    self.status = isDone ? finished : downloading;
    self.progress = sumProgress / (float)(self.contentFiles.count);
}


@end



