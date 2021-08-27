//
// Created by cjl on 2018/9/8.
//

#import <Foundation/Foundation.h>


@interface CompressHandler : NSObject
+ (NSData *)compressWithData:(NSData *)data minWidth:(int)minWidth minHeight:(int)minHeight quality:(int)quality
                      rotate:(int)rotate format:(int)format textOptions:(NSDictionary<NSString*, NSString*> *)txtOptions;

+ (NSData *)compressWithUIImage:(UIImage *)image minWidth:(int)minWidth minHeight:(int)minHeight quality:(int)quality
                         rotate:(int)rotate format:(int)format textOptions:(NSDictionary<NSString*, NSString*> *)txtOptions;

+ (NSData *)compressDataWithUIImage:(UIImage *)image minWidth:(int)minWidth minHeight:(int)minHeight
                            quality:(int)quality rotate:(int)rotate format:(int)format textOptions:(NSDictionary<NSString*, NSString*> *)txtOptions;
@end
