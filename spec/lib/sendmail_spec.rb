require "spec_helper"

describe OttInfra::SendMail do
  it "check config instance variable" do
    ENV["SENDGRID_USER"] = 'sendgrid_user'
    ENV["SENDGRID_PASS"] = 'sendgrid_pass'
    ENV["SENDGRID_FROM"] = 'sendgrid_from'
    expect( OttInfra::SendMail.new.config.sendgrid.user ).to match( "sendgrid_user" )
    expect( OttInfra::SendMail.new.config.sendgrid.pass ).to match( "sendgrid_pass" )
    expect( OttInfra::SendMail.new.config.sendgrid.from ).to match( "sendgrid_from" )
  end
end
