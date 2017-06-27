//
//  OSTRunnerTrackerViewController.m
//  OST Tracker
//
//  Created by Luciano Castro on 6/13/17.
//  Copyright © 2017 OST. All rights reserved.
//

#import "OSTRunnerTrackerViewController.h"
#import "EntryModel.h"
#import "CurrentCourse.h"
#import "OSTSessionManager.h"
#import "EffortModel.h"
#import "UIView+Additions.h"

@interface OSTRunnerTrackerViewController ()

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblTime;
@property (strong, nonatomic) NSTimer * timer;
@property (weak, nonatomic) IBOutlet UISwitch *swchPaser;
@property (weak, nonatomic) IBOutlet UIButton *btnLeft;
@property (weak, nonatomic) IBOutlet UIButton *btnRight;
@property (weak, nonatomic) IBOutlet UISwitch *swchStoppedHere;
@property (weak, nonatomic) IBOutlet UIView *pacerAndAidView;
@property (strong, nonatomic) NSString * splitId;
@property (weak, nonatomic) IBOutlet UILabel *lblOutTimeBadge;
@property (weak, nonatomic) IBOutlet UILabel *lblInTimeBadge;
@property (weak, nonatomic) IBOutlet UILabel *lblRunnerInfo;
@property (strong, nonatomic) NSString * dayString;
@property (strong, nonatomic) EffortModel * racer;
@property (assign, nonatomic) CGRect originalLeftBtnFrame;
@property (assign, nonatomic) CGRect originalRightBtnFrame;
@property (strong, nonatomic) NSDate * entryDateTime;

@end

@implementation OSTRunnerTrackerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.timer = [NSTimer scheduledTimerWithTimeInterval: 0.5
                                                              target: self
                                                            selector:@selector(onTick:)
                                                            userInfo: nil repeats:YES];
    
    self.splitId = [CurrentCourse getCurrentCourse].splitId;
    
    if (IS_IPHONE_5)
    {
        self.pacerAndAidView.top = self.pacerAndAidView.top - 25;
        self.btnLeft.top = self.btnLeft.top - 55;
        self.btnRight.top = self.btnRight.top - 55;
        self.lblInTimeBadge.top = self.lblOutTimeBadge.top = self.lblOutTimeBadge.top - 55;
    }
    
    self.lblOutTimeBadge.layer.cornerRadius = self.lblOutTimeBadge.width/2;
    self.lblInTimeBadge.layer.cornerRadius = self.lblInTimeBadge.width/2;
    self.lblOutTimeBadge.clipsToBounds = YES;
    self.lblInTimeBadge.clipsToBounds = YES;
    
    self.lblOutTimeBadge.hidden = YES;
    self.lblInTimeBadge.hidden = YES;
}

-(void)onTick:(NSTimer *)timer
{
    NSDate * date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    self.lblTime.text = [dateFormatter stringFromDate:date];
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    self.dayString = [dateFormatter stringFromDate:date];
    
    self.entryDateTime = date;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.txtBibNumber becomeFirstResponder];
    self.lblTitle.text = [CurrentCourse getCurrentCourse].splitName;
    
    if (CGRectIsEmpty(self.originalLeftBtnFrame))
    {
        self.originalLeftBtnFrame = self.btnLeft.frame;
    }
    
    if (CGRectIsEmpty(self.originalRightBtnFrame))
    {
        self.originalRightBtnFrame = self.btnRight.frame;
    }
    
    self.btnLeft.frame = self.originalLeftBtnFrame;
    self.btnRight.frame = self.originalRightBtnFrame;
    
    NSArray * entries = [CurrentCourse getCurrentCourse].splitAttributes[@"entries"];
    
    NSArray * splitEntriesIn = [entries filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"subSplitKind == %@",@"in"]];
    NSArray * splitEntriesOut = [entries filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"subSplitKind == %@",@"out"]];
    
    if (splitEntriesIn.count != 0 && splitEntriesOut.count == 0)
    {
        self.btnLeft.width = self.btnRight.right - self.btnLeft.left;
        self.btnRight.hidden = YES;
        
        [self.btnLeft setTitle:splitEntriesIn[0][@"label"] forState:UIControlStateNormal];
    }
    if (splitEntriesIn.count == 0 && splitEntriesOut.count != 0)
    {
        self.btnRight.width = self.btnRight.right - self.btnLeft.left;
        self.btnLeft.hidden = YES;
        self.btnRight.left = self.btnLeft.left;
        
        [self.btnRight setTitle:splitEntriesOut[0][@"label"] forState:UIControlStateNormal];
    }
    else if(splitEntriesIn.count != 0 && splitEntriesOut.count != 0)
    {
        self.btnRight.hidden = NO;
        self.btnLeft.hidden = NO;
        
        self.btnRight.frame = self.originalRightBtnFrame;
        self.btnLeft.frame = self.originalLeftBtnFrame;
        
        [self.btnLeft setTitle:splitEntriesIn[0][@"label"] forState:UIControlStateNormal];
        [self.btnRight setTitle:splitEntriesOut[0][@"label"] forState:UIControlStateNormal];
    }
    
    self.lblInTimeBadge.right = self.btnLeft.right - 5;
}

