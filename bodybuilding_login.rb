require 'capybara'

session = Capybara::Session.new(:selenium)

session.visit "http://www.bodybuilding.com"
session.find('#header__profile-menu__trigger').click

session.within(:xpath, '//div[@class="js-bb-login__container"]') do
  session.fill_in('username', with: ARGV[0] || "capybara1")
  session.fill_in('password', with: ARGV[1] || "longPassword1")
  session.click_button('Log In')
  p "Making some staff inside logged page"
end
sleep 20
