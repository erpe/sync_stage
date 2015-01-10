#!/usr/bin/env ruby

require 'yaml'

module SyncStage
  class Worker

    def self.say_hi
      puts "hi from sync_stage"
    end

    def initialize(dir, init=nil)
      Dir.chdir(dir) do
        if !File.exist?('sync_stage.yml')
          if ! init
            raise "Directory not initialized - try argument --init or see --help"
          end
          if init
            puts "creating example config"
            create_example_config(dir)
          end
        else
          puts "trying existing config"
          read_config
        end
      end
    end

    def print_config
      puts YAML::dump(@config)
    end

    def init_config

    end

    def pg_dump_cmd(opts)
      str = "pg_dump -U #{opts.fetch(:dbuser)} -h localhost -Fc #{opts.fetch(:db)} -f ~/#{opts.fetch(:db)}.sql"
      puts "running #{str}"
      str
    end

    def pack_assets_cmd(opts)
      str = "cd #{opts.fetch(:shared_dir)} && tar cvfzp ~/#{opts.fetch(:host)}-shared.tgz ./public"
      puts "running: " << str
      str
    end

    def ssh_cmd(opts)
      "ssh -l #{opts.fetch(:user)} #{opts.fetch(:host)} "
    end

    def copy_db_cmd(from_opts, to_opts)
      str = "scp #{from_opts.fetch(:user)}@#{from_opts.fetch(:host)}:~/#{from_opts.fetch(:db)}.sql "
      str << " #{to_opts.fetch(:user)}@#{to_opts.fetch(:host)}:~/"
      puts "running: #{str}"
      str
    end

    def copy_assets_cmd(from_opts, to_opts)
      str = "scp #{from_opts.fetch(:user)}@#{from_opts.fetch(:host)}:~/#{from_opts.fetch(:host)}-shared.tgz "
      str << " #{to_opts.fetch(:user)}@#{to_opts.fetch(:host)}:#{to_opts.fetch(:shared_dir)}/"
      puts "running " << str
      str
    end

    def pg_restore_cmd(src, dest)
      str = "sudo -u postgres pg_restore -U postgres -v -d #{dest.fetch(:db)} -c #{src.fetch(:db)}.sql"
      puts str
      str
    end

    private 

    def create_example_config(dir)
      puts Dir.pwd
      _example = YAML::load_file(File.join(File.dirname(__FILE__),'config', 'sync_stage.yml'))
      File.open('sync_stage.yml', 'w') do |f|
        f.puts YAML::dump(_example)
      end
    end

    def read_config
      @config = YAML::load_file('sync_stage.yml')
    end
  end

end


# pack the assets
#ret = system(ssh_cmd(PRODUCTION) << "'" << pack_assets_cmd(PRODUCTION) << "'")
#process = $?
#puts "returned: #{ret} for #{process.inspect}"
# copy the assets to other host
#ret = system(copy_assets_cmd(PRODUCTION, STAGING))
#process = $?
#puts "returned: #{ret} for #{process.inspect}"

# dump the database
#ret = system(ssh_cmd(PRODUCTION) << "'" << pg_dump_cmd(PRODUCTION) << "'")
#process = $?
#puts "returned: #{ret} for #{process.inspect}"

# copy db-dump to other host
#ret = system(copy_db_cmd(PRODUCTION, STAGING))
#process = $?
#puts "returned: #{ret} for #{process.inspect}"

# restore db from dump
#puts "you need to be a sudoer"
#ret = system(ssh_cmd(STAGING) << " -t '" << pg_restore_cmd(PRODUCTION, STAGING) << "'")
#process = $?
#puts "returned: #{ret} for #{process.inspect}"

