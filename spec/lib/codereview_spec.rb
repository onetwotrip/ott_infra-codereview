require "spec_helper"
require "ott_infra/codereview"

describe OttInfra::CodeReview do
  it "start point is exist" do
    expect( OttInfra::CodeReview.run ).to be true
  end
end
