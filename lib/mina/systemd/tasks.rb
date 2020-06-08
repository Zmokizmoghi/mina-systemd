# Add tasks for managing systemd services.

# Usage example:
#   invoke :'systemctl:start', 'SERVICE_NAME'

set :systemctl_command, 'systemctl --user'
set :service_unit_name, "puma.service"

namespace :systemctl do
  desc "Start a systemd service"
  task :start, [:service] do |t, args|
    comment %{Start #{args[:service]} service}
    command %[#{ fetch(:systemctl_command) } start #{args[:service]}]
  end

  desc "Restart a systemd service"
  task :restart, [:service] do |t, args|
    comment %{Restart #{args[:service]} service}
    command %[#{ fetch(:systemctl_command) } restart #{args[:service]}]
  end

  desc "Stop a systemd service"
  task :stop, [:service] do |t, args|
    comment %{Stop #{args[:service]} service}
    command %[#{ fetch(:systemctl_command) } stop #{args[:service]}]
  end

  desc "Get status of a systemd service"
  task :status, [:service] do |t, args|
    command %[#{ fetch(:systemctl_command) } status #{args[:service]}]
  end

  desc "install puma systemd config"
  task :install do
    template =  %{
[Unit]
Description=Puma HTTP Server
After=network.target
[Service]
Type=simple
StandardOutput=append:#{fetch(:deploy_to)}/shared/log/puma.stdout.log
StandardError=append:#{fetch(:deploy_to)}/shared/log/puma.sterr.log
WorkingDirectory=#{fetch(:deploy_to)}/current
Environment=RAILS_ENV=#{fetch(:rails_env)}
ExecStart=/home/#{fetch(:user)}/.rbenv/bin/rbenv exec bundle exec puma
ExecStop=/home/#{fetch(:user)}/.rbenv/bin/rbenv exec bundle exec pumactl -S #{fetch(:deploy_to)}/shared/tmp/sockets/puma.state stop
Restart=always
RestartSec=5
[Install]
WantedBy=multi-user.target
}

    systemd_path = fetch(:service_unit_path, fetch_systemd_unit_path)
    service_path = systemd_path + "/" + fetch(:service_unit_name)
    command %{ mkdir -p #{systemd_path} }
    command %{ touch #{service_path} }
    command %{ echo "#{ template }" > #{ service_path } }
    command %{ #{ fetch(:systemctl_command) } daemon-reload }
    command %{ #{ fetch(:systemctl_command) } enable #{ service_path } }
  end

  task :uninstall do
    command %{ #{ fetch(:systemctl_command) } disable #{fetch(:service_unit_name)} }
    command %{ rm #{File.join(fetch(:service_unit_path, fetch_systemd_unit_path),fetch(:service_unit_name))}  }
  end

  def fetch_systemd_unit_path
    File.join('/home', fetch(:user), '.config', 'systemd', 'user')
  end
end
