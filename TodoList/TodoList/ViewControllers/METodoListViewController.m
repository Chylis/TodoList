//
//  METodoListViewController.h
//  TodoList
//
//  Created by Magnus Eriksson on 21/08/2015.
//  Copyright (c) 2015 MagnusEriksson. All rights reserved.
//

#import "METodoListViewController.h"
#import "MEAddTodoItemViewController.h"

#import "METodoListItem.h"

#import "METodoListItemTableViewCell.h"

typedef NS_ENUM(NSInteger, METodoListSection)
{
    METodoListSectionIncompleted = 0,
    METodoListSectionCompleted,
    METodoListSectionCount
};

@interface METodoListViewController () <UITableViewDataSource, UITableViewDelegate, MEAddTodoItemViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray *completedItems; //Array of METodoListItem
@property (strong, nonatomic) NSMutableArray *incompletedItems; //Array of METodoListItem
@property (strong, nonatomic) NSIndexPath *itemReorderDestinationIndexPath;

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
    //Prepare for self sizing cells
    static const int DefaultRowHeight = 44;
    self.tableView.estimatedRowHeight = DefaultRowHeight;
    
    //Register Cell
    NSString *cellId = NSStringFromClass([METodoListItemTableViewCell class]);
    UINib *nib = [UINib nibWithNibName:cellId bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:cellId];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self observeTodoItemUpdates];
}

-(void)observeTodoItemUpdates
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(METodoItemWasUpdated:)
                                                 name:NOTIFICATION_METodoListItemDidToggleCompleted
                                               object:nil];;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return section == METodoListSectionIncompleted ? @"To do" : @"Completed";
}

#pragma mark - UITableViewDelegate

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    METodoListItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([METodoListItemTableViewCell class]) forIndexPath:indexPath];
    cell.showsReorderControl = YES;
    
    switch (indexPath.section) {
        case METodoListSectionIncompleted:
            [self configureIncompleteTodoListItemCell:cell atIndexPath:indexPath];
            break;
        case METodoListSectionCompleted:
            [self configureCompletedTodoListItemCell:cell atIndexPath:indexPath];
            break;
        default:
            break;
    }
    
    return cell;
}

-(void)configureIncompleteTodoListItemCell:(METodoListItemTableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    METodoListItem *item = [self itemAtIndexPath:indexPath];
    cell.titleLabel.text = item.title;
    cell.createdLabel.text = [item.created description];
    cell.descLabel.text = item.desc;
    cell.accessoryType = UITableViewCellAccessoryNone;
}

-(void)configureCompletedTodoListItemCell:(METodoListItemTableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    METodoListItem *item = [self itemAtIndexPath:indexPath];
    cell.titleLabel.text = item.title;
    cell.createdLabel.text = [item.created description];
    cell.descLabel.text = item.desc;
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSMutableArray *datasource = [self datasourceFromSection:fromIndexPath.section];
    METodoListItem *item = [datasource objectAtIndex:fromIndexPath.row];
    
    if (fromIndexPath.section == toIndexPath.section){
        //Item moved within same section - update underlying model location
        [datasource removeObjectAtIndex:fromIndexPath.row];
        [datasource insertObject:item atIndex:toIndexPath.row];
    } else {
        //Item moved to different section - save destination indexpath and toggle completed property
        self.itemReorderDestinationIndexPath = toIndexPath;
        item.completed = !item.completed;
    }
}

-(NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL itemIsCompleted = indexPath.section == METodoListSectionCompleted;
    UITableViewRowAction *toggleSectionAction = [self actionToggleItemCompleted:itemIsCompleted];
    UITableViewRowAction *deleteItemAction = [self actionDeleteItemFromIndexPath:indexPath];
    
    return @[deleteItemAction, toggleSectionAction];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Implemented to enable tableviewcell-swiping
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView setEditing:!tableView.editing animated:YES];
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:NSStringFromClass([MEAddTodoItemViewController class])]){
        UINavigationController *destVc = segue.destinationViewController;
        MEAddTodoItemViewController *addItemVc = (MEAddTodoItemViewController*)destVc.topViewController;
        addItemVc.delegate = self;
    }
}

