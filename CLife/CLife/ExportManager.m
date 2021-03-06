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
#import "NSArray+CHCSVAdditions.h"
#import "NSString+CHCSVAdditions.h"
#import "MethodTypes.h"

@implementation ExportManager
@synthesize frc_prescriptions           = __frc_prescriptions;
@synthesize frc_prescriptionInstances   = __frc_prescriptionInstances;
@synthesize dateAndTimeFormatter        = m_dateAndTimeFormatter;
@synthesize filteredPrescriptions       = m_filteredPrescriptions;
@synthesize filterDateStart             = m_filterDateStart;
@synthesize filterDateEnd               = m_filterDateEnd;

static ExportManager *sharedManager;

+ (ExportManager *) instanceWithDelegate:(id)delegate forPrescriptions:(NSArray *)prescriptions withStartDate:(NSDate *)startDate withEndDate:(NSDate *)endDate {
    @synchronized (self) {
        if (!sharedManager) {
            sharedManager = [[ExportManager alloc] init];
        }
        
        sharedManager.delegate = delegate;
        sharedManager.filteredPrescriptions = prescriptions;
        sharedManager.filterDateStart = startDate;
        sharedManager.filterDateEnd = endDate;
        
        return sharedManager;
    }
}

- (void) dealloc {
    [super dealloc];
    
    self.dateAndTimeFormatter = nil;
    
}

#pragma mark - Properties
- (id)delegate {
    return m_delegate;
}

- (void)setDelegate:(id<ExportManagerDelegate>)del
{
    m_delegate = del;
}

- (NSFetchedResultsController *)frc_prescriptions {
//    NSString* activityName = @"ExportManager.frc_prescriptions:";
//    if (__frc_prescriptions != nil) {
//        return __frc_prescriptions;
//    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    ResourceContext* resourceContext = [ResourceContext instance];
    ClifeAppDelegate* app = (ClifeAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSEntityDescription *entityDescription  = [NSEntityDescription entityForName:PRESCRIPTION inManagedObjectContext:app.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:NAME ascending:YES];
    
    NSPredicate* predicate;
    if (self.filteredPrescriptions != nil && [self.filteredPrescriptions count] > 0) {
        // Get filtered prescription ids if filters are set and add them to the predicate
        NSMutableArray *prescriptionIDs = [[NSMutableArray alloc] initWithCapacity:[self.filteredPrescriptions count]];
        for (Prescription *prescription in self.filteredPrescriptions) {
            [prescriptionIDs addObject:prescription.objectid];
        }
        predicate = [NSPredicate predicateWithFormat:@"%K IN %@", OBJECTID, prescriptionIDs];
    }
    else {
        predicate = nil;
    }
    
    [fetchRequest setPredicate:predicate];
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
//    if (__frc_prescriptionInstances != nil) {
//        return __frc_prescriptionInstances;
//    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    ResourceContext* resourceContext = [ResourceContext instance];
    ClifeAppDelegate* app = (ClifeAppDelegate*)[[UIApplication sharedApplication]delegate];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:PRESCRIPTIONINSTANCE inManagedObjectContext:app.managedObjectContext];
    
    NSSortDescriptor* sortDescriptor = [[NSSortDescriptor alloc] initWithKey:DATESCHEDULED ascending:NO];
    
    // Setup filter start and end dates, start with defaults
    NSDate *startDate = [NSDate distantPast];
    NSDate *endDate = [NSDate date];
    if (self.filterDateStart != nil) {
        startDate = self.filterDateStart;
    }
    
    if (self.filterDateEnd != nil) {
        endDate = self.filterDateEnd;
    }
    
    double doubleDateStart = [startDate timeIntervalSince1970];
    NSNumber *dateStartNSNum = [NSNumber numberWithDouble:doubleDateStart];
    
    double doubleDateEnd = [endDate timeIntervalSince1970];
    NSNumber *dateEndNSNum = [NSNumber numberWithDouble:doubleDateEnd];
    
    NSPredicate* predicate;
    if (self.filteredPrescriptions != nil && [self.filteredPrescriptions count] > 0) {
        // Get filtered prescription ids if filters are set and add them to the predicate
        NSMutableArray *prescriptionIDs = [[NSMutableArray alloc] initWithCapacity:[self.filteredPrescriptions count]];
        for (Prescription *prescription in self.filteredPrescriptions) {
            [prescriptionIDs addObject:prescription.objectid];
        }
        predicate = [NSPredicate predicateWithFormat:@"%K>=%@ && %K<=%@ && %K IN %@", DATESCHEDULED, dateStartNSNum, DATESCHEDULED, dateEndNSNum, PRESCRIPTIONID, prescriptionIDs];
    }
    else {
        predicate = [NSPredicate predicateWithFormat:@"%K>=%@ && %K<=%@", DATESCHEDULED, dateStartNSNum, DATESCHEDULED, dateEndNSNum];
    }
    
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
        self.dateAndTimeFormatter = [[NSDateFormatter alloc] init];
        [self.dateAndTimeFormatter setLocale:[NSLocale currentLocale]];
    }
    return self;
}

