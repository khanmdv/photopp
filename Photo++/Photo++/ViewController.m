//
//  ViewController.m
//  Photo++
//
//  Created by Mohtashim Khan on 1/17/15.
//  Copyright (c) 2015 XYZ. All rights reserved.
//

#import "ViewController.h"
#import "PSPPhotosManager.h"
#import "TagPhotosViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "TagCellTableViewCell.h"
@interface ViewController () <UITableViewDataSource, UITableViewDelegate,
                              UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tagsTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *takePhotoBtn;

@property (nonatomic, strong) NSArray *tags;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    self.tags = [[PSPPhotosManager sharedManager] fetchAllTags];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tags.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TagCellTableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"TagCell" forIndexPath:indexPath];

    if (cell) {
        cell.tagNameLbl.text = self.tags[indexPath.row];
    }

    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        TagCellTableViewCell *cell = (TagCellTableViewCell *)sender;
        TagPhotosViewController *photosVC
            = (TagPhotosViewController *)segue.destinationViewController;

        photosVC.tagName = cell.tagNameLbl.text;
    }
}

- (IBAction)didTapTakePhotoBtn:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.mediaTypes = [UIImagePickerController
        availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeCamera];

    picker.allowsEditing = YES;
    picker.delegate = self;

    [self.navigationController presentViewController:picker animated:YES completion:nil];
}

#pragma mark - Image Picker delegate
- (void)imagePickerController:(UIImagePickerController *)picker
    didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *editedImage, *originalImage, *imgToSave;

    editedImage = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
    originalImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];

    if (editedImage) {
        imgToSave = editedImage;
    }
    else if (originalImage) {
        imgToSave = originalImage;
    }

    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:imgToSave.CGImage
                              orientation:(ALAssetOrientation)imgToSave.imageOrientation
                          completionBlock:^(NSURL *assetURL, NSError *error) {
                            NSLog(@"Asset = %@", assetURL);
                            [picker dismissViewControllerAnimated:YES completion:nil];
                          }];

    // NSLog(@"Info = %@", info);

    // NSLog(@"Media MetaData = %@", [info objectForKey:UIImagePickerControllerMediaMetadata]);
    // NSLog(@"Media Type = %@", [info objectForKey:UIImagePickerControllerMediaType]);
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end
