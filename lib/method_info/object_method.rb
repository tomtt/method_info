require 'method_info/ancestor_list'

module MethodInfo
  module ObjectMethod
    # Provides information about an object's methods.
    # Options:
    # :print (default: true)
    # Any other options are passed to the AncestorList::build method
    def method_info(options = {})
      do_print = !options.has_key?(:print) || options.delete(:print)
      ancestor_list = AncestorList.build(self, options)
      puts ancestor_list if do_print
      format = options[:format]
      if format
        if format == :string
          ancestor_list.to_s
        else
          ancestor_list.to_a
        end
      end
    end
  end
end

class Object
  include MethodInfo::ObjectMethod
end
