//  RicCache.h
//  MyLRU
//
//  Created by Frederick C. Lee on 8/27/14.
//  Copyright (c) 2014 Amourine Technologies. All rights reserved.
// -----------------------------------------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>

@interface RicCache : NSObject

@property (nonatomic, strong) NSMutableArray *recentlyAccessedKeys;

- (instancetype)initWithName:(NSString *)name;
- (void)cachedArrayItems:(NSArray *)arrayItems;
- (NSMutableArray *)getCachedArrayItems;
- (void)clearCache;
@end
