require 'method_info/ancestor_method_structure'

module MethodInfo
  class OptionHandler
    def self.handle(object, options = {})
      format = options.delete(:format)
      ancestor_method_structure = AncestorMethodStructure.build(object, options)
      if format == :string
        ancestor_method_structure.to_s
      elsif format == :array
        ancestor_method_structure.to_a
      elsif format
        raise(ArgumentError.new("Unknown value for :format option. Supported values are: nil, :array, :string"))
      else
        puts ancestor_method_structure
      end
    end
  end
end
