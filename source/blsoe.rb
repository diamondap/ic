class IC::Source::BLSOE < IC::Source

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
    # @ic.log "Transform..."
    # xform_current_data
    @ic.log "Deleting autofill file"
    delete_autofill_output_file

    # @ic.log "Transforming area autofill data"
    # lines_in, lines_out = xform_area
    # @ic.log "#{lines_in} lines in, #{lines_out} lines out"

    # @ic.log "Transforming industry autofill data"
    # lines_in, lines_out = xform_industry
    # @ic.log "#{lines_in} lines in, #{lines_out} lines out"

    # @ic.log "Transforming occugroup autofill data"
    # lines_in, lines_out = xform_occugroup
    # @ic.log "#{lines_in} lines in, #{lines_out} lines out"

    @ic.log "Transforming occupation autofill data"
    lines_in, lines_out = xform_occupation
    @ic.log "#{lines_in} lines in, #{lines_out} lines out"
  end

  def load
    @ic.log "Load..."
  end

  private

  # Columns for table bls_oe_current
  CURRENT_DATA_COLS = ['seasonal', 'areatype_code', 'area_code',
                       'industry_code', 'occupation_code', 
                       'datatype_code', 'year', 'period', 'value', 
                       'footnote_codes']

  # Transforms the "current" dataset, which includes the wage data
  # for the current year.
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

  
  AREA             = 1
  INDUSTRY         = 2
  SECTOR           = 3
  OCCUPATION_GROUP = 4
  OCCUPATION       = 5
  AREA_FIPS        = 6
  AREA_TYPE        = 7
  DATA_TYPE        = 8
  FOOTNOTE         = 9
  SEASONAL         = 10
  STATE            = 11
  
  def autofill_output_file
    File.join(transform_dir, 'bls_oe_autofill')
  end

  def delete_autofill_output_file
    File.delete(autofill_output_file)
  end

  # Transform the area file for autofill
  def xform_area
    input_count = 0
    output_count = 0
    ignore = ['metropolitan', 'nonmetropolitan', 'area', 'region', 'city']
    infile_path = File.join(raw_data_dir, 'oe.area')    
    outfile = File.open(autofill_output_file, 'a')
    CSV.foreach(infile_path, col_sep: "\t", headers: true) do |data|

      # Get the city name from a value like Washington, DC
      # This prevents 2-letter state codes from polluting the autofill
      region_name = data['area_name'].split(',')[0]

      all_region_names = Autofill::words_and_phrases(region_name, ignore)
      all_region_names.each do |tuple|
        vals = [tuple[0].strip, # word or phrase
                AREA, 
                tuple[1], # bool: does area name start with this word/phrase?
                data['area_code'],
                data['area_name']]
        outfile.puts vals.join("\t")
        output_count += 1 
      end
      input_count += 1
    end
    outfile.close
    [input_count, output_count]
  end

  def xform_industry
    input_count = 0
    output_count = 0
    infile_path = File.join(raw_data_dir, 'oe.industry')
    outfile = File.open(autofill_output_file, 'a')
    CSV.foreach(infile_path, col_sep: "\t", headers: true) do |data|
      record_type = INDUSTRY
      industry_name = data['industry_name']
      if data['industry_code'] =~ /--/
        industry_name = data['industry_name'].split('-')[1].strip
        record_type = SECTOR
      end
      industries = Autofill::words_and_phrases(industry_name)
      industries.each do |tuple|
        vals = [tuple[0].strip, # word or phrase
                record_type, 
                tuple[1], # bool: does industry start with this word/phrase?
                data['industry_code'],
                data['industry_name']]
        outfile.puts vals.join("\t")
        output_count += 1 
      end
      input_count += 1
    end
    outfile.close
    [input_count, output_count]
  end

  def xform_occugroup
    input_count = 0
    output_count = 0
    infile_path = File.join(raw_data_dir, 'oe.occugroup')
    outfile = File.open(autofill_output_file, 'a')
    CSV.foreach(infile_path, col_sep: "\t", headers: true) do |data|
      groups = Autofill::words_and_phrases(data['occugroup_name'])
      groups.each do |tuple|
        vals = [tuple[0].strip, # word or phrase
                OCCUPATION_GROUP,  
                tuple[1], # bool: does area group start with this word/phrase?
                data['occugroup_code'], 
                data['occugroup_name']]
        outfile.puts vals.join("\t")
        output_count += 1 
      end
      input_count += 1
    end
    outfile.close
    [input_count, output_count]
  end

  def xform_occupation
    input_count = 0
    output_count = 0
    infile_path = File.join(raw_data_dir, 'oe.occupation')
    outfile = File.open(autofill_output_file, 'a')
    CSV.foreach(infile_path, col_sep: "\t", headers: true) do |data|
      occupations = Autofill::words_and_phrases(data['occupation_name'])
      occupations.each do |tuple|
        vals = [tuple[0].strip, # word or phrase
                OCCUPATION,  
                tuple[1], # bool: does area group start with this word/phrase?
                data['occupation_code'], 
                data['occupation_name']]
        outfile.puts vals.join("\t")
        output_count += 1 
      end
      input_count += 1
    end
    outfile.close
    [input_count, output_count]
  end

end

