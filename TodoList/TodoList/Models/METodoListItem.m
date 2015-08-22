//
//  METodoListItem.m
//  TodoList
//
//  Created by Magnus Eriksson on 21/08/2015.
//  Copyright (c) 2015 MagnusEriksson. All rights reserved.
//

#import "METodoListItem.h"

@implementation METodoListItem

#pragma mark - Properties

-(void)setCompleted:(BOOL)completed
{
    _completed = completed;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_METodoListItemDidToggleCompleted object:self];
}

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.content forKey:NSStringFromSelector(@selector(content))];
    [aCoder encodeObject:@(self.completed) forKey:NSStringFromSelector(@selector(completed))];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self){
        self.content = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(content))];
        self.completed = [[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(completed))] boolValue];
    }
    return self;
}


@end
