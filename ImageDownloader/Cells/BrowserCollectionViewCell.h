//
//  BrowserCollectionViewCell.h
//  ImageDownloader
//
//  Created by thcanh on 4/25/17.
//  Copyright © 2017 CanhTran. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BrowserCollectionViewCell : UICollectionViewCell

- (void) updateCellWith:(JSONObject *)object indexPath:(NSIndexPath *)indexPath;

@end