#pragma mark - Helper methods
- (NSString *)getBloodTypeStringForUser:(User *)user {
    // Blood Type
    
    NSArray *bloodTypeArray = [NSArray arrayWithObjects:
                           NSLocalizedString(@"A", nil),
                           NSLocalizedString(@"B", nil),
                           NSLocalizedString(@"AB", nil),
                           NSLocalizedString(@"O", nil),
                           nil];
    
    NSArray *bloodRhArray = [NSArray arrayWithObjects:
                         NSLocalizedString(@"POSITIVE", nil),
                         NSLocalizedString(@"NEGATIVE", nil),
                         nil];
    
    NSString *bloodTypeStr;
    
    if (user.bloodtypeconstant != nil && user.bloodrhconstant != nil) {
        bloodTypeStr = [NSString stringWithFormat:@"%@ %@",
                        [bloodTypeArray objectAtIndex:[user.bloodtypeconstant intValue]],
                        [bloodRhArray objectAtIndex:[user.bloodrhconstant intValue]]];
    }
    else {
        bloodTypeStr = @" ";
    }
    
    return bloodTypeStr;
}

- (NSString *)getGenderStringForUser:(User *)user {
    // Gender
    NSArray *genderArray = [NSArray arrayWithObjects:
                            NSLocalizedString(@"MALE", nil),
                            NSLocalizedString(@"FEMALE", nil),
                            nil];
    
    NSString *genderStr;
    
    if (user.sexconstant != nil) {
        genderStr = [genderArray objectAtIndex:[user.sexconstant intValue]];
    }
    else {
        genderStr = @" ";
    }
    
    return genderStr;
}

- (NSString *)getStartDateStringForPrescription:(Prescription *)prescription {
    // Start Date
    NSDate *dateStart;
    NSString *dateStartStr;
    if (prescription.datestart == nil) {
        dateStart = nil;
        dateStartStr = @"";
    }
    else {
        dateStart = [DateTimeHelper parseWebServiceDateDouble:prescription.datestart];
        dateStartStr = [self.dateAndTimeFormatter stringFromDate:dateStart];
    }
    
    return dateStartStr;
}

- (NSString *)getEndDateStringForPrescription:(Prescription *)prescription {
    // End Date
    NSDate *dateEnd;
    NSString *dateEndStr;
    if (prescription.dateend == nil) {
        dateEnd = nil;
        dateEndStr = @"";
    }
    else {
        dateEnd = [DateTimeHelper parseWebServiceDateDouble:prescription.dateend];
        dateEndStr = [self.dateAndTimeFormatter stringFromDate:dateEnd];
    }
    
    return dateEndStr;
}

- (NSString *)getMethodStringForPrescription:(Prescription *)prescription {
    // Method
    NSArray *methodArray = [NSArray arrayWithObjects:
                                            NSLocalizedString(@"PILL", nil),
                                            NSLocalizedString(@"LIQUID", nil),
                                            NSLocalizedString(@"CREAM", nil),
                                            NSLocalizedString(@"INJECTION", nil),
                                            nil];
    
    NSString *methodStr;
    
    if (prescription.methodconstant != nil) {
        methodStr = [methodArray objectAtIndex:[prescription.methodconstant intValue]];
    }
    else {
        methodStr = @" ";
    }
    
    return methodStr;
}

- (NSString *)getDosageStringForPrescription:(Prescription *)prescription {
    // Dosage
    NSString *dosageStr;
    if ([prescription.numberofdoses intValue] == 1) {
        dosageStr = [NSString stringWithFormat:@"%d %@", 1, NSLocalizedString(@"DOSE", nil)];
    }
    else {
        dosageStr = [NSString stringWithFormat:@"%d %@", [prescription.numberofdoses intValue], NSLocalizedString(@"DOSES", nil)];
    }
    
    return dosageStr;
}

- (NSString *)getRepeatsStringForPrescription:(Prescription *)prescription {
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
    
    return repeatsStr;
}

