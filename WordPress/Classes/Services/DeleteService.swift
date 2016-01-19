import CoreData
import WordPressComAnalytics

public extension Blog
{
    /// Only WordPress.com hosted sites we administer may be deleted
    func supportsDeleteServices() -> Bool {
        return isHostedAtWPcom && isAdmin
    }
}

/// DeleteService handles deletion of a user's site.

public class DeleteService : LocalCoreDataService
{
     /**
     Deletes the WordPress.com site for the specified blog.
     
     - parameter blog:    The Blog whose site to delete
     - parameter success: Optional success block with no parameters
     - parameter failure: Optional failure block with NSError parameter
     */
    public func deleteSiteForBlog(blog: Blog, success: (() -> ())?, failure: (NSError -> ())?) {
        let remote = DeleteServiceRemote(api: blog.restApi())
        remote.deleteSite(blog.dotComID, success: {
            self.purgeBlogData(blog)
            success?()
        },
        failure: { (error: NSError) -> Void in
            failure?(error)
        })
    }
    
    /**
     Deletes the specified blog from local CoreData store.
     
     - parameter blog: The Blog to delete
     */
    private func purgeBlogData(blog: Blog) {
        blog.restApi().operationQueue.cancelAllOperations()
        
        let jetpackAccount = blog.jetpackAccount

        managedObjectContext.delete(blog)
        managedObjectContext.processPendingChanges()
        
        if let jetpackAccount = jetpackAccount {
            let accountService = AccountService(managedObjectContext: managedObjectContext)
            accountService.purgeAccount(jetpackAccount)
        }
        
        ContextManager.sharedInstance().saveContext(managedObjectContext)
        WPAnalytics.refreshMetadata()
    }
}
