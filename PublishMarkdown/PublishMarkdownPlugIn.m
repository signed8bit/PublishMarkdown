#import "PublishMarkdownPlugIn.h"
#import "CodaPlugInsController.h"

#include <unistd.h>

@interface PublishMarkdownPlugIn ()

- (id)initWithController:(CodaPlugInsController *)inController;

@end

@implementation PublishMarkdownPlugIn

// Coda 2.0 and lower
- (id)initWithPlugInController:(CodaPlugInsController *)aController bundle:(NSBundle *)aBundle
{
    return [self initWithController:aController];
}

// Coda 2.0.1 and higher
- (id)initWithPlugInController:(CodaPlugInsController *)aController plugInBundle:(NSObject <CodaPlugInBundle> *)plugInBundle
{
    return [self initWithController:aController];
}

- (id)initWithController:(CodaPlugInsController *)inController
{
    if ((self = [super init]) != nil )
    {
        controller = inController;
    }

    return self;
}

// Returns the name of the plug-in
- (NSString *)name
{
    return @"Publish Markdown";
}

// Intercepts publishing and will attempt to convert a file name in the form of name.md.html using Markdown.
// In addition, the resulting HTML will be merged with a template.
- (NSString *)willPublishFileAtPath:(NSString *)inputPath
{

    // TODO: Support preview and syntax mode
    
    NSString *outputPath;
    outputPath = inputPath;

    if ([PublishMarkdownPlugIn shouldConvertFileAtPath:inputPath])
    {
        // Load the contents of the Markdown file to be published
        NSString *markdownSource;
        markdownSource = [[NSString alloc] initWithContentsOfFile:inputPath encoding:NSUTF8StringEncoding error:nil];

        // Transform from Markdown to HTML
        NSString *htmlSource;
        htmlSource = [PublishMarkdownPlugIn mergeWithTemplate:[PublishMarkdownPlugIn convertMarkdownToHtml:markdownSource]];

        // Write out the temp. file using the same name but with a .html extension
        NSString *tempFilePath;
        tempFilePath = [PublishMarkdownPlugIn writeTempFile:htmlSource];

        // Return the path to the temp file
        outputPath = tempFilePath;
    }
    else
    {
        NSLog(@"Not a recognized Publish Markdown file, skipping conversion for: %@", inputPath);
    }

    return outputPath;
}

+ (bool)shouldConvertFileAtPath:(NSString *)fileAtPath
{
    bool result;
    result = false;

    if (fileAtPath != nil)
    {
        if ([fileAtPath hasSuffix:@".md.html"])
        {
            result = true;
        }
    }

    return result;
}

+ (NSString *)convertMarkdownToHtml:(NSString *)source
{
    NSString *result;

    if (source != nil)
    {
        NSString *perlFile;
        perlFile = [[NSBundle bundleForClass:self] pathForResource:@"Markdown" ofType:@"pl"];

        if (perlFile != nil)
        {
            NSTask *runner;
            runner = [[NSTask alloc] init];

            [runner setLaunchPath:perlFile];
            [runner setStandardInput:[NSPipe pipe]];
            [runner setStandardOutput:[NSPipe pipe]];

            NSFileHandle *writingHandle;
            writingHandle = [[runner standardInput] fileHandleForWriting];

            [writingHandle writeData:[source dataUsingEncoding:NSUTF8StringEncoding]];
            [writingHandle closeFile];

            [runner launch];
            [runner waitUntilExit];

            NSData *outputData;
            outputData = [[[runner standardOutput] fileHandleForReading] readDataToEndOfFile];

            result = [[NSString alloc] initWithData:outputData encoding:NSUTF8StringEncoding];
        }
        else
        {
            NSLog(@"Unable to find the bundled Markdown.pl file");
        }
    }
    else
    {
        NSLog(@"The Markdown source cannot be null");
    }

    return result;
}

+ (NSString *)mergeWithTemplate:(NSString *)source
{
    NSString *result;

    if (source != nil)
    {
        NSString *pathToDefaultTemplate;
        pathToDefaultTemplate = [[NSBundle bundleForClass:self] pathForResource:@"default-template" ofType:@"html"];
        
        // Load the contents of the Markdown file to be published
        NSString *templateSource;
        templateSource = [[NSString alloc] initWithContentsOfFile:pathToDefaultTemplate encoding:NSUTF8StringEncoding error:nil];

        NSString *mergedSource;
        mergedSource = [templateSource stringByReplacingOccurrencesOfString:@"@body@" withString:source];

        result = mergedSource;
    }
    
    return result;
}

+ (NSString *)writeTempFile:(NSString *)contents
{
    NSString *pathToPublish;
    pathToPublish = nil;

    NSMutableString *uniqueDirectoryPath;
    uniqueDirectoryPath = [NSMutableString string];

    [uniqueDirectoryPath appendString:@"/tmp/"];
    [uniqueDirectoryPath appendString:[[NSProcessInfo processInfo] globallyUniqueString]];

    NSLog(@"uniqueDirectoryPath = %@", uniqueDirectoryPath);

    NSFileManager *fileManager;
    fileManager = [NSFileManager defaultManager];

    if (![fileManager fileExistsAtPath:uniqueDirectoryPath])
    {
        if ([fileManager createDirectoryAtPath:uniqueDirectoryPath withIntermediateDirectories:YES attributes:nil error:NULL])
        {
            NSString *fileToPublish;
            fileToPublish = [uniqueDirectoryPath stringByAppendingString:@"/test.html"];

            [contents writeToFile:fileToPublish atomically:YES encoding:NSUTF8StringEncoding error:NULL];

            pathToPublish = fileToPublish;
        }
        else
        {
            NSLog(@"Error: Create folder failed %@", uniqueDirectoryPath);
        }
    }

    return pathToPublish;
}

@end

