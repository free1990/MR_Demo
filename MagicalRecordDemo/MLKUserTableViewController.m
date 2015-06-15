//
//  MLKUserTableViewController.m
//  MagicalRecordDemo
//
//  Created by Michael Kral on 3/5/13.
//  Copyright (c) 2013 Michael Kral. All rights reserved.
//

#import "MLKUserTableViewController.h"
#import "MLKViewController.h"
#import "User.h"
#import "UserDetail.h"

@interface MLKUserTableViewController ()

@end

@implementation MLKUserTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    editing = NO;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    users = [User findAll];
    [self.tableView reloadData];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addUserPressed:(id)sender{
    [self performSegueWithIdentifier:@"AddUserSegue" sender:self];
}
-(void)editButtonPressed:(id)sender{
    editing = !editing;
    
    self.tableView.editing = editing;
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        
    }
    // Configure the cell...
    User *user = [users objectAtIndex:indexPath.row];
    cell.textLabel.text = user.name;
    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        NSString *userIDToDelete = [(User*)[users objectAtIndex:indexPath.row] uid];
        
        NSMutableArray *updatedUsers = users.mutableCopy;
        
        [updatedUsers removeObjectAtIndex:indexPath.row];
        
        users = updatedUsers;
        
        [tableView beginUpdates];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [tableView endUpdates];
        
       
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            User *userToDelete = [User findFirstByAttribute:@"uid" withValue:userIDToDelete inContext:localContext];
            
            [userToDelete deleteEntity];
        } completion:^(BOOL success, NSError *error) {
            NSLog(@"User was deleted");
        }];
        
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(User*)user{
    
    if([segue.identifier isEqualToString:@"AddUserSegue"]){
    
    }else if([segue.identifier isEqualToString:@"UserDetailSegue"]){
        MLKViewController * viewController =  segue.destinationViewController;
        viewController.userID = user.uid;

    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    User *user = [users objectAtIndex:indexPath.row];
    
    [self performSegueWithIdentifier:@"UserDetailSegue" sender:user];
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
