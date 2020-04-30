//
// Copyright (c) 2017-2019 Cliqz GmbH. All rights reserved.
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import Foundation

extension BrowserViewController: TrampolineDelegate {
    func trampoline(startSearch query: String, fromTab tab: Tab) {
        if self.tabManager.selectedTab != tab { return }
        self.urlBar.enterOverlayMode(query, pasted: false, search: true)
    }
}
