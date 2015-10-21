#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>
#import "Blog.h"
#import "ContextManager.h"
#import "PostServiceRemoteREST.h"
#import "RemotePost.h"
#import "TestContextManager.h"
#import "WordPressComApi.h"

@interface PostServiceRemoteRESTTests : XCTestCase
@end

@implementation PostServiceRemoteRESTTests

#pragma mark - Common

/**
 *  @brief      Common method for instantiating and initializing the service object.
 *  @details    This is only useful for cases that don't need to mock the API object.
 *
 *  @returns    The newly created service object.
 */
- (PostServiceRemoteREST*)service
{
    WordPressComApi *api = [[WordPressComApi alloc] initWithBaseURL:[NSURL URLWithString:@""]];
    return [[PostServiceRemoteREST alloc] initWithApi:api];
}

#pragma mark - Getting posts by ID

- (void)testThatGetPostWithIDWorks
{
    Blog *blog = OCMStrictClassMock([Blog class]);
    OCMStub([blog dotComID]).andReturn(@10);
    
    WordPressComApi *api = OCMStrictClassMock([WordPressComApi class]);
    PostServiceRemoteREST *service = nil;
    
    NSNumber *postID = @1;
    
    NSString* url = [NSString stringWithFormat:@"v1.1/sites/%@/posts/%@", [blog dotComID], postID];
    
    OCMStub([api GET:[OCMArg isEqual:url]
          parameters:[OCMArg isNotNil]
             success:[OCMArg isNotNil]
             failure:[OCMArg isNotNil]]);
    
    XCTAssertNoThrow(service = [[PostServiceRemoteREST alloc] initWithApi:api]);
    
    [service getPostWithID:postID
                 forBlogID:[blog dotComID]
                   success:^(RemotePost *post) {}
                   failure:^(NSError *error) {}];
}

- (void)testThatGetPostWithIDThrowsExceptionWithoutPostID
{
    Blog *blog = OCMStrictClassMock([Blog class]);
    OCMStub([blog dotComID]).andReturn(@10);
    
    PostServiceRemoteREST *service = nil;
    
    XCTAssertNoThrow(service = [self service]);
    XCTAssertThrows([service getPostWithID:nil
                                 forBlogID:[blog dotComID]
                                   success:^(RemotePost *post) {}
                                   failure:^(NSError *error) {}]);
}

- (void)testThatGetPostWithIDThrowsExceptionWithoutBlog
{
    PostServiceRemoteREST *service = nil;
    
    XCTAssertNoThrow(service = [self service]);
    XCTAssertThrows([service getPostWithID:@2
                                 forBlogID:nil
                                   success:^(RemotePost *post) {}
                                   failure:^(NSError *error) {}]);
}

#pragma mark - Getting posts by type

- (void)testThatGetPostsOfTypeWorks
{
    Blog *blog = OCMStrictClassMock([Blog class]);
    OCMStub([blog dotComID]).andReturn(@10);
    
    WordPressComApi *api = OCMStrictClassMock([WordPressComApi class]);
    PostServiceRemoteREST *service = nil;
    
    NSString* postType = @"SomeType";
    
    NSString* url = [NSString stringWithFormat:@"v1.1/sites/%@/posts", blog.dotComID];
    
    BOOL (^parametersCheckBlock)(id obj) = ^BOOL(NSDictionary *parameters) {
        
        return ([parameters isKindOfClass:[NSDictionary class]]
                && [[parameters objectForKey:@"type"] isEqualToString:postType]);
    };
    
    OCMStub([api GET:[OCMArg isEqual:url]
          parameters:[OCMArg checkWithBlock:parametersCheckBlock]
             success:[OCMArg isNotNil]
             failure:[OCMArg isNotNil]]);
    
    XCTAssertNoThrow(service = [[PostServiceRemoteREST alloc] initWithApi:api]);
    
    [service getPostsOfType:postType
                  forBlogID:[blog dotComID]
                    success:^(NSArray *posts) {}
                    failure:^(NSError *error) {}];
}

- (void)testThatGetPostsOfTypeThrowsExceptionWithoutBlog
{
    PostServiceRemoteREST *service = nil;
    
    XCTAssertNoThrow(service = [self service]);
    XCTAssertThrows([service getPostsOfType:@"SomeType"
                                  forBlogID:nil
                                    success:^(NSArray *posts) {}
                                    failure:^(NSError *error) {}]);
}

