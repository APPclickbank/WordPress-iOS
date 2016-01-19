import Foundation
import AFNetworking
import NSObject_SafeExpectations


/// DeleteServiceRemote handles REST API calls related to deletion of a user's site.

public class DeleteServiceRemote : ServiceRemoteREST
{
     /**
     Deletes the specified WordPress.com site.
     
     - parameter siteID:  The WordPress.com ID of the site.
     - parameter success: Optional success block with no parameters
     - parameter failure: Optional failure block with NSError parameter
     */
    public func deleteSite(siteID: NSNumber, success: (() -> ())?, failure: (NSError -> ())?) {
        let endpoint = "sites/\(siteID)/delete"
        let path = self.pathForEndpoint(endpoint, withVersion: ServiceRemoteRESTApiVersion_1_1)

        api.POST(path,
            parameters: nil,
            success: { (operation:AFHTTPRequestOperation!, response:AnyObject!) in
                
                let responseDict = response as! NSDictionary
                if let status = responseDict.stringForKey(ResultKey.Status) where status == ResultValue.Deleted {
                    success?()
                } else {
                    failure?(ResultError.Failed.error)
                }
            },
            failure: { (operation: AFHTTPRequestOperation?, error: NSError) in
                failure?(error)
        })
    }
    
    
    /// Keys found in API results
    private struct ResultKey
    {
        static let Status = "status"
    }

    /// Values found in API results
    private struct ResultValue
    {
        static let Deleted = "deleted"
    }

    /// Errors generated by this class for API results
    private enum ResultError : Int, ErrorType
    {
        case Failed = 1
        
        var code: Int {
            return rawValue
        }
        
        var domain: String {
            return String(self.dynamicType)
        }
        
        var message: String {
            return NSLocalizedString("The site could not be deleted.", comment: "Message shown when site deletion API failed")
        }
        
        var error: NSError {
            return NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: message])
        }
    }
}
