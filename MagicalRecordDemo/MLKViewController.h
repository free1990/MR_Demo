//
//  MLKViewController.h
//  MagicalRecordDemo
//
//  Created by Michael Kral on 3/5/13.
//  Copyright (c) 2013 Michael Kral. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "UserDetail.h"

@interface MLKViewController : UIViewController {

    IBOutlet UILabel *userNameLabel;
    IBOutlet UILabel *addressLabel;
    IBOutlet UILabel *occupationLabel;
    IBOutlet UILabel *phoneLabel;
    
}

@property(nonatomic, strong) NSString *userID;

-(id)initWithUserID:(NSString*)userID;

-(IBAction)editUserPressed:(id)sender;

@end
