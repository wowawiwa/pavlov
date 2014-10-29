class ::String
  
  # Convert self to a string of given length, truncating or adding spaces
  def normalize_length length
    return "" if length <= 0
    return self.clone if self.length == length
    if self.length > length
      self[0..(length-1)]
    else
      self + Array.new(length - self.length){" "}.inject(:+)
    end
  end
end

class ::Array

  # Puts an array of hash in a tabular fashion
  # Options:
  #   :key_search =>
  #     :first (default)  build the header from the keys of the first hash of the array
  #     :every            build the header as union of all keys in every hash of the array
  #   :header =>
  #     :top (default)    display the header on the top
  #     :inline           display the header inline
  def put_tabular( options={})
    # TODO parameter control
    return if self.blank?

    # work on a copy
    array = self.clone

    # decode params
    key_search = options[:key_search] || :first # || :every
    header = options[:header] || :top # || :inline || []

    # search for the key set to take into account (first element of the array of hash, or every element)
    keys = case key_search
           when :every
             array.inject([]){ |agg, el| (agg + el.keys).uniq }
           when :first, Symbol
             array.first.keys
           end

    # insert header values
    if header == :top
      array.unshift( keys.inject({}){|agg,k| agg.merge!(k => k.to_s)} )
    end

    # compute column size
    column_size = keys.inject({}) do |agg, k|
      agg.merge!( k => array.map{ |el| el[k].to_s.length }.max )
    end

    # insert separator values between header and values
    separator = keys.inject({}){|agg,k| agg.merge!(k => Array.new(column_size[k]){"-"}.inject(:+))}
    if header == :top
      array.insert(1, separator)
    end

    # TODO create a "draw_line" method with either values or - & custom separator
    # compute output string
    tab = array.inject("") do |agg,hash|
      #agg + "| " + hash.values.map{|v| v.normalize_length( column_size[key])}.join(" | ") + "|\n"
      agg + "| " + keys.inject("") do |aggreg, key|
        prefix = (header == :inline) ? "#{key}: " : ""
        aggreg + "#{prefix}#{hash[key].to_s.normalize_length(column_size[key])} | "
      end + "\n"
    end

    # print
    puts tab
  end

  # Deletes from elements from self and return deleted.
  def extract!
    [].tap{|rejected| reject!{|e| (yield(e)) && (rejected << e)}}
  end
end
