#import "BlogServiceRemoteREST.h"
#import <WordPressComApi.h>
#import "Blog.h"
#import "PostCategory.h"
#import "RemoteBlogSettings.h"
#import "Publicizer.h"

@implementation BlogServiceRemoteREST

- (void)checkMultiAuthorForBlog:(Blog *)blog
                        success:(void(^)(BOOL isMultiAuthor))success
                        failure:(void (^)(NSError *error))failure
{
    NSParameterAssert([blog isKindOfClass:[Blog class]]);
    NSParameterAssert(blog.dotComID != nil);
    
    NSDictionary *parameters = @{@"authors_only":@(YES)};
    NSString *path = [NSString stringWithFormat:@"sites/%@/users", blog.dotComID];
    [self.api GET:path
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              if (success) {
                  NSDictionary *response = (NSDictionary *)responseObject;
                  BOOL isMultiAuthor = [[response arrayForKey:@"users"] count] > 1;
                  success(isMultiAuthor);
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (failure) {
                  failure(error);
              }
          }];
}

- (void)syncOptionsForBlog:(Blog *)blog
                   success:(OptionsHandler)success
                   failure:(void (^)(NSError *))failure
{
    NSParameterAssert([blog isKindOfClass:[Blog class]]);
    NSParameterAssert(blog.dotComID != nil);
    
    NSString *path = [self pathForOptionsWithBlog:blog];
    [self.api GET:path
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSDictionary *response = (NSDictionary *)responseObject;
              NSDictionary *options = [self mapOptionsFromResponse:response];
              if (success) {
                  success(options);
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (failure) {
                  failure(error);
              }
          }];
}

- (void)syncPostFormatsForBlog:(Blog *)blog
                       success:(PostFormatsHandler)success
                       failure:(void (^)(NSError *))failure
{
    NSParameterAssert([blog isKindOfClass:[Blog class]]);
    NSParameterAssert(blog.dotComID != nil);
    
    NSString *path = [self pathForPostFormatsWithBlog:blog];
    [self.api GET:path
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSDictionary *formats = [responseObject dictionaryForKey:@"formats"];
              if (success) {
                  success(formats ?: @{});
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (failure) {
                  failure(error);
              }
          }];
}

- (void)syncConnectionsForBlog:(Blog *)blog
                       success:(ConnectionsHandler)success
                       failure:(void (^)(NSError *))failure
{
    NSParameterAssert([blog isKindOfClass:[Blog class]]);
    NSParameterAssert(blog.dotComID != nil);
    
    NSString *path = [self pathForConnectionsWithBlog:blog];
    [self.api GET:path
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSArray *connections = [responseObject arrayForKey:@"connections"];
              if (success) {
                  success(connections ?: @[]);
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (failure) {
                  failure(error);
              }
          }];
}

- (void)checkAuthorizationForPublicizer:(Publicizer *)service
                                success:(AuthorizationHandler)success
                                failure:(void (^)(NSError *))failure
{
    NSParameterAssert([service isKindOfClass:[Publicizer class]]);
    NSParameterAssert(service.blog.dotComID != nil);
    
    NSString *path = @"me/keyring-connections";
    [self.api GET:path
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              NSArray *keyrings = [responseObject arrayForKey:@"connections"];
              for (NSDictionary *keyring in keyrings) {
                  if ([keyring[@"service"] isEqualToString:service.service]) {
                      if (success) {
                          success(keyring);
                      }
                      return;
                  }
              }
              if (failure) {
                  failure(nil);
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (failure) {
                  failure(error);
              }
          }];
}

- (void)connectPublicizer:(Publicizer *)service
        withAuthorization:(NSDictionary *)authorization
                  success:(ConnectionsHandler)success
                  failure:(void (^)(NSError *))failure
{
    NSParameterAssert([service isKindOfClass:[Publicizer class]]);
    NSParameterAssert(service.blog.dotComID != nil);
    
    NSString *path = [self pathForConnectionWithPublicizer:service];
    NSDictionary *parameters = @{ @"keyring_connection_ID" : authorization[@"ID"] };
    [self.api POST:path
       parameters:parameters
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              [self syncConnectionsForBlog:service.blog
                                   success:success
                                   failure:failure];
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (failure) {
                  failure(error);
              }
          }];
}

- (void)disconnectPublicizer:(Publicizer *)service
                     success:(ConnectionsHandler)success
                     failure:(void (^)(NSError *))failure
{
    NSParameterAssert([service isKindOfClass:[Publicizer class]]);
    NSParameterAssert(service.blog.dotComID != nil);
    
    NSString *path = [self pathForDisconnectionWithPublicizer:service];
    [self.api POST:path
        parameters:nil
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               [self syncConnectionsForBlog:service.blog
                                    success:success
                                    failure:failure];
           } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               if (failure) {
                   failure(error);
               }
           }];
}

- (void)syncSettingsForBlog:(Blog *)blog
                    success:(SettingsHandler)success
                    failure:(void (^)(NSError *error))failure
{
    NSParameterAssert([blog isKindOfClass:[Blog class]]);
    NSParameterAssert(blog.dotComID != nil);
    
    NSString *path = [self pathForSettingsWithBlog:blog];
    [self.api GET:path
       parameters:nil
          success:^(AFHTTPRequestOperation *operation, id responseObject) {
              if (![responseObject isKindOfClass:[NSDictionary class]]){
                  if (failure) {
                      failure(nil);
                  }
              }
              NSDictionary *jsonDictionary = (NSDictionary *)responseObject;
              RemoteBlogSettings *remoteSettings = [self remoteBlogSettingFromJSONDictionary:jsonDictionary];
              if (success) {
                  success(remoteSettings);
              }
          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
              if (failure) {
                  failure(error);
              }
          }];
}

