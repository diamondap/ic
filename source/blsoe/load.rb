class IC::Source::BLSOE::Load < IC::Loader

  def initialize(ic, manager)
    @ic = ic
    @manager = manager
    super(ic)
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
      bulk_load(file, batch_size: batch_size)
    end
  end


end
