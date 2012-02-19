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

  def extract
    @ic.log "Extracting..."
    return
    @ic.log "Connecting to #{config[:remote_host]}"
    ftp = Net::FTP.new(config[:remote_host])
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
  end

  def load
    @ic.log "Load..."
  end

end

