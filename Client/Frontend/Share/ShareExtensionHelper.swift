/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared
import MobileCoreServices

private let log = Logger.browserLogger

class ShareExtensionHelper: NSObject {
    fileprivate weak var selectedTab: Tab?

    fileprivate let url: URL
    fileprivate let browserFillIdentifier = "org.appextension.fill-browser-action"

    fileprivate func isFile(url: URL) -> Bool { url.scheme == "file" }

    init(url: URL, file: URL? = nil, tab: Tab?) {
        self.url = url
        self.selectedTab = tab
    }

    func createActivityViewController(withDownloadActivity: Bool = false, _ completionHandler: @escaping (_ completed: Bool, _ activityType: UIActivity.ActivityType?) -> Void) -> UIActivityViewController {
        var activityItems = [AnyObject]()

        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.jobName = (url.absoluteString as NSString).lastPathComponent
        printInfo.outputType = .general
        activityItems.append(printInfo)

        if let tab = selectedTab {
            activityItems.append(TabPrintPageRenderer(tab: tab))
        }

        if let title = selectedTab?.title {
            activityItems.append(TitleActivityItemProvider(title: title))
        }
        activityItems.append(self)
        let activities: [UIActivity]? = withDownloadActivity ? [FileDownloadActivity()] : nil
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: activities)

        // Hide 'Add to Reading List' which currently uses Safari.
        // We would also hide View Later, if possible, but the exclusion list doesn't currently support
        // third-party activity types (rdar://19430419).
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.addToReadingList,
        ]

        activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, activityError in
            if !completed {
                completionHandler(completed, activityType)
                return
            }
            // Bug 1392418 - When copying a url using the share extension there are 2 urls in the pasteboard.
            // This is a iOS 11.0 bug. Fixed in 11.2
            if UIPasteboard.general.hasURLs, let url = UIPasteboard.general.urls?.first {
                UIPasteboard.general.urls = [url]
            }

            completionHandler(completed, activityType)
        }
        return activityViewController
    }
}

extension ShareExtensionHelper: UIActivityItemSource {
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return url
    }

    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        if isOpenByCopy(activityType: activityType) {
            return url
        }

        // Return the URL for the selected tab. If we are in reader view then decode
        // it so that we copy the original and not the internal localhost one.
        return url.isReaderModeURL ? url.decodeReaderModeURL : url
    }

    func activityViewController(_ activityViewController: UIActivityViewController, dataTypeIdentifierForActivityType activityType: UIActivity.ActivityType?) -> String {
        if isPasswordManager(activityType: activityType) {
            return browserFillIdentifier
        } else if isOpenByCopy(activityType: activityType) {
            return isFile(url: url) ? kUTTypeFileURL as String : kUTTypeURL as String
        }

        return activityType == nil ? browserFillIdentifier : kUTTypeURL as String
    }

    private func isPasswordManager(activityType: UIActivity.ActivityType?) -> Bool {
        guard let activityType = activityType?.rawValue else { return false }
        // A 'password' substring covers the most cases, such as pwsafe and 1Password.
        // com.agilebits.onepassword-ios.extension
        // com.app77.ios.pwsafe2.find-login-action-password-actionExtension
        // If your extension's bundle identifier does not contain "password", simply submit a pull request by adding your bundle identifier.
        return (activityType.range(of: "password") != nil)
            || (activityType == "com.lastpass.ilastpass.LastPassExt")
            || (activityType == "in.sinew.Walletx.WalletxExt")
            || (activityType == "com.8bit.bitwarden.find-login-action-extension")
            || (activityType == "me.mssun.passforios.find-login-action-extension")
    }

    private func isOpenByCopy(activityType: UIActivity.ActivityType?) -> Bool {
        guard let activityType = activityType?.rawValue else { return false }
        return activityType.lowercased().range(of: "remoteopeninapplication-bycopy") != nil
    }
}
