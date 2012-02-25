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
     # 'oe.area',
     # 'oe.areatype',
     # 'oe.contacts',
     # 'oe.data.0.Current',
     # 'oe.data.1.AllData',
     # 'oe.datatype',
     # 'oe.footnote',
     # 'oe.industry',
     # 'oe.occugroup',
     # 'oe.occupation',
     # 'oe.release',
     # 'oe.seasonal',
     # 'oe.sector',
     # 'oe.series',
     # 'oe.statemsa',
     'oe.txt'
    ]
  end

  def extract
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

end
