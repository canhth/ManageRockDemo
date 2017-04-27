//
//  HomeViewController.m
//  ImageDownloader
//
//  Created by thcanh on 4/25/17.
//  Copyright © 2017 CanhTran. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController () 

// Outlet
@property (weak, nonatomic) IBOutlet UITableView        *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem    *pauseBarButton;

// Properties
@property (nonatomic) NSURLSession                      *downloadsSession;
@property (strong, nonatomic) NSMutableArray            *jsonFiles;
@property (strong, nonatomic) NSMutableArray            *queue;
@property (strong, nonatomic) NSMutableDictionary       *activeDownloads; // [String: Downloader]

@property (assign, nonatomic) NSInteger                 numberOfConcurrent;
@property (assign, nonatomic) BOOL                      isPause;

@property (weak, nonatomic) ThumbnailViewController     *thumbnailVC;
@property (strong, nonatomic) NSMutableDictionary       *currentItem; // (index: Int, object: JSONObject)

@end

@implementation HomeViewController

- (void) viewDidLoad {
    [super viewDidLoad];
    [self setupProperties];
    
    [self setupObserable];
    
    if (self.jsonFiles.count > 0 && self.queue.count > 0) {
        [self.queue addObjectsFromArray:self.activeDownloads.allValues];
        [self.activeDownloads removeAllObjects];
        [self dequeue];
    }
}

- (void) didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 Setup properties first
 */
- (void) setupProperties {
    self.downloadsSession       = [self backgroundSession];
    self.tableView.delegate     = self;
    self.tableView.dataSource   = self;
    self.activeDownloads        = [[Utils sharedUtils] getActiveDownloads];
    self.currentItem            = [NSMutableDictionary dictionary];
    self.jsonFiles              = [[Utils sharedUtils] getJsonFiles];
    self.queue                  = [[Utils sharedUtils] getQueue];
    self.numberOfConcurrent     = 3;
    self.isPause                = false;
    
    [self.pauseBarButton setEnabled:NO];
    [self createDirectory];
}


/**
 Setup Obserable for get action App Will terminate
 */
- (void) setupObserable {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveCurrentData)
                                                 name:AppWillTerminate
                                               object:nil];
}

/**
 Save current data
 */
- (void) saveCurrentData {
    [[Utils sharedUtils] saveQueue:self.queue];
    [[Utils sharedUtils] saveJsonFiles:self.jsonFiles];
    [[Utils sharedUtils] saveActiveDownloads:self.activeDownloads];
}

/**
 Init url session with background session configuration

 @return NSURLSession
 */
- (NSURLSession *)backgroundSession
{
    static NSURLSession *session = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"com.canh.tran.teaser.ImageDownloader" ];
        session = [NSURLSession sessionWithConfiguration:configuration delegate:self delegateQueue:nil];
    });
    return session;
}

// Find current JsonFile and index of content
- (NSMutableDictionary *) contentIndexForDownloadTask:(NSURLSessionDownloadTask *) downloadTask {
    NSString *urlString = downloadTask.originalRequest.URL.absoluteString;
    if (urlString != nil) {
        for (JSONObject *jsonObject in self.jsonFiles) {
            for (NSInteger i = 0; i < jsonObject.contentFiles.count; i++) {
                FileContent *fileContent = jsonObject.contentFiles[i];
                if ([fileContent.url.absoluteString isEqualToString:urlString]) {
                    id objects[] = { [NSString stringWithFormat:@"%ld", (long)i], jsonObject };
                    id keys[] = { Index, Object };
                    NSUInteger count = sizeof(objects) / sizeof(id);
                    return [NSMutableDictionary dictionaryWithObjects:objects forKeys:keys count:count];;
                }
            }
        }
    }
    return nil;
}


/**
 Insert Downloader task to list queue after unziped file.
 */
