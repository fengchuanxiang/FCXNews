

Pod::Spec.new do |s|
  s.name         = "FCXNews"
  s.version      = "0.0.1"
  s.summary      = "FCX's FCXNews."
  s.description  = <<-DESC
                    FCXNews of FCX
                   DESC

  s.homepage     = "https://github.com/fengchuanxiang/FCXNews.git"
  s.license      = "MIT"
  s.author             = { "fengchuanxiang" => "fengchuanxiang@126.com" }
  s.platform     = :ios, "6.0"
  s.source       = { :git => "https://github.com/fengchuanxiang/FCXNews.git", :tag => "0.0.1" }

  s.source_files  = "FCXNews/", "FCXRefreshView/", "FCXPictureBrowing/"
  s.resources = "FCXPictureBrowing/*.png", "FCXRefreshView/*.png"

  s.dependency "FMDB"
  #s.dependency 'AFNetworking', '~> 3.1.0'

  s.dependency "MBProgressHUD"

end
