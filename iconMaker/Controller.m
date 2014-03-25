//
//  Controller.m
//  iconMaker
//
//  Created by gideon on 12. 9. 21..
//  Copyright (c) 2012년 blesseddeveloper. All rights reserved.
//

#import "Controller.h"

@interface Controller()
- (void)convert;
- (void)saveImage:(NSImage *)saveImage andName:(NSString *)strPath;
- (NSImage *)resizeImage:(NSImage *)originImage andSize:(CGSize)size;
- (void)makeDirectory;
@end

@implementation Controller

- (IBAction)findOutputButtonPressed:(id)sender {
	NSOpenPanel *panel;
    panel = [NSOpenPanel openPanel];
    [panel setFloatingPanel:YES];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:NO];
	[panel setAllowsMultipleSelection:NO];
    NSInteger i = [panel runModal];
	if(i == NSOKButton){
		NSArray *arr = [panel URLs];
        NSURL *url = [arr objectAtIndex:0];
		[self.tfOutput setStringValue:[url path]];
    }
}

- (IBAction)convertButtonPressed:(id)sender {
    [NSThread detachNewThreadSelector:@selector(convert)
                             toTarget:self
                           withObject:nil];
}

- (void)convert {
//    [self makeDirectory];
    NSString *path = [NSString stringWithFormat:@"%@/icons",
                      self.tfOutput.stringValue];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path isDirectory:NULL]) {
        [fileManager createDirectoryAtPath:path
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:NULL];
    }

    
    NSImage *originImage = self.ivPreview.image;
    NSImage *resizeImage = nil;
    
    if (nil == originImage) {
        return;
    }
    NSString *iconSizeSetPath = [[NSBundle mainBundle] pathForResource:@"iconSizeSet" ofType:@"plist"];
    NSMutableArray *iconSizeArray = [[NSMutableArray alloc] initWithContentsOfFile:iconSizeSetPath];
    for(NSDictionary *dict in iconSizeArray){
        CGSize size = CGSizeMake([dict[@"Size"] intValue], [dict[@"Size"] intValue]);
        NSString *fileName = [NSString stringWithFormat:@"icons/%@.png",dict[@"FileName"]];
        switch ([dict[@"Type"] intValue]) {
            case 0:
                break;
            case 1:{
                resizeImage = [self resizeImage:originImage andSize:size];
                [self saveImage:resizeImage andName:fileName];
                break;
            }
            case 2:{
                resizeImage = [self resizeImage:originImage andSize:size];
                [self saveImage:resizeImage andName:fileName];

                fileName = [NSString stringWithFormat:@"icons/%@@2x.png",dict[@"FileName"]];
                resizeImage = [self resizeImage:originImage andSize:CGSizeMake(size.width*2, size.height*2)];
                [self saveImage:resizeImage andName:fileName];
                break;
            }
            case 3:{
                fileName = [NSString stringWithFormat:@"icons/%@@2x.png",dict[@"FileName"]];
                resizeImage = [self resizeImage:originImage andSize:CGSizeMake(size.width*2, size.height*2)];
                [self saveImage:resizeImage andName:fileName];
                break;
            }
                
            default:
                break;
        }
    }
    
    [NSThread exit];
}
- (void)makeDirectory {
    const int DIR_COUNT = 4;
    NSString *dir[ DIR_COUNT] = {
        @"drawable-ldpi",
        @"drawable-mdpi",
        @"drawable-hdpi",
        @"drawable-xhdpi"
    };
    
    NSString *path;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    for (int i = 0; i < DIR_COUNT; i++) {
        path = [NSString stringWithFormat:@"%@/%@",
                self.tfOutput.stringValue, dir[ i]];
        if (![fileManager fileExistsAtPath:path isDirectory:NULL]) {
            [fileManager createDirectoryAtPath:path
                   withIntermediateDirectories:YES
                                    attributes:nil
                                         error:NULL];
        }
    }
}
- (NSImage *)resizeImage:(NSImage *)originImage andSize:(CGSize)size {
    NSImage *resizeImage = [[NSImage alloc] initWithSize: size];
    [resizeImage lockFocus];
    [originImage setSize:size];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    [originImage compositeToPoint:NSZeroPoint operation:NSCompositeCopy];
    [resizeImage unlockFocus];
    
    return resizeImage;
}
- (void)saveImage:(NSImage *)saveImage andName:(NSString *)strPath {
	if (nil == saveImage) {
		return;
	}
    
	NSData *tiffData = [saveImage TIFFRepresentation];
	NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:tiffData];
	NSData *pngData = [imageRep representationUsingType:NSPNGFileType properties:nil];
	
    NSString *path = [NSString stringWithFormat:@"%@/%@", self.tfOutput.stringValue, strPath];
	[pngData writeToFile:path atomically: NO];
}
@end
