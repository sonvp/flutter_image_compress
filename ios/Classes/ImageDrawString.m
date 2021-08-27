#import "ImageDrawString.h"
#import "UIImage+scale.h"
#import "FlutterImageCompressPlugin.h"
#import "SDImageWebPCoder.h"
#import <CoreText/CoreText.h>

@implementation ImageDrawString {

}

+(UIImage*) drawText:(NSString*) text inImage:(UIImage*) image textOptions:(NSDictionary*) textOptions {
    
    NSString *textSize = [textOptions objectForKey:@"size"];
    NSString *textColor = [textOptions objectForKey:@"color"];
    NSString *fontPathtest = [textOptions objectForKey:@"fontPath"];

    UIGraphicsBeginImageContext(image.size);

    // Draw the image into the context
    [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];

    // Set color
    UIColor *color = [UIColor yellowColor];
    if(textColor != (NSString*) [NSNull null] || textColor.length != 0)
        color = [self colorWithHexString:textColor alpha:1];
    
    // Set size
    int size = 20;
    if(textSize != (NSString*) [NSNull null] || textSize.length != 0)
        size = [textSize intValue];
    
    // Set font
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
    NSDictionary* attributes = @{ NSFontAttributeName :uiFont,
                                  NSStrokeColorAttributeName : [UIColor blackColor],
                                  NSForegroundColorAttributeName :color,
                                  NSStrokeWidthAttributeName : @0.0};

    const CGFloat dateWidth = [text sizeWithAttributes:attributes].width;
    const CGFloat dateHeight = [text sizeWithAttributes:attributes].height;
    
    NSDictionary *alignment = [textOptions objectForKey:@"alignment"];
    float x = [[alignment objectForKey:@"x"] floatValue];
    float y = [[alignment objectForKey:@"y"] floatValue];
    
    NSDictionary *margin = [textOptions objectForKey:@"margin"];
    float vertical = [[margin objectForKey:@"vertical"] floatValue];
    float horizontal = [[margin objectForKey:@"horizontal"] floatValue];
    
    const int LENGTH = 2;
    
    float marginX = [ImageDrawString marginText:x inMarginText:horizontal];
    double lengthX = (image.size.width - dateWidth) / 2;
    float X = image.size.width - (((LENGTH - (LENGTH + x -1))* lengthX)) - dateWidth + marginX;
    
    float marginY = [ImageDrawString marginText:y inMarginText:vertical];
    float removePadding = [ImageDrawString removePadingText:y];
    double lengthY = (image.size.height - dateHeight) / 2;
    float Y = image.size.height - (((LENGTH - (LENGTH + y -1))* lengthY)) - dateHeight + marginY + removePadding;

    [text drawAtPoint:CGPointMake(X, Y) withAttributes:attributes];


    // Get the final image
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;

}

+(float) marginText:(float) x inMarginText:(float) marginText {
    if(x < 0.0f){
        return marginText;
    }else if (x > 0.0f){
        return -marginText;
    }else{
        return 0.0f;
    }
}

+(float) removePadingText:(float) x {
    if(x < 0.0f){
        return -30;
    }else if (x > 0.0f){
        return 20;
    }else{
        return 0.0f;
    }
}

+ (UIColor *)colorWithHexString:(NSString *)str_HEX  alpha:(CGFloat)alpha_range{
    int red = 0;
    int green = 0;
    int blue = 0;
    sscanf([str_HEX UTF8String], "#%02X%02X%02X", &red, &green, &blue);
    return  [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha_range];
}

@end
