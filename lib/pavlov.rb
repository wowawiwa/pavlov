module Pavlov
  extend self

  def import_words( file)
    count_success = count_fail = 0
    ActiveRecord::Base.transaction do
      CSV.foreach file.path, quote_char: "\x00", col_sep: "|"  do |row| # bugs when parsing quotes if quote_char not present
        content, tip = row.map{|field| field.try(:strip)}
        card = yield(content, tip)
        card.save ? count_success += 1 : count_fail += 1
      end
    end
    return count_success, count_fail
  end

  def inversor( input_file_path, overwrite=false, output_file_path=input_file_path+"_reverse")
    lines = CSV.readlines( input_file_path, quote_char: "\x00", col_sep: "|").map{|unstriped_fields| unstriped_fields.map{|field| field.try(:strip)}}
    rev_lines = lines.map{|l| l.reverse}
    if not File.exists? output_file_path or overwrite
      CSV.open output_file_path, "w", col_sep: "|" do |file|
        rev_lines.each do |l|
          file << l
        end
      end 
    else
      raise("Cannot overwrite existing file.")
    end
  end
end
