//
//  HomeFileTableViewCell.m
//  ImageDownloader
//
//  Created by thcanh on 4/25/17.
//  Copyright © 2017 CanhTran. All rights reserved.
//

#import "HomeFileTableViewCell.h"

@interface HomeFileTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *downloadProgressView;

@end

@implementation HomeFileTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setupCellWithJSONObject:(JSONObject *) object {
    self.titleLabel.text = object.name;
    self.statusLabel.text = [Utils nameForDownloadStatus:object.status];
    self.downloadProgressView.progress = object.progress;
    NSLog(@"Name: %@, progress: %f", object.name, object.progress);
}

@end
