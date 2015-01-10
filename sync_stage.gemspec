Gem::Specification.new do |s|
  s.name        = 'SyncStage'
  s.version     = '0.0.1'
  s.licenses    = ['GPLv3']
  s.summary     = "Sync your Rails-App data back from production to staging"
  s.description = "dumps and restores postgres database and packs shared/public over to staging server"
  s.authors     = ["rene paulokat"]
  s.email       = 'rene@so36.net'
  s.files       = ["lib/sync_stage.rb", "lib/config/sync_stage.yml"]
  s.homepage    = 'https://github.com/erpe/sync_stage'
  s.executables <<  'sync_stage'
end
