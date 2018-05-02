require "pdf/reader"

module Topobook
  # This class reads an SVG file and writes out each base64 encoded
  # image in the file to the given export directory
  class Pdf2Svg
    def initialize(pdf_file)
      @pdf_file = pdf_file
      @reader = PDF::Reader.new(@pdf_file)
    end

    def to_svg(dir)
      @receiver = TopoMapReceiver.new
      @reader.walk(@receiver)
    end
  end
end
