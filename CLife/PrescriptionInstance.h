//
//  PrescriptionInstance.h
//  CLife
//
//  Created by Jasjeet Gill on 8/14/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import "Resource.h"
#import "Prescription.h"

@interface PrescriptionInstance : Resource
{
 
}

@property (nonatomic,retain) NSNumber* prescriptionid;
@property (nonatomic,retain) NSString* prescriptionname;
@property (nonatomic,retain) NSNumber* datescheduled;
@property (nonatomic,retain) NSNumber* datetaken;
@property (nonatomic,retain) NSNumber* state;
@property (nonatomic,retain) NSString* notes;
@property (nonatomic,retain) NSNumber* hasnotificationbeenscheduled;
@property (nonatomic,retain) Prescription* prescription;

- (NSDate*) fireDate;
- (UILocalNotification*) createLocalNotification;
+ (NSArray*) createPrescriptionInstancesFor:(Prescription*)prescription;
@end
