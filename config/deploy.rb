lock '3.4.0'

set :bundle_bins, fetch(:bundle_bins, []).push('whenever')

set :application, 'shipit'
set :repo_url, 'git@github.com:rubygems/shipit.git'
set :branch, ENV['SHA'] || ENV['REVISION'] || ENV['BRANCH_NAME'] || 'master'

set :deploy_to, '/applications/shipit'
set :format, :pretty
set :pty, true

set :linked_files, %w(config/database.yml config/secrets.yml)
set :linked_dirs, %w(data log tmp vendor/bundle public/system public/assets)

set :keep_releases, 10

before 'deploy:assets:precompile', 'deploy:use_deploy_log'
before 'deploy:symlink:release', 'deploy:use_runtime_log'

after 'deploy:publishing', 'deploy:restart'

namespace :deploy do
  task :use_deploy_log do
    on roles(:app) do
      within release_path do
        execute :ln, '-nsfT', shared_path.join('deploy_log'), './log'
      end
    end
  end

  task :use_runtime_log do
    on roles(:app) do
      within release_path do
        execute :ln, '-nsfT', shared_path.join('log'), './log'
      end
    end
  end

  desc "Signal Thin and Resque services to restart"
  task :restart do
    on roles(:app) do
      execute :sudo, 'sv', 'hup', '/etc/sv/shipit-thin-*'
      execute :sudo, 'sv', 'quit', '/etc/sv/shipit-resque-*'
    end
  end

  desc "Regenerate cron tasks"
  task :cron do
    on roles(:db) do
      within release_path do
        with rails_env: fetch(:rails_env) do
          as 'shipit' do
            execute 'whenever', '--write-crontab'
          end
        end
      end
    end
  end

  desc "Store the deployed revision in a REVISION file"
  task :write_revision do
    on roles(:app) do
      within release_path do
        execute 'echo', fetch(:current_revision), '> REVISION'
      end
    end
  end
end

# before 'deploy:finishing', 'deploy:cron'
# after 'deploy:finishing_rollback', 'deploy:cron'
after 'deploy:log_revision', 'deploy:write_revision'
