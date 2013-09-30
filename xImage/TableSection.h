//
//  TableSection.h
//  xImage
//
//  Created by rockee on 13-5-13.
//
//

#import <Foundation/Foundation.h>

@interface TableSection : NSObject
@property(nonatomic, copy) NSString *header, *footer;
-(id) initWithCapacity:(NSUInteger)numItems;
-(void) insertObject:(id)anObject atIndex:(NSUInteger)index;
-(void) addObject:(id)anObject;
-(void) removeObject:(id) anObject;
-(NSUInteger) count;
-(id) objectAtIndex:(NSUInteger)index;
-(void) removeAllObjects;
@end

