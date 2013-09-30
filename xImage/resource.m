//
//  resource.m
//  xImage
//
//  Created by rockee on 13-5-10.
//
//

#import "resource.h"
#include "images/Icon.m"
#include "images/Icon@2x.m"
#include "images/Icon@2x~iPad.m"
#include "images/Icon~iPad.m"

#define IS_RETINA ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0))
#define IS_iPhone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IMAGE_NAMED(name, sc) [UIImage imageWithData:[NSData dataWithBytes:name length:sizeof(name)] scale: sc]


UIImage* resource_image(int index){
    UIImage *image = nil;
    
    if(index == RIWeiboIcon){
        if(IS_RETINA){
            if(IS_iPhone){
                image = IMAGE_NAMED(__Icon_2x_PNG__, 2.0);
            }else{
                image = IMAGE_NAMED(__Icon_2x_iPad_PNG__, 2.0);
            }
        }else{
            if(IS_iPhone){
                image = IMAGE_NAMED(__Icon_PNG__, 1.0);
            }else{
                image = IMAGE_NAMED(__Icon_iPad_PNG__, 1.0);
            }
        }
    }
    return image;
}

