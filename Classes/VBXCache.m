/**
 * "The contents of this file are subject to the Mozilla Public License
 *  Version 1.1 (the "License"); you may not use this file except in
 *  compliance with the License. You may obtain a copy of the License at
 *  http://www.mozilla.org/MPL/
 
 *  Software distributed under the License is distributed on an "AS IS"
 *  basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
 *  License for the specific language governing rights and limitations
 *  under the License.
 
 *  The Original Code is OpenVBX, released February 18, 2011.
 
 *  The Initial Developer of the Original Code is Twilio Inc.
 *  Portions created by Twilio Inc. are Copyright (C) 2010.
 *  All Rights Reserved.
 
 * Contributor(s):
 **/

#import "VBXCache.h"
#import "VBXPerfTimer.h"
#import "VBXGlobal.h"

#define kDataKey @"data"
#define kTimestampKey @"timestamp"
#define kHadTrustedCertificateKey @"hadTrustedCertificate"

@implementation VBXCache

- (BOOL)validateDirectoryPath:(NSString *)path {
    if (!path) return NO;
    NSError *error = nil;
    BOOL success = [_fileManager createDirectoryAtPath:path
        withIntermediateDirectories:YES attributes:nil error:&error];
    if (!success) debug(@"error: couldn't create %@: %@", path, error);
    return success;
}

- (NSInteger)numFilesAtPath:(NSString *)path {
    NSError *error = nil;
    NSArray *files = [_fileManager contentsOfDirectoryAtPath:path error:&error];
    if (error) {
        debug(@"error: couldn't list %@: %@", path, error);
        return -1;
    }
    return [files count];
}

- (id)initWithFileManager:(NSFileManager *)manager DirectoryPath:(NSString *)path {
    if (self = [super init]) {
        //debug(@"%@", path);
        _fileManager = [manager retain];
        _dictionary = [NSMutableDictionary new];        
        _directoryPath = [self validateDirectoryPath:path]? [path retain] : nil;

        if (_directoryPath) {
            _numDiskEntries = [self numFilesAtPath:_directoryPath];
        }

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning:)
            name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

@synthesize maxDiskEntries = _maxDiskEntries;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_fileManager release];
    [_directoryPath release];
    [_dictionary release];
    [super dealloc];
}

- (BOOL) isDiskCacheEnabled {
    return (_directoryPath != nil);
}

- (BOOL) isEmpty {
    if ([_dictionary count] > 0) return NO;
    if (self.isDiskCacheEnabled && _numDiskEntries > 0) return NO;
    return YES;
}

- (NSString *)filePathForKey:(NSString *)key {
    NSString *filename = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)key, NULL, CFSTR(":/?#[]@!$&’()*+,;="), kCFStringEncodingUTF8);
    NSString *filePath = [_directoryPath stringByAppendingPathComponent:filename];
    [filename release];
    return filePath;
}

NSInteger compareFilesByDate(id filename1, id filename2, void *context) {
    NSDictionary *fileDates = context;
    return [[fileDates objectForKey:filename1] compare:[fileDates objectForKey:filename2]];
}

- (void)ensureRoomOnDisk {
    if (_numDiskEntries < _maxDiskEntries) return;
    
    NSError *error = nil;
    NSArray *files = [_fileManager contentsOfDirectoryAtPath:_directoryPath error:&error];
    if (error) {
        debug(@"error: can't list %@: %@", _directoryPath, error);
        return;
    }
    
    NSMutableDictionary *fileDates = [NSMutableDictionary dictionaryWithCapacity:[files count]];
    for (NSString *filename in files) {
        NSString *path = [_directoryPath stringByAppendingPathComponent:filename];
        NSDictionary *attributes = [_fileManager attributesOfItemAtPath:path error:&error];
        if (error) {
            debug(@"error: can't get attributes of %@: %@", path, error);
            continue;
        }
        [fileDates setObject:[attributes fileModificationDate] forKey:path];
    }
    
    NSArray *sortedPaths = [[fileDates allKeys] sortedArrayUsingFunction:compareFilesByDate context:fileDates];
    for (int index = 0; index < [sortedPaths count]; index++) {
        NSString *path = [sortedPaths objectAtIndex:index];
        [_fileManager removeItemAtPath:path error:&error];
        if (error) {
            debug(@"error: can't remove %@: %@", path, error);
            continue;
        }
        _numDiskEntries--;
        if (_numDiskEntries < _maxDiskEntries) {
            break;
        }
    }
}

