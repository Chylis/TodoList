//
//  METodoListItem.m
//  TodoList
//
//  Created by Magnus Eriksson on 21/08/2015.
//  Copyright (c) 2015 MagnusEriksson. All rights reserved.
//

#import "METodoListItem.h"

@implementation METodoListItem

-(void)setCompleted:(BOOL)completed
{
    _completed = completed;
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_METodoListItemDidToggleCompleted object:self];
}

@end
