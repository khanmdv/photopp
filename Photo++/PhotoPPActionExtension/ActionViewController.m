//
//  ActionViewController.m
//  PhotoPPActionExtension
//
//  Created by Mohtashim Khan on 1/20/15.
//  Copyright (c) 2015 XYZ. All rights reserved.
//

#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "PPPhotosManager.h"
#import "PPTagButton.h"
#import "PPUtil.h"
#import <AssetsLibrary/AssetsLibrary.h>

#define kPPAlphaIncrement 0.09

@interface ActionViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIVisualEffectView *visualView;

@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *tagsScrollView;
@property (weak, nonatomic) IBOutlet UIImageView *transparentImgView;

@property (nonatomic, strong) NSMutableSet *tags;
@property (nonatomic, strong) NSArray *selectedTags;
@property (nonatomic, strong) NSMutableDictionary *tagsByName;
@property (nonatomic, strong) NSMutableDictionary *cellStatusByName;
@property (weak, nonatomic) IBOutlet UITableView *tagsTableView;
@property (nonatomic, strong) Assets *currentAsset;

@end

@implementation ActionViewController

- (void)p_setupTagsView
{
    self.tagsScrollView.contentSize = CGSizeMake(self.tagsScrollView.frame.size.width,
                                                 self.tagsScrollView.frame.size.height * 2);
}

- (Tags *)p_newTag:(NSString *)tagName forAsset:(Assets *)asset
{
    Tags *tag = [[PPPhotosManager sharedManager] emptyTagObject];
    tag.tagName = tagName;
    tag.tagId = [[NSUUID UUID] UUIDString];
    tag.tagDisplayOrder = @(1);
    [tag addAssetsObject:asset];

    return tag;
}

- (NSMutableDictionary *)p_tagsByName:(NSSet *)tags
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    if (tags.count > 0) {
        for (Tags *tag in tags) {

            dict[tag.tagName] = tag;
        }
    }

    return dict;
}

- (void)p_renderTags
{

    for (UIView *v in self.tagsScrollView.subviews) {
        [v removeFromSuperview];
    }

    float topOffset = 400.0f;
    float scrollViewwidth = self.tagsScrollView.frame.size.width;
    float margin = 5.0f;
    float xPos = 0.0f;
    float yPos = 0.0f + topOffset;
    float insets = 10.0f;
    float totalTagsWidth = 0.0f;

    for (NSString *tagName in self.tags) {

        CGSize size = [PPUtil textSize:tagName forFont:[UIFont systemFontOfSize:14.0]];
        CGRect frame;
        size.width += insets * 2;
        size.height += insets;

        frame.size = size;
        totalTagsWidth = xPos + margin + size.width;

        if (totalTagsWidth >= scrollViewwidth) {

            yPos += size.height + margin;
            xPos = totalTagsWidth = 0.0f;
        }

        frame.origin = CGPointMake(xPos, yPos);

        xPos += margin + size.width;

        PPTagButton *view =
            [[PPTagButton alloc] initWithFrame:frame
                                         title:tagName
                                      selected:(self.tagsByName[tagName] != nil)
                                 andTapHandler:^(BOOL selected, NSString *tagName2) {

                                   if (!selected) {

                                       Tags *tag = self.tagsByName[tagName2];
                                       [self.currentAsset removeTagsObject:tag];
                                       [self.tagsByName removeObjectForKey:tagName2];
                                   }
                                   else {

                                       Tags *tag =
                                           [self p_newTag:tagName2 forAsset:self.currentAsset];
                                       self.tagsByName[tagName2] = tag;
                                       [self.currentAsset addTagsObject:tag];
                                   }
                                 }];

        [self.tagsScrollView addSubview:view];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self p_setupTagsView];

    self.cellStatusByName = [NSMutableDictionary dictionary];

    self.tags = [NSMutableSet setWithArray:@[
        @"Travel",
        @"Favorites",
        @"Important",
        @"Selfies",
        @"Family",
        @"International",
        @"Recent"
    ]];

    // Get the item[s] we're handling from the extension context.

    // For example, look for an image and place it into an image view.
    // Replace this with something appropriate for the type[s] your extension supports.
    BOOL imageFound = NO;
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        NSLog(@"Title = %@", item.attributedTitle);
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
                // This is an image. We'll load it, then place it in our image view.
                __weak UIImageView *imageView = self.imageView;
                [itemProvider
                    loadItemForTypeIdentifier:(NSString *)kUTTypeImage
                                      options:nil
                            completionHandler:^(NSURL *url, NSError *error) {
                              if (url) {

                                  NSLog(@"FIle URL = %@", url);

                                  NSString *photoId = url.lastPathComponent;

                                  dispatch_sync(dispatch_get_main_queue(), ^{

                                    NSLog(@"Abs = %@", url.absoluteString);
                                    UIImage *image =
                                        [UIImage imageWithData:[NSData dataWithContentsOfURL:url]];
                                    [imageView setImage:image];

                                    self.transparentImgView.image = image;

                                  });

                                  self.currentAsset =
                                      [[PPPhotosManager sharedManager] photoWithId:photoId];

                                  if (self.currentAsset == nil) {
                                      Assets *newAsset =
                                          [[PPPhotosManager sharedManager] emptyAssetObject];

                                      newAsset.photoId = photoId;
                                      newAsset.resolved = @(NO);
                                      self.currentAsset = newAsset;
                                  }

                                  NSLog(@"All Photos = %@", self.currentAsset);
                                  self.tagsByName = [self p_tagsByName:self.currentAsset.tags];

                                  [self.tags addObjectsFromArray:self.tagsByName.allKeys];

                                  [self p_renderTags];
                              }
                            }];

                imageFound = YES;
                break;
            }
        }

        if (imageFound) {
            // We only handle one image, so stop looking for more.
            break;
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done
{
    [[PPPhotosManager sharedManager] saveAll];
    // Return any edited content to the host app.
    // This template doesn't do anything, so we just echo the passed in items.
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems
                                       completionHandler:nil];
}

