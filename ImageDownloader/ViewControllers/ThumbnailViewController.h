//
//  ThumbnailViewController.h
//  ImageDownloader
//
//  Created by thcanh on 4/25/17.
//  Copyright © 2017 CanhTran. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ThumbnailViewControllerDelegate

- (void)reloadDataWithJSONObject:(JSONObject *)object;

@end

@interface ThumbnailViewController : UIViewController <UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak) id<ThumbnailViewControllerDelegate> delegate;
@property (strong, nonatomic) JSONObject *jsonFile;

@end
