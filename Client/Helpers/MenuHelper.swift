/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

import Foundation
import Shared

@objc public protocol MenuHelperInterface {
    @objc optional func menuHelperCopy()
    @objc optional func menuHelperOpenAndFill()
    @objc optional func menuHelperReveal()
    @objc optional func menuHelperSecure()
    @objc optional func menuHelperFindInPage()
    @objc optional func menuHelperSearchWithFirefox()
    @objc optional func menuHelperPasteAndGo()
}

open class MenuHelper: NSObject {
    public static let SelectorCopy: Selector = #selector(MenuHelperInterface.menuHelperCopy)
    public static let SelectorHide: Selector = #selector(MenuHelperInterface.menuHelperSecure)
    public static let SelectorOpenAndFill: Selector = #selector(MenuHelperInterface.menuHelperOpenAndFill)
    public static let SelectorReveal: Selector = #selector(MenuHelperInterface.menuHelperReveal)
    public static let SelectorFindInPage: Selector = #selector(MenuHelperInterface.menuHelperFindInPage)
    public static let SelectorSearchWithFirefox: Selector = #selector(MenuHelperInterface.menuHelperSearchWithFirefox)
    public static let SelectorPasteAndGo: Selector = #selector(MenuHelperInterface.menuHelperPasteAndGo)

    open class var defaultHelper: MenuHelper {
        struct Singleton {
            static let instance = MenuHelper()
        }
        return Singleton.instance
    }

    open func setItems() {
        let pasteAndGoItem = UIMenuItem(title: Strings.MenuHelper.PasteGo, action: MenuHelper.SelectorPasteAndGo)

        let revealPasswordItem = UIMenuItem(title: Strings.MenuHelper.Reveal, action: MenuHelper.SelectorReveal)

        let hidePasswordItem = UIMenuItem(title: Strings.MenuHelper.Hide, action: MenuHelper.SelectorHide)

        let copyItem = UIMenuItem(title: Strings.General.CopyString, action: MenuHelper.SelectorCopy)

        let openAndFillItem = UIMenuItem(title: Strings.MenuHelper.OpenAndFill, action: MenuHelper.SelectorOpenAndFill)

        let findInPageItem = UIMenuItem(title: Strings.MenuHelper.FindInPage, action: MenuHelper.SelectorFindInPage)

        let searchItem = UIMenuItem(title: Strings.MenuHelper.SearchWithUserAgent, action: MenuHelper.SelectorSearchWithFirefox)

        if UIPasteboard.general.isCopiedStringValidURL {
            UIMenuController.shared.menuItems = [pasteAndGoItem, copyItem, revealPasswordItem, hidePasswordItem, openAndFillItem, findInPageItem, searchItem]
        } else {
            UIMenuController.shared.menuItems = [copyItem, revealPasswordItem, hidePasswordItem, openAndFillItem, findInPageItem, searchItem]
        }
    }
}
