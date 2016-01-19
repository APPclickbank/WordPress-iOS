import UIKit
import WordPressShared

/**
*  @class   DeleteSiteViewController
*
*  @brief   Allows user to permanently delete site
*/

final class DeleteSiteViewController: UITableViewController
{
    // MARK: - Properties: must be set by creator
    
    /**
    *  @brief      The blog to permanently delete
    *  @details    Must be set by creator
    */
    var blog : Blog!
    
    var primaryDomain: String!

    // MARK: - Properties
    
    private var tableViewModel = ImmuTable(sections: []) {
        didSet {
            if isViewLoaded() {
                tableView.reloadData()
            }
        }
    }
    
    private weak var deleteAction: UIAlertAction?

    // MARK: - UIViewController

    convenience init(blog: Blog) {
        self.init(style: .Grouped)
        self.blog = blog
        self.primaryDomain = blog.displayURL
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Delete Site", comment: "Title of Delete Site settings page")
        
        buildViewModel()
        
        WPStyleGuide.resetReadableMarginsForTableView(tableView)
        WPStyleGuide.configureColorsForView(view, andTableView: tableView)
    }
    
    private func buildViewModel() {
        ImmuTable.registerRows([
            TextRow.self,
            ButtonRow.self,
            DestructiveButtonRow.self,
            ], tableView: tableView)

        let domainHeading = NSLocalizedString("Domain Removal", comment: "Heading for Domain Removal on Delete Site settings page")
        
        let domainDetail = NSLocalizedString("Be careful! Deleting your site will also remove your domain listed below.", comment: "Detail for Domain Removal on Delete Site settings page")

        let domain = TextRow(title: primaryDomain, value: "")

        let contentHeading = NSLocalizedString("Keep Your Content", comment: "Heading for Keep Your Content on Delete Site settings page")
        
        let contentDetail = NSLocalizedString("If you are sure, please be sure to take the time and export your content now. It can not be recovered in the future.", comment: "Detail for Keep Your Content on Delete Site settings page")
        
        let content = ButtonRow(
            title: NSLocalizedString("Export Content", comment: "Button to export content on Start Over settings page"),
            action: exportContent())

        let deleteHeading = NSLocalizedString("Are You Sure", comment: "Heading for Are You Sure on Delete Site settings page")
        
        let deleteDetail = NSLocalizedString("This action can not be undone. Deleting your site will remove all content, contributors, and domains from the site.", comment: "Detail for Are You Sureon Delete Site settings page")
        
        let delete = DestructiveButtonRow(
            title: NSLocalizedString("Delete Site", comment: "Button to delete site on Start Over settings page"),
            action: confirmDeleteSite())

        tableViewModel =  ImmuTable(sections: [
            ImmuTableSection(headerText: domainHeading, rows: [], footerText: domainDetail),
            ImmuTableSection(rows: [domain]),
            ImmuTableSection(headerText: contentHeading, rows: [], footerText: contentDetail),
            ImmuTableSection(rows: [content]),
            ImmuTableSection(headerText: deleteHeading, rows: [], footerText: deleteDetail),
            ImmuTableSection(rows: [delete]),
            ])
    }

    // MARK: Table View Data Source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tableViewModel.sections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewModel.sections[section].rows.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let row = tableViewModel.rowAtIndexPath(indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier(row.reusableIdentifier, forIndexPath: indexPath)
        
        row.configureCell(cell)
        
        return cell
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableViewModel.sections[section].headerText
    }
    
    override func tableView(tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return tableViewModel.sections[section].footerText
    }

    // MARK: - Table View Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = tableViewModel.rowAtIndexPath(indexPath)
        row.action?(row)
    }

    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = self.tableView(tableView, titleForHeaderInSection: section) where !title.isEmpty else {
            return nil
        }
        
        let view = WPTableViewSectionHeaderFooterView(reuseIdentifier: nil)
        view.title = title
        return view
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard let title = self.tableView(tableView, titleForHeaderInSection: section) where !title.isEmpty else {
            return CGFloat.min
        }

        return WPTableViewSectionHeaderFooterView.heightForHeader(title, width: tableView.frame.width)
    }

    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let title = self.tableView(tableView, titleForFooterInSection: section) where !title.isEmpty else {
            return nil
        }
    
        let view = WPTableViewSectionHeaderFooterView(reuseIdentifier: nil, style: .Footer)
        view.title = title
        return view
    }

    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard let title = self.tableView(tableView, titleForFooterInSection: section) where !title.isEmpty else {
            return CGFloat.min
        }

        return WPTableViewSectionHeaderFooterView.heightForFooter(title, width: tableView.frame.width)
    }

    // MARK: - Actions

    private func exportContent() -> ImmuTableAction {
        return { [unowned self] row in
            self.tableView.deselectSelectedRowWithAnimation(true)
        }
    }
    
    private func confirmDeleteSite() -> ImmuTableAction {
        return { [unowned self] row in
            self.tableView.deselectSelectedRowWithAnimation(true)

            self.presentViewController(self.confirmDeleteController(), animated: true, completion: nil)
        }
    }
    
    private func confirmDeleteController() -> UIAlertController {
        let title = NSLocalizedString("Delete Site", comment: "Title of Delete Site confirmation alert")
        let messageFormat = NSLocalizedString("Enter the primary domain to confirm\n“%@”", comment: "Message of Delete Site confirmation alert")
        let message = String(format: messageFormat, self.primaryDomain)
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        let cancelTitle = NSLocalizedString("Cancel", comment: "Delete site cancel action title")
        alertController.addCancelActionWithTitle(cancelTitle, handler: nil)
        
        let deleteTitle = NSLocalizedString("Delete", comment: "Delete site confirmation action title")
        let deleteAction = UIAlertAction(title: deleteTitle, style: .Destructive, handler: { (action: UIAlertAction) in
            self.deleteSiteConfirmed()
        })
        if false { deleteAction.enabled = false }
        alertController.addAction(deleteAction)
        self.deleteAction = deleteAction
        
        alertController.addTextFieldWithConfigurationHandler({ (textField: UITextField) in
            textField.addTarget(self, action: "alertTextFieldDidChange:", forControlEvents: .EditingChanged)
        })
        
        return alertController
    }
    
    func alertTextFieldDidChange(sender: UITextField) {
        deleteAction?.enabled = sender.text == primaryDomain
    }
    
    private func deleteSiteConfirmed() {
        let navController = self.navigationController

        let deleteService = DeleteService(managedObjectContext: ContextManager.sharedInstance().mainContext)
        deleteService.deleteSiteForBlog(blog,
            success: {
                navController?.popToRootViewControllerAnimated(true)
            },
            failure: { [weak self] (error : NSError) in
                DDLogSwift.logError("Error deleting site \(self?.primaryDomain): \(error.localizedDescription)")
                
                self?.showError(error)
        })
    }
    
    private func showError(error : NSError) {
        let errorTitle = NSLocalizedString("Delete Site Error", comment:"Title of alert when site deletion fails")
        let alertController = UIAlertController(title: errorTitle,
            message: error.localizedDescription,
            preferredStyle: .Alert)
        
        let okTitle = NSLocalizedString("OK", comment:"Alert dismissal title")
        alertController.addDefaultActionWithTitle(okTitle, handler: nil)
        
        alertController.presentFromRootViewController()
    }
}