- (void) initQueue {
    for (JSONObject *object in self.jsonFiles) {
        for (FileContent *item in object.contentFiles) {
            NSURL *url = item.url;
            if (url != nil) {
                Downloader *downloader = [[Downloader alloc] initWithURL:url.absoluteString];
                NSURLRequest *request = [NSURLRequest requestWithURL:url];
                downloader.downloadTask = [self.downloadsSession downloadTaskWithRequest:request]; 
                downloader.isDownloading = false;
                [self.queue addObject:downloader];
            }
        }
    }
}


/**
 Set active download by insert form queue and then start download
 */
- (void) dequeue {
    [self.pauseBarButton setEnabled:NO];
    if (self.isPause) {
        return;
    }
    
    NSInteger remainNumber = self.numberOfConcurrent - self.activeDownloads.count;
    if (remainNumber < 1) {
        return;
    }
    
    for (NSInteger i = 0; i < remainNumber; i++) {
        if (self.queue.count == 0) {
            return;
        }
        Downloader *download = [self.queue firstObject];
        [self.queue removeObjectAtIndex:0];
        self.activeDownloads[download.url] = download;
        download.downloadTask = [self.downloadsSession  downloadTaskWithURL: [NSURL URLWithString:download.url]];
        [download.downloadTask resume];
        NSLog(@"URL to Download: %@", download.url);
        download.isDownloading = true;
        
    }
}

#pragma mark - Display json data

- (void) createDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:FolderName];
    
    if (![fileManager fileExistsAtPath:path]) {
        @try {
            [fileManager createDirectoryAtPath:path withIntermediateDirectories:true attributes:nil error:nil];
        } @catch (NSException *exception) {
            NSLog(@"Excetion when create Directory: %@", exception.debugDescription);
        }
    } else {
        NSLog(@"This dictionary already created.");
    }
}

- (NSURL *) localFilePathForURL:(NSString *) previewURL {
    NSString *documentsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:FolderName];
    NSURL *url = [NSURL URLWithString:previewURL];
    if (url != nil) {
        NSString *lastPathComponent = url.lastPathComponent;
        NSString *fullPath = [documentsPath stringByAppendingPathComponent:lastPathComponent];
        return [NSURL fileURLWithPath:fullPath];
    }
    return nil;
}


/**
 Function to unzip file

 @param url Path of file
 */
- (void) unzipFileWithURL:(NSURL *)url {
    NSString *documentsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:FolderName];
    NSString *sourcePath = [NSString stringWithFormat:@"%@/%@", documentsPath, url.lastPathComponent];
    [SSZipArchive unzipFileAtPath:sourcePath toDestination:documentsPath delegate:self];
}


#pragma mark - NSURLSession & NSURLSessionDownload Delegate
// NSURLSession
- (void) URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session {
    [self.activeDownloads removeAllObjects];
    [self.queue removeAllObjects];
    [self dequeue];
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    if (appDelegate != nil) {
        BackgroundSessionCompletionHandler completionHandler = appDelegate.backgroundSessionCompletion;
        if (completionHandler != nil) {
            appDelegate.backgroundSessionCompletion = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                completionHandler();
            });
        }
    }
}

// NSURLSessionDownload

