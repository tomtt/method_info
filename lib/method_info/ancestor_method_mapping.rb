module MethodInfo
  # Given an object, determine the owner for each of its methods. Also
  # keep note of the hierarchy of the object's ancestors
  class AncestorMethodMapping < Hash
    def initialize(object)
      @object = object
      build_ancestor_hierarchy
      find_owner_for_each_method
    end

    attr_reader :ancestors

    private

    def build_ancestor_hierarchy
      @ancestors = @object.class.ancestors
      begin
        @eigenclass = class << @object;self;end
        unless @ancestors.include?(@eigenclass)
          @ancestors = [@eigenclass] + @ancestors
        end
      rescue TypeError
      end
    end

    def find_owner_for_each_method
      @object.methods.each do |method|
        self[method.to_sym] = method_owner(method)
      end
    end

    # Returns the class or module where method is defined on @object
    def method_owner(method_symbol)
      # Under normal circumstances just calling @object.method(method_symbol) would work,
      # but this will go wrong if the object has redefined the method method.
      method = Object.instance_method(:method).bind(@object).call(method_symbol)

      method.owner
    rescue NoMethodError
      poor_mans_method_owner(method, method_symbol.to_s)
    end

    # Ruby 1.8.6 has no Method#owner method, this is a poor man's replacement. It has horrible
    # performance and may break for other ruby implementations than MRI.
    def poor_mans_method_owner(method, method_name)
      # A Method object has no :owner method, but we can infer it's owner from the result of it's
      # :to_s method. Examples:
      # 37.method(:rdiv).to_s => "#<Method: Fixnum#rdiv>"
      # 37.method(:ceil).to_s => "#<Method: Fixnum(Integer)#ceil>"
      # 37.method(:prec).to_s => "#<Method: Fixnum(Precision)#prec>"
      # obj.method(:singleton_method).to_s => "#<Method: #<Object:0x5673b8>.singleton_method>"
      # For a nested module: "#<Method: Module1::ClassName(Module1::Module2::Module3)#method>"

      build_ancestor_regexp_map
      @ancestors.each do |ancestor|
        return ancestor if method.to_s =~ @ancestor_regexp_map[ancestor]
      end
      nil
    end

    def build_ancestor_regexp_map
      unless @ancestor_regexp_map
        @ancestor_regexp_map = Hash.new
        ancestors.each do |ancestor|
          ancestor_name = ancestor.to_s
          if ancestor_name =~ /^#<Class:(.*)>$/
            ancestor_name = $1
          end
          @ancestor_regexp_map[ancestor] = /#{Regexp.escape(ancestor_name)}[)#.]/
        end
      end
    end
  end
end