#pragma mark - MEAddTodoItemViewControllerDelegate

-(void)MEAddTodoItemViewController:(MEAddTodoItemViewController *)vc didCreateItem:(METodoListItem *)item
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [vc.presentingViewController dismissViewControllerAnimated:YES completion:^{
            [self addItem:item toSection:METodoListSectionIncompleted];
        }];
    });
}

-(void)MEAddTodoItemViewControllerDidCancelItemCreation:(MEAddTodoItemViewController *)vc
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [vc.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    });
}

#pragma mark - Helpers

-(void)deleteItem:(METodoListItem*)item fromSection:(NSInteger)section
{
    //Update data source
    NSMutableArray *datasource = [self datasourceFromSection:section];
    NSUInteger row = [datasource indexOfObject:item];
    [datasource removeObject:item];
    
    if ([self.tableView numberOfRowsInSection:section] != datasource.count){
        //Model-view mismatch - update view
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

-(void)addItem:(METodoListItem*)item toSection:(NSInteger)section
{
    NSMutableArray *datasource = [self datasourceFromSection:section];
    [self insertItem:item intoIndexPath:[NSIndexPath indexPathForRow:datasource.count inSection:section]];
}

-(void)insertItem:(METodoListItem*)item intoIndexPath:(NSIndexPath*)indexPath
{
    //Update data source
    NSMutableArray *datasource = [self datasourceFromSection:indexPath.section];
    [datasource insertObject:item atIndex:indexPath.row];
    
    if ([self.tableView numberOfRowsInSection:indexPath.section] != datasource.count){
        //Model-view mismatch - update view
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

-(METodoListItem*)itemAtIndexPath:(NSIndexPath*)indexPath
{
    NSArray *datasource = [self datasourceFromSection:indexPath.section];
    return [datasource objectAtIndex:indexPath.item];
}

-(NSMutableArray*)datasourceFromSection:(NSInteger)section
{
    return section == METodoListSectionIncompleted ? self.incompletedItems : self.completedItems;
}

-(UITableViewRowAction*)actionToggleItemCompleted:(BOOL)itemIsCompleted
{
    NSString *actionTitle = itemIsCompleted ? @"Undo" : @"Done";
    
    return [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal
                                              title:actionTitle
                                            handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                METodoListItem *item = [self itemAtIndexPath:indexPath];
                                                item.completed = !item.completed;
                                            }];
}

-(UITableViewRowAction*)actionDeleteItemFromIndexPath:(NSIndexPath*)indexPath
{
    return [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive
                                              title:@"Delete"
                                            handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
                                                METodoListItem *item = [self itemAtIndexPath:indexPath];
                                                [self deleteItem:item fromSection:indexPath.section];
                                            }];
}

/*
 - Triggered when the 'METodoItem.completed' property is updated
 - Moves the cell from one section to the other, depending on the 'item.completed' value
 */
-(void)METodoItemWasUpdated:(NSNotification*)notification
{
    METodoListItem *item = notification.object;
    NSInteger sourceSection = item.completed ? METodoListSectionIncompleted : METodoListSectionCompleted;
    NSInteger destinationSection = item.completed ? METodoListSectionCompleted : METodoListSectionIncompleted;
    
    [self.tableView beginUpdates];
    
    //Remove item from source section
    [self deleteItem:item fromSection:sourceSection];
    
    if (self.itemReorderDestinationIndexPath){
        //User dragged item to new section - Insert item in specified indexpath
        [self insertItem:item intoIndexPath:self.itemReorderDestinationIndexPath];
        self.itemReorderDestinationIndexPath = nil;
    } else {
        //User toggled item.complete - append item to destination section
        [self addItem:item toSection:destinationSection];
    }
    
    [self.tableView endUpdates];
}


@end
