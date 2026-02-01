//
//  A5AFCClient.m
//  A5
//
//  Created by RHCP011235
//  Copyright © 2026 RHCP011235. All rights reserved.
//

#import "A5AFCClient.h"
#import <libimobiledevice/libimobiledevice.h>
#import <libimobiledevice/lockdown.h>
#import <libimobiledevice/afc.h>

@implementation A5AFCClient

+ (BOOL)transferFile:(NSString *)localPath
          toDevice:(NSString *)udid
        remotePath:(NSString *)remotePath
             error:(NSError **)error {

    idevice_t device = NULL;
    lockdownd_client_t lockdown = NULL;
    afc_client_t afc = NULL;
    lockdownd_service_descriptor_t service = NULL;
    NSData *fileData = nil;
    uint64_t file_handle = 0;
    BOOL success = NO;

    // Convert UDID to C string
    const char *udid_cstr = [udid UTF8String];

    // Connect to device
    if (idevice_new(&device, udid_cstr) != IDEVICE_E_SUCCESS) {
        if (error) {
            *error = [NSError errorWithDomain:@"A5AFCClient"
                                        code:100
                                    userInfo:@{NSLocalizedDescriptionKey: @"Failed to connect to device"}];
        }
        goto cleanup;
    }

    // Create lockdown client
    if (lockdownd_client_new_with_handshake(device, &lockdown, "A5") != LOCKDOWN_E_SUCCESS) {
        if (error) {
            *error = [NSError errorWithDomain:@"A5AFCClient"
                                        code:101
                                    userInfo:@{NSLocalizedDescriptionKey: @"Failed to establish lockdown connection"}];
        }
        goto cleanup;
    }

    // Start AFC service
    if (lockdownd_start_service(lockdown, "com.apple.afc", &service) != LOCKDOWN_E_SUCCESS) {
        if (error) {
            *error = [NSError errorWithDomain:@"A5AFCClient"
                                        code:102
                                    userInfo:@{NSLocalizedDescriptionKey: @"Failed to start AFC service"}];
        }
        goto cleanup;
    }

    // Create AFC client
    if (afc_client_new(device, service, &afc) != AFC_E_SUCCESS) {
        if (error) {
            *error = [NSError errorWithDomain:@"A5AFCClient"
                                        code:103
                                    userInfo:@{NSLocalizedDescriptionKey: @"Failed to create AFC client"}];
        }
        goto cleanup;
    }

    // Read local file
    fileData = [NSData dataWithContentsOfFile:localPath];
    if (!fileData) {
        if (error) {
            *error = [NSError errorWithDomain:@"A5AFCClient"
                                        code:104
                                    userInfo:@{NSLocalizedDescriptionKey: @"Failed to read local file"}];
        }
        goto cleanup;
    }

    // Open remote file for writing
    const char *remote_path = [remotePath UTF8String];

    if (afc_file_open(afc, remote_path, AFC_FOPEN_WR, &file_handle) != AFC_E_SUCCESS) {
        if (error) {
            *error = [NSError errorWithDomain:@"A5AFCClient"
                                        code:105
                                    userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Failed to open remote file: %@", remotePath]}];
        }
        goto cleanup;
    }

    // Write file data
    uint32_t bytes_written = 0;
    if (afc_file_write(afc, file_handle, [fileData bytes], (uint32_t)[fileData length], &bytes_written) != AFC_E_SUCCESS) {
        afc_file_close(afc, file_handle);
        if (error) {
            *error = [NSError errorWithDomain:@"A5AFCClient"
                                        code:106
                                    userInfo:@{NSLocalizedDescriptionKey: @"Failed to write file data"}];
        }
        goto cleanup;
    }

    // Close file
    afc_file_close(afc, file_handle);

    // Verify bytes written
    if (bytes_written == [fileData length]) {
        success = YES;
    } else {
        if (error) {
            *error = [NSError errorWithDomain:@"A5AFCClient"
                                        code:107
                                    userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Partial write: %u of %lu bytes", bytes_written, (unsigned long)[fileData length]]}];
        }
    }

cleanup:
    if (afc) {
        afc_client_free(afc);
    }
    if (service) {
        lockdownd_service_descriptor_free(service);
    }
    if (lockdown) {
        lockdownd_client_free(lockdown);
    }
    if (device) {
        idevice_free(device);
    }

    return success;
}

@end
