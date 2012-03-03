class IC::Source

  # Param ic is an instance of IC::Base.
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

  def create_schema_file
    File.join(File.dirname(__FILE__), 'schema', "#{self.name}_create.sql") 
  end

  def drop_schema_file
    File.join(File.dirname(__FILE__), 'schema', "#{self.name}_drop.sql") 
  end

  def create_index_file
    File.join(File.dirname(__FILE__), 'index', "#{self.name}_create.sql") 
  end

  def drop_index_file
    File.join(File.dirname(__FILE__), 'index', "#{self.name}_drop.sql") 
  end

  def file_content(file_path)
    if File.exist?(file_path)
      File.open(file_path, 'r').read
    else
      raise "File #{schema_file} is missing"
    end
  end

  def read_sql_file(file_path)
    commands = []
    cmd = ''
    File.open(file_path, 'r').each_line do |line|
      line.strip!
      next if line == '' or line =~ /^--/
      cmd += line + "\n"
      if line =~ /;$/
        commands.push(cmd)
        cmd = ''
      end
    end
    commands
  end

  def execute_sql_file(file_path)
    commands = read_sql_file(file_path)
    commands.each do |command|
      sql = command.strip
      @ic.log sql
      @ic.db.exec(sql)
    end
  end

  def show_schema
    puts file_content(drop_schema_file)
    puts file_content(create_schema_file)
  end

  def drop_schema
    @ic.log "Dropping schema for #{name}"
    execute_sql_file(drop_schema_file)    
  end

  def create_schema
    @ic.log "Creating schema for #{name}"
    execute_sql_file(create_schema_file)
  end

  def rebuild_schema
    drop_schema
    rebuild_schema
  end

  def show_index
    puts file_content(drop_index_file)
    puts file_content(create_index_file)
  end

  def drop_index
    @ic.log "Dropping index for #{name}"
    execute_sql_file(drop_index_file)
  end

  def create_index
    @ic.log "Creating index for #{name}"
    execute_sql_file(create_index_file)
  end

  def rebuild_index
    drop_index
    rebuild_index
  end

end