- (void)updateSettingsForBlog:(Blog *)blog
                      success:(SuccessHandler)success
                      failure:(void (^)(NSError *error))failure
{
    NSParameterAssert([blog isKindOfClass:[Blog class]]);
    NSDictionary *parameters = @{ @"blogname" : blog.blogName,
                                  @"blogdescription" : blog.blogTagline,
                                  @"default_category" : blog.defaultCategoryID,
                                  @"default_post_format" : blog.defaultPostFormat
                                  };
    NSString *path = [NSString stringWithFormat:@"sites/%@/settings?context=edit", blog.dotComID];
    [self.api POST:path
        parameters:parameters
           success:^(AFHTTPRequestOperation *operation, id responseObject) {
               if (![responseObject isKindOfClass:[NSDictionary class]]) {
                   if (failure) {
                       failure(nil);
                   }
               }
               NSDictionary *jsonDictionary = (NSDictionary *)responseObject;
               if (!jsonDictionary[@"updated"]) {
                   if (failure) {
                       failure(nil);
                   }
               }
               if (success) {
                   success();
               }
           }
           failure:^(AFHTTPRequestOperation *operation, NSError *error) {
               if (failure) {
                   failure(error);
               }
           }];
}

#pragma mark - API paths

- (NSString *)pathForOptionsWithBlog:(Blog *)blog
{
    return [NSString stringWithFormat:@"sites/%@", blog.dotComID];
}

- (NSString *)pathForPostFormatsWithBlog:(Blog *)blog
{
    return [NSString stringWithFormat:@"sites/%@/post-formats", blog.dotComID];
}

- (NSString *)pathForConnectionsWithBlog:(Blog *)blog
{
    // Also note /publicize-connections specific call
    return [NSString stringWithFormat:@"sites/%@/connections", blog.dotComID];
}

- (NSString *)pathForConnectionWithPublicizer:(Publicizer *)service
{
    return [NSString stringWithFormat:@"sites/%@/publicize-connections/new", service.blog.dotComID];
}

- (NSString *)pathForDisconnectionWithPublicizer:(Publicizer *)service
{
    return [NSString stringWithFormat:@"sites/%@/connections/%d/delete", service.blog.dotComID, service.connectionID];
}

- (NSString *)pathForSettingsWithBlog:(Blog *)blog
{
    return [NSString stringWithFormat:@"sites/%@/settings", blog.dotComID];
}


#pragma mark - Mapping methods

- (NSDictionary *)mapOptionsFromResponse:(NSDictionary *)response
{
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    options[@"home_url"] = response[@"URL"];
    // We'd be better off saving this as a BOOL property on Blog, but let's do what XML-RPC does for now
    options[@"blog_public"] = [[response numberForKey:@"is_private"] boolValue] ? @"-1" : @"0";
    if ([[response numberForKey:@"jetpack"] boolValue]) {
        options[@"jetpack_client_id"] = [response numberForKey:@"ID"];
    }
    if ( response[@"options"] ) {
        options[@"post_thumbnail"] = [response valueForKeyPath:@"options.featured_images_enabled"];
        NSArray *optionsDirectMapKeys = @[
                                    @"admin_url",
                                    @"login_url",
                                    @"image_default_link_type",
                                    @"software_version",
                                    @"videopress_enabled",
                                    @"timezone",
                                    @"gmt_offset",
                                    @"allowed_file_types",
                                    ];

        for (NSString *key in optionsDirectMapKeys) {
            NSString *sourceKeyPath = [NSString stringWithFormat:@"options.%@", key];
            options[key] = [response valueForKeyPath:sourceKeyPath];
        }
    } else {
        //valid default values
        options[@"software_version"] = @"3.6";
    }
    NSMutableDictionary *valueOptions = [NSMutableDictionary dictionaryWithCapacity:options.count];
    [options enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        valueOptions[key] = @{@"value": obj};
    }];

    return [NSDictionary dictionaryWithDictionary:valueOptions ];
}

- (RemoteBlogSettings *)remoteBlogSettingFromJSONDictionary:(NSDictionary *)json
{
    RemoteBlogSettings *remoteSettings = [[RemoteBlogSettings alloc] init];
    
    remoteSettings.name = [json stringForKey:@"name"];
    remoteSettings.desc = [json stringForKey:@"description"];
    
    if (json[@"settings"][@"default_category"]) {
        remoteSettings.defaultCategory = [json numberForKeyPath:@"settings.default_category"];
    } else {
        remoteSettings.defaultCategory = @(PostCategoryUncategorized);
    }
    if ([json[@"settings"][@"default_post_format"] isEqualToString:@"0"]) {
        remoteSettings.defaultPostFormat = PostFormatStandard;
    } else {
        remoteSettings.defaultPostFormat = [json stringForKeyPath:@"settings.default_post_format"];
    }
    
    return remoteSettings;
}

@end
