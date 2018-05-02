require "pdf/reader"

module Topobook
  # This class reads an SVG file and writes out each base64 encoded
  # image in the file to the given export directory
  class Pdf2Svg
    def initialize
    end

    def respond_to?(meth)
      true
    end

    def method_missing(methodname, *args)
      STDERR.puts {:name => methodname.to_sym, :args => args}.inspect
    end
  end
end
