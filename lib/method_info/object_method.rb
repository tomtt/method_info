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
    # :include_names_of_excluded_ancestors (default: true)
    # :include_names_of_methodless_ancestors (default: true)
    # :enable_colors (default: false)
    # :class_color Set colour for a line printing out a class (only used when :enable_colors is true)
    # :module_color Set colour for a line printing out a module (only used when :enable_colors is true)
    # :message_color Set colour for a line with a message (only used when :enable_colors is true)
    # :methods_color Set colour for a line with methods (only used when :enable_colors is true)
    # :punctuation_color Set colour for punctuation (only used when :enable_colors is true)
    def method_info(options = {})
      OptionHandler.handle(self, options)
    end
  end
end

class Object
  include MethodInfo::ObjectMethod
end