- (NSString *)getOccursStringForPrescription:(Prescription *)prescription {
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
    
    return occursStr;
}

- (NSString *)getReasonAndNotesStringForPrescription:(Prescription *)prescription {
    // Reason and Notes
    NSString *reasonAndNotesStr;
    if (prescription.notes == nil) {
        reasonAndNotesStr = @"";
    }
    else {
        reasonAndNotesStr = prescription.notes;
    }
    
    return reasonAndNotesStr;
}

- (NSString *)getDateScheduledStringForPrescription:(PrescriptionInstance *)prescriptionInstance {
    // Date Scheduled
    NSDate *dateScheduled;
    NSString *dateScheduledStr;
    if (prescriptionInstance.datescheduled == nil) {
        dateScheduled = nil;
        dateScheduledStr = @"";
    }
    else {
        dateScheduled = [DateTimeHelper parseWebServiceDateDouble:prescriptionInstance.datescheduled];
        dateScheduledStr = [self.dateAndTimeFormatter stringFromDate:dateScheduled];
    }
    
    return dateScheduledStr;
}

- (NSString *)getDateTakenStringForPrescription:(PrescriptionInstance *)prescriptionInstance {
    // Date Taken
    NSDate *dateTaken;
    NSString *dateTakenStr;
    if (prescriptionInstance.datetaken == nil) {
        dateTaken = nil;
        dateTakenStr = @"";
    }
    else {
        dateTaken = [DateTimeHelper parseWebServiceDateDouble:prescriptionInstance.datetaken];
        dateTakenStr = [self.dateAndTimeFormatter stringFromDate:dateTaken];
    }
    
    return dateTakenStr;
}

- (NSString *)getStateStringForPrescription:(PrescriptionInstance *)prescriptionInstance {
    // State
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
    
    return stateStr;
}

- (NSString *)getNotesStringForPrescription:(PrescriptionInstance *)prescriptionInstance {
    // Notes
    NSString *notesStr;
    if (prescriptionInstance.notes == nil) {
        notesStr = @"";
    }
    else {
        notesStr = prescriptionInstance.notes;
    }
    
    return notesStr;
}

#pragma mark - Mail composition methods
- (void)composeExportEmailWithFileName:(NSString *)fileName {
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* appVersionNum = [infoDict objectForKey:@"CFBundleShortVersionString"];
    NSString* appBundleVersionNum = [infoDict objectForKey:@"CFBundleVersion"];
    NSString* appName = [infoDict objectForKey:@"CFBundleDisplayName"];
    
    MFMailComposeViewController *mailComposer = [[MFMailComposeViewController alloc] init];
    mailComposer.mailComposeDelegate = self;
    
    // Set the email subject
    [mailComposer setSubject:[NSString stringWithFormat:@"%@: %@", appName, NSLocalizedString(@"EXPORTED DATA", nil)]];
    
    // Setup date formatter
    NSDateFormatter *dateAndTimeFormatter = [[NSDateFormatter alloc] init];
    [dateAndTimeFormatter setLocale:[NSLocale currentLocale]];
    [dateAndTimeFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateAndTimeFormatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateExported = [dateAndTimeFormatter stringFromDate:[NSDate date]];
    
    // Set email message header
    NSString *messageHeader = [NSString stringWithFormat:@"%@: %@<br>%@ v%@ (%@)<br><br>", NSLocalizedString(@"DATA EXPORTED ON", nil), dateExported, appName, appVersionNum, appBundleVersionNum];
    [mailComposer setMessageBody:messageHeader isHTML:YES];
    
    // Set attachment of CSV file
    // get documents path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // the path of the export file
    NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    NSData *attachment = [NSData dataWithContentsOfFile:path];
    
    [mailComposer addAttachmentData:attachment mimeType:@"text/csv" fileName:fileName];
//    [mailComposer addAttachmentData:attachment mimeType:@"text" fileName:fileName];
    
    // Present the mail composition interface
    UIViewController *viewController = (UIViewController *)self.delegate;
    [viewController presentModalViewController:mailComposer animated:YES];
    [mailComposer release]; // Can safely release the controller now.
}

#pragma mark MailComposeController Delegate
// The mail compose view controller delegate method
- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
    [self.delegate mailComposeController:controller didFinishWithResult:result error:error];
}

