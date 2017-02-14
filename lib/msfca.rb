require "msfca/version"
require "msfca/lattice"
module Msfca

	def self.MultiStage(filename)
		# file = File.open(filename)
		filename = "/Users/zhuwei/Desktop/FCA/code/example.oal"
		lattice = Lattice.new(filename)
		lattice.startFCA
		lattice.PrintLattice("/Users/zhuwei/Desktop/FCA/code/example.dot")
	end

end
