class IC::Loader

  # Param ic is an instance of IC::Base.
  def initialize(ic)
    @ic = ic
  end

  # Bulk loads text file into the database.
  # Assumes table name is file basename.
  # 
  # Options in the opts param may include:
  #
  # * :delimiter (defaults to tab)
  # * :batch_size (defaults to 1000) This is used for
  #   reporting only. We'll log a message each time
  #   we've imported batch_size rows.
  def bulk_load(file, opts = {})
    delimiter  = opts[:delimiter] || "\t"
    batch_size = opts[:batch_size] || 1000
    table = File.basename(file)
    @ic.log "Loading file #{table} into table #{table}"
    stmt = "COPY #{table} FROM STDIN WITH CSV HEADER DELIMITER '#{delimiter}'"
    begin
      count = 0
      @ic.log stmt
      @ic.db.exec(stmt)
      File.open(file, 'r').each_line do |line|
        @ic.db.put_copy_data(line)
        count += 1
        if count % batch_size == 0
          @ic.log "Imported #{count} records"
        end
      end
      @ic.log "Imported #{count} records"
    rescue Exception => ex
      @ic.log "Error in bulk copy"
      @ic.log ex.message
    ensure
      @ic.db.put_copy_end
    end
  end


end
