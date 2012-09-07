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

//Converts this Prescription Instance object into a 
//UILocalNotification instance, does not schedule the notification
- (UILocalNotification*) createLocalNotification
{
    UILocalNotification* retVal = [[UILocalNotification alloc]init];
    retVal.fireDate = [self fireDate];
    retVal.soundName = UILocalNotificationDefaultSoundName;
    retVal.alertAction = [NSString stringWithFormat:NSLocalizedString(@"REMINDER ACTION", nil)];
    retVal.alertBody = [NSString stringWithFormat:@"%@ %@", NSLocalizedString(@"REMINDER ACTION", nil), self.prescription.name];
    retVal.hasAction = YES;
    
    //we also create a user dictionary to add information about the prescription and prescription instance
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc]init];
    [userInfo setValue:self.objectid forKey:PRESCRIPTIONINSTANCEID];

    retVal.userInfo = userInfo;
    [userInfo release];
    
    [retVal autorelease];
    return retVal;
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
        endDate = [calendar dateByAddingComponents:components toDate:[NSDate date] options:0];
        components.year = 0;
    }
    else {
        endDate = [DateTimeHelper parseWebServiceDateDouble:prescription.dateend];
    }
    
    int recurrances = 0;
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
    
    // Now we create PrescriptionInstances for each occurance of the schedule
    ResourceContext* resourceContext = [ResourceContext instance];
    
    NSMutableArray *prescriptionInstances = [[NSMutableArray alloc] init];
    
    int occurances = [prescription.occurmultiple intValue];
    
    if (period != kHOUR) {
        for (int i = 1; i <= recurrances; i++) {
            // first skip ahead the appropriate period
            switch (period) {
                case kDAY:
                    components.day = i;
                    break;
                    
                case kWEEK:
                    components.week = i;
                    break;
                    
                case kMONTH:
                    components.month = i;
                    break;
                    
                case kYEAR:
                    components.year = i;
                    break;
                    
                default:
                    break;
            }
            
            if (occurances > 0) {
                for (int j = 1; j <= occurances; j++) {
                    // next create an instance for each occurance that day
                    
                    components.hour = (24 / occurances) * j;
                    
                    NSDate *reminderDate = [calendar dateByAddingComponents:components toDate:startDate options:0];
                    
                    PrescriptionInstance *instance = (PrescriptionInstance*)[Resource createInstanceOfType:PRESCRIPTIONINSTANCE withResourceContext:resourceContext];
                    
                    IDGenerator* idGenerator = [IDGenerator instance];
                    NSNumber* instanceID = [idGenerator generateNewId:PRESCRIPTIONINSTANCE];
                    prescription.objectid = instanceID;
                    
                    instance.prescriptionid = prescription.objectid;
                    instance.prescriptionname = prescription.name;
                    
                    double doubleDate = [reminderDate timeIntervalSince1970];
                    instance.datescheduled = [NSNumber numberWithDouble:doubleDate];
                    
                    instance.state = nil;
                    instance.datetaken = nil;
                    instance.notes = nil;
                    instance.hasnotificationbeenscheduled = NO;
                    
                    [prescriptionInstances addObject:instance];
                }
            }
            else {
                // create the single instance for that day
                NSDate *reminderDate = [calendar dateByAddingComponents:components toDate:startDate options:0];
                
                PrescriptionInstance *instance = (PrescriptionInstance*)[Resource createInstanceOfType:PRESCRIPTIONINSTANCE withResourceContext:resourceContext];
                
                IDGenerator* idGenerator = [IDGenerator instance];
                NSNumber* instanceID = [idGenerator generateNewId:PRESCRIPTIONINSTANCE];
                prescription.objectid = instanceID;
                
                instance.prescriptionid = prescription.objectid;
                instance.prescriptionname = prescription.name;
                
                double doubleDate = [reminderDate timeIntervalSince1970];
                instance.datescheduled = [NSNumber numberWithDouble:doubleDate];
                
                instance.state = nil;
                instance.datetaken = nil;
                instance.notes = nil;
                instance.hasnotificationbeenscheduled = NO;
                
                [prescriptionInstances addObject:instance];
            }
        }
    }
    
    return prescriptionInstances;
}


@end

