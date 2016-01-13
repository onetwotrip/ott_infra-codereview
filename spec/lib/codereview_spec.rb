require "spec_helper"

describe OttInfra::CodeReview do
  it "start point is exist" do
    expect( OttInfra::CodeReview.run ).to be true
  end
end
