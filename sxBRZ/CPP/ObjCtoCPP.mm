//
//  ObjCtoCPP.mm
//  sxBRZ
//
//  Created by T!T@N on 04.26.16.
//

#import "ObjCtoCPP.h"
#import "xbrz.h"

@implementation xBRZC

+ (void) scale:(size_t)factor source:(const uint32_t *)src target:(uint32_t *)trg width:(int)srcWidth height:(int)srcHeight hasAlpha:(bool) hasAlpha
{
    xbrz::scale(factor, src, trg, srcWidth, srcHeight, hasAlpha ? xbrz::ColorFormat::ARGB : xbrz::ColorFormat::RGB);
}
@end