- (NSData *)dataInMemoryForKey:(NSString *)key {
    return [[_dictionary objectForKey:key] objectForKey:kDataKey];
}

- (NSDate *)timestampForDataInMemoryForKey:(NSString *)key {
    return [[_dictionary objectForKey:key] objectForKey:kTimestampKey];
}

- (NSNumber *)hadTrustedCertificateForDataInMemoryForKey:(NSString *)key {
    return [[_dictionary objectForKey:key] objectForKey:kHadTrustedCertificateKey]; 
}

- (void)cacheDataInMemory:(NSData *)data hadTrustedCertificate:(BOOL)hadTrustedCertificate forKey:(NSString *)key {    
    [_dictionary setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithBool:hadTrustedCertificate],
                            kHadTrustedCertificateKey,                            
                            [NSDate date],
                            kTimestampKey,
                            data,
                            kDataKey,
                            nil]
                   forKey:key];
}

- (void)removeDataInMemoryForKey:(NSString *)key {
    [_dictionary removeObjectForKey:key];
}

- (void)removeAllObjectsInMemory {
    [_dictionary removeAllObjects];
}

- (NSData *)dataOnDiskForKey:(NSString *)key {
    if (!self.isDiskCacheEnabled) {
        return nil;
    }
    
    NSString *path = [self filePathForKey:key];
    NSData *data = [_fileManager contentsAtPath:path];
    
    return data;
}

- (NSDate *)timestampForDataOnDiskForKey:(NSString *)key {
    if (!self.isDiskCacheEnabled) {
        return nil;
    }

    NSString *path = [self filePathForKey:key];
    NSError *error = nil;
    NSDictionary *attributes = [_fileManager attributesOfItemAtPath:path error:&error];
    
    if (!error) {
        return nil;
    } else {
        return [attributes fileModificationDate];
    }
}

- (NSNumber *)hadTrustedCertificateForDataOnDiskForKey:(NSString *)key {
    if (!self.isDiskCacheEnabled) {
        return nil;
    }

    NSString *path = [self filePathForKey:key];
    NSError *error = nil;
    NSDictionary *attributes = [_fileManager attributesOfItemAtPath:path error:&error];

    if (!error) {
        NSNumber *permissions = [attributes objectForKey:NSFilePosixPermissions];
        
        // Remember: we've repurposed the global execute bit as our
        // "had trusted certificate" bit.
        return [NSNumber numberWithBool:(([permissions unsignedLongValue] & 1) == 1)];
    } else {
        return nil;
    }
}

- (void)cacheDataOnDisk:(NSData *)data hadTrustedCertificate:(BOOL)hadTrustedCertificate forKey:(NSString *)key {
    if (!self.isDiskCacheEnabled) {
        return;
    }
    
    NSString *path = [self filePathForKey:key];
    
    BOOL exists = [_fileManager fileExistsAtPath:path];
    if (!exists) [self ensureRoomOnDisk];
    
    // We've repurposed the POSIX global execute bit to be our "hadTrustedCertificate"
    // bit.  We're causing no harm and this is way easier than added some extra attributes
    // storage for each of our cache items.
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [NSNumber numberWithUnsignedLong:(0420 | (hadTrustedCertificate ? 1 : 0))],
                                NSFilePosixPermissions,
                                nil];
    
    BOOL success = [_fileManager createFileAtPath:path contents:data attributes:attributes];
    if (!success) {
        debug(@"error: couldn't cache %d bytes at %@", [data length], path);
        return;
    }
    
    //debug(@"%d bytes cached at %@ (%@)", [data length], path, timer);
    if (!exists) {
        _numDiskEntries++;
    }
}

