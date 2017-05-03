Pod::Spec.new do |s|
s.name         = "TCParallax"
s.version      = "2.0.2"
s.summary      = "Parallax scrolling effect on UITableView header view when a tableView is scrolled"
s.homepage     = "https://github.com/itanchao/TCParallax"
#s.screenshots  = "./演示.gif"
s.license      = "MIT"
s.author       = { "谈超" => "itanchao@gmail.com" }
s.platform     = :ios, "8.0"
s.source       = { :git => "https://github.com/itanchao/TCParallax.git", :tag => s.version }
s.source_files  = "Sauces", "Sauces/*.{swift}"

end
