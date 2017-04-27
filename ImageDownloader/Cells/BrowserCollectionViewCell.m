//
//  BrowserCollectionViewCell.m
//  ImageDownloader
//
//  Created by thcanh on 4/25/17.
//  Copyright © 2017 CanhTran. All rights reserved.
//

#import "BrowserCollectionViewCell.h"

@interface BrowserCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;

@end

@implementation BrowserCollectionViewCell

- (void) prepareForReuse {
    [super prepareForReuse];
    
    self.coverImageView.image = nil;
    self.coverImageView.backgroundColor = [UIColor clearColor];
}

- (void) updateCellWith:(JSONObject *)object indexPath:(NSIndexPath *)indexPath {
    if (object != nil) {
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
                        self.coverImageView.image = [Utils loadImageFromPDFatPath:imagePath];
                        self.coverImageView.backgroundColor = [UIColor whiteColor];
                    } else if ([((FileContent *)object.contentFiles[indexPath.row]).url.pathExtension  isEqual: @"zip"]) {
                        self.coverImageView.image = [Utils unZipImageAtPath:imagePath];
                    } else {
                        UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
                        self.coverImageView.image = image;
                    }
                }
            }
        }
    }

}

@end
