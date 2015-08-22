//
//  NSUserDefaults+METodoListItems.h
//  TodoList
//
//  Created by Magnus Eriksson on 22/08/2015.
//  Copyright (c) 2015 MagnusEriksson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (METodoListItems)

+(NSArray*)completedTodoItems;
+(NSArray*)incompletedTodoItems;

+(void)updateCompletedTodoItems:(NSArray*)completedItems;
+(void)updateIncompetedTodoItems:(NSArray*)incompletedItems;

@end
