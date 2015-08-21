//
//  METodoListItem.h
//  TodoList
//
//  Created by Magnus Eriksson on 21/08/2015.
//  Copyright (c) 2015 MagnusEriksson. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NOTIFICATION_METodoListItemDidToggleCompleted @"NOTIFICATION_METodoListItemDidToggleCompleted"

@interface METodoListItem : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *desc;
@property (strong, nonatomic) NSDate *created;
@property (nonatomic) BOOL completed;

@end
