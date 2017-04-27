//
//  ImagesBrowserViewController.h
//  ImageDownloader
//
//  Created by thcanh on 4/25/17.
//  Copyright © 2017 CanhTran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImagesBrowserViewController : UIViewController <UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) JSONObject *jsonFile;
@property (strong, nonatomic) NSIndexPath *currentIndexPath;

@end
