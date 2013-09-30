//
//  TableSection.m
//  xImage
//
//  Created by rockee on 13-5-13.
//
//

#import "TableSection.h"

@interface TableSection(){
    NSString *_header, *_footer;
    NSMutableArray *cells;
}

@end

@implementation TableSection
@synthesize header = _header, footer = _footer;
-(id) initWithCapacity:(NSUInteger)numItems
{
    self = [super init];
    if(self)
    {
        cells = [[NSMutableArray alloc] initWithCapacity:numItems];
    }
    return self;
}

-(void)dealloc
{
    [cells release];
    [_header release];
    [_footer release];
    [super dealloc];
}

-(void) insertObject:(id)anObject atIndex:(NSUInteger)index{
    [cells insertObject:anObject atIndex:index];
}

- (void)addObject:(id)anObject
{
    [cells addObject:anObject];
}

-(void) removeObject:(id) anObject
{
    [cells removeObject:anObject];
}

- (NSUInteger)count
{
    return [cells count];
}

- (id)objectAtIndex:(NSUInteger)index
{
    return [cells objectAtIndex:index];
}

-(void) removeAllObjects
{
    [cells removeAllObjects];
}
@end