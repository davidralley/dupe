//
//  ViewController.m
//  dupe
//
//  Created by david on 10/10/15.
//  Copyright © 2015 Trance. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self loadContactData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//----------------------------------------------------------------------------------
//  loadContactData
//----------------------------------------------------------------------------------
//load the contact data from the leads.json file
-(void)loadContactData{
    
    NSBundle* theBundle = [NSBundle mainBundle];
    NSString* path = [theBundle pathForResource:@"leads" ofType:@"json"];
    NSData *theReceivedData;
    
    
    if([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        theReceivedData = [[NSFileManager defaultManager] contentsAtPath:path];
    }
        else
    {
        NSLog(@"File does not exist");
    }
    
    //serialize the NSData into an NSDictionary
    self.contactDictionary = [NSJSONSerialization JSONObjectWithData:theReceivedData options:(NSJSONReadingMutableLeaves + NSJSONReadingMutableContainers) error:nil];
    //NSLog(@"dictionary data %@",self.contactDictionary);
    
    //we want to keep the most recent duplicate, so first reverse the list:
    NSMutableArray*    theContactArray = self.contactDictionary[@"leads"];
    self.contactDictionary[@"leads"] = [[[theContactArray reverseObjectEnumerator] allObjects] mutableCopy];
    //NSLog(@"dictionary data %@",self.contactDictionary);
    
    [self eliminateDuplicateIDsFromData];
    [self eliminateDuplicateEmailsFromData];
    
    //then reverse the array again, so it's sorted by date again
    theContactArray = self.contactDictionary[@"leads"];
    self.contactDictionary[@"leads"] = [[[theContactArray reverseObjectEnumerator] allObjects] mutableCopy];
    
    //tell the table in the UI to refresh with the new data
    [self.contactTable reloadData];
}

//----------------------------------------------------------------------------------
//  eliminateDuplicateIDsFromData
//----------------------------------------------------------------------------------
//find the duplicate IDs in the incoming data, and filter them out
-(void)eliminateDuplicateIDsFromData{
    
    NSMutableSet *seenIDs = [NSMutableSet set];
    
    //get the array of the leads
    NSMutableArray*    theContactArray = self.contactDictionary[@"leads"];
    
    //construct a predicate that will find duplicates
    NSPredicate *dupIDsPred = [NSPredicate predicateWithBlock: ^BOOL(id obj, NSDictionary *bind) {
        NSDictionary*    theNameDictionary = (NSDictionary*)obj;
        NSString*        theID = [theNameDictionary objectForKey:@"_id"];
        BOOL seen = [seenIDs containsObject:theID];
        if (!seen) {
            [seenIDs addObject:theID];
            }
        else{
            NSLog(@"record with duplicate id: %@",theNameDictionary);
        }
        return !seen;
    }];
    
    [theContactArray filterUsingPredicate:dupIDsPred];
    //NSLog(@"dictionary data %@",self.contactDictionary);
    
}

//----------------------------------------------------------------------------------
//  eliminateDuplicateEmailsFromData
//----------------------------------------------------------------------------------
//find the duplicate email addresses in the incoming data, and filter them out
-(void)eliminateDuplicateEmailsFromData{
    
    NSMutableSet *seenIDs = [NSMutableSet set];
    
    //get the array of the leads
    NSMutableArray*    theContactArray = self.contactDictionary[@"leads"];
    
    //construct a predicate that will find duplicates
    NSPredicate *dupIDsPred = [NSPredicate predicateWithBlock: ^BOOL(id obj, NSDictionary *bind) {
        NSDictionary*    theNameDictionary = (NSDictionary*)obj;
        NSString*        theID = [theNameDictionary objectForKey:@"email"];
        BOOL seen = [seenIDs containsObject:theID];
        if (!seen) {
            [seenIDs addObject:theID];
        }
        else{
            NSLog(@"record with duplicate email: %@",theNameDictionary);
        }

        return !seen;
    }];
    
    [theContactArray filterUsingPredicate:dupIDsPred];
    //NSLog(@"dictionary data %@",self.contactDictionary);
    
}

#pragma mark table data routines

//—————————————————————————————————————————————————————————————————————————————————————————————
//                  numberOfRowsInSection
//—————————————————————————————————————————————————————————————————————————————————————————————
// tableview delegate function that provides the number of rows in the table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray*    theContactArray = self.contactDictionary[@"leads"];
    NSInteger theRowCount = [theContactArray count];
    
    return theRowCount;
}


//—————————————————————————————————————————————————————————————————————————————————————————————
//                  cellForRowAtIndexPath
//—————————————————————————————————————————————————————————————————————————————————————————————
//  provide the content for the specified table cell.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"leads";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NSArray*    theContactArray = self.contactDictionary[@"leads"];
    NSDictionary*    theNameDictionary = theContactArray[indexPath.row];
    
    NSString* firstName = [theNameDictionary objectForKey:@"firstName"];
    NSString* LastName = [theNameDictionary objectForKey:@"lastName"];
    NSString* email = [theNameDictionary objectForKey:@"email"];
    NSString* address = [theNameDictionary objectForKey:@"address"];
    
//    //get the day of the week as a string
     //NSTimeInterval theUNIXDate = [theDailyForecast[@"dt"] doubleValue];
    NSTimeInterval theUNIXDate = [theNameDictionary [@"entryDate"] doubleValue];
    NSDate *theDate = [NSDate dateWithTimeIntervalSince1970:theUNIXDate];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"EEEE"];
    NSString* theDayOfTheWeek = [formatter stringFromDate:theDate];
    
    //NSString* firstName = @"foo";;
//    NSString* LastName = @"bar";
//    NSString* email = @"me@me.com";
//    NSString* address = @"address";
    
    UILabel *theFirstName = (UILabel *)[cell viewWithTag:100];
    theFirstName.text = firstName;
    UILabel *theLastName = (UILabel *)[cell viewWithTag:200];
    theLastName.text = LastName;

    UILabel *theEmailAddress = (UILabel *)[cell viewWithTag:300];
    theEmailAddress.text = email;
    
    UILabel *theAddress = (UILabel *)[cell viewWithTag:400];
    theAddress.text = address;
    
    return cell;
}

@end
