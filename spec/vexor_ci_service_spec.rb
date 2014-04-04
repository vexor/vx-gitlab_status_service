# == Schema Information
#
# Table name: services
#
#  id          :integer          not null, primary key
#  type        :string(255)
#  title       :string(255)
#  token       :string(255)
#  project_id  :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  active      :boolean          default(FALSE), not null
#  project_url :string(255)
#  subdomain   :string(255)
#  room        :string(255)
#  api_key     :string(255)
#

require "spec_helper"
require "vx/gitlab_status_service/vexor_ci_service"

describe VexorCiService do
  describe "Associations" do
    it { should belong_to :project }
    it { should have_one :service_hook }
  end

  describe "Mass assignment" do
    it { should_not allow_mass_assignment_of(:project_id) }
  end

  describe "commit_status" do
    before do
      subject.stub(:project_url).and_return("")
      subject.stub(:token).and_return("")
    end

    describe "pending" do
      before do
        response = double(code: 200, :[] => "pending")
        HTTParty.stub(:get).and_return(response)
      end

      it "returns correct status" do
        expect(subject.commit_status("somecommitsha")).to be == "pending"
      end
    end

    describe "error" do
      before do
        response = double(code: 200, :[] => nil)
        HTTParty.stub(:get).and_return(response)
      end

      it "returns correct status" do
        expect(subject.commit_status("somecommitsha")).to be == :error
      end
    end

    describe "unavailable" do
      before do
        response = double(code: 404)
        HTTParty.stub(:get).and_return(response)
      end

      it "returns correct status" do
        expect(subject.commit_status("somecommitsha")).to be == :error
      end
    end
  end

  describe 'commits methods' do
    before do
      @service = VexorCiService.new
      @service.stub(
        service_hook: true,
        project_url: 'http://ci.gitlab.org/projects/2',
        token: 'verySecret'
      )
    end

    describe :commit_status_path do
      it { @service.commit_status_path("2ab7834c").should == "http://ci.gitlab.org/projects/2/builds/2ab7834c/status.json?token=verySecret"}
    end

    describe :build_page do
      it { @service.build_page("2ab7834c").should == "http://ci.gitlab.org/projects/2/builds/2ab7834c"}
    end
  end
end
