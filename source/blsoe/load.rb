class IC::Source::BLSOE::Load

  def initialize(ic, manager)
    @ic = ic
    @manager = manager
  end

  def files
    Dir[@manager.transform_dir + '/*']
  end

  def load
    files.each do |file|
      table = File.basename(file)
      if table == 'bls_oe_current'
        batch_size = 100000
      else 
        batch_size = 1000
      end
      @ic.log "Loading file #{table} into table #{table}"
      @ic.log "Batch size is #{batch_size}"
      load_into_table(file, table, batch_size)
    end
  end

  # def load
  #   files.each do |file|
  #     table = File.basename(file)
  #     # @ic.log "Loading file #{table} into table #{table}"
  #     stmt = "COPY #{table} FROM '#{file}' WITH CSV HEADER DELIMITER '\t'"
  #     @ic.log stmt
  #     @ic.dbh.do(stmt)
  #   end
  # end

  def load_into_table(file, table, batch_size = 1000)
    begin 
      @ic.dbh['AutoCommit'] = false
      count = 0
      current_record = nil
      insert_statement = create_insert_statement(file, table)
      @ic.log insert_statement
      sth = @ic.dbh.prepare(insert_statement)
      CSV.foreach(file, col_sep: "\t", headers: true) do |data|
        current_record = data
        sth.execute(*(data.fields))
        count += 1
        if count % batch_size == 0
          @ic.log "Committing #{batch_size} records"
          @ic.dbh.commit
        end
      end
      @ic.dbh.commit
      sth.finish
    rescue Exception => ex
      @ic.log "Source file #{file} line #{count}"
      @ic.log current_record.inspect
      @ic.log ex.message
      @ic.log ex.backtrace
    ensure
      @ic.dbh['AutoCommit'] = true
    end
  end

  def create_insert_statement(file, table)
    headers = nil
    File.open(file, 'r') { |f|
      headers = f.readline.chomp.split(/\t/)
    }
    placeholders = ('?' * headers.count).split(//).join(', ')
    "insert into #{table} (#{headers.join(', ')}) " + 
      "values (#{placeholders})"
  end

end