- (void)testThatGetPostsOfTypeWithOptionsWorks
{
    Blog *blog = OCMStrictClassMock([Blog class]);
    OCMStub([blog dotComID]).andReturn(@10);
    
    WordPressComApi *api = OCMStrictClassMock([WordPressComApi class]);
    PostServiceRemoteREST *service = nil;
    
    NSString* postType = @"SomeType";
    
    NSString* url = [NSString stringWithFormat:@"v1.1/sites/%@/posts", blog.dotComID];
    
    NSString *testOptionKey = @"SomeKey";
    NSString *testOptionValue = @"SomeValue";
    NSDictionary *options = @{testOptionKey: testOptionValue};
    
    BOOL (^parametersCheckBlock)(id obj) = ^BOOL(NSDictionary *parameters) {
        
        return ([parameters isKindOfClass:[NSDictionary class]]
                && [[parameters objectForKey:@"type"] isEqualToString:postType]
                && [parameters objectForKey:testOptionKey] == testOptionValue);
    };
    
    OCMStub([api GET:[OCMArg isEqual:url]
          parameters:[OCMArg checkWithBlock:parametersCheckBlock]
             success:[OCMArg isNotNil]
             failure:[OCMArg isNotNil]]);
    
    XCTAssertNoThrow(service = [[PostServiceRemoteREST alloc] initWithApi:api]);
    
    [service getPostsOfType:postType
                  forBlogID:[blog dotComID]
                    options:options
                    success:^(NSArray *posts) {}
                    failure:^(NSError *error) {}];
}

- (void)testThatGetPostsOfTypeWithOptionsThrowsExceptionWithoutBlog
{
    PostServiceRemoteREST *service = nil;
    
    XCTAssertNoThrow(service = [self service]);
    XCTAssertThrows([service getPostsOfType:@"SomeType"
                                  forBlogID:nil
                                    options:@{}
                                    success:^(NSArray *posts) {}
                                    failure:^(NSError *error) {}]);
}

#pragma mark - Creating posts

- (void)testThatCreatePostWorks
{
    Blog *blog = OCMStrictClassMock([Blog class]);
    OCMStub([blog dotComID]).andReturn(@10);
    
    WordPressComApi *api = OCMStrictClassMock([WordPressComApi class]);
    PostServiceRemoteREST *service = nil;
    
    RemotePost *post = OCMClassMock([RemotePost class]);
    OCMStub([post title]).andReturn(@"Title");
    OCMStub([post content]).andReturn(@"Content");
    OCMStub([post status]).andReturn(@"Status");
    OCMStub([post password]).andReturn(@"Password");
    OCMStub([post type]).andReturn(@"Type");
    OCMStub([post metadata]).andReturn(@[]);
    
    NSString* url = [NSString stringWithFormat:@"v1.1/sites/%@/posts/new?context=edit", blog.dotComID];
    
    OCMStub([api POST:[OCMArg isEqual:url]
           parameters:[OCMArg isKindOfClass:[NSDictionary class]]
              success:[OCMArg isNotNil]
              failure:[OCMArg isNotNil]]);
    
    XCTAssertNoThrow(service = [[PostServiceRemoteREST alloc] initWithApi:api]);
    
    [service createPost:post
              forBlogID:[blog dotComID]
                success:^(RemotePost *posts) {}
                failure:^(NSError *error) {}];
}

- (void)testThatCreatePostThrowsExceptionWithoutPost
{
    Blog *blog = OCMStrictClassMock([Blog class]);
    OCMStub([blog dotComID]).andReturn(@10);
    
    PostServiceRemoteREST *service = nil;
    
    XCTAssertNoThrow(service = [self service]);
    XCTAssertThrows([service createPost:nil
                              forBlogID:[blog dotComID]
                                success:^(RemotePost *posts) {}
                                failure:^(NSError *error) {}]);
}

- (void)testThatCreatePostThrowsExceptionWithoutBlog
{
    RemotePost *post = OCMClassMock([RemotePost class]);
    
    PostServiceRemoteREST *service = nil;
    
    XCTAssertNoThrow(service = [self service]);
    XCTAssertThrows([service createPost:post
                              forBlogID:nil
                                success:^(RemotePost *posts) {}
                                failure:^(NSError *error) {}]);
}