- (IBAction)didTapAddTagBtn:(id)sender
{
    UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:@"Custom Tag"
                                            message:@"Enter custom tag name."
                                     preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction *okAction =
        [UIAlertAction actionWithTitle:@"Ok"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action) {

                                 NSString *tagName = ((UITextField *)alert.textFields[0]).text;
                                 Tags *t = [self p_newTag:tagName forAsset:self.currentAsset];

                                 self.tagsByName[tagName] = t;
                                 [self.currentAsset addTagsObject:t];

                                 [self.tags addObject:tagName];
                                 [self p_renderTags];

                                 [self dismissViewControllerAnimated:YES completion:nil];

                               }];

    UIAlertAction *cancelAction =
        [UIAlertAction actionWithTitle:@"Cancel"
                                 style:UIAlertActionStyleCancel
                               handler:^(UIAlertAction *action) {
                                 [self dismissViewControllerAnimated:YES completion:nil];
                               }];

    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField){

    }];

    [alert addAction:okAction];
    [alert addAction:cancelAction];

    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tags.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:@"TagCell" forIndexPath:indexPath];

    if (cell) {

        cell.textLabel.text = [self.tags allObjects][indexPath.row];

        if (self.tagsByName[[self.tags allObjects][indexPath.row]]) {
            Tags *tag = self.tagsByName[[self.tags allObjects][indexPath.row]];
            if ([tag.tagName isEqualToString:[self.tags allObjects][indexPath.row]]) {
                cell.backgroundColor = [UIColor lightGrayColor];
            }
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *tagName = [self.tags allObjects][indexPath.row];
    BOOL cellSelected = [self.cellStatusByName[tagName] boolValue];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    if (cellSelected) {
        cell.backgroundColor = [UIColor clearColor];
        self.cellStatusByName[tagName] = @(NO);
        Tags *tag = self.tagsByName[tagName];
        [self.currentAsset removeTagsObject:tag];
        [self.tagsByName removeObjectForKey:tagName];
    }
    else {
        cell.backgroundColor = [UIColor lightGrayColor];
        self.cellStatusByName[tagName] = @(YES);
        Tags *tag = [[PPPhotosManager sharedManager] emptyTagObject];
        tag.tagName = tagName;
        tag.tagId = [[NSUUID UUID] UUIDString];
        tag.tagDisplayOrder = @(1);
        [tag addAssetsObject:self.currentAsset];
        self.tagsByName[tagName] = tag;
        [self.currentAsset addTagsObject:tag];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    static int counter = 0;
    static float prevYPosition;
    float currentYPosition;

    currentYPosition = scrollView.contentOffset.y;

    if (currentYPosition >= scrollView.contentSize.height || currentYPosition <= 0.0) return;

    NSLog(@"Current = %f, Prev = %f", currentYPosition, prevYPosition);
    int direction = currentYPosition - prevYPosition;

    if (direction > 0) {
        // Scroll down
        if (++counter % 5 == 0 && self.visualView.alpha < 0.8) {
            self.visualView.alpha += kPPAlphaIncrement;
            NSLog(@"U r scrolling %f", self.visualView.alpha);
        }
    }
    else if (direction < 0) {
        // scroll up
        if (++counter % 5 == 0 && self.visualView.alpha > 0.0) {
            self.visualView.alpha -= kPPAlphaIncrement;
            NSLog(@"U r scrolling %f", self.visualView.alpha);
        }
    }

    prevYPosition = currentYPosition;
}

@end
