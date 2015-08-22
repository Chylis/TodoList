//
//  METodoListItem.h
//  TodoList
//
//  Created by Magnus Eriksson on 21/08/2015.
//  Copyright (c) 2015 MagnusEriksson. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NOTIFICATION_METodoListItemDidToggleCompleted @"NOTIFICATION_METodoListItemDidToggleCompleted"

@interface METodoListItem : NSObject <NSCoding>

@property (strong, nonatomic) NSString *content;
@property (nonatomic) BOOL completed;

//NSCoding
- (void)encodeWithCoder:(NSCoder *)aCoder;
- (id)initWithCoder:(NSCoder *)aDecoder;

@end
