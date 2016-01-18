require "spec_helper"

describe Git::Lib do
  it "Git::Lib.checkattr returns attributes" do
    file = 'lib'
    expected_string = `git check-attr -a #{file}`.chomp
    expect( Git::Lib.new.checkattr( file ) ).to eq(expected_string)
  end
end

describe OttInfra::SendMail do
  ENV["SENDGRID_USER"] = 'sendgrid_user'
  ENV["SENDGRID_PASS"] = 'sendgrid_pass'
  ENV["SENDGRID_FROM"] = 'sendgrid_from'
  it "check config instance variable" do
    expect( OttInfra::SendMail.new.config.sendgrid.user ).to match( "sendgrid_user" )
    expect( OttInfra::SendMail.new.config.sendgrid.pass ).to match( "sendgrid_pass" )
    expect( OttInfra::SendMail.new.config.sendgrid.from ).to match( "sendgrid_from" )
  end
end

describe OttInfra::CodeReview do
  owner_key = 'owner.mail'
  commit_id = srand
  ENV["SENDGRID_USER"] = 'sendgrid_user'
  ENV["SENDGRID_PASS"] = 'sendgrid_pass'
  ENV["SENDGRID_FROM"] = 'sendgrid_from'

  it ".get_review_info returns all git data" do
    stub = {
      :get_last_changes => 'lib/module.rb',
      :reviewers        => 'reviewer@test.com,reviewer@test.com,reviewer2@test.com',
      :diff_full        => 'Diff_text',
      :name             => 'Name Surname',
      :email            => 'author@test.com',
    }
    allow_any_instance_of(Git::Lib).to receive(:diff_full)
                                       .and_return( stub[:diff_full] )
    allow_any_instance_of(Git::Author).to receive(:name)
                                       .and_return( stub[:name] )
    allow_any_instance_of(Git::Author).to receive(:email)
                                       .and_return( stub[:email] )
    allow_any_instance_of(Git::Object::Commit).to receive(:objectish)
                                       .and_return( commit_id )
    allow_any_instance_of(Git::Diff).to receive(:stats)
                                       .and_return({:files => {
                                         stub[:get_last_changes] => "" }})
    allow_any_instance_of(Git::Lib).to receive(:checkattr)
      .and_return( "#{stub[:get_last_changes]}: #{owner_key}: #{stub[:reviewers]}\n" )

    expected_hash = {
      :author => {
        :name => "Name Surname",
        :email => "author@test.com"
      },
      :reviewers => ['reviewer@test.com','reviewer2@test.com'],
      :patch => "/tmp/#{commit_id}.patch"
    }
    expect( OttInfra::CodeReview.new.get_review_info ).to include( expected_hash )
  end

  it ".run is correct" do
    stub = {
      :get_last_changes => 'lib/module.rb',
      :reviewers        => 'reviewer@test.com,reviewer@test.com,reviewer2@test.com',
      :diff_full        => 'Diff_text',
      :name             => 'Name Surname',
      :email            => 'author@test.com',
    }
    allow_any_instance_of(Git::Lib).to receive(:diff_full)
                                       .and_return( stub[:diff_full] )
    allow_any_instance_of(Git::Author).to receive(:name)
                                       .and_return( stub[:name] )
    allow_any_instance_of(Git::Author).to receive(:email)
                                       .and_return( stub[:email] )
    allow_any_instance_of(Git::Object::Commit).to receive(:objectish)
                                       .and_return( commit_id )
    allow_any_instance_of(Git::Diff).to receive(:stats)
                                       .and_return({:files => {
                                         stub[:get_last_changes] => "" }})
    allow_any_instance_of(Git::Lib).to receive(:checkattr)
      .and_return( "#{stub[:get_last_changes]}: #{owner_key}: #{stub[:reviewers]}\n" )

    expect( OttInfra::CodeReview.run ).not_to be false
  end

  after(:all) do
    File.delete("/tmp/#{commit_id}.patch")
  end
end
