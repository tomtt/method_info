require 'method_info/ancestor_method_structure'

module MethodInfo
  class OptionHandler
    @@custom_default_options = {}

    def self.handle(object, options = {})
      processed_options = process_options(options)
      format = processed_options.delete(:format)
      ancestor_method_structure = AncestorMethodStructure.build(object, processed_options)
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

    def self.default_profile
      {
        :ancestors_to_show => [],
        :ancestors_to_exclude => [],
        :format => nil,
        :include_name_of_excluded_ancestors => true,
        :include_name_of_methodless_ancestors => true,
        :private_methods => false,
        :protected_methods => false,
        :singleton_methods => true,
        :public_methods => true
      }
    end

    def self.default_options=(options = {})
      @@custom_default_options = options
    end

    def self.process_options(options = {})
      defaults = default_profile.merge(@@custom_default_options)
      unknown_options = options.keys - defaults.keys
      if unknown_options.empty?
        defaults.merge(options)
      else
        raise ArgumentError.new("Unsupported options: " + unknown_options.map { |k| k.to_s }.sort.join(', '))
      end
    end
  end
end
