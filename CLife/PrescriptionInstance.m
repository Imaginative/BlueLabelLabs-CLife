//
//  PrescriptionInstance.m
//  CLife
//
//  Created by Jasjeet Gill on 8/14/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "PrescriptionInstance.h"
#import "IDGenerator.h"
#import "AuthenticationManager.h"
#import "User.h"
#import "DateTimeHelper.h"
#import "Attributes.h"
#import "SchedulePeriods.h"
#import "PrescriptionInstanceState.h"
#import "Macros.h"

@implementation PrescriptionInstance
@dynamic prescriptionid;
@dynamic prescriptionname;
@dynamic datetaken;
@dynamic datescheduled;
@dynamic state;
@dynamic notes;
@dynamic hasnotificationbeenscheduled;
@synthesize prescription = __prescription;


- (Prescription*) prescription
{
    if (__prescription == nil)
    {
        //lets find the prescription object
        ResourceContext* resourceContext = [ResourceContext instance];
        __prescription = (Prescription*)[resourceContext resourceWithType:PRESCRIPTION withID:self.prescriptionid];
    }
    return __prescription;
}

//returns an NSDate object representing the date that this particular instance
//should prompt a user to enter in details
- (NSDate*) fireDate
{
    //the prescription alert time is the seconds before the scheduled time that
    //the user should be reminded
    double dbl_dateScheduled = [self.datescheduled doubleValue];
    
    //this is the date to remind the user
    double dbl_dateToRemind = dbl_dateScheduled;
    
    NSDate* fireDate = [NSDate dateWithTimeIntervalSince1970:dbl_dateToRemind];
    return fireDate;
}

- (NSString *) scheduleDateString {
    [self willAccessValueForKey:@"scheduleDateString"];
    NSDate *scheduleDate = [DateTimeHelper parseWebServiceDateDouble:self.datescheduled];
    [self didAccessValueForKey:@"scheduleDateString"];
    
    // Setup date formatter
    NSDateFormatter *dateOnlyFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateOnlyFormatter setDateStyle:NSDateFormatterLongStyle];
    [dateOnlyFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    NSString* scheduleDateStr = [dateOnlyFormatter stringFromDate:scheduleDate];
    
    return scheduleDateStr;
}

//Converts this Prescription Instance object into a 
//UILocalNotification instance, does not schedule the notification
- (UILocalNotification*) createLocalNotification
{
    // Get the prescription object
    ResourceContext* resourceContext = [ResourceContext instance];
    Prescription* prescription = (Prescription*)[resourceContext resourceWithType:PRESCRIPTION withID:self.prescriptionid];
    
    UILocalNotification* retVal = [[UILocalNotification alloc]init];
    retVal.fireDate = [self fireDate];
    retVal.soundName = UILocalNotificationDefaultSoundName;
    retVal.alertAction = [NSString stringWithFormat:NSLocalizedString(@"REMINDER ACTION", nil)];
//    retVal.alertBody = [NSString stringWithFormat:@"%@ %@. %@", NSLocalizedString(@"REMINDER ACTION PART 1", nil), self.prescription.name, NSLocalizedString(@"REMINDER ACTION PART 2", nil)];
    retVal.alertBody = [NSString stringWithFormat:@"%@ %@. %@", NSLocalizedString(@"REMINDER ACTION PART 1", nil), prescription.name, NSLocalizedString(@"REMINDER ACTION PART 2", nil)];
    retVal.hasAction = YES;
    
    //we also create a user dictionary to add information about the prescription and prescription instance
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc]init];
    [userInfo setValue:self.objectid forKey:PRESCRIPTIONINSTANCEID];

    retVal.userInfo = userInfo;
    [userInfo release];
    
    [retVal autorelease];
    return retVal;
}

//Returns an array of PrescriptionInstance objects which are unconfirmed, and which are scheduled
//for after the date passed in
+ (NSArray*)unconfirmedPrescriptionInstancesAfter:(NSDate *)date
{
    NSString* activityName = @"PrescriptionInstance.unconfirmedPrescriptionInstancesAfter:";
    NSArray* retVal = nil;
    
  
    
    ResourceContext* resourceContext = [ResourceContext instance];
    NSManagedObjectContext *appContext = resourceContext.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:PRESCRIPTIONINSTANCE inManagedObjectContext:appContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    double doubleDate = [date timeIntervalSince1970];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"%K=%d AND %K >%f",STATE,kUNCONFIRMED, DATESCHEDULED,doubleDate];
    
    [request setPredicate:predicate];
    
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:DATESCHEDULED ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError* error = nil;
    NSArray* results = [appContext executeFetchRequest:request error:&error];
    
    if (error != nil) {
        
//        LOG_PRESCRIPTIONINSTANCE(1, @"%@Error due to:%@",activityName, error);
    }
    
    else 
    {
//        LOG_PRESCRIPTIONINSTANCE(0,@"%@Successfully retrieved %d PrescriptionInstance objects",activityName,[results count]);
        retVal = results;
    }
    [request release];
    
    return retVal; 

    
    
}

