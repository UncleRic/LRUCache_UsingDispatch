//  RicCache.m
//  MyLRU
//
//  Created by Frederick C. Lee on 8/27/14.
//  Copyright (c) 2014 Amourine Technologies. All rights reserved.
// -----------------------------------------------------------------------------------------------------------------------

#import "RicCache.h"

static int kCacheMemoryLimit;
static dispatch_queue_t concurrentQueue;

@interface RicCache ()
@property (nonatomic, strong) NSString *cacheDirectory;
@property (nonatomic, strong) NSString *appVersion;  // ...Keep cache distinct per app version.
@property (nonatomic, strong) NSMutableDictionary *memoryCache;
@end

@implementation RicCache
+ (void)initialize {
    if (self == [RicCache class]) {
         concurrentQueue = dispatch_queue_create("com.AmourineTechn.SerialQueue", DISPATCH_QUEUE_CONCURRENT);
    }
}

// -----------------------------------------------------------------------------------------------------------------------

- (instancetype)initWithName:(NSString *)name {
    if ((self = [super init])) {
        [self cacheDirectoryForName:name];
    }
    return self;
}

// -----------------------------------------------------------------------------------------------------------------------

- (void)cacheDirectoryForName:(NSString *)name {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    self.cacheDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:name];
    if (![[NSFileManager defaultManager] fileExistsAtPath:_cacheDirectory]){
        [[NSFileManager defaultManager] createDirectoryAtPath:_cacheDirectory
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:nil];
    }
    // Invalidating the Cache.
    // Check if app's current version is dated; if true, then clear it via 'clearCache':
    
    double lastSavedCacheVersion = [[NSUserDefaults standardUserDefaults] doubleForKey:@"CACHE_VERSION"];
    double currentAppVersion = [[self appVersion] doubleValue];
    
    if (lastSavedCacheVersion < currentAppVersion) {
        // assigning current version to preference
        [self clearCache];
        
        [[NSUserDefaults standardUserDefaults] setDouble:currentAppVersion forKey:@"CACHE_VERSION"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    self.memoryCache = [[NSMutableDictionary alloc] init];
    self.recentlyAccessedKeys = [[NSMutableArray alloc] init];
    
    // you can set this based on the running device and expected cache size
    kCacheMemoryLimit = 10;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveMemoryCacheToDisk:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveMemoryCacheToDisk:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(saveMemoryCacheToDisk:)
                                                 name:UIApplicationWillTerminateNotification
                                               object:nil];
    
}

// -----------------------------------------------------------------------------------------------------------------------
#pragma mark -
// ...Getter: getting the current app version from its info.plist.

- (NSString *)appVersion {
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *version = [infoDict objectForKey:(NSString *)kCFBundleVersionKey];
    return version;
}

// -----------------------------------------------------------------------------------------------------------------------

- (void)saveMemoryCacheToDisk:(NSNotification  *)notification {
    dispatch_barrier_async(concurrentQueue, ^{
        for (NSString *filename in [_memoryCache allKeys]){
            NSString *archivePath = [_cacheDirectory stringByAppendingPathComponent:filename];
            NSData *cacheData = [_memoryCache objectForKey:filename];
            [cacheData writeToFile:archivePath atomically:YES];
        }
        
        [_memoryCache removeAllObjects];
    });
}

// -----------------------------------------------------------------------------------------------------------------------

- (void)clearCache {
    dispatch_barrier_async(concurrentQueue, ^{
        NSError *error;
        NSArray *cachedItems = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_cacheDirectory
                                                                                   error:&error];
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            for (NSString *path in cachedItems) {
                [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
                if (error) NSLog(@"Error: %@", error);
            }
            [_memoryCache removeAllObjects];
        }
    });
}

// -----------------------------------------------------------------------------------------------------------------------

- (NSData *)dataFromFile:(NSString *)fileName {
        
    __block NSData *myData = nil;
    
    dispatch_sync(concurrentQueue, ^{
        NSData *data = [_memoryCache objectForKey:fileName];
        // data is NOT present in memory cache
        if (!data)         {
            NSString *archivePath = [_cacheDirectory stringByAppendingPathComponent:fileName];
            data = [NSData dataWithContentsOfFile:archivePath];
            if (data) {
                [self cacheData:data toFile:fileName]; // put the recently accessed data to memory cache
            }
        }
        myData = data;
    });
    
    return myData;
}

// -----------------------------------------------------------------------------------------------------------------------
#pragma mark - Caching Data

- (void)cacheData:(NSData *)data toFile:(NSString *)fileName {
    dispatch_barrier_async(concurrentQueue, ^{
        [_memoryCache setObject:data forKey:fileName];
        [_recentlyAccessedKeys removeObject:fileName];
        [_recentlyAccessedKeys insertObject:fileName atIndex:0];
        
        // Write oldest data to file if cache is full:
        if ([_recentlyAccessedKeys count] > kCacheMemoryLimit) {
            NSString *leastRecentlyUsedDataFilename = [_recentlyAccessedKeys lastObject];
            NSData *leastRecentlyUsedCacheData = [_memoryCache objectForKey:leastRecentlyUsedDataFilename];
            NSString *archivePath = [_cacheDirectory stringByAppendingPathComponent:fileName];
            [leastRecentlyUsedCacheData writeToFile:archivePath atomically:YES];
            
            [_recentlyAccessedKeys removeLastObject];
            [_memoryCache removeObjectForKey:leastRecentlyUsedDataFilename];
        }
    });
}

// -----------------------------------------------------------------------------------------------------------------------
#pragma mark - Caching Assessors

- (void)cachedArrayItems:(NSArray *)arrayItems {
    [self cacheData:[NSKeyedArchiver archivedDataWithRootObject:arrayItems] toFile:@"RicItems.archive"];
}

// -----------------------------------------------------------------------------------------------------------------------

- (NSMutableArray *)getCachedArrayItems {
    // 1) Get data from either cache or file.
    // 2) Reposition data in cache.
    // 3) Unarchive (deSerialize) it.
    return [NSKeyedUnarchiver unarchiveObjectWithData:[self dataFromFile:@"RicItems.archive"]];
}

// -----------------------------------------------------------------------------------------------------------------------
#pragma mark -

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillTerminateNotification object:nil];
    
}


@end
