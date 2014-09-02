//  ViewController.m
//  MyLRU
//
//  Created by Frederick C. Lee on 8/27/14.
//  Copyright (c) 2014 Amourine Technologies. All rights reserved.
// -----------------------------------------------------------------------------------------------------------------------

#import "ViewController.h"
#import "RicCache.h"



@interface ViewController()
@property (strong, nonatomic) NSArray *arrayItems;
@property (strong, nonatomic) RicCache *ricCache;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.arrayItems = @[@"One",@"Two",@"Three",@"Four",@"Five",@"Six",@"Seven",@"Eight",@"Nine",@"Ten"];
    self.ricCache = [[RicCache alloc] initWithName:@"myCache"];
}

// -----------------------------------------------------------------------------------------------------------------------


- (void)viewWillAppear:(BOOL)animated {
//    self.arrayItems = [_ricCache getCachedArrayItems];
}

// -----------------------------------------------------------------------------------------------------------------------

- (void)viewWillDisappear:(BOOL)animated {
    [_ricCache cachedArrayItems:self.arrayItems];
    [super viewWillDisappear:animated];
}

// -----------------------------------------------------------------------------------------------------------------------
#pragma mark - Action methods

- (IBAction)cacheSomething:(UIButton *)sender {
    [_ricCache cachedArrayItems:self.arrayItems];
}

// -----------------------------------------------------------------------------------------------------------------------

- (IBAction)retrieveCache:(UIButton *)sender {
    self.arrayItems = [_ricCache getCachedArrayItems];
}

// -----------------------------------------------------------------------------------------------------------------------

- (IBAction)exitButton:(id)sender {
    exit(0);
}

// -----------------------------------------------------------------------------------------------------------------------

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [_ricCache clearCache];
}

@end