+ (PrescriptionInstance *) createPrescriptionInstanceForPrescription:(Prescription *)prescription withReminderDate:(NSDate *)reminderDate
{
    ResourceContext* resourceContext = [ResourceContext instance];
    
    PrescriptionInstance *instance = (PrescriptionInstance*)[Resource createInstanceOfType:PRESCRIPTIONINSTANCE withResourceContext:resourceContext];
    
    IDGenerator* idGenerator = [IDGenerator instance];
    NSNumber* instanceID = [idGenerator generateNewId:PRESCRIPTIONINSTANCE];
    instance.objectid = instanceID;
    
    instance.prescriptionid = prescription.objectid;
    instance.prescriptionname = prescription.name;
    
    NSDate* currentDate = [NSDate date];
    NSNumber* createdDateDouble = [NSNumber numberWithDouble:[currentDate timeIntervalSince1970]];
    instance.datemodified = createdDateDouble;
    instance.datecreated = createdDateDouble;
    
    double doubleDate = [reminderDate timeIntervalSince1970];
    instance.datescheduled = [NSNumber numberWithDouble:doubleDate];
    
    instance.state = [NSNumber numberWithInt:kUNCONFIRMED];
    instance.datetaken = nil;
    instance.notes = nil;
    instance.hasnotificationbeenscheduled = [NSNumber numberWithBool:NO];
    
    return instance;
}

