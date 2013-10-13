#import <Cocoa/Cocoa.h>
#import "CodaPluginsController.h"

@class CodaPlugInsController;

@interface PublishMarkdownPlugIn : NSObject <CodaPlugIn>
{
    CodaPlugInsController *controller;
}

+ (bool)shouldConvertFileAtPath:(NSString *)fileAtPath;

+ (NSString *)convertMarkdownToHtml:(NSString *)source;

+ (NSString *)mergeWithTemplate:(NSString *)source;

+ (NSString *)writeTempFile:(NSString *)source;

@end
