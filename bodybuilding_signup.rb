require 'capybara'

class BodybuldingSignup

  attr_reader :session, :username, :password

  def initialize
    @session = Capybara::Session.new(:selenium)
    @username = "capybara#{Time.now.to_i}".slice(0,14)
    @password = "longPassword1"
  end

  def signup
    session.visit("http://www.bodybuilding.com")

    session.find('#header__profile-menu__trigger').click
    session.within(:xpath, '//div[@class="bb-well ProfileMenu__well"]') do
      session.click_button('Sign up now')
    end

    fill_form
  end

  def fill_form
    session.within(:xpath, '//div[@class="bb-dialog__content"]') do
      session.fill_in('username', with: @username)
      session.fill_in('password', with: @password)
      session.fill_in('realName', with: "My Name")
      session.fill_in('emailAddress', with: "myEmaillong#{Time.now.to_i}@gmail.com")
      session.select("January", :from => "dobMonth")
      session.select("1", :from => "dobDay")
      session.select("1984", :from => "dobYear")
      sleep 1
      session.within(:xpath, '//div[@class="Signup-row Signup-footer-row"]') do
        session.click_button('Sign Up')
      end
    end
  end

  def print_stats
    p "Succesfully signed in with credentials User: #@username , Password: #@password "
  end
end

bb_page = BodybuldingSignup.new
bb_page.signup
bb_page.print_stats




