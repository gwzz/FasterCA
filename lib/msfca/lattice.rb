require 'set'
module Msfca
	class Lattice

		def initialize(filename)
			@concept_count = 0
			@concept_tree = Hash.new
			@node_name = {}
			@attribute_name = {}
			@matrix = {}
			@inverse_matrix = {}
			# @children = []
			att_inverse = {}
			attribute_seen = Set.new()
			node_count = attribute_count = 0
			file = File.open(filename,"r")
			file.each_line {|line|
				row = []
				tokens = line.strip().split(":")
				@node_name[node_count] = tokens[0]
				att_tokens = tokens[1].split(";")
				att_tokens.each do |at|
					at = at.strip()
					if attribute_seen.include?(at)
						row << att_inverse[at]
						@inverse_matrix[att_inverse[at]] << node_count
					else
						attribute_seen << at
						@attribute_name[attribute_count] = at
						att_inverse[at] = attribute_count
						row << attribute_count
						if !@inverse_matrix.include?(attribute_count)
							@inverse_matrix[attribute_count] = []
						end
						@inverse_matrix[attribute_count] << node_count
						attribute_count += 1
					end
				end
				row.sort!
				@matrix[node_count] = row
				node_count += 1
	    }
	    # p @node_name
	    # p @attribute_name
	    # p @matrix
	    # p @inverse_matrix
	    # p @concept_tree
		end

		def startFCA
			concepts = @matrix.values()
			i = 0
			while i < concepts.length
				if concepts[i+1..-1].include?(concepts[i]) 
					concepts.delete_at(i)
				else
					i += 1
				end
			end
			aname_range = Range.new(0,@attribute_name.length - 1).to_a
			if !concepts.include?(aname_range)
				concepts << aname_range
			end
			@concept_count = 0
			concepts.each do |con|
				CheckConcept(@concept_tree, con)
			end
			@concepts = DoFCA(concepts, 0)

			p "test"
			p @concepts
			p "test"
		end

		def CheckConcept(tree, concept)
			if concept.empty? and tree.include?(-1)
				return tree[-1]
			elsif concept.empty? or !tree.include?(concept[0])
				return AddConcept(tree, concept)
			else
				return CheckConcept(tree[concept[0]], concept[1..-1])
			end

		end

		def AddConcept(tree, concept)

			if concept.empty?
				tree[-1] = @concept_count
				@concept_count += 1
				return tree[-1]
			else
				tree[concept[0]] = {}
				return AddConcept(tree[concept[0]],concept[1..-1])
			end
		end

		def DoFCA(concepts, start)
			new_concepts = []
			(start..concepts.length-1).each do |i|
				(i+1..concepts.length-1).each do |j|
					candidate = Intersection(concepts[i], concepts[j])
					if not candidate.empty?
						old = @concept_count
						id = CheckConcept(@concept_tree, candidate)
						if old != @concept_count
							new_concepts << candidate
						end
					end
				end
			end
			if not new_concepts.empty?
				old_length = concepts.length
				concepts += new_concepts
				return DoFCA(concepts, old_length)
			else
				return concepts
			end
		end

		def Intersection(a,b)
			ai = bi = 0
			result = []
			while (ai < a.length and bi < b.length)
				if a[ai] < b[bi]
					ai+=1
				elsif a[ai] > b[bi]
					bi+=1
				else
					result << a[ai]
					ai+=1
					bi+=1
				end
			end
			return result
		end

		def IsSubset(a,b)
			if a.length > b.length
				return false
			end
			ai = bi = 0
			while (ai < a.length and bi < b.length)
				if a[ai] < b[bi]
					return false
				elsif a[ai] == b[bi]
					ai+=1	
				end
				bi+=1
			end
			if ai<a.length
				return false
			else
				return true
			end
		end

		def PrintConcepts
			# PrintConcepts2(@concept_tree,[])
		end

		def PrintConcepts2(tree, concept)

		end

		def PrintConcept(concept, file)
			file.write( '"')
			if !concept.empty?
				concept.collect{|c| @inverse_matrix[c]}.inject{|x,y| Intersection(x,y)}.each do |elem|
					file.write(@node_name[elem])
				end
			else
				@node_name.values.each do |name|
					file.write(name)
				end
			end
			file.write(':')
			concept.each do |c|
				file.write(@attribute_name[c])
			end
			file.write('"')
		end
		
		def PrintLattice(filename='')
			p @concepts
			file = File.open(filename,"w+")
			@children = Array.new(@concepts.length) { |i| i=Set.new() }
			(0..@concepts.length-1).each do |i|
				(0..@concepts.length-1).each do |j|
					if i != j and IsSubset(@concepts[i],@concepts[j])
						@children[j].add(i)
					end
				end
			end
			p @children
			file.puts("""graph lattice\n{\nranksep=2\n""")
			(0..@concepts.length-1).each do |i|
				if !@children[i].empty?
					@children[i].each do |c|
						skip = false
						@children[i].each do |check|
							if @children[check].include?(c)
								skip = true
							end
						end
						unless skip
							PrintConcept(@concepts[i],file)
							file.write( ' -- ')
							PrintConcept(@concepts[c],file)
							file.write( "\n")
						end
					end
				else
					PrintConcept(@concepts[i],file)
					file.write( ' -- ')
					PrintConcept([],file)
					file.write( "\n")
				end
			end
			file.write( "}\n")
		end

	end
end
