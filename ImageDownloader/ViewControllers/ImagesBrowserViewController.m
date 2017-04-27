//
//  ImagesBrowserViewController.m
//  ImageDownloader
//
//  Created by thcanh on 4/25/17.
//  Copyright © 2017 CanhTran. All rights reserved.
//

#import "ImagesBrowserViewController.h"
#import "BrowserCollectionViewCell.h"

@interface ImagesBrowserViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *currentIndexLabel;

@end

@implementation ImagesBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.currentIndexPath != nil) {
        [self.collectionView scrollToItemAtIndexPath:self.currentIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self updateIndex];
}


/**
 Update Index in te first time and after scroll collection
 */
- (void) updateIndex {
    UICollectionViewCell *visibleCell = [[self.collectionView visibleCells] firstObject];
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:visibleCell];
    
    self.currentIndexLabel.text = [NSString stringWithFormat:@"%ld/%ld", indexPath.row + 1, self.jsonFile.contentFiles.count];
}

- (IBAction)cancelButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Collection view Delegate, DataSource and FlowLayout

- (CGSize) collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return collectionView.frame.size;
}

- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self updateIndex];
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.jsonFile.contentFiles.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BrowserCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"BrowserCollectionViewCell" forIndexPath:indexPath];
    [cell updateCellWith:self.jsonFile indexPath:indexPath];
    return cell;
}


@end
