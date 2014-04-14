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

class ::VexorCiService < ::Service
  attr_accessible :project_url

  validates :project_url, presence: true, if: :activated?
  validates :token, presence: true, if: :activated?

  def commit_status_path(sha)
    project_url + "/api/builds/sha/#{sha}.json?token=#{token}"
  end

  def commit_status(sha)
    response = HTTParty.get(commit_status_path(sha), verify: false)

    if response.code == 200 && response["status"]
      response["status"]
    else
      :error
    end
  end

  def build_page(sha)
    project_url + "/builds/sha/#{sha}"
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
    "Continuous integration server from Vexor"
  end

  def to_param
    "vexor_ci"
  end

  def fields
    [
      { type: "text", name: "token", placeholder: "Vexor CI project specific token" },
      { type: "text", name: "project_url", placeholder: "http://ci.vexor.io/projects/3"}
    ]
  end

  def execute(push_data)
    # NOOP
  end
end
