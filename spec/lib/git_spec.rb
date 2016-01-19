require "spec_helper"

describe Git::Lib do
  it "Git::Lib.checkattr returns attributes" do
    file = 'lib'
    expected_string = `git check-attr -a #{file}`.chomp
    expect( Git::Lib.new.checkattr( file ) ).to eq(expected_string)
  end
end
