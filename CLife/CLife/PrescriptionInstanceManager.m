//
//  PrescriptionInstanceManager.m
//  CLife
//
//  Created by Jasjeet Gill on 9/12/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "PrescriptionInstanceManager.h"
#import "Macros.h"
#import "Prescription.h"
#import "PrescriptionInstance.h"
#import "LocalNotificationManager.h"


@implementation PrescriptionInstanceManager


static PrescriptionInstanceManager* sharedManager;

+ (PrescriptionInstanceManager*) instance {
    @synchronized (self) {
        if (!sharedManager) {
            sharedManager = [[PrescriptionInstanceManager alloc]init];
        }
        return sharedManager;
    }
    
}




- (id) init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

//When a prescription is 'finished' by the user, we need to clean up the store and eliminate
//all unused unconfirmed prescriptioninstance objects in the future
- (void) deleteUnconfirmedPrescriptionInstanceObjectsFor:(Prescription *)prescription shouldSave:(BOOL)shouldSave
{   
    NSString* activityName = @"PrescriptionInstanceManager.deleteUnconfirmedPrescriptionInstanceObjectsFor:";
    
    NSDate* todaysDate = [NSDate date];
    
    //we grab a list of all unconfirmed prescription instances which are scheduled after today
    NSArray* unconfirmedPrescriptionInstances = [prescription unconfirmedPrescriptionInstancesAfter:todaysDate];
   
    ResourceContext* resourceContext = [ResourceContext instance];
    LOG_PRESCRIPTIONINSTANCEMANAGER(0,@"%@Deleting %d unconfirmed prescription instance objects associated with Prescription:%@ (%@)",activityName,[unconfirmedPrescriptionInstances count],prescription.objectid,prescription.name);
    
    //now that we have these objects, we can go ahead and delete them
    for (PrescriptionInstance* prescriptionInstance in unconfirmedPrescriptionInstances) {
        
        [resourceContext delete:prescriptionInstance.objectid withType:PRESCRIPTIONINSTANCE];
        
    }
    
    if (shouldSave)
    {
        [resourceContext save:NO onFinishCallback:nil trackProgressWith:nil];
        LOG_PRESCRIPTION(0,@"%@ Committed deletions to the local store",activityName);
    }    
    
}

//When a prescription is 'deleted' by the user, we need to clean up the store and eliminate
//all prescriptioninstance objects releated to this prescription, past, present and future.
- (void) deletePrescriptionInstanceObjectsFor:(Prescription *)prescription shouldSave:(BOOL)shouldSave
{   
    NSString* activityName = @"PrescriptionInstanceManager.deletePrescriptionInstanceObjectsFor:";
    
    //we grab a list of all prescription instances for this prescription
    NSArray* prescriptionInstances = [prescription prescriptionInstances];
    
    ResourceContext* resourceContext = [ResourceContext instance];
    LOG_PRESCRIPTIONINSTANCEMANAGER(0,@"%@Deleting %d prescription instance objects associated with Prescription:%@ (%@)", activityName, [prescriptionInstances count], prescription.objectid, prescription.name);
    
    //now that we have these objects, we can go ahead and delete them
    for (PrescriptionInstance* prescriptionInstance in prescriptionInstances) {
        // First, cancel any associated Local Notifications
        LocalNotificationManager* notificationManager = [LocalNotificationManager instance];
        
        NSArray *notifications = [notificationManager localNotificationsForPrescriptionInstance:prescriptionInstance];
        
        for (UILocalNotification *notification in notifications) {
            /* NSLog */
            NSDateFormatter *dateAndTimeFormatter = [[[NSDateFormatter alloc] init] autorelease];
            [dateAndTimeFormatter setDateStyle:NSDateFormatterMediumStyle];
            [dateAndTimeFormatter setTimeStyle:NSDateFormatterShortStyle];
            NSLog([NSString stringWithFormat:@"Canceled Local Notification for PrescriptionInstanceID:%@, with FireDate:%@", [prescriptionInstance.objectid stringValue], [dateAndTimeFormatter stringFromDate:notification.fireDate]]);
            
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
        
        // Now delete the object
        [resourceContext delete:prescriptionInstance.objectid withType:PRESCRIPTIONINSTANCE];
        NSLog([NSString stringWithFormat:@"Deleted PrescriptionInstance with ID:%@", [prescriptionInstance.objectid stringValue]]);
    }
    
    if (shouldSave)
    {
        [resourceContext save:NO onFinishCallback:nil trackProgressWith:nil];
        LOG_PRESCRIPTION(0,@"%@ Committed deletions to the local store",activityName);
    }    
    
}

//this method will iterate through all of the Prescriptions and depending on its end
//date and how many prescription instance objects remain will create additional ones as needed
- (void) createMissingPrescriptionInstanceObjects
{
    NSString* activityName = @"PrescriptionInstanceManager.createMissingPrescriptionInstanceObjects:";
    
    
}
@end
