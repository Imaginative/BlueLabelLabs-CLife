//
//  ExportManager.m
//  CLife
//
//  Created by Jordan Gurrieri on 9/21/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "ExportManager.h"
#import "ClifeAppDelegate.h"
#import "Attributes.h"
#import "Macros.h"
#import "AuthenticationManager.h"
#import "User.h"
#import "Prescription.h"
#import "PrescriptionInstance.h"
#import "DateTimeHelper.h"
#import "CHCSV.h"

@implementation ExportManager
@synthesize frc_prescriptions           = __frc_prescriptions;
@synthesize frc_prescriptionInstances   = __frc_prescriptionInstances;

static ExportManager *sharedManager;

+ (ExportManager *) instance {
    @synchronized (self) {
        if (!sharedManager) {
            sharedManager = [[ExportManager alloc] init];
        }
        return sharedManager;
    }
}

- (void) dealloc {
    [super dealloc];
    
}

#pragma mark - Properties
- (NSFetchedResultsController *)frc_prescriptions {
//    NSString* activityName = @"ExportManager.frc_prescriptions:";
    if (__frc_prescriptions != nil) {
        return __frc_prescriptions;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    ResourceContext* resourceContext = [ResourceContext instance];
    ClifeAppDelegate* app = (ClifeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSEntityDescription *entityDescription  = [NSEntityDescription entityForName:PRESCRIPTION inManagedObjectContext:app.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:NAME ascending:YES];
    
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:resourceContext.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
    
    controller.delegate = self;
    self.frc_prescriptions = controller;
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
//        LOG_EXPORTMANAGER(1, @"%@Could not create instance of NSFetchedResultsController due to %@", activityName, [error userInfo]);
    }
    
    [controller release];
    [fetchRequest release];
    [sortDescriptor release];
    return __frc_prescriptions;
    
}

- (NSFetchedResultsController*)frc_prescriptionInstances {
//    NSString* activityName = @"ClifeHistoryViewController.frc_prescriptionInstances:";
    if (__frc_prescriptionInstances != nil) {
        return __frc_prescriptionInstances;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    ResourceContext* resourceContext = [ResourceContext instance];
    ClifeAppDelegate* app = (ClifeAppDelegate*)[[UIApplication sharedApplication]delegate];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:PRESCRIPTIONINSTANCE inManagedObjectContext:app.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:DATESCHEDULED ascending:NO];
    
    double doubleDate = [[NSDate date] timeIntervalSince1970];
    NSNumber *today = [NSNumber numberWithDouble:doubleDate];
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"%K<=%@", DATESCHEDULED, today];
    
    [fetchRequest setPredicate:predicate];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setReturnsDistinctResults:YES];
    
    NSFetchedResultsController* controller = [[NSFetchedResultsController alloc]initWithFetchRequest:fetchRequest managedObjectContext:resourceContext.managedObjectContext sectionNameKeyPath:@"scheduleDateString" cacheName:@"History"];
    
    controller.delegate = self;
    self.frc_prescriptionInstances = controller;
    
    NSError* error = nil;
    [controller performFetch:&error];
  	if (error != nil)
    {
//        NSLog(@"%@ Could not create instance of NSFetchedResultsController due to %@", activityName, [error userInfo]);
    }
    
    [controller release];
    [fetchRequest release];
    [sortDescriptor release];
    return __frc_prescriptionInstances;
    
}

#pragma mark - Initializers
- (id) init {
    self = [super init];
    
    if (self) {
        
    }
    return self;
}

