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

require 'uri'

class ::VexorCiService < ::Service
  attr_accessible :project_url

  validates :token, presence: true, if: :activated?
  validates :project_url, :format => URI::regexp(%w(http https)), if: :activated?

  def commit_status_path(sha)
    project_url + "/api/builds/#{sha}/status_for_gitlab.json"
  end

  def commit_status(sha)
    request_build_status(sha, 'status') || :error
  end

  def build_page(sha)
    request_build_status sha, 'location'
  end

  def builds_path
    ""
  end

  def status_img_path
    # project_url + "/status.png?ref=" + project.default_branch
    ""
  end

  def title
    "Vexor CI"
  end

  def description
    "Vexor continuous integration and deploy service"
  end

  def to_param
    "vexor_ci"
  end

  def project_url
    if super.blank?
      'https://ci.vexor.io'
    else
      super
    end
  end

  def fields
    [
      { type: "text", name: "token", placeholder: "Project secure token" },
      { type: "text", name: "project_url", placeholder: "https://ci.vexor.io"}
    ]
  end

  def execute(push_data)
    # NOOP
  end

  private

    def request_build_status(sha, key)
      response = HTTParty.get(
        commit_status_path(sha),
        verify: false,
        headers: {
          'X-Vexor-Project-Token' => token
        }
      )

      if response.code == 200 && response[key]
        response[key]
      end
    end
end
