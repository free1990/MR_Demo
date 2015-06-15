//
//  MLKAddUserViewController.h
//  MagicalRecordDemo
//
//  Created by Michael Kral on 3/5/13.
//  Copyright (c) 2013 Michael Kral. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserDetail.h"
#import "User.h"

@interface MLKAddUserViewController : UIViewController {
    IBOutlet UITextField *nameLabel;
    IBOutlet UITextField *addressLabel;
    IBOutlet UITextField *occupationLabel;
    IBOutlet UITextField *phoneLabel;
    
}

@property(nonatomic, strong) NSString *userID;
-(IBAction)saveButtonPressed:(id)sender;
@end
