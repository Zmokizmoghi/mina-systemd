# Mina::Systemd
This is wrapper for `systemd` service manager for [mina](https://github.com/mina-deploy/mina)


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mina-systemd', require: false, github: 'knockwaitknock/mina-systemd'
```

And then execute:
``` bash
bundle install
```

And then
``` bash
mina staging systemctl:install
```
or
``` bash
mina production systemctl:install
```

This command will install systemd unit file to userpspace on your remote server.

## Usage

in `deploy.rb`

```ruby
require 'mina/systemd'

task deploy: :environment do
  deploy do
    ...
    on :launch do
      invoke :'systemctl:restart', 'puma'
    end
  end
end
```

Call it as mina task:

`mina systemctl:stop['puma']`

if you use zsh add noglob

`noglob mina systemctl:status['puma']`

## Typical deploy config
``` ruby
require 'mina/systemd'
require 'mina/multistage'
require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'

set :deploy_to, '/home/www/app_name'
set :repository, '...'

set :shared_dirs, fetch(:shared_dirs, []).push('log', 'tmp', 'public/uploads', 'public/storage', 'pids')
set :shared_files, fetch(:shared_files, []).push('config/database.yml')

task :remote_environment do
  invoke :'rbenv:load'
end

desc "Deploys the current version to the server."
task :deploy do
  deploy do
    invoke :'rbenv:load'
    invoke :'git:clone'
    invoke :'deploy:link_shared_paths'
    invoke :'bundle:install'
    invoke :'rails:db_migrate'
    invoke :'deploy:cleanup'

    on :launch do
      invoke :'rbenv:load'
      invoke :'systemctl:restart', 'puma'
    end
  end

end

```

To control puma daemon from remote server cli please add `--user` parameter to systemctl call:
``` bash
systemctl --user restart puma
```


