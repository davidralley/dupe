//
//  ViewController.h
//  dupe
//
//  Created by david on 10/10/15.
//  Copyright © 2015 Trance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSMutableDictionary*      contactDictionary;     
@property (strong) IBOutlet UITableView* contactTable;

@end

