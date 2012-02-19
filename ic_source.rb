class ICSource

  def initialize(ic, name, description)
    @ic = ic
    @name = name
    @description = description
    ensure_data_directories
  end

  def name
    @name
  end

  def description
    @description
  end

  def base_data_dir
    File.join(@ic.data_dir, self.name)
  end

  def raw_data_dir
    File.join(base_data_dir, "raw")
  end

  def transform_dir 
    File.join(base_data_dir, "transformed")
  end

  def ensure_data_directories
    [base_data_dir, raw_data_dir, transform_dir].each do |dir|
      ensure_dir(dir)
    end
  end

  # Ensure directory exists. Create it if necessary.
  def ensure_dir(dir)
    if !File.exists?(dir)
      @ic.log "Creating directory #{dir}"
      Dir.mkdir(dir)
    end
  end

  def schema_file
    File.join(File.dirname(__FILE__), 'schema', "#{self.name}.sql") 
  end

  # Rebuild the database schema for this source.
  def rebuild_schema
    if File.exist?(schema_file)
      @ic.log "Rebuilding schema for #{name}"
      sql = File.open(schema_file, 'r').read
      @ic.dbh.do(sql)
    else
      raise "Schema file #{schema_file} is missing"
    end
  end

end
