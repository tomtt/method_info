require 'method_info/option_handler'

module MethodInfo
  module ObjectMethod
    # Provides information about an object's methods.
    # Options:
    # :format (default: nil)
    # - :string returns a string representation
    # - :array returns an array representation
    # - anything else prints out a string representation
    # :ancestors_to_show (default: []) (Overrules the hiding of any ancestors as specified
    #                    by the :ancestors_to_exclude option)
    # :ancestors_to_exclude (default: []) (If a class is excluded, all modules included
    #                       under it are excluded as well, an ancestor specified in
    #                       :ancestors_to_show will be shown regardless of the this value)
    # :method_missing (default: false)
    # :public_methods (default: true)
    # :protected_methods (default: false)
    # :private_methods (default: false)
    # :singleton_methods (default: true)
    # :include_name_of_excluded_ancestors (default: true)
    def method_info(options = {})
      OptionHandler.handle(self, options)
    end
  end
end

class Object
  include MethodInfo::ObjectMethod
end
