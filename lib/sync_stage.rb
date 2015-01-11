#!/usr/bin/env ruby

require 'yaml'
require 'pp'

module SyncStage
  class Worker

    def initialize(cfg)
      s = Time.now
      Dir.chdir(cfg.app) do
        if !File.exist?('sync_stage.yml')
          if ! cfg.init
            puts "Directory not initialized - try argument --init or see --help"
            exit 1
          end
          if cfg.init
            create_example_config(cfg.app)
          end
        else
          read_config
        end
      end
      if cfg.explain
        explain(cfg.restore)
        exit 0
      end
      if cfg.run
        run(cfg.restore)
      end
      duration = Time.now - s
      puts "synced data \nfrom #{@config[:source].fetch(:host)} to #{@config[:destination].fetch(:host)} \n
      done in #{duration.ceil} seconds."
    end

    private 

    def explain(restore)
      puts "sync_stage would use following settings: \n\n"
      pp @config

      cmds = []
      cmds.push(ssh_cmd(@config[:source]) << "'" << pg_dump_cmd(@config[:source]) << "'")
      cmds.push(ssh_cmd(@config[:source]) << "'" << pack_assets_cmd(@config[:source]) << "'")
      cmds.push(copy_db_cmd(@config[:source], @config[:destination]))
      cmds.push(copy_assets_cmd(@config[:source], @config[:destination]))
      if restore
        cmds.push(ssh_cmd(@config[:destination]) << "-t '" << 
                  pg_restore_cmd(@config[:source], @config[:destination]) << "'")
        cmds.push(ssh_cmd(@config[:destination]) << "'" << 
                  unpack_assets_cmd(@config[:source], @config[:destination]) << "'")
      end
      puts "\nand run the following commands in order: \n\n"
      cmds.each_with_index do |c,i|
        puts "#{i} $: " << c   
      end
    end


    def run(restore)
      puts "this could take a while....\n"
      execute_db_dump
      execute_asset_packing
      execute_db_copying
      execute_asset_copying
      if restore
        execute_db_restoring
        execute_asset_unpacking
      end
    end

    def execute_db_dump
      ret = system(ssh_cmd(@config[:source]) << "'" << pg_dump_cmd(@config[:source]) << "'")
      if ret
        puts "done dumping database"
      else
        raise "error dumping database"
      end
    end

    def execute_asset_packing
      ret = system(ssh_cmd(@config[:source]) << "'" << pack_assets_cmd(@config[:source]) << "'")
      if ret
        puts "done packing shared directory"
      else
        raise "error packing shared directory"
      end
    end

    def execute_db_copying
      ret = system(copy_db_cmd(@config[:source], @config[:destination]))
      if ret 
        puts "done copying database over"
      else
        raise "error copying database over"
      end
    end

    def execute_asset_copying
      puts "start to copy over shared dir... be patient..."
      ret = system(copy_assets_cmd(@config[:source], @config[:destination]))
      if ret 
        puts "done copying assets"
      else
        raise "error copying assets over"
      end
    end

    def execute_db_restoring
      ret = system(ssh_cmd(@config[:destination]) << " -t '" << 
                  pg_restore_cmd(@config[:source], @config[:destination]) << "'")
      if ret
        puts "done restoring database"
      else
        raise "error restoring database"
      end
    end

    def execute_asset_unpacking
      ret = system(ssh_cmd(@config[:destination]) << "'" << unpack_assets_cmd(@config[:source], @config[:destination]) << "'")
      if ret
        puts "done unpacking shared dir"
      else
        raise "error unpacking shared dir"
      end
    end

    def pg_dump_cmd(opts)
      str = "pg_dump -U #{opts.fetch(:dbuser)} -h localhost -Fc #{opts.fetch(:db)} -f ~/#{opts.fetch(:db)}.sql"
      str
    end

    def pack_assets_cmd(opts)
      str = "cd #{opts.fetch(:shared_dir)} && tar cvfzp ~/#{opts.fetch(:host)}-shared.tgz ./public"
      str
    end

    def ssh_cmd(opts)
      "ssh -l #{opts.fetch(:user)} #{opts.fetch(:host)} "
    end

    def copy_db_cmd(from_opts, to_opts)
      str = "scp #{from_opts.fetch(:user)}@#{from_opts.fetch(:host)}:~/#{from_opts.fetch(:db)}.sql "
      str << " #{to_opts.fetch(:user)}@#{to_opts.fetch(:host)}:~/"
      str
    end

    def copy_assets_cmd(from_opts, to_opts)
      str = "scp #{from_opts.fetch(:user)}@#{from_opts.fetch(:host)}:~/#{from_opts.fetch(:host)}-shared.tgz "
      str << " #{to_opts.fetch(:user)}@#{to_opts.fetch(:host)}:#{to_opts.fetch(:shared_dir)}/"
      str
    end

    def pg_restore_cmd(src, dest)
      str = "sudo -u postgres pg_restore -U postgres -v -d #{dest.fetch(:db)} -c #{src.fetch(:db)}.sql"
      str
    end

    def unpack_assets_cmd(src, dest)
      str = "cd #{dest.fetch(:shared_dir)} && 
              mv public public-#{Time.now.to_i} && 
              tar xvfzp #{src.fetch(:host)}-shared.tgz"
      str
    end

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
#ret = system(copy_assets_cmd(PRODUCTION, STAGING))

# dump the database
#ret = system(ssh_cmd(PRODUCTION) << "'" << pg_dump_cmd(PRODUCTION) << "'")

# copy db-dump to other host
#ret = system(copy_db_cmd(PRODUCTION, STAGING))

# restore db from dump
#puts "you need to be a sudoer"
#ret = system(ssh_cmd(STAGING) << " -t '" << pg_restore_cmd(PRODUCTION, STAGING) << "'")

