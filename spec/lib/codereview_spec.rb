require "spec_helper"

describe Git::Lib do
  it "Git::Lib.checkattr returns attributes" do
    file = 'lib'
    expected_string = `git check-attr -a #{file}`.chomp
    expect( Git::Lib.new.checkattr( file ) ).to eq(expected_string)
  end
end

describe OttInfra::CodeReview do
  owner_key = 'owner.mail'

  it ".run is exist" do
    expect( OttInfra::CodeReview.run )
  end

  it ".get_last_changes returns last commit changes" do
    expected_array = `git diff-tree --name-only -r 'HEAD^..HEAD'`.split
    expect( OttInfra::CodeReview.run.get_last_changes).to match_array(expected_array)
  end

  it ".find_git_root returns git root path" do
    expected_string = `git rev-parse --show-toplevel`.chomp
    expect( OttInfra::CodeReview.run.find_git_root         ).to eq(expected_string)
    expect( OttInfra::CodeReview.run.find_git_root('lib/') ).to eq(expected_string)
    expect( OttInfra::CodeReview.run.find_git_root('')     ).to eq(expected_string)
    expect( OttInfra::CodeReview.run.find_git_root('./')   ).to eq(expected_string)
    expect( OttInfra::CodeReview.run.find_git_root('/tmp') ).to be nil
  end

  it ".get_file_attrs returns attributes" do
    file = 'lib.rb'
    stub_array = ["#{file}: #{owner_key}: mail@example.com",
                  "#{file}: #{owner_key}2: mail@example.com\n",
                  "#{file}: #{owner_key}: mail@example.com\n"\
                  "#{file}: #{owner_key}: mail2@example.com\n"]

    expected_array = [
      ['mail@example.com'],
      [],
      ['mail@example.com', 'mail2@example.com']
    ]

    Hash[stub_array.zip(expected_array)].each do |stub, expected|
      allow_any_instance_of(Git::Lib).to receive(:checkattr)
                                         .with( file )
                                         .and_return( stub )
      expect( OttInfra::CodeReview.run.get_file_attrs(file, :attr => owner_key) ).to eq( expected )
    end
  end

  it ".get_reviewers returns reviewers" do
    stub = {
      :get_last_changes => ['lib/module.rb','Gemfile','spec/module_spec.rb'],
      :get_file_attrs   => ['mail@ex.com','mail_2@ex.com','mail@ex.com']
    }
    expected_array = ['mail@ex.com','mail_2@ex.com']

    allow_any_instance_of(OttInfra::CodeReview).to receive(:get_last_changes)
                                   .and_return( stub[:get_last_changes] )
    Hash[stub[:get_last_changes].zip(stub[:get_file_attrs])].each do |file, reviewer|
      allow_any_instance_of(OttInfra::CodeReview).to receive(:get_file_attrs)
                                     .with( file, :attr => 'owner.mail' )
                                     .and_return( reviewer )
    end

    expect( OttInfra::CodeReview.run.get_reviewers ).to match_array( expected_array )
  end

  it ".get_review_info returns all git data" do
    stub = {
      :get_last_changes => ['lib/module.rb'],
      :get_file_attrs   => ['reviewer@test.com']
    }
    allow_any_instance_of(OttInfra::CodeReview).to receive(:get_last_changes)
                                   .and_return( stub[:get_last_changes] )
    Hash[stub[:get_last_changes].zip(stub[:get_file_attrs])].each do |file, reviewer|
      allow_any_instance_of(OttInfra::CodeReview).to receive(:get_file_attrs)
                                     .with( file, :attr => 'owner.mail' )
                                     .and_return( reviewer )
    end
    allow_any_instance_of(Git::Lib).to receive(:diff_full)
                                       .and_return( "Diff_Text" )
    allow_any_instance_of(Git::Author).to receive(:name)
                                       .and_return( "Name Surname" )
    allow_any_instance_of(Git::Author).to receive(:email)
                                       .and_return( "author@test.com" )
    expected_hash = {
      :author => {
        :name => "Name Surname",
        :email => "author@test.com"
      },
      :reviewers => ['reviewer@test.com'],
      :diff => "Diff_Text"
    }
    expect( OttInfra::CodeReview.run.get_review_info ).to include( expected_hash )
  end
end
