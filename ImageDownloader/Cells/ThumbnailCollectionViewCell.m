//
//  ThumbnailCollectionViewCell.m
//  ImageDownloader
//
//  Created by thcanh on 4/25/17.
//  Copyright © 2017 CanhTran. All rights reserved.
//

#import "ThumbnailCollectionViewCell.h"

@interface ThumbnailCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;


@end

@implementation ThumbnailCollectionViewCell

- (void) prepareForReuse {
    [super prepareForReuse];
    self.thumbnailImageView.image = nil;
    self.thumbnailImageView.backgroundColor = [UIColor clearColor];
}

- (void) updateCellWith:(JSONObject *)object indexPath:(NSIndexPath *)indexPath {
    if (object != nil) {
        NSLog(@"%ld", (long)downloading);
        if (((FileContent *)object.contentFiles[indexPath.row]).status == downloading) {
            self.progressLabel.text = [NSString stringWithFormat: @"Downloading %.1f%%", ((FileContent *)object.contentFiles[indexPath.row]).progress * 100];
        } else {
            self.progressLabel.text = [Utils nameForDownloadStatus: ((FileContent *)object.contentFiles[indexPath.row]).status];
        }
        
        
        if (((FileContent *)object.contentFiles[indexPath.row]).status == finished) {
            
            NSString *imagePath = [object.path stringByAppendingPathComponent: ((FileContent *)object.contentFiles[indexPath.row]).name];
            NSString *path;
            
            // Check for the case resume: If we can't find exactly path of image
            if (![[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
                path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:FolderName];
                path = [path stringByAppendingPathComponent:object.name];
                imagePath =  [path stringByAppendingPathComponent: ((FileContent *)object.contentFiles[indexPath.row]).name];
            } else {
                if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
                    if ([((FileContent *)object.contentFiles[indexPath.row]).url.pathExtension  isEqual: @"pdf"]) {
                        self.thumbnailImageView.image = [Utils loadImageFromPDFatPath:imagePath];
                        self.thumbnailImageView.backgroundColor = [UIColor whiteColor];
                    } else if ([((FileContent *)object.contentFiles[indexPath.row]).url.pathExtension  isEqual: @"zip"]) {
                        self.thumbnailImageView.image = [Utils unZipImageAtPath:imagePath];
                    } else {
                        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
                        self.thumbnailImageView.image = image;
                    }
                }
            }
        }
    }
}

@end
