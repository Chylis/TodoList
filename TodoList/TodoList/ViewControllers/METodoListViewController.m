//
//  METodoListViewController.h
//  TodoList
//
//  Created by Magnus Eriksson on 21/08/2015.
//  Copyright (c) 2015 MagnusEriksson. All rights reserved.
//

#import "METodoListViewController.h"

#import "METodoListItem.h"

typedef NS_ENUM(NSInteger, METodoListSection)
{
    METodoListSectionIncompleted = 0,
    METodoListSectionCompleted,
    METodoListSectionCount
};

@interface METodoListViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *completedItems; //List of METodoListItem
@property (strong, nonatomic) NSMutableArray *incompletedItems; //List of METodoListItem

@end

@implementation METodoListViewController

#pragma mark - Life cycle / Setup

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupTableView];
}

-(void)setupTableView
{
#warning implement
}



#pragma mark - Properties

-(NSMutableArray*)completedItems
{
#warning load from storage
    if (!_completedItems){
        _completedItems = [NSMutableArray new];
    }
    return _completedItems;
}

-(NSMutableArray*)incompletedItems
{
#warning load from storage
    if (!_incompletedItems){
        _incompletedItems = [NSMutableArray new];
    }
    return _incompletedItems;
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return METodoListSectionCount;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case METodoListSectionIncompleted:      return self.incompletedItems.count;
        case METodoListSectionCompleted:        return self.completedItems.count;
        default:                                return 0;
    }
}

#pragma mark - UITableViewDelegate

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
#warning - implement
    return [UITableViewCell new];
}


@end
