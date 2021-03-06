module IRT
  module Commands
    module Ri

      @@choices_map = {}

      def self.reset_choices_map
        @@choices_map = {}
      end

      def ri(arg)
        ensure_session
        raise IRT::NotImplementedError, "No available ri_command_format for this system." unless IRT.ri_command_format
        case
        when arg.nil?, arg.empty?
          return puts('nil')
        when arg.match(/^\d+$/)
          if @@choices_map.key?(arg)
            to_search = @@choices_map[arg]
          else
            raise IndexError, "No such method index -- [#{arg}]"
          end
        else
          segm = arg.split('.')
          to_search = segm.pop
          receiver = eval segm.join('.'), IRB.CurrentContext.workspace.binding
          raise NoMethodError, %(undefined method "#{to_search}" for "#{segm.join('.')}") \
            unless receiver.respond_to? to_search.to_sym

          meth = receiver.method(to_search.to_sym).inspect
          meth = meth.match(/^\#<Method: (.+)>$/)[1]
          if m = meth.match(/\((.+)\)(.+)/)
            to_search = m[1] + m[2]
          else
            to_search = meth
          end
        end
        process_ri to_search
      end

    private

      def process_ri(to_search)
        ri = `#{sprintf(IRT.ri_command_format, to_search)}`
         if m = ri.match(/^(-+.*Multiple choices:.*\n\n)(.+)/m)
           output, methods = m.captures
           IRT::Commands::Ri.reset_choices_map
           fmt = "%+7s  %s\n"
           methods.gsub(/\s+/, '').split(',').each_with_index do |m, i|
             @@choices_map[(i+1).to_s] = m
             output << sprintf( fmt, "#{i+1}", m )
           end
           output << "\n"
         else
           output = ri
         end
        puts output
      end

    end
  end
end