#pragma mark - Updating posts

- (void)testThatUpdatePostWorks
{
    Blog *blog = OCMStrictClassMock([Blog class]);
    OCMStub([blog dotComID]).andReturn(@10);
    
    WordPressComApi *api = OCMStrictClassMock([WordPressComApi class]);
    PostServiceRemoteREST *service = nil;
    
    RemotePost *post = OCMClassMock([RemotePost class]);
    OCMStub([post postID]).andReturn(@1);
    OCMStub([post title]).andReturn(@"Title");
    OCMStub([post content]).andReturn(@"Content");
    OCMStub([post status]).andReturn(@"Status");
    OCMStub([post password]).andReturn(@"Password");
    OCMStub([post type]).andReturn(@"Type");
    OCMStub([post metadata]).andReturn(@[]);
    
    NSString* url = [NSString stringWithFormat:@"v1.1/sites/%@/posts/%@?context=edit", blog.dotComID, post.postID];
    
    OCMStub([api POST:[OCMArg isEqual:url]
           parameters:[OCMArg isKindOfClass:[NSDictionary class]]
              success:[OCMArg isNotNil]
              failure:[OCMArg isNotNil]]);
    
    XCTAssertNoThrow(service = [[PostServiceRemoteREST alloc] initWithApi:api]);
    
    [service updatePost:post
              forBlogID:[blog dotComID]
                success:^(RemotePost *posts) {}
                failure:^(NSError *error) {}];
}

- (void)testThatUpdatePostThrowsExceptionWithoutPost
{
    Blog *blog = OCMStrictClassMock([Blog class]);
    OCMStub([blog dotComID]).andReturn(@10);
    
    PostServiceRemoteREST *service = nil;
    
    XCTAssertNoThrow(service = [self service]);
    XCTAssertThrows([service updatePost:nil
                              forBlogID:[blog dotComID]
                                success:^(RemotePost *posts) {}
                                failure:^(NSError *error) {}]);
}

- (void)testThatUpdatePostThrowsExceptionWithoutBlog
{
    RemotePost *post = OCMClassMock([RemotePost class]);
    
    PostServiceRemoteREST *service = nil;
    
    XCTAssertNoThrow(service = [self service]);
    XCTAssertThrows([service updatePost:post
                              forBlogID:nil
                                success:^(RemotePost *posts) {}
                                failure:^(NSError *error) {}]);
}

#pragma mark - Deleting posts

- (void)testThatDeletePostWorks
{
    Blog *blog = OCMStrictClassMock([Blog class]);
    OCMStub([blog dotComID]).andReturn(@10);
    
    WordPressComApi *api = OCMStrictClassMock([WordPressComApi class]);
    PostServiceRemoteREST *service = nil;
    
    RemotePost *post = OCMClassMock([RemotePost class]);
    OCMStub([post postID]).andReturn(@1);
    
    NSString* url = [NSString stringWithFormat:@"v1.1/sites/%@/posts/%@/delete", blog.dotComID, post.postID];
    
    OCMStub([api POST:[OCMArg isEqual:url]
           parameters:[OCMArg isNil]
              success:[OCMArg isNotNil]
              failure:[OCMArg isNotNil]]);
    
    XCTAssertNoThrow(service = [[PostServiceRemoteREST alloc] initWithApi:api]);
    
    [service deletePost:post
              forBlogID:[blog dotComID]
                success:^(RemotePost *posts) {}
                failure:^(NSError *error) {}];
}

- (void)testThatDeletePostThrowsExceptionWithoutPost
{
    Blog *blog = OCMStrictClassMock([Blog class]);
    OCMStub([blog dotComID]).andReturn(@10);
    
    PostServiceRemoteREST *service = nil;
    
    XCTAssertNoThrow(service = [self service]);
    XCTAssertThrows([service deletePost:nil
                              forBlogID:[blog dotComID]
                                success:^(RemotePost *posts) {}
                                failure:^(NSError *error) {}]);
}

