//
//  PrescriptionInstanceManager.h
//  CLife
//
//  Created by Jasjeet Gill on 9/12/12.
//  Copyright (c) 2012 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Prescription.h"
@interface PrescriptionInstanceManager : NSObject

- (void) createMissingPrescriptionInstanceObjects;
- (void) deleteUnconfirmedPrescriotionInstanceObjectsFor:(Prescription*)prescription;
+ (PrescriptionInstanceManager*) instance;
@end
