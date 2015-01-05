class Object
  def metaclass
    class << self; self; end
  end
  def make_callback(obj, meth)
    metaclass = class << self; self; end
    metaclass.send(:define_method, :callback) do
      obj.send(meth)
    end
  end
end
