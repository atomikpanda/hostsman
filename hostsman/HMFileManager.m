//
//  HMFileManager.m
//  hostsman
//
//  Created by Bailey Seymour on 10/17/16.
//  Copyright © 2016 Bailey Seymour. All rights reserved.
//

#import "HMFileManager.h"

@implementation HMFileManager
@synthesize path=_path;

- (id)initWithPath:(NSString *)path
{
    self = [self init];

    if (self)
    {
       self.path = path;
    }
    
    return self;
}

+ (NSString *)originalHostsPath
{
    return @"/etc/hostsman_original_hosts";
}

- (NSString *)includeFileContentsAtPath:(NSString *)path
{
    if (path.pathComponents.count == 1)
    {
        path = [[self.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:path.lastPathComponent];
    }
    
    if (path.pathComponents.count == 3)
    {
        // redirect /etc/hosts includes
        NSString *root = [[path pathComponents] objectAtIndex:1];
        NSString *folder = [[path pathComponents] objectAtIndex:2];
        
        if ([root isEqualToString:@"etc"] && [folder isEqualToString:@"hosts"])
        {
            path = [HMFileManager originalHostsPath];
        }
    }
    
    NSString *main = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if (!main) return @"";
    
    NSString *origMain = [[main copy] autorelease];
    
    NSRegularExpression *includeRX = [NSRegularExpression regularExpressionWithPattern:@"#\\s?include[^\"]\"([^\"]+)\"" options:0 error:nil];
    
    NSArray *matches = [includeRX matchesInString:origMain options:0 range:NSMakeRange(0, origMain.length)];
    
    for (NSTextCheckingResult *match in matches)
    {
        NSRange group1 = [match rangeAtIndex:1];
        NSString *fileP = [origMain substringWithRange:group1];
        
        main = [main stringByReplacingOccurrencesOfString:[origMain substringWithRange:match.range]
                                               withString:[self includeFileContentsAtPath:fileP]];
    }
    
    return main;
}

- (NSString *)mainContents
{
    NSString *main = [self includeFileContentsAtPath:self.path];
    
    return main;
}

- (void)dealloc
{
    [_path release];
    
    [super dealloc];
}

@end
