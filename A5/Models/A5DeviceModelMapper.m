//
//  A5DeviceModelMapper.m
//  A5
//
//  Created by RHCP011235
//  Copyright © 2026 RHCP011235. All rights reserved.
//

#import "A5DeviceModelMapper.h"

@implementation A5DeviceModelMapper

// FNV-1a hash implementation from iOSDevice2.cs lines 88-98
+ (uint32_t)calculateHashForProductType:(NSString *)productType {
    uint32_t hash = 2166136261U;  // FNV offset basis

    if (productType == nil) {
        return hash;
    }

    for (NSUInteger i = 0; i < productType.length; i++) {
        unichar c = [productType characterAtIndex:i];
        hash = (hash ^ c) * 16777619;  // FNV prime
    }

    return hash;
}

+ (NSString *)modelNameForProductType:(NSString *)productType {
    if (productType == nil || productType.length == 0) {
        return @"Unknown Device";
    }

    uint32_t hash = [self calculateHashForProductType:productType];

    // Device model mappings from iOSDevice2.cs DetermineModel() switch statement
    switch (hash) {
        // A5 Devices - Primary targets
        case 235638739U:  // iPhone4,1
            if ([productType isEqualToString:@"iPhone4,1"]) {
                return @"iPhone 4S";
            }
            break;

        case 194068216U:  // iPhone5,1
            if ([productType isEqualToString:@"iPhone5,1"]) {
                return @"iPhone 5 (AT&T/Canada)";
            }
            break;

        case 244401073U:  // iPhone5,2
            if ([productType isEqualToString:@"iPhone5,2"]) {
                return @"iPhone 5";
            }
            break;

        case 227623454U:  // iPhone5,3
            if ([productType isEqualToString:@"iPhone5,3"]) {
                return @"iPhone 5c";
            }
            break;

        case 277956311U:  // iPhone5,4
            if ([productType isEqualToString:@"iPhone5,4"]) {
                return @"iPhone 5c";
            }
            break;

        case 3497150978U:  // iPad2,1
            if ([productType isEqualToString:@"iPad2,1"]) {
                return @"iPad 2 Wifi";
            }
            break;

        case 3480373359U:  // iPad2,2
            if ([productType isEqualToString:@"iPad2,2"]) {
                return @"iPad 2 GSM";
            }
            break;

        case 3463595740U:  // iPad2,3
            if ([productType isEqualToString:@"iPad2,3"]) {
                return @"iPad 2 3G";
            }
            break;

        case 3446818121U:  // iPad2,4
            if ([productType isEqualToString:@"iPad2,4"]) {
                return @"iPad 2 Wifi";
            }
            break;

        case 3430040502U:  // iPad2,5
            if ([productType isEqualToString:@"iPad2,5"]) {
                return @"iPad Mini Wifi";
            }
            break;

        case 3413262883U:  // iPad2,6
            if ([productType isEqualToString:@"iPad2,6"]) {
                return @"iPad Mini Wifi + Cellular";
            }
            break;

        case 3396485264U:  // iPad2,7
            if ([productType isEqualToString:@"iPad2,7"]) {
                return @"iPad Mini Wifi + Cellular";
            }
            break;

        // iPhone 3G/3GS/4
        case 1613858532U:  // iPhone1,1
            if ([productType isEqualToString:@"iPhone1,1"]) {
                return @"iPhone 1";
            }
            break;

        case 1664191389U:  // iPhone1,2
            if ([productType isEqualToString:@"iPhone1,2"]) {
                return @"iPhone 3G";
            }
            break;

        case 1027150186U:  // iPhone3,1
            if ([productType isEqualToString:@"iPhone3,1"]) {
                return @"iPhone 4 (GSM)";
            }
            break;

        case 1010372567U:  // iPhone3,2
            if ([productType isEqualToString:@"iPhone3,2"]) {
                return @"iPhone 4 (GSM Rev A)";
            }
            break;

        case 993594948U:  // iPhone3,3
            if ([productType isEqualToString:@"iPhone3,3"]) {
                return @"iPhone 4 (CDMA/Verizon/Sprint)";
            }
            break;

        // iPhone 5s
        case 2081752929U:  // iPhone6,1
            if ([productType isEqualToString:@"iPhone6,1"]) {
                return @"iPhone 5s";
            }
            break;

        case 2031420072U:  // iPhone6,2
            if ([productType isEqualToString:@"iPhone6,2"]) {
                return @"iPhone 5s (Global)";
            }
            break;

        // iPhone 6/6 Plus
        case 1760014814U:  // iPhone7,1
            if ([productType isEqualToString:@"iPhone7,1"]) {
                return @"iPhone 6 Plus";
            }
            break;

        case 1743237195U:  // iPhone7,2
            if ([productType isEqualToString:@"iPhone7,2"]) {
                return @"iPhone 6";
            }
            break;

        // iPhone 7/7 Plus
        case 926932844U:  // iPhone9,1
            if ([productType isEqualToString:@"iPhone9,1"]) {
                return @"iPhone 7 (CDMA)";
            }
            break;

        case 977265701U:  // iPhone9,2
            if ([productType isEqualToString:@"iPhone9,2"]) {
                return @"iPhone 7 Plus (CDMA)";
            }
            break;

        case 960488082U:  // iPhone9,3
            if ([productType isEqualToString:@"iPhone9,3"]) {
                return @"iPhone 7 (GSM)";
            }
            break;

        case 876599987U:  // iPhone9,4
            if ([productType isEqualToString:@"iPhone9,4"]) {
                return @"iPhone 7 Plus (GSM)";
            }
            break;

        // iPhone 8/8 Plus/X
        case 2337319562U:  // iPhone10,1
            if ([productType isEqualToString:@"iPhone10,1"]) {
                return @"iPhone 8 (CDMA)";
            }
            break;

        case 2320541943U:  // iPhone10,2
            if ([productType isEqualToString:@"iPhone10,2"]) {
                return @"iPhone 8 Plus (CDMA)";
            }
            break;

        case 2303764324U:  // iPhone10,3
            if ([productType isEqualToString:@"iPhone10,3"]) {
                return @"iPhone X (CDMA)";
            }
            break;

        case 2286986705U:  // iPhone10,4
            if ([productType isEqualToString:@"iPhone10,4"]) {
                return @"iPhone 8 (GSM)";
            }
            break;

        case 2270209086U:  // iPhone10,5
            if ([productType isEqualToString:@"iPhone10,5"]) {
                return @"iPhone 8 Plus (GSM)";
            }
            break;

        case 2253431467U:  // iPhone10,6
            if ([productType isEqualToString:@"iPhone10,6"]) {
                return @"iPhone X (GSM)";
            }
            break;

        // iPhone XS/XS Max/XR
        case 450846996U:  // iPhone11,2
            if ([productType isEqualToString:@"iPhone11,2"]) {
                return @"iPhone XS";
            }
            break;

        case 417291758U:  // iPhone11,4
            if ([productType isEqualToString:@"iPhone11,4"]) {
                return @"iPhone XS Max";
            }
            break;

        case 383736520U:  // iPhone11,6
            if ([productType isEqualToString:@"iPhone11,6"]) {
                return @"iPhone XS Max China";
            }
            break;

        case 350181282U:  // iPhone11,8
            if ([productType isEqualToString:@"iPhone11,8"]) {
                return @"iPhone XR";
            }
            break;

        // iPhone 11/11 Pro/11 Pro Max
        case 755807492U:  // iPhone12,1
            if ([productType isEqualToString:@"iPhone12,1"]) {
                return @"iPhone 11";
            }
            break;

        case 789362730U:  // iPhone12,3
            if ([productType isEqualToString:@"iPhone12,3"]) {
                return @"iPhone 11 Pro";
            }
            break;

        case 688697016U:  // iPhone12,5
            if ([productType isEqualToString:@"iPhone12,5"]) {
                return @"iPhone 11 Pro Max";
            }
            break;

        // iPad 1
        case 2509658711U:  // iPad1,1
            if ([productType isEqualToString:@"iPad1,1"]) {
                return @"iPad 1 Wifi";
            }
            break;

        case 2526436330U:  // iPad1,2
            if ([productType isEqualToString:@"iPad1,2"]) {
                return @"iPad 1 Wifi + Cellular";
            }
            break;

        // iPad 3
        case 1655788389U:  // iPad3,1
            if ([productType isEqualToString:@"iPad3,1"]) {
                return @"iPad 3 Wifi";
            }
            break;

        case 1605455532U:  // iPad3,2
            if ([productType isEqualToString:@"iPad3,2"]) {
                return @"iPad 3 Wifi + Cellular";
            }
            break;

        case 1622233151U:  // iPad3,3
            if ([productType isEqualToString:@"iPad3,3"]) {
                return @"iPad 3 Wifi + Cellular";
            }
            break;

        case 1571900294U:  // iPad3,4
            if ([productType isEqualToString:@"iPad3,4"]) {
                return @"iPad 4 Wifi";
            }
            break;

        case 1588677913U:  // iPad3,5
            if ([productType isEqualToString:@"iPad3,5"]) {
                return @"iPad 4 Wifi + Cellular";
            }
            break;

        case 1538345056U:  // iPad3,6
            if ([productType isEqualToString:@"iPad3,6"]) {
                return @"iPad 4 Wifi + Cellular";
            }
            break;

        // iPad Air
        case 2643280656U:  // iPad4,1
            if ([productType isEqualToString:@"iPad4,1"]) {
                return @"iPad AIR Wifi";
            }
            break;

        case 2693613513U:  // iPad4,2
            if ([productType isEqualToString:@"iPad4,2"]) {
                return @"iPad AIR Wifi + Cellular";
            }
            break;

        case 2676835894U:  // iPad4,3
            if ([productType isEqualToString:@"iPad4,3"]) {
                return @"iPad AIR Wifi + Cellular";
            }
            break;

        // iPad Mini 2/3
        case 2727168751U:  // iPad4,4
            if ([productType isEqualToString:@"iPad4,4"]) {
                return @"iPad Mini 2 Wifi";
            }
            break;

        case 2710391132U:  // iPad4,5
            if ([productType isEqualToString:@"iPad4,5"]) {
                return @"iPad Mini 2 Wifi + Cellular";
            }
            break;

        case 2760723989U:  // iPad4,6
            if ([productType isEqualToString:@"iPad4,6"]) {
                return @"iPad Mini 2 Wifi + Cellular";
            }
            break;

        case 2743946370U:  // iPad4,7
            if ([productType isEqualToString:@"iPad4,7"]) {
                return @"iPad Mini 3 Wifi";
            }
            break;

        case 2794279227U:  // iPad4,8
            if ([productType isEqualToString:@"iPad4,8"]) {
                return @"iPad Mini 3 Wifi + Cellular";
            }
            break;

        case 2777501608U:  // iPad4,9
            if ([productType isEqualToString:@"iPad4,9"]) {
                return @"iPad Mini 3 Wifi + Cellular";
            }
            break;

        // iPad Mini 4 / iPad Air 2
        case 1084645515U:  // iPad5,1
            if ([productType isEqualToString:@"iPad5,1"]) {
                return @"iPad Mini 4 Wifi";
            }
            break;

        case 1101423134U:  // iPad5,2
            if ([productType isEqualToString:@"iPad5,2"]) {
                return @"iPad Mini 4 Wifi + Cellular";
            }
            break;

        case 1118200753U:  // iPad5,3
            if ([productType isEqualToString:@"iPad5,3"]) {
                return @"iPad AIR 2 Wifi";
            }
            break;

        case 1134978372U:  // iPad5,4
            if ([productType isEqualToString:@"iPad5,4"]) {
                return @"iPad AIR 2 Wifi + Cellular";
            }
            break;

        // iPad Pro 9.7
        case 13713525U:  // iPad6,4
            if ([productType isEqualToString:@"iPad6,4"]) {
                return @"iPad PRO 9.7 Wifi + Cellular";
            }
            break;

        // iPad Pro 12.9
        case 80824001U:  // iPad6,8
            if ([productType isEqualToString:@"iPad6,8"]) {
                return @"iPad PRO 12.9 Wifi + Cellular";
            }
            break;

        case 291253989U:  // iPad6,11
            if ([productType isEqualToString:@"iPad6,11"]) {
                return @"iPad (5th) Wifi";
            }
            break;

        case 240921132U:  // iPad6,12
            if ([productType isEqualToString:@"iPad6,12"]) {
                return @"iPad (5th) Wifi + Cellular";
            }
            break;

        // iPad Pro 12.9 2nd gen
        case 251563545U:  // iPad7,1
            if ([productType isEqualToString:@"iPad7,1"]) {
                return @"iPad PRO 12.9 Wifi";
            }
            break;

        case 201230688U:  // iPad7,2
            if ([productType isEqualToString:@"iPad7,2"]) {
                return @"iPad PRO 12.9 Wifi + Cellular";
            }
            break;

        // iPad Pro 10.5
        case 218008307U:  // iPad7,3
            if ([productType isEqualToString:@"iPad7,3"]) {
                return @"iPad PRO 10.5 Wifi";
            }
            break;

        case 301896402U:  // iPad7,4
            if ([productType isEqualToString:@"iPad7,4"]) {
                return @"iPad PRO 10.5 Wifi + Cellular";
            }
            break;

        // iPad 6th gen
        case 318674021U:  // iPad7,5
            if ([productType isEqualToString:@"iPad7,5"]) {
                return @"iPad (6th) WiFi";
            }
            break;

        case 268341164U:  // iPad7,6
            if ([productType isEqualToString:@"iPad7,6"]) {
                return @"iPad (6th) WiFi + Cellular";
            }
            break;

        // iPad 7th gen
        case 3266955512U:  // iPad7,11
            if ([productType isEqualToString:@"iPad7,11"]) {
                return @"iPad (7th) WiFi";
            }
            break;

        case 3317288369U:  // iPad7,12
            if ([productType isEqualToString:@"iPad7,12"]) {
                return @"iPad (7th) WiFi + Cellular";
            }
            break;

        // iPad Pro 11 3rd gen
        case 460252244U:  // iPad8,1
            if ([productType isEqualToString:@"iPad8,1"]) {
                return @"iPad PRO 11 WiFi";
            }
            break;

        case 510585101U:  // iPad8,2
            if ([productType isEqualToString:@"iPad8,2"]) {
                return @"iPad PRO 11 1TB, WiFi";
            }
            break;

        case 493807482U:  // iPad8,3
            if ([productType isEqualToString:@"iPad8,3"]) {
                return @"iPad PRO 11 WiFi + Cellular";
            }
            break;

        case 409919387U:  // iPad8,4
            if ([productType isEqualToString:@"iPad8,4"]) {
                return @"iPad PRO 11 1TB, WiFi + Cellular";
            }
            break;

        // iPad Pro 12.9 3rd gen
        case 393141768U:  // iPad8,5
            if ([productType isEqualToString:@"iPad8,5"]) {
                return @"iPad PRO 12.9 WiFi";
            }
            break;

        case 443474625U:  // iPad8,6
            if ([productType isEqualToString:@"iPad8,6"]) {
                return @"iPad PRO 12.9 1TB, WiFi";
            }
            break;

        case 426697006U:  // iPad8,7
            if ([productType isEqualToString:@"iPad8,7"]) {
                return @"iPad PRO 12.9 WiFi + Cellular";
            }
            break;

        case 342808911U:  // iPad8,8
            if ([productType isEqualToString:@"iPad8,8"]) {
                return @"iPad PRO 12.9 1TB, WiFi + Cellular";
            }
            break;

        // iPad Mini 5th gen / iPad Air 3rd gen
        case 2950802044U:  // iPad11,1
            if ([productType isEqualToString:@"iPad11,1"]) {
                return @"iPad mini 5th Gen WiFi";
            }
            break;

        case 3001134901U:  // iPad11,2
            if ([productType isEqualToString:@"iPad11,2"]) {
                return @"iPad mini 5th Gen Wifi + Cellular";
            }
            break;

        case 2984357282U:  // iPad11,3
            if ([productType isEqualToString:@"iPad11,3"]) {
                return @"iPad Air 3rd Gen Wifi";
            }
            break;

        case 2900469187U:  // iPad11,4
            if ([productType isEqualToString:@"iPad11,4"]) {
                return @"iPad Air 3rd Gen Wifi + Cellular";
            }
            break;

        // iPod Touch
        case 1886294147U:  // iPod3,1
            if ([productType isEqualToString:@"iPod3,1"]) {
                return @"iPod Touch Third Generation";
            }
            break;

        case 519927770U:  // iPod4,1
            if ([productType isEqualToString:@"iPod4,1"]) {
                return @"iPod Touch Fourth Generation";
            }
            break;

        case 2989097949U:  // iPod5,1
            if ([productType isEqualToString:@"iPod5,1"]) {
                return @"iPod Touch 5th Generation";
            }
            break;

        case 1158652399U:  // iPod7,1
            if ([productType isEqualToString:@"iPod7,1"]) {
                return @"iPod Touch 6th Generation";
            }
            break;

        case 897947417U:  // iPod9,1
            if ([productType isEqualToString:@"iPod9,1"]) {
                return @"iPod Touch 7th Generation";
            }
            break;

        default:
            break;
    }

    return @"Unknown Device";
}

+ (BOOL)isA5Device:(NSString *)productType {
    if (productType == nil || productType.length == 0) {
        return NO;
    }

    // A5 chip devices that can be bypassed
    NSArray *a5Devices = @[
        @"iPhone4,1",     // iPhone 4S
        @"iPhone5,1",     // iPhone 5 (AT&T)
        @"iPhone5,2",     // iPhone 5 (GSM)
        @"iPhone5,3",     // iPhone 5c
        @"iPhone5,4",     // iPhone 5c (Global)
        @"iPad2,1",       // iPad 2 WiFi
        @"iPad2,2",       // iPad 2 GSM
        @"iPad2,3",       // iPad 2 3G
        @"iPad2,4",       // iPad 2 WiFi Rev A
        @"iPad2,5",       // iPad Mini WiFi
        @"iPad2,6",       // iPad Mini WiFi + Cellular
        @"iPad2,7",       // iPad Mini WiFi + Cellular
    ];

    return [a5Devices containsObject:productType];
}

@end
