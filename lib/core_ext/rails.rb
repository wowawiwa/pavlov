module ActiveRecord::FinderMethods
  def find_by( *args)
    raise ArgumentError.new("[overwritten!] You must pass a hash as an argument.") if not args.first.kind_of? Hash 
    return nil if args.first.empty?
    where(*args).take
  end
end

# To be included in an ActiveRecord::Base model
#   duration_attrs opts
#   where opts:
#     :my_attr => { :max_scale => :days}, ...
#     such as my_attr_tspan is an integer field
# creates a getter and a setter attr_ts and attr_ts=
#   setter: 
#     nil if no value != ""
#     seconds equivalent otherwise
#   getter: 
#     { weeks: 12, days: 3 } with no key-value which value is 0
module DurationAttrs
  def self.included( base)
    base.class_eval do
      def self.duration_attrs( attrs)
        attrs.each do |attr, opts|
          max_scale = opts[:max_scale]
          meth_name = opts[:virtual_attr_name]
          define_method :"#{meth_name.to_s}" do
            if seconds = self.send(:"#{attr}")
              Hashie::Mash.new( 
                TimeTools.seconds_to_timeunits(seconds)[max_scale].select{|k,v| v != 0}
              )
            else
              {}
            end
          end
          define_method :"#{meth_name.to_s}=" do |hash={}|
            hash = hash.reject{|k,v| v.empty?}
            seconds = hash.empty? ? nil : TimeTools.timeunits_to_seconds( hash)
            self.send(:"#{attr}=", seconds)
          end
        end
      end
    end
  end
end

class ActiveRecord::Relation
  def put_tabular( opts={})
    self.map(&:attributes).put_tabular( opts)
  end
end


