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
    [aCoder encodeObject:self.title forKey:NSStringFromSelector(@selector(title))];
    [aCoder encodeObject:self.desc forKey:NSStringFromSelector(@selector(desc))];
    [aCoder encodeObject:self.created forKey:NSStringFromSelector(@selector(created))];
    [aCoder encodeObject:@(self.completed) forKey:NSStringFromSelector(@selector(completed))];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self){
        self.title = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(title))];
        self.desc = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(desc))];
        self.created = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(created))];
        self.completed = [[aDecoder decodeObjectForKey:NSStringFromSelector(@selector(completed))] boolValue];
    }
    return self;
}


@end
