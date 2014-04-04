module Vx
  module GitlabStatusService
    class Railtie < ::Rails::Railtie
      config.after_initialize do

        # Register Vexor CI in list of project services
        available_services_names_with_vexor = Project.new.available_services_names + %w(vexor_ci)

        Project.instance_eval do
          has_one :vexor_ci_service, dependent: :destroy
          define_method(:available_services_names) { available_services_names_with_vexor }
        end

        require_relative "vexor_ci_service"


        # patch controller to make possible to show Vexor CI status on MR page instead of Gitlab CI
        Projects::MergeRequestsController.instance_eval do
          def ci_status
            status = @merge_request.source_project.vexor_ci_service.commit_status(merge_request.last_commit.sha)
            response = {status: status}

            render json: response
          end
        end

        Project.instance_eval do
          # call to `gitlab_ci?` is hardcoded in `app/views/projects/merge_requests/_show.html.haml`
          # so we need to patch it
          def gitlab_ci?
            vexor_ci?
          end

          def vexor_ci?
            vexor_ci_service && vexor_ci_service.active
          end
        end
      end
    end
  end
end
