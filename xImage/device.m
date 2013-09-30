//
//  device.c
//  xImage
//
//  Created by rockee on 13-5-22.
//
//

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <CommonCrypto/CommonDigest.h>

#include "device.h"

#define  MAC_ADDRESS_LEN    (6)

static char __UUID__[64];
static int __init__ = 0;

static int _get_device_mac_address(){
    int ret = -1;
    int                 mib[MAC_ADDRESS_LEN];
    size_t              len;
    char                *buf;
    unsigned char       *ptr;
    struct if_msghdr    *ifm;
    struct sockaddr_dl  *sdl;
    CC_MD5_CTX          md5_ctx;
    unsigned char       result[CC_MD5_DIGEST_LENGTH];
    char                __MAC_ADRESS_TEXT[64];


    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        return NULL;
    }
    
    if (sysctl(mib, MAC_ADDRESS_LEN, NULL, &len, NULL, 0) < 0) {
        return NULL;
    }
    
    if ((buf = malloc(len)) == NULL) {
        return NULL;
    }
    
    if (sysctl(mib, MAC_ADDRESS_LEN, buf, &len, NULL, 0) < 0) {
        free(buf);
        return NULL;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    
    sprintf(__MAC_ADRESS_TEXT, "%02X:%02X:%02X:%02X:%02X:%02X", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5));
    
    CC_MD5_Init(&md5_ctx);
    CC_MD5_Update(&md5_ctx, __MAC_ADRESS_TEXT, strlen(__MAC_ADRESS_TEXT));
    CC_MD5_Final(result, &md5_ctx);
    
    sprintf(__UUID__, "%02X%02X%02X%02X-%02X%02X-%02X%02X-%02X%02X-%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]);
    
    free(buf);
    ret = 1;
    return ret;
}

const char* device_uuid(){
    //    "B5791DC0-127E-49EF-876E-98AED0E6A0CE"
    if(__init__ == 0){
        __init__ = _get_device_mac_address();
    }
    if(__init__ == 1){
        return __UUID__;
    }else{
        return NULL;
    }
}