- (void) URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location {
    
    NSString *originalURL = downloadTask.originalRequest.URL.absoluteString;
    NSString *fileName = downloadTask.originalRequest.URL.lastPathComponent;
    
    if (originalURL != nil && fileName != nil) {
        NSURL *destinationURL;
        NSMutableDictionary *currentCompletedItem = [NSMutableDictionary dictionary];
        NSMutableDictionary *currentItem = [self contentIndexForDownloadTask:downloadTask];
        if (currentItem != nil) {
            JSONObject *object = currentItem[Object];
            destinationURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", object.path, fileName]];
            currentCompletedItem = currentItem;
            [object updateContent:originalURL withStatus:finished progress:1.0];
            self.currentItem[Object] = object;
           // self.jsonFiles[[currentItem[Index] integerValue]] = object;
        } else {
            if ([self localFilePathForURL:originalURL] != nil) {
                destinationURL = [self localFilePathForURL:originalURL];
            } else {
                return;
            }
        }
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        // Remove Item first
        @try {
            [fileManager removeItemAtURL:destinationURL error:nil];
        } @catch (NSException *exception) {
            NSLog(@"Exception when remove Item %@", exception.debugDescription);
        }
        
        // Copy item to destination URL
        @try {
            [fileManager copyItemAtURL:location toURL:destinationURL error:nil
             ];
        } @catch (NSException *exception) {
            NSLog(@"Exception when copy Item %@. Could not copy file to disk", exception.debugDescription);
        }
        
        if ([originalURL isEqual: JSONFileURL]) {
            [self unzipFileWithURL:destinationURL];
        } else {
            self.activeDownloads[originalURL] = nil;
            
            [self dequeue];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
            // Reload data for ThumbnailViewController
            JSONObject *object = self.thumbnailVC.jsonFile;
            if (object != nil && currentCompletedItem.count > 0) {
                if (object.name == ((JSONObject *)currentCompletedItem[Object]).name) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.thumbnailVC.collectionView reloadItemsAtIndexPaths: @[[NSIndexPath indexPathForRow:[currentCompletedItem[Index] integerValue] inSection:0]]];
                    });
                }
            }
        }
    }
}

- (void) URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite {
    
    NSString *downloadURL = downloadTask.originalRequest.URL.absoluteString;
    Downloader *download = self.activeDownloads[downloadURL];
   
    if (download != nil) {
        download.progress = (float)(totalBytesWritten/totalBytesExpectedToWrite);
        NSMutableDictionary *currentItem = [self contentIndexForDownloadTask:downloadTask];
        if (currentItem != nil) {
            [((JSONObject*)currentItem[Object]) updateContent:downloadURL withStatus:downloading progress:download.progress];
            self.currentItem = currentItem;
            //self.jsonFiles[[currentItem[Index] integerValue]] = currentItem[Object];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
            if (self.thumbnailVC.jsonFile.name == ((JSONObject *)currentItem[Object]).name) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.thumbnailVC.collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:[currentItem[Index] integerValue] inSection:0]]];
                });
            }
        }
    }
}

#pragma mark - SSZipArchiveDelegate

- (void) zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath {
    NSString *zipPath = [path stringByDeletingPathExtension];
   
    for (NSURL *url in [[NSFileManager defaultManager] listFiles:zipPath ext:@"json"]) {
        [self.jsonFiles addObject: [[JSONObject alloc] initWithURL: (NSURL *)url]];
    }
    
    [self initQueue];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
        [self dequeue];
    });
}

#pragma mark - UITableViewDataSource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.jsonFiles.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HomeFileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeFileTableViewCell" forIndexPath:indexPath];
    [cell setupCellWithJSONObject: self.jsonFiles[indexPath.row]];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ThumbnailViewController *thumbnailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ThumbnailViewController"];
    if (thumbnailVC != nil) {
        self.thumbnailVC = thumbnailVC;
        self.thumbnailVC.delegate = self;
        self.thumbnailVC.jsonFile = self.jsonFiles[indexPath.row];
        [self.navigationController pushViewController:thumbnailVC animated:YES];
    }
}

#pragma mark - Navigationbar actions

/**
 Action when tap Pause button

 @param sender not use
 */
