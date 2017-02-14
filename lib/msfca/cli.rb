require 'thor'
require 'msfca'

module Msfca
  class CLI < Thor
    
  desc "version", "Show current version"
	def version
		puts Msfca::VERSION
	end

  desc "multistage", "Read in file, and do Faster Concept Analysis"
  option :p, :required => true
  def multistage
    Msfca.MultiStage(options[:p])
  end

  end
end