- (void)testThatDeletePostThrowsExceptionWithoutBlog
{
    RemotePost *post = OCMClassMock([RemotePost class]);
    
    PostServiceRemoteREST *service = nil;
    
    XCTAssertNoThrow(service = [self service]);
    XCTAssertThrows([service deletePost:post
                              forBlogID:nil
                                success:^(RemotePost *posts) {}
                                failure:^(NSError *error) {}]);
}

#pragma mark - Trashing posts

- (void)testThatTrashPostWorks
{
    Blog *blog = OCMStrictClassMock([Blog class]);
    OCMStub([blog dotComID]).andReturn(@10);
    
    WordPressComApi *api = OCMStrictClassMock([WordPressComApi class]);
    PostServiceRemoteREST *service = nil;
    
    RemotePost *post = OCMClassMock([RemotePost class]);
    OCMStub([post postID]).andReturn(@1);
    
    NSString* url = [NSString stringWithFormat:@"v1.1/sites/%@/posts/%@/delete", blog.dotComID, post.postID];
    
    OCMStub([api POST:[OCMArg isEqual:url]
           parameters:[OCMArg isNil]
              success:[OCMArg isNotNil]
              failure:[OCMArg isNotNil]]);
    
    XCTAssertNoThrow(service = [[PostServiceRemoteREST alloc] initWithApi:api]);
    
    [service trashPost:post
             forBlogID:[blog dotComID]
               success:^(RemotePost *posts) {}
               failure:^(NSError *error) {}];
}

- (void)testThatTashPostThrowsExceptionWithoutPost
{
    Blog *blog = OCMStrictClassMock([Blog class]);
    OCMStub([blog dotComID]).andReturn(@10);
    
    PostServiceRemoteREST *service = nil;
    
    XCTAssertNoThrow(service = [self service]);
    XCTAssertThrows([service trashPost:nil
                             forBlogID:[blog dotComID]
                               success:^(RemotePost *posts) {}
                               failure:^(NSError *error) {}]);
}

- (void)testThatTrashPostThrowsExceptionWithoutBlog
{
    RemotePost *post = OCMClassMock([RemotePost class]);
    
    PostServiceRemoteREST *service = nil;
    
    XCTAssertNoThrow(service = [self service]);
    XCTAssertThrows([service trashPost:post
                             forBlogID:nil
                               success:^(RemotePost *posts) {}
                               failure:^(NSError *error) {}]);
}

#pragma mark - Trashing posts

- (void)testThatRestorePostWorks
{
    Blog *blog = OCMStrictClassMock([Blog class]);
    OCMStub([blog dotComID]).andReturn(@10);
    
    WordPressComApi *api = OCMStrictClassMock([WordPressComApi class]);
    PostServiceRemoteREST *service = nil;
    
    RemotePost *post = OCMClassMock([RemotePost class]);
    OCMStub([post postID]).andReturn(@1);
    
    NSString* url = [NSString stringWithFormat:@"v1.1/sites/%@/posts/%@/restore", blog.dotComID, post.postID];
    
    OCMStub([api POST:[OCMArg isEqual:url]
           parameters:[OCMArg isNil]
              success:[OCMArg isNotNil]
              failure:[OCMArg isNotNil]]);
    
    XCTAssertNoThrow(service = [[PostServiceRemoteREST alloc] initWithApi:api]);
    
    [service restorePost:post
               forBlogID:[blog dotComID]
                 success:^(RemotePost *posts) {}
                 failure:^(NSError *error) {}];
}

- (void)testThatRestorePostThrowsExceptionWithoutPost
{
    Blog *blog = OCMStrictClassMock([Blog class]);
    OCMStub([blog dotComID]).andReturn(@10);
    
    PostServiceRemoteREST *service = nil;
    
    XCTAssertNoThrow(service = [self service]);
    XCTAssertThrows([service restorePost:nil
                               forBlogID:[blog dotComID]
                                 success:^(RemotePost *posts) {}
                                 failure:^(NSError *error) {}]);
}

- (void)testThatRestorePostThrowsExceptionWithoutBlog
{
    RemotePost *post = OCMClassMock([RemotePost class]);
    
    PostServiceRemoteREST *service = nil;
    
    XCTAssertNoThrow(service = [self service]);
    XCTAssertThrows([service restorePost:post
                               forBlogID:nil
                                 success:^(RemotePost *posts) {}
                                 failure:^(NSError *error) {}]);
}

@end
