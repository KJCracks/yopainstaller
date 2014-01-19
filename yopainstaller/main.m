//
//  main.m
//  yopainstaller
//
//  Created by Zorro on 19.01.14.
//  Copyright (c) 2014 Zorro. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <xpc.h>

int main (int argc, const char * argv[])
{
    
    @autoreleasepool
    {
        
        if (argc!=2)
        {
            printf("%s yopa_file \n",[NSString stringWithFormat:@"%s",argv[0]].lastPathComponent.UTF8String);
            return 666;
        }
        
        NSString *yopaPath = [NSString stringWithFormat:@"%s",argv[1]];
        
        xpc_connection_t c = xpc_connection_create_mach_service("zorro.yopainstalld", NULL, 0);
        
        
        xpc_connection_set_event_handler(c, ^(xpc_object_t event)
                                         {
                                             xpc_type_t type = xpc_get_type(event);
                                             if (xpc_get_type(event) == XPC_TYPE_ERROR) {
                                                 if (event == XPC_ERROR_CONNECTION_INVALID)
                                                 {
                                                     NSLog(@"DAFUQ JUST HAPPENED. make sure you are r00t");
                                                     xpc_connection_cancel(c);
                                                     
                                                 } else if (event == XPC_ERROR_TERMINATION_IMMINENT)
                                                 {
                                                     NSLog(@"TERMINATOR!!!!!!!");
                                                     //dunno what to do
                                                 }
                                             } else {
                                                 assert(type == XPC_TYPE_DICTIONARY);
                                                 
                                                 NSString *status = [NSString stringWithUTF8String:xpc_dictionary_get_string(event, "Status")];
                                                 
                                                 
                                                 if ([status isEqualToString:@"Complete"]) {
                                                     NSLog(@"Complete! YAY");
                                                     xpc_connection_cancel(c);
                                                 }
                                                 else if ([status isEqualToString:@"Error"])
                                                 {
                                                     NSString *error = nil;
                                                     
                                                     if (xpc_dictionary_get_string(event, "Error")) {
                                                         error = [NSString stringWithUTF8String:xpc_dictionary_get_string(event, "Error")];
                                                     }

                                                     NSLog(@"Error %@",error);
                                                     
                                                     xpc_connection_cancel(c);
                                                     
                                                 }
                                                 else
                                                 {
                                                     NSLog(@"%@",status);
                                                 }
                                                 
                                             }
                                         });
        xpc_connection_resume(c);
        
        // Messages are always dictionaries.
        xpc_object_t message = xpc_dictionary_create(NULL, NULL, 0);
        xpc_dictionary_set_string(message, "Command", "Install");
        xpc_dictionary_set_string(message, "PackagePath", yopaPath.UTF8String);
        
        xpc_object_t reply = xpc_connection_send_message_with_reply_sync(c, message);
        
        xpc_release(message);
        
        xpc_type_t type = xpc_get_type(reply);
        if (xpc_get_type(reply) == XPC_TYPE_ERROR) {
            if (reply == XPC_ERROR_CONNECTION_INVALID)
            {
                NSLog(@"DAFUQ JUST HAPPENED. make sure you are r00t");
                xpc_connection_cancel(c);
                
            } else if (reply == XPC_ERROR_TERMINATION_IMMINENT)
            {
                NSLog(@"TERMINATOR!!!!!!!");
                //dunno what to do
            }
        } else {
            assert(type == XPC_TYPE_DICTIONARY);
            
            NSString *status = [NSString stringWithUTF8String:xpc_dictionary_get_string(reply, "Status")];
            
            
            if ([status isEqualToString:@"Complete"]) {
                NSLog(@"Complete! YAY");
                xpc_connection_cancel(c);
            }
            else if ([status isEqualToString:@"Error"])
            {
                NSString *error = nil;
                
                if (xpc_dictionary_get_string(reply, "Error")) {
                    error = [NSString stringWithUTF8String:xpc_dictionary_get_string(reply, "Error")];
                }
                
                NSLog(@"Error %@",error);
                
                xpc_connection_cancel(c);
                
            }
            else
            {
                NSLog(@"%@",status);
            }
            
        }
        
        
    }
	return 0;
}


