//
//  User.h
//  Platform
//
//  Created by Bobby Gill on 10/7/11.
//  Copyright 2011 Blue Label Solutions LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Resource.h"

@interface User : Resource {
    
}

@property (nonatomic,retain) NSString* app_version;
@property (nonatomic,retain) NSString* devicetoken;
@property (nonatomic,retain) NSString* displayname;
@property (nonatomic,retain) NSString* email;
@property (nonatomic,retain) NSNumber* fb_user_id;
@property (nonatomic,retain) NSString* imageurl;


@property (nonatomic,retain) NSString* thumbnailurl;
@property (nonatomic,retain) NSString* twitter_user_id;
@property (nonatomic,retain) NSString* username;


@property (nonatomic,retain) NSString* sex;
@property (nonatomic,retain) NSNumber* dateborn;
@property (nonatomic,retain) NSString* bloodtype;


+ (void) deleteUserWithID:(NSNumber *)userID;

+ (User*) createNewDefaultUser;

@end
