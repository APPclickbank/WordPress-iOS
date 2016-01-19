import UIKit
import WordPressShared

/**
*  @class   StartOverViewController
*
*  @brief   Allows user to trigger help session to remove site content
*/

final class StartOverViewController: UITableViewController
{
    // MARK: - Properties: must be set by creator
    
    /**
    *  @brief      The blog to remove content from
    *  @details    Must be set by creator
    */
    var blog : Blog!

    // MARK: - Properties
    
    var tableViewModel = ImmuTable(sections: []) {
        didSet {
            if isViewLoaded() {
                tableView.reloadData()
            }
        }
    }

    // MARK: - UIViewController

    convenience init(blog: Blog) {
        self.init(style: .Grouped)
        self.blog = blog
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Start Over", comment: "Title of Start Over settings page")
        
        buildViewModel()
        
        WPStyleGuide.resetReadableMarginsForTableView(tableView)
        WPStyleGuide.configureColorsForView(view, andTableView: tableView)
    }
    
    private func buildViewModel() {
        ImmuTable.registerRows([
            ButtonRow.self,
            ], tableView: tableView)

        let heading = NSLocalizedString("Let Us Help", comment: "Heading for instructions on Start Over settings page")
        
        let instructions = NSLocalizedString("If you want a site but don't want any of the posts and pages you have now, our support team can delete your posts, pages, media, and comments for you.\n\nThis will keep your site and URL active, but give you a fresh start on your content creation. Just contact us to have your current content cleared out.", comment: "Instructions on Start Over settings page")

        let contact = ButtonRow(
            title: NSLocalizedString("Contact Support", comment: "Button to contact support on Start Over settings page"),
            action: contactSupport())
        
        tableViewModel =  ImmuTable(sections: [
            ImmuTableSection(headerText: heading, rows: [], footerText: instructions),
            ImmuTableSection(rows: [contact]),
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

    private func contactSupport() -> ImmuTableAction {
        return { [unowned self] row in
            self.tableView.deselectSelectedRowWithAnimation(true)

            if HelpshiftUtils.isHelpshiftEnabled() {
                self.setupHelpshift(self.blog.account)
                
                let metadata = self.helpshiftMetadata(self.blog)
                Helpshift.sharedInstance().showConversation(self, withOptions: metadata)
            } else {
                let contact = NSURL(string: "https://support.wordpress.com/contact/")!
                UIApplication.sharedApplication().openURL(contact)
            }
            
        }
    }

    private func setupHelpshift(account: WPAccount) {
        let user = account.userID.stringValue
        Helpshift.setUserIdentifier(user)
        
        let name = account.username
        let email = account.email
        Helpshift.setName(name, andEmail: email)
    }
    
    private func helpshiftMetadata(blog: Blog) -> [NSObject: AnyObject] {
        let options: [String: String] = [
            "Source": "Start Over",
            "Blog": blog.logDescription(),
            ]

        return [HSCustomMetadataKey: options]
    }
}
