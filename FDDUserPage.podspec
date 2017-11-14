Pod::Spec.new do |s|

s.name         = "FDDUserPage"
s.version      =    "1.0.1"
s.summary      = "FDDUserPage can be used to guide the user."
s.homepage     = "https://github.com/DonyFang/FDDUserPage"
s.license      = "MIT"
s.author       = { "DonyFang" => "978805355@qq.com" }
s.source       = { :git => "https://github.com/DonyFang/FDDUserPage.git",:tag => "1.0.1"}
s.platform     = :ios, '6.0'
s.requires_arc = true
s.source_files =  'FDDUserPage','FDDUserPage/FDDUserPage/**/*.{h,m}'
s.framework  = "UIKit"

end
