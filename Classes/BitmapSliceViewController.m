//
//  BitmapSliceViewController.m
//  BitmapSlice
//
//  Created by Matt Long on 2/16/11.
//  Copyright 2011 Skye Road Systems, Inc. All rights reserved.
//

#import "BitmapSliceViewController.h"
#import "TileView.h"

@implementation BitmapSliceViewController

@synthesize scrollView;

- (void)dealloc
{
  [super dealloc];
}

- (void)viewDidUnload 
{
  [super viewDidUnload];
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
  NSString *directoryPath = [paths objectAtIndex:0];

  // Uncomment these lines to actually tile the image. You would only
  // need to do this once. In my tests, it was big enough to crash
  // the app, so you may need to use a smaller image. Running it on
  // the simulator faired better. Works great on iPad2, though, so go
  // buy one of those. Mmmmkay?
  
//  dispatch_queue_t tilingQueue = dispatch_queue_create("tilingQueue", NULL);
//  dispatch_async(tilingQueue, ^{
//    UIImage *big = [UIImage imageNamed:@"bigimage.png"];
//    [self saveTilesOfSize:(CGSize){256, 256} forImage:big toDirectory:directoryPath usingPrefix:@"bigimage_"];
//    dispatch_async(dispatch_get_main_queue(), ^{
//      [scrollView setNeedsDisplay];
//    });
//  });
//  dispatch_release(tilingQueue);

  TileView *tv = [[TileView alloc] initWithFrame:(CGRect){{0,0}, (CGSize){5000,5000}}];
  [tv setTileTag:@"bigimage_"];
  [tv setTileDirectory:directoryPath];
  
  [scrollView addSubview:tv];
  
  [scrollView setContentSize:(CGSize){5000,5000}];
  
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)saveTilesOfSize:(CGSize)size 
               forImage:(UIImage*)image 
            toDirectory:(NSString*)directoryPath 
            usingPrefix:(NSString*)prefix
{
  CGFloat cols = [image size].width / size.width;
  CGFloat rows = [image size].height / size.height;
  
  int fullColumns = floorf(cols);
  int fullRows = floorf(rows);
  
  CGFloat remainderWidth = [image size].width - 
                          (fullColumns * size.width);
  CGFloat remainderHeight = [image size].height - 
                          (fullRows * size.height);


  if (cols > fullColumns) fullColumns++;
  if (rows > fullRows) fullRows++;

  CGImageRef fullImage = [image CGImage];

  for (int y = 0; y < fullRows; ++y) {
    for (int x = 0; x < fullColumns; ++x) {
      CGSize tileSize = size;
      if (x + 1 == fullColumns && remainderWidth > 0) {
        // Last column
        tileSize.width = remainderWidth;
      }
      if (y + 1 == fullRows && remainderHeight > 0) {
        // Last row
        tileSize.height = remainderHeight;
      }
      
      CGImageRef tileImage = CGImageCreateWithImageInRect(fullImage, 
                                        (CGRect){{x*size.width, y*size.height}, 
                                          tileSize});
      NSData *imageData = UIImagePNGRepresentation([UIImage imageWithCGImage:tileImage]);
      NSString *path = [NSString stringWithFormat:@"%@/%@%d_%d.png", 
                        directoryPath, prefix, x, y];
      [imageData writeToFile:path atomically:NO];
    }
  }    
}

@end
