//
// Created by cjl on 2018/9/8.
//

#import "CompressHandler.h"
#import "UIImage+scale.h"
#import "FlutterImageCompressPlugin.h"
#import "SDImageWebPCoder.h"
#import <CoreText/CoreText.h>
#import "ImageDrawString.h"

@implementation CompressHandler {

}

+ (NSData *)compressWithData:(NSData *)data minWidth:(int)minWidth minHeight:(int)minHeight quality:(int)quality
                      rotate:(int)rotate format:(int)format textOptions:(NSDictionary<NSString*, NSString*> *)txtOptions{
    UIImage *img = [[UIImage alloc] initWithData:data];
    return [CompressHandler compressWithUIImage:img minWidth:minWidth minHeight:minHeight quality:quality rotate:rotate format:format textOptions:txtOptions];
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
    UIImage *img = image;
    if(txtOptions){
        NSString *text = [txtOptions objectForKey:@"text"];
        if(text != (NSString*) [NSNull null] || text.length != 0)
        img = [ImageDrawString drawText:text inImage:image textOptions:txtOptions];
    }
    
    img = [img scaleWithMinWidth:minWidth minHeight:minHeight];
    if(rotate % 360 != 0){
        img = [img rotate: rotate];
    }
    NSData *resultData = [self compressDataWithImage:img quality:quality format:format];

    return resultData;
}

+ (NSData *)compressDataWithUIImage:(UIImage *)image minWidth:(int)minWidth minHeight:(int)minHeight
                            quality:(int)quality rotate:(int)rotate format:(int)format textOptions:(NSDictionary<NSString*, NSString*> *)txtOptions{
    UIImage *img = image;
    if(txtOptions){
        NSString *text = [txtOptions objectForKey:@"text"];
        if(text != (NSString*) [NSNull null] || text.length != 0)
        img = [ImageDrawString drawText:text inImage:image textOptions:txtOptions];
    }
    
    img = [img scaleWithMinWidth:minWidth minHeight:minHeight];
    if(rotate % 360 != 0){
        img = [img rotate: rotate];
    }
    return [self compressDataWithImage:img quality:quality format:format];
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
