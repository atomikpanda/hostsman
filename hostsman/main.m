//
//  main.m
//  hostsman
//
//  Created by Bailey Seymour on 10/17/16.
//  Copyright © 2016 Bailey Seymour. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HMFileManager.h"

void flushDNS()
{
    NSTask *cmd = [[NSTask alloc] init];
    cmd.launchPath = @"/usr/bin/dscacheutil";
    cmd.arguments = @[@"-flushcache"];
    [cmd launch];
    
    [cmd release];
}

int main(int argc, const char * argv[])
{
    @autoreleasepool
    {
        if (geteuid() != 0)
        {
            printf("not root. try using sudo. exiting...\n");
            return EXIT_FAILURE;
        }
        
        if (![[NSFileManager defaultManager] fileExistsAtPath:[HMFileManager originalHostsPath]])
        {
            BOOL backedUp = [[NSFileManager defaultManager] copyItemAtPath:@"/etc/hosts" toPath:[HMFileManager originalHostsPath] error:nil];
            if (!backedUp)
            {
                printf("failed to backup /etc/hosts to %s\n", [HMFileManager originalHostsPath].UTF8String);
                return EXIT_FAILURE;
            }
        }
        
        NSString *documentsDirectory = [[[[NSProcessInfo processInfo] environment] objectForKey:@"HOME"] stringByAppendingPathComponent:@"Documents"];
        
        NSString *mainPath = [documentsDirectory stringByAppendingString:@"/hostman/hosts.hman"];
        
        if (argc > 1)
        {
            const char *hman = argv[1];
            if (hman != NULL && ![[NSFileManager defaultManager] fileExistsAtPath:@(hman)])
                printf("no file at `%s` defaulting to `%s`\n\n", hman, mainPath.UTF8String);
            else if (hman != NULL)
                mainPath = @(hman);
        }
        else printf("no hman file specified. defaulting to `%s`\n\n", mainPath.UTF8String);
        
        printf("*****\n");
        HMFileManager *hman = [[HMFileManager alloc] initWithPath:mainPath];
        
        NSString *currentHosts = [hman mainContents];
//        NSLog(@"hosts: \n%@", currentHosts);
        if (currentHosts && currentHosts.length > 0)
        {
            BOOL did = [currentHosts writeToFile:@"/etc/hosts" atomically:YES encoding:NSUTF8StringEncoding error:nil];
            if (did)
                printf("wrote to /etc/hosts successfully.\nrun `cat /etc/hosts` for more info.\n");
        }
        else printf("failed to generate hosts file.\n");
        
        printf("*****\n");
        
        [hman release];
        
        flushDNS();
    }
    
    return 0;
}
