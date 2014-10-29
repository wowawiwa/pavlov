require "#{Rails.root}/lib/core_ext/ruby"
require "#{Rails.root}/lib/core_ext/rails"
require File.join( Rails.root, "lib/pavlov.rb") # Since the constant Pavlov exists and autolaod is triggered by constant not found, lib/pavlov.rb will never be autoloaded
