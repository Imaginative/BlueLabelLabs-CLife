//
//  PrescriptionInstanceManager.m
//  CLife
//
//  Created by Jasjeet Gill on 9/12/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "PrescriptionInstanceManager.h"
#import "Macros.h"

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
//all unused unconfirmed prescriptioninstance objects
- (void) deleteUnconfirmedPrescriotionInstanceObjectsFor:(Prescription *)prescription
{
    
}
//this method will iterate through all of the Prescriptions and depending on its end
//date and how many prescription instance objects remain will create additional ones as needed
- (void) createMissingPrescriptionInstanceObjects
{
    NSString* activityName = @"PrescriptionInstanceManager.createMissingPrescriptionInstanceObjects:";
    
    
}
@end
