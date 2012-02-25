module IC::Source::BLSOE

  require_relative 'blsoe/extract'
  require_relative 'blsoe/transform'
  require_relative 'blsoe/load'

  class Manager < IC::Source

    def initialize(ic)
      @name = "blsoe"
      @description = "Bureau of Labor Statistics Occupational Employment"
      super(ic, name, description)
    end

    def extract
      extractor = Extract.new(@ic, self)
      extractor.extract
    end

    def transform
      transformer = Transform.new(@ic, self)
      transformer.transform
    end

    def load
      loader = Load.new(@ic, self)
      loader.load
    end

  end

end
