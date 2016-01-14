require "spec_helper"

describe OttInfra::CodeReview do
  it "start point is exist" do
    expect( OttInfra::CodeReview.run ).to be true
  end
  it "returns last commit changes" do
    expected_array = ['ott_infra-codereview.gemspec', 'spec/lib/codereview_spec.rb', 'spec/spec_helper.rb']
    expect( OttInfra::CodeReview.get_last_changes).to match_array(expected_array)
  end
  it "returns git root path" do
    expected_string = `git rev-parse --show-toplevel`.chomp
    expect( OttInfra::CodeReview.find_git_root         ).to eq(expected_string)
    expect( OttInfra::CodeReview.find_git_root('lib/') ).to eq(expected_string)
    expect( OttInfra::CodeReview.find_git_root('')     ).to eq(expected_string)
    expect( OttInfra::CodeReview.find_git_root('./')   ).to eq(expected_string)
    expect( OttInfra::CodeReview.find_git_root('/tmp') ).to be nil
  end
end