- (void)removeDataOnDiskForKey:(NSString *)key {
    if (!self.isDiskCacheEnabled) return;
    NSString *path = [self filePathForKey:key];
    NSError *error = nil;
    BOOL success = [_fileManager removeItemAtPath:path error:&error];
    if (success) _numDiskEntries--;
    else debug(@"error: couldn't remove item at %@: %@", path, error);
}

- (void)removeAllObjectsOnDisk {
    if (!self.isDiskCacheEnabled) return;

    NSError *error = nil;
    NSArray *files = [_fileManager contentsOfDirectoryAtPath:_directoryPath error:&error];
    if (error) {
        debug(@"error: can't list %@: %@", _directoryPath, error);
        return;
    }
    
    for (NSString *filename in files) {
        NSString *path = [_directoryPath stringByAppendingPathComponent:filename];
        BOOL success = [_fileManager removeItemAtPath:path error:&error];
        if (success) _numDiskEntries--;
        else debug(@"error: couldn't remove item at %@: %@", path, error);
    }
}

- (NSData *)dataForKey:(NSString *)key {
    NSData *data = [self dataInMemoryForKey:key];
    if (data) {
        //debug(@"mem hit for %@", key);
        return data;
    }

    data = [self dataOnDiskForKey:key];
    if (data) {
        // Move the item into the memory cache
        [_dictionary setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                [self hadTrustedCertificateForDataOnDiskForKey:key],
                                kHadTrustedCertificateKey,                                
                                [self timestampForDataOnDiskForKey:key],
                                kTimestampKey,
                                data,
                                kDataKey,
                                nil]
                       forKey:key];
        return data;
    }
    
    //debug(@"miss for %@", key);
    return nil;
}

- (NSDate *)timestampForDataForKey:(NSString *)key {
    NSDate *date = [self timestampForDataInMemoryForKey:key];
    
    if (date) {
        return date;
    }
    
    date = [self timestampForDataOnDiskForKey:key];
    if (date) {
        return date;
    }
    
    return nil;
}

- (BOOL)hadTrustedCertificateForDataForKey:(NSString *)key {
    NSNumber *hadTrustedCertificate = [self hadTrustedCertificateForDataInMemoryForKey:key];
    
    if (hadTrustedCertificate) {
        return [hadTrustedCertificate boolValue];
    } else {
        hadTrustedCertificate = [self hadTrustedCertificateForDataOnDiskForKey:key];
        
        if (hadTrustedCertificate) {
            return [hadTrustedCertificate boolValue];
        } else {
            return NO;
        }
    }
}

- (void)cacheData:(NSData *)data hadTrustedCertificate:(BOOL)hadTrustedCertificate forKey:(NSString *)key {
    debug(@"caching %d bytes for: %@", data.length, key);
    [self cacheDataInMemory:data hadTrustedCertificate:(BOOL)hadTrustedCertificate forKey:key];
    [self cacheDataOnDisk:data hadTrustedCertificate:(BOOL)hadTrustedCertificate forKey:key];
}

- (void)removeDataForKey:(NSString *)key {
    [self removeDataInMemoryForKey:key];
    [self removeDataOnDiskForKey:key];
}

- (void)removeAllObjects {
    [self removeAllObjectsInMemory];
    [self removeAllObjectsOnDisk];
}

- (void)didReceiveMemoryWarning:(NSNotification *)notification {
    debug(@"removing %d objects from in-memory cache", [_dictionary count]);
    [self removeAllObjectsInMemory];
}

@end
