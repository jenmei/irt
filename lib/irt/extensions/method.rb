class Method

  def location
    f = l = nil
    n = case
        when arity >= 0
          arity
        when arity == -1
          0
        when arity < -1
          arity.abs - 1
        end
    arr = Array.new(n)
    set_trace_func proc{ |event, file, line, meth_name, binding, classname|
      if event.eql?('call') && name.to_s.match(meth_name.to_s)
        f = file
        l = line
        set_trace_func nil
        throw :method_located
      end
    }
    catch(:method_located) { call *arr }
    set_trace_func nil
    [f,l]
  end

  def info
    file, line = location
    { :name  => name,
      :owner => owner.name,
      :file  => file,
      :line  => line,
      :arity => arity }
  end

end