//creates an array of prescription instance objects based off the details
//of the prescription object
+ (NSArray*) createPrescriptionInstancesFor:(Prescription *)prescription
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [[[NSDateComponents alloc] init] autorelease];
    
    NSDate *startDate = [DateTimeHelper parseWebServiceDateDouble:prescription.datestart];
    
    NSDate *endDate;
    if (prescription.dateend == nil) {
        // If the end date is not set we set it to 1 year from now
        components.year = 1;
//        components.day = 2;
        components.second = -1; // sets the date to the last second on that day
        endDate = [calendar dateByAddingComponents:components toDate:[NSDate date] options:0];
        
        // reset the date components
        components.year = 0;
//        components.day = 0;
        components.second = 0;
    }
    else {
        endDate = [DateTimeHelper parseWebServiceDateDouble:prescription.dateend];
    }
    
    int recurrances = 0;
    int recurranceMultiple = [prescription.repeatmultiple intValue];
    int period = [prescription.repeatperiod intValue];
    
    switch (period) {
        case kHOUR:
            recurrances = [[calendar components:NSHourCalendarUnit
                                       fromDate:startDate
                                         toDate:endDate
                                        options:0] hour];
            break;
            
        case kDAY:
            recurrances = [[calendar components:NSDayCalendarUnit
                                       fromDate:startDate
                                         toDate:endDate
                                        options:0] day];
            break;
        
        case kWEEK:
            recurrances = [[calendar components:NSWeekCalendarUnit
                                       fromDate:startDate
                                         toDate:endDate
                                        options:0] week];
            break;
            
        case kMONTH:
            recurrances = [[calendar components:NSMonthCalendarUnit
                                       fromDate:startDate
                                         toDate:endDate
                                        options:0] month];
            break;
            
        case kYEAR:
            recurrances = [[calendar components:NSYearCalendarUnit
                                       fromDate:startDate
                                         toDate:endDate
                                        options:0] year];
            break;
            
        default:
            break;
    }
    recurrances = recurrances / recurranceMultiple;
    
    // Now we create PrescriptionInstances for each occurance of the schedule and add them to the array
    NSMutableArray *prescriptionInstances = [[NSMutableArray alloc] init];
    
    int occurances = [prescription.occurmultiple intValue];
    // overwrite the default case of nil daily occurances
    if (occurances == 0) {
        occurances = 1;
    }
    
    if (period != kHOUR) {
        for (int i = 0; i <= recurrances; i++) {
            // first skip ahead the appropriate period
            switch (period) {
                case kDAY:
                    components.day = i * recurranceMultiple;
                    break;
                    
                case kWEEK:
                    components.week = i * recurranceMultiple;
                    break;
                    
                case kMONTH:
                    components.month = i * recurranceMultiple;
                    break;
                    
                case kYEAR:
                    components.year = i * recurranceMultiple;
                    break;
                    
                default:
                    break;
            }
            
            // create the first instance for that day
            NSDate *reminderDate = [calendar dateByAddingComponents:components toDate:startDate options:0];
            
            // reset the components
            components.day = 0;
            components.week = 0;
            components.month = 0;
            components.year = 0;
            
            if ([reminderDate compare:endDate] == NSOrderedAscending) {
                // reminder date is earlier than the end date, we can create the reminder
                PrescriptionInstance *instance = [self createPrescriptionInstanceForPrescription:prescription withReminderDate:reminderDate];
                
                [prescriptionInstances addObject:instance];
                
                /* NSLog */
                NSDateFormatter *dateAndTimeFormatter = [[[NSDateFormatter alloc] init] autorelease];
                [dateAndTimeFormatter setDateStyle:NSDateFormatterMediumStyle];
                [dateAndTimeFormatter setTimeStyle:NSDateFormatterShortStyle];
                NSLog([NSString stringWithFormat:@"PrescriptionInstanceID:%@, RedminderDate:%@", [instance.objectid stringValue], [dateAndTimeFormatter stringFromDate:reminderDate]]);
                
                
                // next create an instance for each remaining occurance that day if more than 1
                if (occurances > 1) {
                    
                    // Grab the hour component from the start day so we can determine the time between occurances
                    NSDateComponents *startHourComponent = [calendar components:(NSHourCalendarUnit) fromDate:startDate];
                    NSInteger hours = [startHourComponent hour];
                    
                    components.hour = (((24 - hours) + occurances - 1) / occurances);    // round up (A+B-1)/B
                    
                    for (int j = 1; j < occurances; j++) {
                        reminderDate = [calendar dateByAddingComponents:components toDate:reminderDate options:0];
                        
                        if ([reminderDate compare:endDate] == NSOrderedAscending) {
                            // reminder date is earlier than the end date, we can create the reminder
                            
                            instance = [self createPrescriptionInstanceForPrescription:prescription withReminderDate:reminderDate];
                            
                            [prescriptionInstances addObject:instance];
                            
                            /* NSLog */
                            NSDateFormatter *dateAndTimeFormatter = [[[NSDateFormatter alloc] init] autorelease];
                            [dateAndTimeFormatter setDateStyle:NSDateFormatterMediumStyle];
                            [dateAndTimeFormatter setTimeStyle:NSDateFormatterShortStyle];
                            NSLog([NSString stringWithFormat:@"PrescriptionInstanceID:%@, RedminderDate:%@", [instance.objectid stringValue], [dateAndTimeFormatter stringFromDate:reminderDate]]);
                        }
                    }
                    
                    // reset the components
                    components.hour = 0;
                }
            }
        }
    }
    else {
        // Handle the HOURLY case
        
        // If specified, limit the reminders to the number of daily occurances specified by the user
        if (occurances > 1) {
            for (int i = 0; i < recurrances; i++) {
                
                components.day = i;
                
                for (int j = 0; j < occurances; j++ ) {
                    
                    components.hour = j * recurranceMultiple;
                    
                    // create the first instance for that day
                    NSDate *reminderDate = [calendar dateByAddingComponents:components toDate:startDate options:0];
                    
                    if ([reminderDate compare:endDate] == NSOrderedAscending) {
                        // reminder date is earlier than the end date, we can create the reminder
                        PrescriptionInstance *instance = [self createPrescriptionInstanceForPrescription:prescription withReminderDate:reminderDate];
                        
                        [prescriptionInstances addObject:instance];
                        
                        /* NSLog */
                        NSDateFormatter *dateAndTimeFormatter = [[[NSDateFormatter alloc] init] autorelease];
                        [dateAndTimeFormatter setDateStyle:NSDateFormatterMediumStyle];
                        [dateAndTimeFormatter setTimeStyle:NSDateFormatterShortStyle];
                        NSLog([NSString stringWithFormat:@"PrescriptionInstanceID:%@, RedminderDate:%@", [instance.objectid stringValue], [dateAndTimeFormatter stringFromDate:reminderDate]]);
                    }
                    
                    // reset the components
                    components.hour = 0;
                }
                
                // reset the components
                components.day = 0;
            }
        }
        else {
            // Create a reminder for every interval of hours specificed
            
            NSDate *reminderDate;
            
            for (int i = 0; i <= recurrances; i++) {
                
                components.hour = i * recurranceMultiple;
                
                reminderDate = [calendar dateByAddingComponents:components toDate:startDate options:0];
                
                if ([reminderDate compare:endDate] == NSOrderedAscending) {
                    // reminder date is earlier than the end date, we can create the reminder
                    PrescriptionInstance *instance = [self createPrescriptionInstanceForPrescription:prescription withReminderDate:reminderDate];
                    
                    [prescriptionInstances addObject:instance];
                    
                    /* NSLog */
                    NSDateFormatter *dateAndTimeFormatter = [[[NSDateFormatter alloc] init] autorelease];
                    [dateAndTimeFormatter setDateStyle:NSDateFormatterMediumStyle];
                    [dateAndTimeFormatter setTimeStyle:NSDateFormatterShortStyle];
                    NSLog([NSString stringWithFormat:@"PrescriptionInstanceID:%@, RedminderDate:%@", [instance.objectid stringValue], [dateAndTimeFormatter stringFromDate:reminderDate]]);
                }
                
                // reset the components
                components.hour = 0;
            }
            
        }
    }
    
    return prescriptionInstances;
}


@end