#pragma mark - Instance methods
- (void)exportData {
    CHCSVWriter *writer = [[CHCSVWriter alloc] initForWritingToString];
    
    // Setup date formatter
    NSDateFormatter *dateAndTimeFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateAndTimeFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateAndTimeFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    // First write the column headers
    [writer writeLineOfFields:
     NSLocalizedString(@"ITEM", nil),
     NSLocalizedString(@"NAME", nil),
     NSLocalizedString(@"BIRTHDAY", nil),
     NSLocalizedString(@"GENDER", nil),
     NSLocalizedString(@"BLOOD TYPE", nil),
     NSLocalizedString(@"METHOD", nil),
     NSLocalizedString(@"STRENGTH", nil),
     NSLocalizedString(@"UNIT", nil),
     NSLocalizedString(@"DOSAGE", nil),
     NSLocalizedString(@"STARTS", nil),
     NSLocalizedString(@"REPEATS", nil),
     NSLocalizedString(@"OCCURS", nil),
     NSLocalizedString(@"ENDS", nil),
     NSLocalizedString(@"REASON AND NOTES", nil),
     NSLocalizedString(@"SCHEDULED", nil),
     NSLocalizedString(@"TAKEN", nil),
     NSLocalizedString(@"CONFIRMATION", nil),
     NSLocalizedString(@"NOTES", nil),
     nil];
    
    /* Next write the user profile info */
    
    // Get the user object
    ResourceContext* resourceContext = [ResourceContext instance];
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    User *user = (User*)[resourceContext resourceWithType:USER withID:authenticationManager.m_LoggedInUserID];
    
    NSDate *dateBorn = [DateTimeHelper parseWebServiceDateDouble:user.dateborn];
    [writer writeLineOfFields:
     NSLocalizedString(@"PROFILE", nil),
     user.username,
     [dateAndTimeFormatter stringFromDate:dateBorn],
     user.sex,
     user.bloodtype,
     @"",
     @"",
     @"",
     @"",
     @"",
     @"",
     @"",
     @"",
     @"",
     @"",
     @"",
     @"",
     @"",
     nil];
    
    
    /* Next write the prescription info */
    
    // Update the date time formatter to include time
    [dateAndTimeFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    for (Prescription *prescription in [self.frc_prescriptions fetchedObjects]) {
        
        // Start Date
        NSDate *dateStart;
        NSString *dateStartStr;
        if (prescription.datestart == nil) {
            dateStart = nil;
            dateStartStr = @"";
        }
        else {
            dateStart = [DateTimeHelper parseWebServiceDateDouble:prescription.datestart];
            dateStartStr = [dateAndTimeFormatter stringFromDate:dateStart];
        }
        
        // End Date
        NSDate *dateEnd;
        NSString *dateEndStr;
        if (prescription.dateend == nil) {
            dateEnd = nil;
            dateEndStr = @"";
        }
        else {
            dateEnd = [DateTimeHelper parseWebServiceDateDouble:prescription.dateend];
            dateEndStr = [dateAndTimeFormatter stringFromDate:dateEnd];
        }
        
        // Dosage
        NSString *dosageStr;
        if ([prescription.numberofdoses intValue] == 1) {
            dosageStr = [NSString stringWithFormat:@"%d %@", 1, NSLocalizedString(@"DOSE", nil)];
        }
        else {
            dosageStr = [NSString stringWithFormat:@"%d %@", [prescription.numberofdoses intValue], NSLocalizedString(@"DOSES", nil)];
        }
        
        // Repeats
        NSArray *schedulePeriodSingularArray = [NSArray arrayWithObjects:
                                            NSLocalizedString(@"HOUR", nil),
                                            NSLocalizedString(@"DAY", nil),
                                            NSLocalizedString(@"WEEK", nil),
                                            NSLocalizedString(@"MONTH", nil),
                                            NSLocalizedString(@"YEAR", nil),
                                            nil];
        
        NSArray *schedulePeriodPluralArray = [NSArray arrayWithObjects:
                                          NSLocalizedString(@"HOURS", nil),
                                          NSLocalizedString(@"DAYS", nil),
                                          NSLocalizedString(@"WEEKS", nil),
                                          NSLocalizedString(@"MONTHS", nil),
                                          NSLocalizedString(@"YEARS", nil),
                                          nil];
        
        NSString *repeatsStr;
        if ([prescription.repeatmultiple intValue] == 0) {
            repeatsStr = NSLocalizedString(@"DOES NOT REPEAT", nil);
        }
        else if ([prescription.repeatmultiple intValue] == 1) {
            repeatsStr = [NSString stringWithFormat:@"%@ %@",
                                           NSLocalizedString(@"EVERY", nil),
                                           [schedulePeriodSingularArray objectAtIndex:[prescription.repeatperiod intValue]]];
        }
        else {
            repeatsStr = [NSString stringWithFormat:@"%@ %d %@",
                                           NSLocalizedString(@"EVERY", nil),
                                           [prescription.repeatmultiple intValue],
                                           [schedulePeriodPluralArray objectAtIndex:[prescription.repeatperiod intValue]]];
        }
        
        // Occurs
        NSString *occursStr;
        if ([prescription.occurmultiple intValue] == 0) {
            occursStr = @"";
        }
        else if ([prescription.occurmultiple intValue] == 1) {
            occursStr = [NSString stringWithFormat:@"%d %@", 1, NSLocalizedString(@"TIME THAT DAY", nil)];
        }
        else {
            occursStr = [NSString stringWithFormat:@"%d %@", [prescription.occurmultiple intValue], NSLocalizedString(@"TIMES THAT DAY", nil)];
        }
        
        NSString *reasonAndNotesStr;
        if (prescription.notes == nil) {
            reasonAndNotesStr = @"";
        }
        else {
            reasonAndNotesStr = prescription.notes;
        }
        
        [writer writeLineOfFields:
         NSLocalizedString(@"PRESCRIPTION", nil),
         prescription.name,
         @"",
         @"",
         @"",
         prescription.method,
         prescription.strength,
         prescription.unit,
         dosageStr,
         dateStartStr,
         repeatsStr,
         occursStr,
         dateEndStr,
         reasonAndNotesStr,
         @"",
         @"",
         @"",
         @"",
         nil];
    }
    
    
    // Finally write the history info
    for (PrescriptionInstance *prescriptionInstance in [self.frc_prescriptionInstances fetchedObjects]) {
        NSDate *dateScheduled;
        NSString *dateScheduledStr;
        if (prescriptionInstance.datescheduled == nil) {
            dateScheduled = nil;
            dateScheduledStr = @"";
        }
        else {
            dateScheduled = [DateTimeHelper parseWebServiceDateDouble:prescriptionInstance.datescheduled];
            dateScheduledStr = [dateAndTimeFormatter stringFromDate:dateScheduled];
        }
        
        NSDate *dateTaken;
        NSString *dateTakenStr;
        if (prescriptionInstance.datetaken == nil) {
            dateTaken = nil;
            dateTakenStr = @"";
        }
        else {
            dateTaken = [DateTimeHelper parseWebServiceDateDouble:prescriptionInstance.datetaken];
            dateTakenStr = [dateAndTimeFormatter stringFromDate:dateTaken];
        }
        
        NSString *stateStr;
        switch ([prescriptionInstance.state intValue]) {
            case 2:
                stateStr = NSLocalizedString(@"TAKEN", nil);
                break;
                
            case 1:
                stateStr = NSLocalizedString(@"NOT TAKEN", nil);
                break;
                
            default:
                stateStr = NSLocalizedString(@"UNCONFIRMED", nil);
                break;
        }
        
        NSString *notesStr;
        if (prescriptionInstance.notes == nil) {
            notesStr = @"";
        }
        else {
            notesStr = prescriptionInstance.notes;
        }
        
        [writer writeLineOfFields:
         NSLocalizedString(@"HISTORY", nil),
         @"",
         @"",
         @"",
         @"",
         @"",
         @"",
         @"",
         @"",
         @"",
         @"",
         @"",
         @"",
         @"",
         dateScheduledStr,
         dateTakenStr,
         stateStr,
         notesStr,
         nil];
    }
    
    NSLog(@"%@",writer.stringValue);
}

@end
