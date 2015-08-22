//
//  NSUserDefaults+METodoListItems.m
//  TodoList
//
//  Created by Magnus Eriksson on 22/08/2015.
//  Copyright (c) 2015 MagnusEriksson. All rights reserved.
//

#import "NSUserDefaults+METodoListItems.h"

#define MEUserDefaultKeyCompletedItems @"MEUserDefaultKeyCompletedItems"
#define MEUserDefaultKeyIncompleteItems @"MEUserDefaultKeyIncompleteItems"

@implementation NSUserDefaults (METodoListItems)

#pragma mark - Public API

+(NSArray*)completedTodoItems
{
    NSArray *archivedItems = [[NSUserDefaults standardUserDefaults] objectForKey:MEUserDefaultKeyCompletedItems];
    return [self regularItemsFromArchivedItems:archivedItems];
}

+(NSArray*)incompletedTodoItems
{
    NSArray *archivedItems = [[NSUserDefaults standardUserDefaults] objectForKey:MEUserDefaultKeyIncompleteItems];
    return [self regularItemsFromArchivedItems:archivedItems];
}

+(void)updateCompletedTodoItems:(NSArray*)completedItems
{
    NSArray *archivedItems = [self archivedItemsFromRegularItems:completedItems];
    [[NSUserDefaults standardUserDefaults] setObject:archivedItems forKey:MEUserDefaultKeyCompletedItems];
}

+(void)updateIncompetedTodoItems:(NSArray*)incompletedItems
{
    NSArray *archivedItems = [self archivedItemsFromRegularItems:incompletedItems];
    [[NSUserDefaults standardUserDefaults] setObject:archivedItems forKey:MEUserDefaultKeyIncompleteItems];
}

#pragma mark - Private API

+(NSArray*)archivedItemsFromRegularItems:(NSArray*)items
{
    NSMutableArray *archivedItems = [NSMutableArray arrayWithCapacity:items.count];
    for (id item in items) {
        NSData *archivedItem = [NSKeyedArchiver archivedDataWithRootObject:item];
        [archivedItems addObject:archivedItem];
    }
    
    return archivedItems;
}

+(NSArray*)regularItemsFromArchivedItems:(NSArray*)archivedItems
{
    NSMutableArray *regularItems = [NSMutableArray arrayWithCapacity:archivedItems.count];
    for (NSData *data in archivedItems){
        id item = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        [regularItems addObject:item];
    }
    
    return regularItems;
}

@end
