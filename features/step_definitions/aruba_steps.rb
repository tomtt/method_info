When /^I run "(.*)" in ruby with method_info required$/ do |code|
  When 'I run "ruby -r../../lib/method_info -e \"%s\""' % code
end
