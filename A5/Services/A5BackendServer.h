//
//  A5BackendServer.h
//  A5
//
//  Created by RHCP011235
//  Copyright © 2026 RHCP011235. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface A5BackendServer : NSObject

- (BOOL)startServerOnPort:(NSInteger)port withBackendPath:(NSString *)backendPath;
- (void)stopServer;
- (BOOL)isRunning;

@end

NS_ASSUME_NONNULL_END
