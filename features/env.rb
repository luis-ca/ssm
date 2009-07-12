# Comment out the next line if you don't want Cucumber Unicode support
require 'cucumber/formatter/unicode'
require 'rubygems'
require File.join(File.dirname(__FILE__), '..', 'lib', 'ssm')

File.delete('tmp_sqlite_file')