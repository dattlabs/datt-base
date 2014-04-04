
require 'spec_helper'

describe "base image" do
  before(:all) {
    @image = Docker::Image.all().detect{ |i| i.info['RepoTags'] == ['datt/datt-base:latest'] }
  }

  it "should be available" do
    expect(@image).to_not be_nil
  end
end
