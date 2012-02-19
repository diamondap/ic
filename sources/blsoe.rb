class BLSOE < ICSource

  def initialize(ic)
    @name = "blsoe"
    @description = "Bureau of Labor Statistics Occupational Employment"
    super(ic, name, description)
  end

  def config
    {
      fetch_scheme: 'ftp',
      remote_host:  'ftp.bls.gov',
      remote_dir:   'pub/time.series/oe/',
      schedule:     'annual',      
    }
  end

  def files
    [
     'oe.area',
     'oe.areatype',
     'oe.contacts',
     'oe.data.0.Current',
     'oe.data.1.AllData',
     'oe.datatype',
     'oe.footnote',
     'oe.industry',
     'oe.occugroup',
     'oe.occupation',
     'oe.release',
     'oe.seasonal',
     'oe.sector',
     'oe.series',
     'oe.statemsa',
     'oe.txt'
    ]
  end

  def extract
    @ic.log "Connecting to #{config[:remote_host]}"
    ftp = Net::FTP.new(config[:remote_host], 'anonymous', 'user@host.com')
    @ic.log ftp.welcome
    ftp.passive = true
    
    @ic.log "Starting fetch. All files will be saved to #{raw_data_dir}"
    ftp.chdir(config[:remote_dir])
    files.each do |remote_file|
      local_file = File.join(raw_data_dir, remote_file)
        @ic.log "Fetching text file #{remote_file}"
        ftp.gettextfile(remote_file, local_file)
    end

    @ic.log "Disconnecting from #{config[:remote_host]}"
    ftp.close
  end

  def transform
    @ic.log "Transform..."
    xform_current_data
  end

  def load
    @ic.log "Load..."
  end

  # Adapter-specific functions from here down

  # Columns for table bls_oe_current
  CURRENT_DATA_COLS = ['seasonal', 'areatype_code', 'area_code',
                       'industry_code', 'occupation_code', 
                       'datatype_code', 'year', 'period', 'value', 
                       'footnote_codes']

  def xform_current_data
    line_num = 0
    infile_path = File.join(raw_data_dir, 'oe.data.0.Current')
    outfile_path = File.join(transform_dir, 'bls_oe_current')
    outfile = File.open(outfile_path, 'w')
    outfile.puts(CURRENT_DATA_COLS.join("\t"))
    File.open(infile_path, 'r').each_line do |line|
      # Skip first line, which has column names
      if line_num == 0
        line_num = 1
        next
      end
      series_id, year, period, value, footnote_codes = line.split(/\t/)
      seasonal = series_id[2]
      areatype_code = series_id[3]
      area_code = series_id[4..10]
      industry_code = series_id[11..16]
      occupation_code = series_id[17..22]
      datatype_code = series_id[23..24]      
      outfile.print([seasonal, areatype_code, area_code,
                     industry_code, occupation_code, 
                     datatype_code, year, period, value, 
                     footnote_codes].join("\t"))
      line_num += 1
      if line_num % 50000 == 0
        puts "Transformed #{line_num} records"
      end
    end
    outfile.close
  end

end