- (IBAction)onRight:(id)sender
{
    [self.txtBibNumber resignFirstResponder];
    [[AppDelegate getInstance].rightMenuVC showRightMenu:YES];
}

- (IBAction)onEntryButton:(id)sender
{
    CurrentCourse * course = [CurrentCourse MR_findFirst];

    EntryModel * entry = [EntryModel MR_createEntity];
    
    if (self.txtBibNumber.text.length == 0)
    {
        entry.bibNumber = @"-1";
    }
    else entry.bibNumber = self.txtBibNumber.text;
    if (sender == self.btnLeft)
        entry.bitKey = @"in";
    else entry.bitKey = @"out";
    entry.splitId = self.splitId;
    int timezoneoffset = (int)([[NSTimeZone systemTimeZone] secondsFromGMT])/60/60;
    entry.absoluteTime = [NSString stringWithFormat:@"%@ %@%02d:00",self.dayString, self.lblTime.text,timezoneoffset];
    entry.displayTime = self.lblTime.text;
    if (self.swchPaser.on)
        entry.withPacer = @"true";
    else entry.withPacer = @"false";
    if (self.swchStoppedHere.on)
        entry.stoppedHere = @"true";
    else entry.stoppedHere = @"false";
    
    entry.courseName = course.eventName;
    entry.splitName = course.splitName;
    entry.courseId = course.eventId;
    entry.splitId = course.splitId;
    entry.entryTime = self.entryDateTime;
    
    entry.timeEntered = [NSDate date];
    
    if (self.racer)
    {
        entry.fullName = self.racer.fullName;
    }
    
    entry.source = [NSString stringWithFormat:@"ost-remote-%@",[OSTSessionManager getUUIDString]];
    
    [[NSManagedObjectContext MR_defaultContext] processPendingChanges];
    [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
    
    self.txtBibNumber.text = @"";
    self.swchPaser.on = NO;
    self.swchStoppedHere.on = NO;
    
    [self txtBibNumberChanged:nil];
}

- (IBAction)txtBibNumberChanged:(id)sender
{
    self.lblOutTimeBadge.hidden = YES;
    self.lblInTimeBadge.hidden = YES;
    self.racer = nil;
    self.lblRunnerInfo.textColor = [UIColor darkGrayColor];
    if (self.txtBibNumber.text.length == 0)
    {
        self.lblRunnerInfo.text = @"Add Bib Number to search for runner";
    }
    else
    {
        EffortModel * effort = [EffortModel MR_findFirstWithPredicate:[NSPredicate predicateWithFormat:@"bibNumber == %@", [NSDecimalNumber decimalNumberWithString:self.txtBibNumber.text]]];
        
        if (effort)
        {
            self.lblRunnerInfo.text = [NSString stringWithFormat:@"Bib Found: %@",effort.fullName];
            self.racer = effort;
            
            if ([[EntryModel MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"bitKey == %@ && bibNumber == %@ && courseId == %@ && splitId == %@",@"in",self.txtBibNumber.text,[CurrentCourse getCurrentCourse].eventId,[CurrentCourse getCurrentCourse].splitId]] count])
            {
                self.lblInTimeBadge.hidden = NO;
                if ([CurrentCourse getCurrentCourse].multiLap.boolValue)
                {
                    self.lblInTimeBadge.text = [NSString stringWithFormat:@"%ld",[[EntryModel MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"bitKey == %@ && bibNumber == %@ && courseId == %@ && splitId == %@",@"in",self.txtBibNumber.text,[CurrentCourse getCurrentCourse].eventId,[CurrentCourse getCurrentCourse].splitId]] count]];
                }
                else
                {
                    self.lblInTimeBadge.text = @"!";
                }
            }
            
            if ([[EntryModel MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"bitKey == %@ && bibNumber == %@ && courseId == %@ && splitId == %@",@"out",self.txtBibNumber.text,[CurrentCourse getCurrentCourse].eventId,[CurrentCourse getCurrentCourse].splitId]] count])
            {
                self.lblOutTimeBadge.hidden = NO;
                if ([CurrentCourse getCurrentCourse].multiLap.boolValue)
                {
                    self.lblOutTimeBadge.text =  [NSString stringWithFormat:@"%ld",[[EntryModel MR_findAllWithPredicate:[NSPredicate predicateWithFormat:@"bitKey == %@ && bibNumber == %@ && courseId == %@ && splitId == %@",@"out",self.txtBibNumber.text,[CurrentCourse getCurrentCourse].eventId,[CurrentCourse getCurrentCourse].splitId]] count]];
                }
                else
                {
                    self.lblOutTimeBadge.text = @"!";
                }
            }

        }
        else
        {
            self.lblRunnerInfo.text = @"Bib Not Found";
            self.lblRunnerInfo.textColor = [UIColor redColor];
        }
    }
}

@end
