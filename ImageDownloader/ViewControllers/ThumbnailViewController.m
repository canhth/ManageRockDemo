//
//  ThumbnailViewController.m
//  ImageDownloader
//
//  Created by thcanh on 4/25/17.
//  Copyright © 2017 CanhTran. All rights reserved.
//

#import "ThumbnailViewController.h"
#import "ImagesBrowserViewController.h"
#import "ThumbnailCollectionViewCell.h"

@interface ThumbnailViewController ()

@end

@implementation ThumbnailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.jsonFile.name;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Reload" style:UIBarButtonItemStylePlain target:self action:@selector(didTapReload:)];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)didTapReload:(UIBarButtonItem *)sender {
    [self.delegate reloadDataWithJSONObject:self.jsonFile];
}

#pragma mark - Collection view Delegate, DataSource and FlowLayout

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    CGFloat width = (self.view.frame.size.width - 2 * 3) / 4;
    CGFloat height = width;
    return CGSizeMake(width, height);
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    ImagesBrowserViewController *browserVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ImagesBrowserViewController"];
    browserVC.jsonFile = self.jsonFile;
    browserVC.currentIndexPath = indexPath;
    [self presentViewController:browserVC animated:YES completion:nil];
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.jsonFile.contentFiles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ThumbnailCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ThumbnailCollectionViewCell" forIndexPath:indexPath];
    [cell updateCellWith:self.jsonFile indexPath:indexPath];
    return cell;
}


@end
