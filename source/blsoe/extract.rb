class IC::Source::BLSOE::Extract

  def initialize(ic, manager)
    @ic = ic
    @manager = manager
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

  def extract_ftp
    @ic.log "Connecting to #{config[:remote_host]}"
    ftp = Net::FTP.new(config[:remote_host], 'anonymous', 'user@host.com')
    @ic.log ftp.welcome
    ftp.passive = true
    
    @ic.log "Starting fetch. "
    @ic.log "All files will be saved to #{@manager.raw_data_dir}"
    ftp.chdir(config[:remote_dir])
    files.each do |remote_file|
      local_file = File.join(@manager.raw_data_dir, remote_file)
        @ic.log "Fetching text file #{remote_file}"
        ftp.gettextfile(remote_file, local_file)
    end

    @ic.log "Disconnecting from #{config[:remote_host]}"
    ftp.close
  end

  def http_urls
    [
     'http://www.bls.gov/oes/current/area_definitions_m2010.xls',
     'http://www.bls.gov/oes/current/occupation_definitions_m2010.xls',
     'http://www.bls.gov/oes/current/industry_titles_m2010.xls'
    ]
  end

  def extract_http
    http_urls.each do |url|
      @ic.log "Fetching #{url}"
      outfile = File.join(@manager.raw_data_dir, File.basename(url))
      File.open(outfile, 'wb') do |file|
        file.print Net::HTTP.get(URI(url))
      end
    end
  end

  def extract
    extract_ftp
    extract_http
  end

end
