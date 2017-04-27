//
//  HomeViewController.h
//  ImageDownloader
//
//  Created by thcanh on 4/25/17.
//  Copyright © 2017 CanhTran. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeFileTableViewCell.h"
#import "ThumbnailViewController.h"

@interface HomeViewController : UIViewController <SSZipArchiveDelegate, UITableViewDelegate, UITableViewDataSource, ThumbnailViewControllerDelegate, NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate, NSURLSessionDownloadDelegate, NSURLSessionStreamDelegate>

@end
