//
// Created by cjl on 2018/9/8.
//

#import "CompressHandler.h"
#import "UIImage+scale.h"
#import "FlutterImageCompressPlugin.h"
#import "SDImageWebPCoder.h"
#import <CoreText/CoreText.h>

@implementation CompressHandler {

}

+ (NSData *)compressWithData:(NSData *)data minWidth:(int)minWidth minHeight:(int)minHeight quality:(int)quality
                      rotate:(int)rotate format:(int)format {
    UIImage *img = [[UIImage alloc] initWithData:data];
    return [CompressHandler compressWithUIImage:img minWidth:minWidth minHeight:minHeight quality:quality rotate:rotate format:format textOptions:nil];
}

+ (NSData *)compressWithUIImage:(UIImage *)image minWidth:(int)minWidth minHeight:(int)minHeight quality:(int)quality
                         rotate:(int)rotate format:(int)format textOptions:(NSDictionary<NSString*, NSString*> *)txtOptions{
    if([FlutterImageCompressPlugin showLog]){
        NSLog(@"width = %.0f",[image size].width);
        NSLog(@"height = %.0f",[image size].height);
        NSLog(@"minWidth = %d",minWidth);
        NSLog(@"minHeight = %d",minHeight);
        NSLog(@"format = %d", format);
    
}
    UIImage *img=image;
    if(txtOptions){
        NSString *text = [txtOptions objectForKey:@"text"];

        if(text != (NSString*) [NSNull null] || text.length != 0)
        img = [CompressHandler drawText:text inImage:image textOptions:txtOptions];
    }
    
    img = [img scaleWithMinWidth:minWidth minHeight:minHeight];
    if(rotate % 360 != 0){
        img = [img rotate: rotate];
    }
    NSData *resultData = [self compressDataWithImage:img quality:quality format:format];

    return resultData;
}


+(UIImage*) drawText:(NSString*) text inImage:(UIImage*) image textOptions:(NSDictionary*) textOptions {
    
    NSString *textSize = [textOptions objectForKey:@"size"];
    NSString *textColor = [textOptions objectForKey:@"color"];
    NSString *fontPathtest = [textOptions objectForKey:@"fontPath"];

    UIGraphicsBeginImageContext(image.size);

    // Draw the image into the context
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];

    
    UIColor *color = [UIColor yellowColor];
    if(textColor != (NSString*) [NSNull null] || textColor.length != 0)
        color = [self colorWithHexString:textColor alpha:1];
    
    int size = 20;
    if(textSize != (NSString*) [NSNull null] || textSize.length != 0)
        size=[textSize intValue];
    
    NSString * key = [FlutterDartProject lookupKeyForAsset:fontPathtest];

    NSString *fontPath1 = [[NSBundle mainBundle] pathForResource:key ofType:nil];
        if (!fontPath1) {
            NSLog(@"Failed to load font: no fontPath %@", key);
            
        }
        NSData *inData = [NSData dataWithContentsOfFile:fontPath1];

        CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)inData);
        CGFontRef font = CGFontCreateWithDataProvider(provider);
    

    CTFontRef ctFont = CTFontCreateWithGraphicsFont(font, size, NULL, NULL);
    UIFont *uiFont = CFBridgingRelease(ctFont);
    
    // Position the date in the bottom right
    NSDictionary* attributes = @{NSFontAttributeName :uiFont,
                                    
                                     NSStrokeColorAttributeName : [UIColor blackColor],
                                     NSForegroundColorAttributeName :color,
                                     NSStrokeWidthAttributeName : @-2.0};

    const CGFloat dateWidth = [text sizeWithAttributes:attributes].width;
    const CGFloat dateHeight = [text sizeWithAttributes:attributes].height;
    const CGFloat datePadding = 25;
    
    NSDictionary *alignment = [textOptions objectForKey:@"alignmennt"];
    float x = [[alignment objectForKey:@"x"] floatValue];
    float y = [[alignment objectForKey:@"y"] floatValue];
    
    const int LENGTH = 2;
    
    double lengthX = (image.size.width - dateWidth) / 2;
    float X = image.size.width - (((LENGTH - (LENGTH + x -1))* lengthX)) - dateWidth;
    
    double lengthY = (image.size.height - dateHeight) / 2;
    float Y = image.size.height - (LENGTH +y -1) * lengthY - dateHeight;

    [text drawAtPoint:CGPointMake(X, Y) withAttributes:attributes];


    // Get the final image
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;

}

+ (UIColor *)colorWithHexString:(NSString *)str_HEX  alpha:(CGFloat)alpha_range{
    int red = 0;
    int green = 0;
    int blue = 0;
    sscanf([str_HEX UTF8String], "#%02X%02X%02X", &red, &green, &blue);
    return  [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha_range];
}


+ (NSData *)compressDataWithUIImage:(UIImage *)image minWidth:(int)minWidth minHeight:(int)minHeight
                            quality:(int)quality rotate:(int)rotate format:(int)format {
    image = [image scaleWithMinWidth:minWidth minHeight:minHeight];
    if(rotate % 360 != 0){
        image = [image rotate: rotate];
    }
    return [self compressDataWithImage:image quality:quality format:format];
}

+ (NSData *)compressDataWithImage:(UIImage *)image quality:(float)quality format:(int)format  {
    NSData *data;
    if (format == 2) { // heic
        CIImage *ciImage = [CIImage imageWithCGImage:image.CGImage];
        CIContext *ciContext = [[CIContext alloc]initWithOptions:nil];
        NSString *tmpDir = NSTemporaryDirectory();
        double time = [[NSDate alloc]init].timeIntervalSince1970;
        NSString *target = [NSString stringWithFormat:@"%@%.0f.heic",tmpDir, time * 1000];
        NSURL *url = [NSURL fileURLWithPath:target];
        
        NSMutableDictionary *options = [NSMutableDictionary new];
        NSString *qualityKey = (__bridge NSString *)kCGImageDestinationLossyCompressionQuality;
//        CIImageRepresentationOption
        [options setObject:@(quality / 100) forKey: qualityKey];
        
        if (@available(iOS 11.0, *)) {
            [ciContext writeHEIFRepresentationOfImage:ciImage toURL:url format: kCIFormatARGB8 colorSpace: ciImage.colorSpace options:options error:nil];
            data = [NSData dataWithContentsOfURL:url];
        } else {
            // Fallback on earlier versions
            data = nil;
        }
    } else if(format == 3){ // webp
        SDImageCoderOptions *option = @{SDImageCoderEncodeCompressionQuality: @(quality / 100)};
        data = [[SDImageWebPCoder sharedCoder]encodedDataWithImage:image format:SDImageFormatWebP options:option];
    } else if(format == 1){ // png
        data = UIImagePNGRepresentation(image);
    }else { // 0 or other is jpeg
        data = UIImageJPEGRepresentation(image, (CGFloat) quality / 100);
    }

    return data;
}

@end
