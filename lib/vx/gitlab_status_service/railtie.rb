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
        Projects::MergeRequestsController.class_eval do
          def ci_status
            status = @merge_request.source_project.vexor_ci_service.commit_status(merge_request.last_commit.sha)
            vexor_ci_build_status_to_gitlab_status_map = {
              initialized: :pending,
              started: :running,
              passed: :success,
              failed: :failed,
              errored: :failed
            }.with_indifferent_access
            response = {status: vexor_ci_build_status_to_gitlab_status_map[status]}

            render json: response
          end
        end

        Project.class_eval do
          # call to `gitlab_ci?` (and `@project.gitlab_ci_service.builds_path`) is hardcoded in `app/views/projects/merge_requests/_show.html.haml`
          # so we need to patch it
          def gitlab_ci?
            vexor_ci?
          end

          def vexor_ci?
            vexor_ci_service && vexor_ci_service.active
          end

          def gitlab_ci_service
            vexor_ci_service
          end
        end

        MergeRequestsHelper.module_eval do
          def ci_build_details_path(merge_request)
            merge_request.source_project.vexor_ci_service.build_page(merge_request.last_commit.sha)
          end
        end
      end
    end
  end
end
