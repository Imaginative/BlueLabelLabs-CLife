//
//  Prescription.m
//  CLife
//
//  Created by Jasjeet Gill on 8/14/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Prescription.h"
#import "AuthenticationManager.h"
#import "User.h"
#import "DateTimeHelper.h"
#import "IDGenerator.h"
#import "Attributes.h"
#import "PrescriptionInstanceState.h"
#import "Macros.h"
#import "PrescriptionInstanceManager.h"
#import "LocalNotificationManager.h"

@implementation Prescription

@dynamic userid;

@dynamic name;
@dynamic strength;
@dynamic unit;

@dynamic datestart;
@dynamic numberofdoses;
@dynamic method;
@dynamic repeatmultiple;
@dynamic repeatperiod;
@dynamic occurmultiple;
@dynamic dateend;

@dynamic notes;

#pragma mark - Methods
//returns an array of all unconfirmed prescription instances
//which are scheduled past the date passed in
- (NSArray*) unconfirmedPrescriptionInstancesAfter:(NSDate*)date
{
    NSString* activityName = @"Prescription.unfconfirmedPrescriptionInstancesAfter:";
    NSArray* retVal = nil;
    
    ResourceContext* resourceContext = [ResourceContext instance];
    NSManagedObjectContext *appContext = resourceContext.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:PRESCRIPTIONINSTANCE inManagedObjectContext:appContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    double doubleDate = [date timeIntervalSince1970];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"%K=%@ AND %K=%d AND %K >%f",PRESCRIPTIONID,self.objectid,STATE,kUNCONFIRMED, DATESCHEDULED,doubleDate];
    [request setPredicate:predicate];
    
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:DATESCHEDULED ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
     
     NSError* error = nil;
     NSArray* results = [appContext executeFetchRequest:request error:&error];
    
    if (error != nil) {
        
//        LOG_PRESCRIPTION(1, @"%@Error PrescriptionInstance objects for Prescription:%@ (%@) due to:%@",activityName,self.objectid,self.name, error);
    }
    
    else 
    {
//        LOG_PRESCRIPTION(0,@"%@Successfully retrieved %d PrescriptionInstance objects for Prescription:%@ (%@)",activityName,[results count],self.objectid,self.name);
        retVal = results;
    }
    [request release];
    
    return retVal; 

}

//returns an array of all  prescription instances
//associated with this prescription
- (NSArray*) prescriptionInstances
{
    NSString* activityName = @"Prescription.prescriptionInstances:";
    NSArray* retVal = nil;
    
    ResourceContext* resourceContext = [ResourceContext instance];
    NSManagedObjectContext *appContext = resourceContext.managedObjectContext;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:PRESCRIPTIONINSTANCE inManagedObjectContext:appContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"%K=%@", PRESCRIPTIONID, self.objectid];
    [request setPredicate:predicate];
    
    NSSortDescriptor* sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:DATESCHEDULED ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    NSError* error = nil;
    NSArray* results = [appContext executeFetchRequest:request error:&error];
    
    if (error != nil) {
//        LOG_PRESCRIPTION(1, @"%@Error PrescriptionInstance objects for Prescription:%@ (%@) due to:%@",activityName,self.objectid,self.name, error);
    }
    
    else 
    {
//        LOG_PRESCRIPTION(0,@"%@Successfully retrieved %d PrescriptionInstance objects for Prescription:%@ (%@)",activityName,[results count],self.objectid,self.name);
        retVal = results;
    }
    [request release];
    
    return retVal;
    
}

#pragma mark - Static Methods
+ (void) deletePrescriptionWithID:(NSNumber *)prescriptionID {
    NSString* activityName = @"Prescription.deletePrescriptionWithID:";
    
    // Get the presciption object
    ResourceContext *resourceContext = [ResourceContext instance];
    Prescription* prescription = (Prescription*)[resourceContext resourceWithType:PRESCRIPTION withID:prescriptionID];
    
    // First delete all associated prescription instance objects and their local notifications
    PrescriptionInstanceManager* prescriptionInstanceManager = [PrescriptionInstanceManager instance];
    [prescriptionInstanceManager deletePrescriptionInstanceObjectsFor:prescription shouldSave:YES];
    
    // Now delete the prescription object
    [resourceContext delete:prescriptionID withType:PRESCRIPTION];
    
    [resourceContext save:NO onFinishCallback:nil trackProgressWith:nil];
//    LOG_PRESCRIPTION(0,@"%@ Committed deletions to the local store",activityName);
    
    // Now clean up and cancel any local notifications associated with this prescription object
    LocalNotificationManager* notificationManager = [LocalNotificationManager instance];
    [notificationManager scheduleNotifications];

}

#pragma mark - Static Initializers
+ (Prescription *) createPrescriptionWithName:(NSString *)name 
                                   withMethod:(NSString *)method 
                                 withStrength:(NSNumber *)strength 
                                     withUnit:(NSString *)unit
                                withDateStart:(NSNumber *)dateStart
                            withNumberOfDoses:(NSNumber *)numberOfDoses
                           withRepeatMultiple:(NSNumber *)repeatMultiple
                             withRepeatPeriod:(NSNumber *)repeatPeriod
                            withOccurMultiple:(NSNumber *)occurMultiple
                                  withDateEnd:(NSNumber *)dateEnd
                                    withNotes:(NSString *)notes
{
    
    
    AuthenticationManager* authenticationManager = [AuthenticationManager instance];
    ResourceContext* resourceContext = [ResourceContext instance];
    Prescription* prescription = (Prescription*)[Resource createInstanceOfType:PRESCRIPTION withResourceContext:resourceContext];
    
    User* user = (User*)[resourceContext resourceWithType:USER withID:authenticationManager.m_LoggedInUserID];
    
    IDGenerator* idGenerator = [IDGenerator instance];
    NSNumber* prescriptionID = [idGenerator generateNewId:PRESCRIPTION];
    
    prescription.objectid = prescriptionID;
    
    prescription.userid = user.objectid;
    
    prescription.name = name;
    prescription.method = method;
    
    prescription.strength = strength;
    prescription.unit = unit;
    
    prescription.datestart = dateStart;
    prescription.numberofdoses = numberOfDoses;
    prescription.repeatmultiple = repeatMultiple;
    prescription.repeatperiod = repeatPeriod;
    prescription.occurmultiple = occurMultiple;
    prescription.dateend = dateEnd;
    
    prescription.notes = notes;
    
    return prescription;
    
}



@end