//
//  A5AFCClient.h
//  A5
//
//  Created by RHCP011235
//  Copyright © 2026 RHCP011235. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface A5AFCClient : NSObject

/**
 * Transfer file to device using native AFC protocol
 * @param udid Device UDID
 * @param localPath Local file path to transfer
 * @param remotePath Remote path on device (relative to AFC root)
 * @param error Error pointer
 * @return YES if successful, NO otherwise
 */
+ (BOOL)transferFile:(NSString *)localPath
          toDevice:(NSString *)udid
        remotePath:(NSString *)remotePath
             error:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