#pragma mark - Instance methods
- (void)exportData {
    CHCSVWriter *writer = [[CHCSVWriter alloc] initForWritingToString];
//    writer.encoding = NSUTF16StringEncoding;  // Hardcoded into CHCSVWriter.m method: - (void)_writeString:(NSString *)string
    writer.delimiter = @"\t";
    
    // Setup date formatter
    [self.dateAndTimeFormatter setDateStyle:NSDateFormatterLongStyle];
    [self.dateAndTimeFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    /* First write the column headers */
    
    [writer writeLineOfFields:
     NSLocalizedString(@"ITEM", nil),
     NSLocalizedString(@"ID", nil),
     NSLocalizedString(@"NAME", nil),
     NSLocalizedString(@"BIRTHDAY", nil),
     NSLocalizedString(@"GENDER", nil),
     NSLocalizedString(@"BLOOD TYPE", nil),
     NSLocalizedString(@"DOCTOR", nil),
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
     [user.objectid stringValue],
     user.username,
     [self.dateAndTimeFormatter stringFromDate:dateBorn],
     [self getGenderStringForUser:user],
     [self getBloodTypeStringForUser:user],
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
     @"",
     nil];
    
    // Update the date time formatter to include time
    [self.dateAndTimeFormatter setTimeStyle:NSDateFormatterShortStyle];
    
    /* Next write the prescription info */
    
    // We only include the prescription items if we are exporting all data
    if (self.filterDateEnd == nil &&
        self.filterDateStart == nil &&
        self.filteredPrescriptions == nil &&
        [self.filteredPrescriptions count] == 0)
    {
        for (Prescription *prescription in [self.frc_prescriptions fetchedObjects]) {
            
            [writer writeLineOfFields:
             NSLocalizedString(@"PRESCRIPTION", nil),
             [prescription.objectid stringValue],
             prescription.name,
             @"",
             @"",
             @"",
             prescription.doctor,
             [self getMethodStringForPrescription:prescription],
             prescription.strength,
             prescription.unit,
             [self getDosageStringForPrescription:prescription],
             [self getStartDateStringForPrescription:prescription],
             [self getRepeatsStringForPrescription:prescription],
             [self getOccursStringForPrescription:prescription],
             [self getEndDateStringForPrescription:prescription],
             [self getReasonAndNotesStringForPrescription:prescription],
             @"",
             @"",
             @"",
             @"",
             nil];
            
        }
    }
    
    /* Finally write the history info */
    
    for (PrescriptionInstance *prescriptionInstance in [self.frc_prescriptionInstances fetchedObjects]) {
        // Get the prescription object associated with this prescription instance
        Prescription *prescription = (Prescription*)[resourceContext resourceWithType:PRESCRIPTION withID:prescriptionInstance.prescriptionid];
        
        [writer writeLineOfFields:
         NSLocalizedString(@"HISTORY", nil),
         [prescriptionInstance.objectid stringValue],
         prescriptionInstance.prescriptionname,
         @"",
         @"",
         @"",
         prescription.doctor,
         [self getMethodStringForPrescription:prescription],
         prescription.strength,
         prescription.unit,
         [self getDosageStringForPrescription:prescription],
         [self getStartDateStringForPrescription:prescription],
         [self getRepeatsStringForPrescription:prescription],
         [self getOccursStringForPrescription:prescription],
         [self getEndDateStringForPrescription:prescription],
         [self getReasonAndNotesStringForPrescription:prescription],
         [self getDateScheduledStringForPrescription:prescriptionInstance],
         [self getDateTakenStringForPrescription:prescriptionInstance],
         [self getStateStringForPrescription:prescriptionInstance],
         [self getNotesStringForPrescription:prescriptionInstance],
         nil];
    }
    
//    NSLog(@"%@",writer.stringValue);
    
    /* Now save the csv file and return the file path */
    
    // get documents path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // the path to write file
    NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString* appName = [infoDict objectForKey:@"CFBundleDisplayName"];
    
    NSString *fileName = [NSString stringWithFormat:@"%@_%@_%@.csv", appName, NSLocalizedString(@"EXPORT", nil), [self.dateAndTimeFormatter stringFromDate:[NSDate date]]];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:fileName];
    
    // now write to file
    NSError* error = nil;
    NSArray *csvArray = [writer.stringValue CSVComponents];
    
    BOOL writeDidSucceed = [csvArray writeToCSVFile:path atomically:YES error:&error];
    
    if (writeDidSucceed == YES) {
        NSLog(@"CSV file successfully created.");
    }
    else {
        NSLog(@"CSV file failed with error:%@", [error userInfo]);
    }
    
    /* Finally, setup the email to send the exported file */
    [self composeExportEmailWithFileName:fileName];
}

@end
