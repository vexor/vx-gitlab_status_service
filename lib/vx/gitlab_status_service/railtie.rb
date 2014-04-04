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
      end
    end
  end
end
