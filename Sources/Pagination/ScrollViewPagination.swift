import ObjectiveC
import UIKit

private var paginationKey: UInt8 = 0

public extension UIScrollView {
    @objc var pagination: Pagination {
        get {
            if let pagination = objc_getAssociatedObject(self, &paginationKey) as? Pagination {
                return pagination
            } else {
                let pagination = Pagination()
                pagination.scrollView = self
                objc_setAssociatedObject(self, &paginationKey, pagination, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return pagination
            }
        }
        set {
            objc_setAssociatedObject(self, &paginationKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
