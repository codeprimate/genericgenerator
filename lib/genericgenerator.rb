module Codeprimate
	VERSION = "0.1.0"
	class GenericGenerator
		require 'faker'
			
		@fields = []
		@model_klass = nil
		@generator = lambda{nil}
		@associated = {}
		@validated = false
		@generated = false
		@before_block = Proc.new{}
		@after_block = Proc.new{}
			
		# Set the generator model, accepts a Class
		def self.set_model(model)
			@model_klass = model
		end
			
		# Specify a list of field names used by the generator.  Accepts an arbitrary
		# number of Symbol's as arguments
		def self.has_fields(*field_names)
			@fields = field_names
		end
			
		# Specify a dependent Model, and generate data for it.
		#
		# Possible options:
		#
		# :generator => GenericGenerator (Required. Specify the generator)
		# :count => Integer (Required. Specify the number of records to create)
		# :as => Symbol (Optional. Specify a polymorphic type)
		# :fixture => String (Optional. Override with filename)
		#
		def self.has_many(assoc_model, options={})
			raise "Specify generator for 'has_many'" if options[:generator].to_s.empty?
			raise "Invalid generator" unless options[:generator].is_a?(Class)
			raise "Invalid generator" unless options[:generator].respond_to?("generate!")
			@associated ||= {}
			@associated[assoc_model] = options
		end
		
		# private
		def self.fields
			@fields
		end
			
		# private
		def self.model
			@model_klass
		end
		
		# private
		def self.before_block
			@before_block
		end
		
		# private
		def self.after_block
			@after_block
		end
			
		# Generate Random Data
		#
		# Example:
		# 
		# FoobarGenerator.generate!(100) => Generate 100 Foobars
		# FoobarGenerator.generate!(50, {:user_id => 10}) => 
		#   Generate 50 Foobars, with default data
		def self.generate!(count=1, default_values={})
			validate_generator
			puts " * Generating #{count} #{model.to_s.pluralize}..."
			run_before
			data = self.generate_data(count, default_values)
			model.import(fields, data, {:validate => false})
			@generated = true
			generate_associations!
			run_after
			return true
		end
		 
		# private
		def self.generate_associations!
			raise "Cannot create associations until generate! is called" unless @generated
			puts "  - Generating associations for #{model.to_s}..."
			assoc_data = []
			@associated ||= {}
			@associated.each_pair do |assoc, options|
				opts = {:foreign_key => model.to_s.foreign_key, :count => 1, :as => false}.merge(options)
				default_values = {}
				puts "  - Generating #{assoc.to_s} associations (#{opts[:count]} per #{model.to_s})..."

				# Load fixture if specified
				if opts[:fixture]
					options[:generator].class_eval "fixture '#{opts[:fixture]}'"
				end
				
				options[:generator].run_before
				
				model.find(:all, :select => :id).each do |m|
					id = m.id
					if opts[:as]
						# Add polymorphic association keys
						polymorphic_base = opts[:as].to_s
						polymorphic_id = (polymorphic_base + '_id').to_sym
						polymorphic_type = (polymorphic_base + '_type').to_sym
						default_values[polymorphic_id] = id
						default_values[polymorphic_type] = m.class.to_s
					else
						# Or just set the foreign key 
						default_values[opts[:foreign_key]] = id
					end
					default_values = default_values.symbolize_keys.merge((options[:defaults] || {})) 
					assoc_data += options[:generator].generate_data(opts[:count].to_i, default_values)
				end
				
				options[:generator].model.import(options[:generator].fields, assoc_data, {:validate => false})
				options[:generator].run_after
			end
		end
		 
		# private
		def self.generate_data(count=1, default_values={})
			return Array.new(count){new_record(default_values)}
		end
		
	# private  
		def self.new_record(default_values={})
			validate_generator
			data = run_generator(default_values)
			return fields.inject(out=[]){|out, f| out << data[f]}
		end
			
		# private
		def self.run_generator(default_values={})
			return @generator.call(default_values).merge(default_values)
		end
			
		# private
		def self.validate_generator
			unless @validated
				raise "Model not specified, use 'set_model Modelname' declaration" if model.nil?
				raise "No fields specified, use 'has_fields :field1, :field2' declaration" if fields.empty?
				raise "Is the 'ar-extensions' module loaded?" unless @model_klass.respond_to?("import")
				@validated = true
			end
		end
		
		# Cache data for key using value returned from block
		def self.cache_data(key, &block)
			@cache_block ||= {}
			@cache_block[key] = block || Proc.new{}
		end
		
		# private
		def self.cache_for(key)
			@cache ||= {}
			@cache[key] ||= @cache_block[key].call
		end
		
		# private
		def self.cache_size(key)
			@cache_size ||= {}
			@cache_size[key] ||= cache_for(key).size
		end
		
		# Clear cache for key.  Use ":all" as argument to clear entire cache
		def self.clear_cache(key = :all)
			if key == :all
				@cache = {}
				@cache_size = {}
				@cache_block = {}
			else
				@cache ||= {}
				@cache_size ||= {}
				@cache_block ||= {}
				@cache[key] = nil
				@cache_size[key] = nil
				@cache_block[key] = nil
			end
		end
		
		# Get random data from cache identified by key
		def self.get_random(key)
			cache_for(key)[rand(cache_size(key) - 1)]
		end
		
		# Specify random data generator block
		def self.generator(&block)
			@generator = block
		end
		
		# Load YAML into cache for key ":fixture"
		def self.fixture(filename)
			clear_cache(:fixture)
			cache_data(:fixture) do
				YAML.load(File.read(filename))
			end
		end
		
		# Specify block to be executed before generation
		def self.before(&block)
			@before_block = block
		end
		
		# Specify block to be executed after generation
		def self.after(&block)
			@after_block = block
		end
		
		# private
		def self.run_before
			before_block.call if before_block
		end
		
		# private
		def self.run_after
			after_block.call if after_block
		end
	end
end
