//
//  HMFileManager.h
//  hostsman
//
//  Created by Bailey Seymour on 10/17/16.
//  Copyright © 2016 Bailey Seymour. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMFileManager : NSObject

@property (nonatomic, copy) NSString *path;
+ (NSString *)originalHostsPath;
- (id)initWithPath:(NSString *)path;
- (NSString *)mainContents;

@end
