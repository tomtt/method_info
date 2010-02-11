
module MethodInfoMethod
  def method_info
    MethodInfo.new(self)
  end
end

class Object
  include MethodInfoMethod
end

class MethodInfo
  def initialize(object)
    @object = object
    unless @object.singleton_methods.empty?
      @eigenclass = class << object; self; end
    end
  end

  def ancestors
    @ancestors = []
    if @eigenclass
      @ancestors << @eigenclass
    end
    @ancestors += @object.class.ancestors
  end

  # Returns the class or module where method is defined
  def method_owner(method)
    @object.method(method).owner
  end

  # Returns the same value as :method_owner, but also check if the
  # method is handled by a method_missing method in the chain. If it
  # is :method_missing is returned, otherwise the error raised is
  # reraised. This requires an invocation of the method which could
  # cause side effects. Hence this method is considered to be
  # dangerous.
  def method_owner!(method)
    method_owner(method)
  rescue NameError => e
    begin
      @object.clone.send(method)
      :method_missing
    rescue NoMethodError
      raise e
    end
  end
end
