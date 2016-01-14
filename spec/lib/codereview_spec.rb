require "spec_helper"

describe OttInfra::CodeReview do
  it "OttInfra::CoreReview.run is exist" do
    expect( OttInfra::CodeReview.run )
  end
  it "OttInfra::CodeReview.get_last_changes returns last commit changes" do
    expected_array = `git diff-tree --name-only -r 'HEAD^..HEAD'`.split
    expect( OttInfra::CodeReview.get_last_changes).to match_array(expected_array)
  end
  it "OttInfra::CodeReview.find_git_root returns git root path" do
    expected_string = `git rev-parse --show-toplevel`.chomp
    expect( OttInfra::CodeReview.find_git_root         ).to eq(expected_string)
    expect( OttInfra::CodeReview.find_git_root('lib/') ).to eq(expected_string)
    expect( OttInfra::CodeReview.find_git_root('')     ).to eq(expected_string)
    expect( OttInfra::CodeReview.find_git_root('./')   ).to eq(expected_string)
    expect( OttInfra::CodeReview.find_git_root('/tmp') ).to be nil
  end

  it "Git::Lib.checkattr returns attributes" do
    file = 'lib'
    expected_string = `git check-attr -a #{file}`.chomp
    expect( Git::Lib.new.checkattr( file ) ).to eq(expected_string)
  end

  it "OttInfra::CodeReview.get_file_attrs returns attributes" do
    file = 'lib.rb'
    owner_key = 'owner.mail'
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
      expect( OttInfra::CodeReview.get_file_attrs(file, :attr => owner_key) ).to eq( expected )
    end

  end
end
