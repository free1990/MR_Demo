//
//  MLKViewController.m
//  MagicalRecordDemo
//
//  Created by Michael Kral on 3/5/13.
//  Copyright (c) 2013 Michael Kral. All rights reserved.
//

#import "MLKViewController.h"
#import "MLKAddUserViewController.h"
@interface MLKViewController ()

@end

@implementation MLKViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    User *user = [User findFirstByAttribute:@"uid" withValue:self.userID];
    
    userNameLabel.text = user.name;
    addressLabel.text = user.userDetail.address;
    occupationLabel.text = user.userDetail.occupation;
    phoneLabel.text = user.userDetail.phoneNumber;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"EditUserSegue"]){
        MLKAddUserViewController * vc = segue.destinationViewController;
        vc.userID = self.userID;
    }
}
-(void)editUserPressed:(id)sender{
    [self performSegueWithIdentifier:@"EditUserSegue" sender:self];
}
@end
