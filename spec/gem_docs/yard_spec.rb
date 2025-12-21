# frozen_string_literal: true

module GemDocs
  RSpec.describe Yard do
    let(:fake_gem_lib) do
      <<~RUBY
        class Column
          # The symbol representing this Column.
          attr_reader :header

          # The header as provided by the caller before its conversion to a symbol.
          # You can use this to recover the original string form of the header.
          attr_reader :raw_header

          # A string representing the deduced type of this Column. One of
          # Column::TYPES.
          attr_reader :type

          # An Array of the items of this Column, all of which must be values of the
          # Column's type or a nil.  This Array contains the value of the item after
          # conversion to a native Ruby type, such as TrueClass, Date, DateTime,
          # Integer, String, etc.  Thus, you can perform operations on the items,
          # perhaps after removing nils with +.items.compact+.
          attr_reader :items

          attr_accessor :tolerant

          # Valid Column types as strings.
          TYPES = %w[NilClass Boolean DateTime Numeric String].freeze

          # :category: Constructors

          # Create a new Column with the given +header+ and initialized with the given
          # +items+, as an array of either strings or ruby objects that are one of the
          # permissible types or strings parsable as one of the permissible types. If
          # no +items+ are passed, returns an empty Column to which items may be added
          # with the Column#<< method. The item types must be one of the following
          # types or strings parseable as one of them:
          #
          # Boolean::
          #     an object of type TrueClass or FalseClass or a string that is either
          #     't', 'true', 'y', 'yes', 'f', 'false', 'n', or 'no', in each case,
          #     regardless of case.
          #
          # DateTime::
          #      an object of class Date, DateTime, or a string that matches
          #      +/\d\d\d\d[-\/]\d\d?[-\/]\d\d?/+ and is parseable by DateTime.parse.
          #
          # Numeric:: on object that is of class Numeric, or a string that looks like
          #      a number after removing '+$+', '+,+', and '+_+' as well as Rationals
          #      in the form /<number>:<number>/ or <number>/<number>, where <number>
          #      is an integer.
          #
          # String::
          #      if the object is a non-blank string that does not parse as any
          #      of the foregoing, it its treated as a Sting type, and once a column
          #      is typed as such, blank strings represent blank strings rather than
          #      nil values.
          #
          # NilClass::
          #      until a Column sees an item that qualifies as one of the
          #      foregoing, it is typed as NilClass, meaning that the type is
          #      undetermined. Until a column obtains a type, blank strings are
          #      treated as nils and do not affect the type of the column. After a
          #      column acquires a type, blank strings are treated as nil values
          #      except in the case of String columns, which retain them a blank
          #      strings.
          #
          # @example
          #   require 'fat_table'
          #   col = FatTable::Column.new(header: 'date')
          #   col << Date.today - 30
          #   col << '2017-05-04'
          #   col.type #=> 'DateTime'
          #   col.header #=> :date
          #   nums = [35.25, 18, '35:14', '$18_321']
          #   col = FatTable::Column.new(header: :prices, items: nums)
          #   col.type #=> 'Numeric'
          #   col.header #=> :prices
          #   col.sum #=> 18376.75
          #
          # @param header [String, Symbol] the name of the column header
          # @param items [Array<String>, Array<DateTime>, Array<Numeric>, Array<Boolean>] the initial data items in column
          # @param type [String] the column type: 'String', 'Numeric', 'DateTime', 'Boolean', or 'NilClass'
          # @param tolerant [Boolean] whether the column accepts unconvertable items not of its type as Strings
          # @return [Column] the new Column
          def initialize(header:, items: [], type: 'NilClass', tolerant: false)
            @raw_header = header
            @header =
              if @raw_header.is_a?(Symbol)
                @raw_header
              else
                @raw_header.to_s.as_sym
              end
            @type = type
            @tolerant = tolerant
            msg = "unknown column type '\#{type}"
            raise UserError, msg unless TYPES.include?(@type.to_s)

            @items = []
            items.each { |i| self << i }
          end
        end
      RUBY
    end

    around do |example|
      Dir.mktmpdir do |dir|
        root = dir
        Dir.chdir(root) do
          lib_dir = File.join(root, "lib/")
          FileUtils.mkdir_p(lib_dir)
          File.write(File.join(lib_dir, "fake_gem.rb"), fake_gem_lib)
          File.write("Gemfile", "\#Empty")
          File.write("README.md", "\#Empty")
          example.run
        end
      end
    end

    describe ".generate" do
      it "produces yard docs" do
        doc_dir = "./doc"
        expect(File).not_to exist(".yardopts")
        expect(File).not_to exist(doc_dir)
        Yard.generate(supress_out: true)
        expect(File).to exist(".yardopts")
        expect(File).to exist(File.join(doc_dir, 'index.html'))
      end
    end
  end
end
