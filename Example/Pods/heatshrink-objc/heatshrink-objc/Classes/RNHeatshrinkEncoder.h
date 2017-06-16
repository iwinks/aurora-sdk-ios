//
//  RNHeatshrinkEncoder.h
//  Pods
//
//  Created by Rafael Nobre on 06/05/17.
//
//

#import <Foundation/Foundation.h>

@interface RNHeatshrinkEncoder : NSObject
    
- (instancetype)initWithWindowSize:(NSInteger)windowBitSize andLookaheadSize:(NSInteger)lookaheadBitSize;
    
- (NSData *)encodeData:(NSData *)dataToEncode;

@end
