#import "Publicizer.h"

@implementation Publicizer

@dynamic service;
@dynamic label;
@dynamic detail;
@dynamic icon;
@dynamic connect;
@dynamic order;
@dynamic blog;

- (BOOL)isConnected
{
    return self.connectionID > 0;
}

- (NSInteger)connectionID
{
    for (NSDictionary *connection in self.blog.connections) {
        if ([[connection stringForKey:@"service"] isEqualToString:self.service]) {
            NSInteger connectionID = [[connection numberForKey:@"ID"] integerValue];
            return connectionID;
        }
    }
    return 0;
}

@end
