//
//  MLKAddUserViewController.m
//  MagicalRecordDemo
//
//  Created by Michael Kral on 3/5/13.
//  Copyright (c) 2013 Michael Kral. All rights reserved.
//

#import "MLKAddUserViewController.h"
#import "Guid.h"

@interface MLKAddUserViewController ()

@end

@implementation MLKAddUserViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    User *user = [User findFirstByAttribute:@"uid" withValue:self.userID];
    if(user){
        nameLabel.text = user.name;
        addressLabel.text = user.userDetail.address;
        occupationLabel.text = user.userDetail.occupation;
        phoneLabel.text = user.userDetail.phoneNumber;
    }
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)saveButtonPressed:(id)sender{
    
    if(nameLabel.text.length > 0){
        
        [MagicalRecord saveWithBlock:^(NSManagedObjectContext *localContext) {
            
            User *user = [User findFirstByAttribute:@"uid" withValue:self.userID inContext:localContext];

            if(!user){
                user = [User createInContext:localContext];
                UserDetail *userDetail = [UserDetail createInContext:localContext];
                user.userDetail = userDetail;
                user.uid = [Guid randomGuidString];
            }
            
            user.name = nameLabel.text;
            user.userDetail.address = addressLabel.text;
            user.userDetail.occupation = occupationLabel.text;
            user.userDetail.phoneNumber = phoneLabel.text;
            
        } completion:^(BOOL success, NSError *error) {
            
            NSLog(@"Save Complete");
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        }];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ERROR" message:@"YOU MUST ENTER A NAME" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    
}
@end
