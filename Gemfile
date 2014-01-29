source 'http://rubygems.org'

gemspec :name => 'certmeister'

Dir['certmeister-*.gemspec'].each do |gemspec|
  plugin = gemspec.scan(/certmeister-(.*)\.gemspec/).flatten.first
  gemspec(:name => "certmeister-#{plugin}", :development_group => plugin)
end
