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
    retVal.alertAction = [NSString stringWithFormat:@"Time to Take %@",self.prescription.name];
    retVal.alertBody = [NSString stringWithFormat:@"Take your next dosage of %@",self.prescription.name];
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
   // ResourceContext* resourceContext = [ResourceContext instance];
    
    //TODO: we need to calculate and create all of the prescription instance objects
    //for a particular prescription
    
    
    //we return an empty array for now
    NSArray* emptyRet = [[NSArray alloc]init];
    [emptyRet autorelease];
    return emptyRet;
}


@end

