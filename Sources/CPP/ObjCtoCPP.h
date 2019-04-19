//
//  ObjCtoCPP.h
//  sxBRZ
//
//  Created by T!T@N on 04.26.16.
//

#ifndef ObjCtoCPP_h
#define ObjCtoCPP_h

#import <Foundation/Foundation.h>

@interface xBRZC : NSObject
+ (void) scale:(size_t)factor source:(const uint32_t *)src target:(uint32_t *)trg width:(int)srcWidth height:(int)srcHeight hasAlpha:(bool) hasAlpha;
@end

#endif /* ObjCtoCPP_h */
