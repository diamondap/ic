#
# ic.rb
# 
# Data loading.
# ------------------------------------------------------------------
require 'bundler/setup'
require_relative 'ic_source'
require_relative 'autofill'
require 'net/ftp'
require 'net/http'
require 'csv'


class IC

  def initialize
    @dbh = nil
    @sources = {}
    require_dbi
    load_all_sources
  end

  # Silence annoying "already initialized constant Deprecate"
  # warning that comes out of the DBI module.
  def require_dbi
    warn_level = $VERBOSE
    $VERBOSE = nil
    begin
      require 'dbi'
    ensure
      $VERBOSE = warn_level
    end    
  end

  def load_all_sources
    Dir[File.dirname(__FILE__) + '/sources/*.rb'].each do |file| 
      require file 
    end
    ObjectSpace.each_object(Class) do |klass|
      if klass < ICSource
        instance = klass.new(self)
        register_source(instance.name, instance)
      end
    end
  end

  def db_host
    '127.0.0.1'
  end
  
  def db_catalog 
    'govdata'
  end 
  
  def db_user 
    'govdatauser'
  end

  def db_password 
    'GvrLwYmPPR'
  end

  def data_dir
    '/mnt/external/icdata'
  end

  # Allow source adapters to register themselves.
  def register_source(name, source_adapter)
    @sources[name] = source_adapter
  end

  def dbh
    log "Connecting to DBI:Pg:#{db_catalog} as user #{db_user}"
    @dbh ||= DBI.connect("DBI:Pg:#{db_catalog}", db_user, db_password)
  end

  def disconnect!
    @dbh.disconnect if @dbh
    @dbh = nil
  end

  def log(message)
    puts message
  end

  def list
    puts "The following sources are available."
    @sources.keys.sort.each do |name|
      printf("%20s  %58s\n", name, @sources[name].description)
    end
  end

  def run(source_name, action)
    adapter = @sources[source_name]
    adapter.send(action.to_sym)
  end

  def show_usage_and_exit
    puts "\n"
    puts "ic.rb - ETL tool for InfoClarity"
    puts "To list available data sources:"
    puts "  ruby ic.rb -l \n"
    puts "To run an action for a data source:"
    puts "  ruby ic.rb -r <source_name> <command>\n\n"
    puts "The following commands are available:"
    puts "  extract         - Extract data from remote source"
    puts "  transform       - Transform data to local format"
    puts "  load            - Load transformed data into DB"
    puts "  show_schema     - Show the local schema for this data set"
    puts "  drop_schema     - Drop all tables for this data set"
    puts "  create_schema   - Create local DB schema for data set"
    puts "  rebuild_schema  - Drop and rebuild schema for data set"
    puts "  show_indexes    - Show all indexes for this data set"
    puts "  drop_indexes    - Drop all indexes for this data set"
    puts "  create_indexes  - Create all indexes for this data set"
    puts "  rebuild_indexes - Drop & recreate all indexes for this data set"
    exit(0)
  end

  def run_cli
    if ARGV[0] == '-l'
      list
    elsif ARGV[0] == '-r'
      source_name = ARGV[1]
      action = ARGV[2]
      show_usage_and_exit if source_name.nil? or action.nil?
      valid_actions = ['extract', 'transform', 'load', 'show_schema',
                      'drop_schema', 'create_schema', 'rebuild_schema',
                      'show_indexes', 'drop_indexes', 'create_indexes',
                      'rebuild_indexes']
      if !@sources.has_key?(source_name)
        puts "Source '#{source_name}' does not exist."
        puts "Available sources are: "
        list
        exit(1)
      end
      if !valid_actions.include?(action)
        puts "Invalid action. Options are #{valid_actions.join(', ')}"
        exit(1)
      end
      run(source_name, action)
    else
      show_usage_and_exit
    end
  end

end

ic = IC.new
ic.run_cli
