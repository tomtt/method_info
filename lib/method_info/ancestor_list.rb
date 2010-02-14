module MethodInfo
  class AncestorList
    # :ancestors_to_show (default: []) (Overrules the hiding of any ancestors as specified by the :ancestors_to_exclude option)
    # :ancestors_to_exclude (default: []) (If a class is excluded, all modules included under it are excluded as well, an ancestor specified in :ancestors_to_show will be shown regardless of the this value)
    # :method (default: nil) More detailed info about one method
    # :method_missing (default: false)
    # :public_methods (default: true)
    # :protected_methods (default: false)
    # :private_methods (default: false)
    # :include_name_of_excluded_ancestors (default: true)
    # :format (default: :string)
    def self.build(object, options)
    end

    private

    def self.process_options(options = {})
      defaults = {
        :ancestors_to_show => [],
        :ancestors_to_exclude => [],
        :format => :string,
        :include_name_of_excluded_ancestors => true,
        :method => nil,
        :method_missing => false,
        :private_methods => false,
        :protected_methods => false,
        :public_methods => true
      }
      unknown_options = options.keys - defaults.keys
      if unknown_options.empty?
        defaults.merge(options)
      else
        raise ArgumentError.new("Unsupported options: " + unknown_options.map { |k| k.to_s }.sort.join(', '))
      end
    end
  end
end
