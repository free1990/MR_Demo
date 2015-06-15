//
//  MLKUserTableViewController.h
//  MagicalRecordDemo
//
//  Created by Michael Kral on 3/5/13.
//  Copyright (c) 2013 Michael Kral. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MLKUserTableViewController : UITableViewController {
    NSArray *users;
    BOOL editing;
}

-(IBAction)addUserPressed:(id)sender;
-(IBAction)editButtonPressed:(id)sender;
@end
