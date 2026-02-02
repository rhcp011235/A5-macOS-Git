//
//  A5BackendServer.m
//  A5
//
//  Created by RHCP011235
//  Copyright © 2026 RHCP011235. All rights reserved.
//

#import "A5BackendServer.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>

@interface A5BackendServer ()
@property (assign, nonatomic) int serverSocket;
@property (strong, nonatomic) NSString *backendPath;
@property (strong, nonatomic) dispatch_queue_t serverQueue;
@property (assign, nonatomic) BOOL running;
@end

@implementation A5BackendServer

- (instancetype)init {
    self = [super init];
    if (self) {
        _serverSocket = -1;
        _running = NO;
        _serverQueue = dispatch_queue_create("com.a5.backend", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (BOOL)startServerOnPort:(NSInteger)port withBackendPath:(NSString *)backendPath {
    if (self.running) {
        return YES;
    }

    self.backendPath = backendPath;

    self.serverSocket = socket(AF_INET, SOCK_STREAM, 0);
    if (self.serverSocket < 0) {
        return NO;
    }

    int reuse = 1;
    setsockopt(self.serverSocket, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse));

    struct sockaddr_in serverAddr;
    memset(&serverAddr, 0, sizeof(serverAddr));
    serverAddr.sin_family = AF_INET;
    serverAddr.sin_addr.s_addr = INADDR_ANY; // Listen on ALL interfaces (not just 127.0.0.1)
    serverAddr.sin_port = htons((uint16_t)port);

    if (bind(self.serverSocket, (struct sockaddr *)&serverAddr, sizeof(serverAddr)) < 0) {
        close(self.serverSocket);
        self.serverSocket = -1;
        return NO;
    }

    if (listen(self.serverSocket, 5) < 0) {
        close(self.serverSocket);
        self.serverSocket = -1;
        return NO;
    }

    self.running = YES;

    dispatch_async(self.serverQueue, ^{
        [self acceptConnections];
    });

    return YES;
}

- (void)acceptConnections {
    while (self.running) {
        struct sockaddr_in clientAddr;
        socklen_t clientLen = sizeof(clientAddr);

        int clientSocket = accept(self.serverSocket, (struct sockaddr *)&clientAddr, &clientLen);
        if (clientSocket < 0) {
            if (self.running) {
                continue;
            } else {
                break;
            }
        }

        dispatch_async(self.serverQueue, ^{
            [self handleClient:clientSocket];
        });
    }
}

- (void)log:(NSString *)message {
    if (self.logHandler) {
        self.logHandler(message);
    }
    NSLog(@"%@", message); // Still log to console for debugging
}

- (void)handleClient:(int)clientSocket {
    char buffer[4096];
    ssize_t bytesRead = recv(clientSocket, buffer, sizeof(buffer) - 1, 0);

    if (bytesRead <= 0) {
        close(clientSocket);
        return;
    }

    buffer[bytesRead] = '\0';
    NSString *request = [NSString stringWithUTF8String:buffer];

    [self log:@"[Backend] ========================================"];
    [self log:[NSString stringWithFormat:@"[Backend] Received HTTP request (%zd bytes)", bytesRead]];

    // Log first line (request method and path)
    NSArray *lines = [request componentsSeparatedByString:@"\n"];
    if (lines.count > 0) {
        [self log:[NSString stringWithFormat:@"[Backend] Request: %@", [lines[0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]]];
    }

    NSString *userAgent = [self extractUserAgentFromRequest:request];
    [self log:[NSString stringWithFormat:@"[Backend] User-Agent: %@", userAgent.length > 0 ? userAgent : @"(empty)"]];

    NSString *model = [self extractValueFromString:userAgent withPattern:@"model/([a-zA-Z0-9,]+)"];
    NSString *build = [self extractValueFromString:userAgent withPattern:@"build/([a-zA-Z0-9]+)"];

    [self log:[NSString stringWithFormat:@"[Backend] Parsed model: %@", model ?: @"(none)"]];
    [self log:[NSString stringWithFormat:@"[Backend] Parsed build: %@", build ?: @"(none)"]];

    if (model && build && ![model containsString:@".."] && ![build containsString:@".."]) {
        NSString *plistPath = [NSString stringWithFormat:@"%@/plists/%@/%@/patched.plist",
                              self.backendPath, model, build];

        [self log:[NSString stringWithFormat:@"[Backend] Looking for plist: %@", plistPath]];

        if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
            NSError *error = nil;
            NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:plistPath error:&error];
            unsigned long long fileSize = [attrs fileSize];

            [self log:[NSString stringWithFormat:@"[Backend] ✓ Plist found (%llu bytes)", fileSize]];
            [self log:@"[Backend] Sending 200 OK with plist data"];
            [self sendFile:plistPath toSocket:clientSocket];
        } else {
            [self log:@"[Backend] ✗ Plist NOT found at path"];
            [self log:@"[Backend] Sending 403 Forbidden"];
            [self sendForbidden:clientSocket];
        }
    } else {
        [self log:@"[Backend] ✗ Invalid or missing model/build in User-Agent"];
        [self log:@"[Backend] Sending 403 Forbidden"];
        [self sendForbidden:clientSocket];
    }

    [self log:@"[Backend] Request handling complete"];
    [self log:@"[Backend] ========================================"];

    close(clientSocket);
}

- (NSString *)extractUserAgentFromRequest:(NSString *)request {
    NSArray *lines = [request componentsSeparatedByString:@"\n"];
    for (NSString *line in lines) {
        if ([line hasPrefix:@"User-Agent:"]) {
            NSString *value = [line substringFromIndex:11];
            return [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
    return @"";
}

- (NSString *)extractValueFromString:(NSString *)string withPattern:(NSString *)pattern {
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                            options:0
                                                                              error:&error];
    if (error) {
        return nil;
    }

    NSTextCheckingResult *match = [regex firstMatchInString:string
                                                     options:0
                                                       range:NSMakeRange(0, string.length)];
    if (match && match.numberOfRanges > 1) {
        return [string substringWithRange:[match rangeAtIndex:1]];
    }

    return nil;
}

- (void)sendFile:(NSString *)filePath toSocket:(int)clientSocket {
    NSData *fileData = [NSData dataWithContentsOfFile:filePath];
    if (!fileData) {
        [self sendForbidden:clientSocket];
        return;
    }

    NSString *response = [NSString stringWithFormat:
        @"HTTP/1.1 200 OK\r\n"
        @"Content-Description: File Transfer\r\n"
        @"Content-Type: application/xml\r\n"
        @"Content-Length: %lu\r\n"
        @"Content-Disposition: attachment; filename=\"patched.plist\"\r\n"
        @"Cache-Control: must-revalidate\r\n"
        @"Pragma: public\r\n"
        @"\r\n", (unsigned long)fileData.length];

    send(clientSocket, [response UTF8String], response.length, 0);
    send(clientSocket, fileData.bytes, fileData.length, 0);
}

- (void)sendForbidden:(int)clientSocket {
    NSString *response = @"HTTP/1.1 403 Forbidden\r\n"
                         @"Content-Type: text/plain\r\n"
                         @"Content-Length: 9\r\n"
                         @"\r\n"
                         @"Forbidden";
    send(clientSocket, [response UTF8String], response.length, 0);
}

- (void)stopServer {
    self.running = NO;
    if (self.serverSocket >= 0) {
        close(self.serverSocket);
        self.serverSocket = -1;
    }
}

- (BOOL)isRunning {
    return self.running;
}

- (void)dealloc {
    [self stopServer];
}

@end