- (IBAction) pauseBarButtonTapped:(id)sender {
    self.isPause = !self.isPause;
    
    // Is pausing --> Will store resume data
    if (self.isPause) {
        for (Downloader *download in self.activeDownloads.allValues) {
            if (download.isDownloading) {
                [download.downloadTask cancelByProducingResumeData:^(NSData *resumeData) {
                    if (resumeData != nil) {
                        download.resumeData = resumeData;
                    }
                }];
                download.isDownloading = NO;
            }
        }
        [self.pauseBarButton setTitle:@"Resume"];
    } else {
        // Resume downloading
        for (Downloader *download in self.activeDownloads.allValues) {
            // Resume downloading with resumeData
            if (download.resumeData != nil) {
                download.downloadTask = [self.downloadsSession downloadTaskWithResumeData:download.resumeData];
                [download.downloadTask resume];
                download.isDownloading = YES;
            } else {
                // Start the new one
                download.downloadTask = [self.downloadsSession downloadTaskWithURL:[NSURL URLWithString: download.url]];
                [download.downloadTask resume];
                download.isDownloading = YES;
            }
        }
        [self.pauseBarButton setTitle:@"Pause"];
    }
}

/**
 Action when tap Add barButton --> Need some enhance here

 @param sender not use
 */
- (IBAction) addBarButtonTapped:(id)sender {
    
    // Clear data first
    [self clearAllData];
    
    NSURL *url = [NSURL URLWithString: JSONFileURL];
    
    Downloader *download = [[Downloader alloc] initWithURL:JSONFileURL];
    download.downloadTask = [self.downloadsSession downloadTaskWithURL:url];
    [download.downloadTask resume];
    download.isDownloading = YES;
}


/**
 Action reset BarButton

 @param sender button
 */
- (IBAction) resetBarButtonTapped:(id)sender {
    
    NSString *documentsPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:FolderName];
    
    @try {
        // Remove root document path
        [[NSFileManager defaultManager] removeItemAtPath: documentsPath error:nil];
        [self createDirectory];
    } @catch (NSException *exception) {
        NSLog(@"Could not reset: %@", exception.debugDescription);
    }
    
    [self clearAllData];
}


/**
 To clear all Data after Reset or Start Add
 */
- (void) clearAllData {
    
    for (Downloader *download in self.activeDownloads.allValues) {
        [download.downloadTask cancel];
    }
    
    [self.activeDownloads removeAllObjects];
    [self.queue removeAllObjects];
    [self.jsonFiles removeAllObjects];
    
    [self.tableView reloadData];
    [self.pauseBarButton setEnabled:NO];
    
    // Remove all key of NSUserDefault
    NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:appDomain];
}


#pragma mark - Slider

- (IBAction) sliderDidChange:(UISlider *)sender {
    self.numberOfConcurrent = sender.value;
}

#pragma mark - ThumbnailViewControllerDelegate

/**
 Function to reload data from Thumbnail delegate

 @param object The object from ThumbnailView
 */
- (void) reloadDataWithJSONObject:(JSONObject *)object {
    if (object != nil) {
        // Remove all file that belong to the JsonFile
        @try {
            [[NSFileManager defaultManager] removeItemAtPath:object.path error:nil];
        } @catch (NSException *exception) {
            NSLog(@"Exception when remove item at Path: %@, %@", object.path, exception.debugDescription);
        }
        
        // Remove in queue
        for (Downloader *download in self.queue) {
            for (FileContent *content in object.contentFiles) {
                if (download.url == content.url.absoluteString) {
                    if ([object.contentFiles containsObject:download]) {
                        [self.queue removeObject:download];
                    }
                }
            }
        }
        
        // Add to queue
        [object getContentFiles:object.url];
        object.isDownloading = NO;
        object.progress = 0;
        object.status = queuering;
        
        for (FileContent *content in object.contentFiles) {
            if (content.url != nil) {
                Downloader *download = [[Downloader alloc] initWithURL:content.url.absoluteString];
                download.downloadTask = [self.downloadsSession downloadTaskWithURL:content.url];
                download.isDownloading = false;
                [self.queue addObject:download];
            }
        }
        
        // Resume all downloader
        for (Downloader *download in [self.activeDownloads allValues]) {
            [download.downloadTask resume];
        }
        
        // Dequeue if we don't have any active download
        if (self.activeDownloads.count == 0) {
            [self dequeue];
        }
        
        // Reload data
        [self.tableView reloadData];
        [self.thumbnailVC.collectionView reloadData];
    }
}

@end
