#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "Blog.h"
#import "BlogServiceRemoteREST.h"
#import "WordPressComApi.h"

@interface BlogServiceRemoteRESTTests : XCTestCase
@end

@implementation BlogServiceRemoteRESTTests

#pragma mark - Checking multi author for a blog

- (void)testThatCheckMultiAuthorForBlogWorks
{
    Blog *blog = OCMStrictClassMock([Blog class]);
    OCMStub([blog dotComID]).andReturn(@10);
    
    WordPressComApi *api = OCMStrictClassMock([WordPressComApi class]);
    BlogServiceRemoteREST *service = nil;
    
    NSString* url = [NSString stringWithFormat:@"v1.1/sites/%@/users", blog.dotComID];
    
    OCMStub([api GET:[OCMArg isEqual:url]
          parameters:[OCMArg isKindOfClass:[NSDictionary class]]
             success:[OCMArg isNotNil]
             failure:[OCMArg isNotNil]]);
    
    XCTAssertNoThrow(service = [[BlogServiceRemoteREST alloc] initWithApi:api]);
    
    [service checkMultiAuthorForBlogID:[blog dotComID]
                             success:^(BOOL isMultiAuthor) {}
                             failure:^(NSError *error) {}];
}


- (void)testThatCheckMultiAuthorForBlogThrowsExceptionWithoutBlog
{
    WordPressComApi *api = OCMStrictClassMock([WordPressComApi class]);
    BlogServiceRemoteREST *service = nil;
    
    XCTAssertNoThrow(service = [[BlogServiceRemoteREST alloc] initWithApi:api]);
    XCTAssertThrows([service checkMultiAuthorForBlogID:nil
                                             success:^(BOOL isMultiAuthor) {}
                                             failure:^(NSError *error) {}]);
}

#pragma mark - Synchronizing options for a blog

- (void)testThatSyncOptionForBlogWorks
{
    Blog *blog = OCMStrictClassMock([Blog class]);
    OCMStub([blog dotComID]).andReturn(@10);
    
    WordPressComApi *api = OCMStrictClassMock([WordPressComApi class]);
    BlogServiceRemoteREST *service = nil;
    
    NSString *url = [NSString stringWithFormat:@"v1.1/sites/%@", blog.dotComID];
    
    OCMStub([api GET:[OCMArg isEqual:url]
          parameters:[OCMArg isNil]
             success:[OCMArg isNotNil]
             failure:[OCMArg isNotNil]]);
    
    XCTAssertNoThrow(service = [[BlogServiceRemoteREST alloc] initWithApi:api]);
    
    [service syncOptionsForBlogID:[blog dotComID]
                          success:^(NSDictionary *options) {}
                          failure:^(NSError *error) {}];
}

- (void)testThatSyncOptionForBlogThrowsExceptionWithoutBlog
{
    WordPressComApi *api = OCMStrictClassMock([WordPressComApi class]);
    BlogServiceRemoteREST *service = nil;
    
    XCTAssertNoThrow(service = [[BlogServiceRemoteREST alloc] initWithApi:api]);
    XCTAssertThrows([service syncOptionsForBlogID:nil
                                        success:^(NSDictionary *options) {}
                                        failure:^(NSError *error) {}]);
}

#pragma mark - Synchronizing post formats for a blog

- (void)testThatSyncPostFormatsForBlogWorks
{
    Blog *blog = OCMStrictClassMock([Blog class]);
    OCMStub([blog dotComID]).andReturn(@10);
    
    WordPressComApi *api = OCMStrictClassMock([WordPressComApi class]);
    BlogServiceRemoteREST *service = nil;
    
    NSString* url = [NSString stringWithFormat:@"v1.1/sites/%@/post-formats", blog.dotComID];
    
    OCMStub([api GET:[OCMArg isEqual:url]
          parameters:[OCMArg isNil]
             success:[OCMArg isNotNil]
             failure:[OCMArg isNotNil]]);
    
    XCTAssertNoThrow(service = [[BlogServiceRemoteREST alloc] initWithApi:api]);
    
    [service syncPostFormatsForBlogID:[blog dotComID]
                              success:^(NSDictionary *options) {}
                              failure:^(NSError *error) {}];
}

- (void)testThatSyncPostFormatsForBlogThrowsExceptionWithoutBlog
{
    WordPressComApi *api = OCMStrictClassMock([WordPressComApi class]);
    BlogServiceRemoteREST *service = nil;
    
    XCTAssertNoThrow(service = [[BlogServiceRemoteREST alloc] initWithApi:api]);
    XCTAssertThrows([service syncPostFormatsForBlogID:nil
                                            success:^(NSDictionary *options) {}
                                            failure:^(NSError *error) {}]);
}


#pragma mark - Synchronizing connections for a blog

- (void)testThatSyncConnectionsForBlogWorks
{
    Blog *blog = OCMStrictClassMock([Blog class]);
    OCMStub([blog dotComID]).andReturn(@10);
    
    WordPressComApi *api = OCMStrictClassMock([WordPressComApi class]);
    BlogServiceRemoteREST *service = nil;
    
    NSString *url = [NSString stringWithFormat:@"v1.1/sites/%@/connections", blog.dotComID];
    
    OCMStub([api GET:[OCMArg isEqual:url]
          parameters:[OCMArg isNil]
             success:[OCMArg isNotNil]
             failure:[OCMArg isNotNil]]);
    
    XCTAssertNoThrow(service = [[BlogServiceRemoteREST alloc] initWithApi:api]);
    
    [service syncConnectionsForBlogID:blog.dotComID
                            success:^(NSArray *connections) {}
                            failure:^(NSError *error) {}];
}

- (void)testThatSyncConnectionsForBlogThrowsExceptionWithoutBlog
{
    WordPressComApi *api = OCMStrictClassMock([WordPressComApi class]);
    BlogServiceRemoteREST *service = nil;
    
    XCTAssertNoThrow(service = [[BlogServiceRemoteREST alloc] initWithApi:api]);
    XCTAssertThrows([service syncConnectionsForBlogID:nil
                                            success:^(NSArray *connections) {}
                                            failure:^(NSError *error) {}]);
}

@end
