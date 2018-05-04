require "pdf/reader"

module Topobook
  # This class reads an SVG file and writes out each base64 encoded
  # image in the file to the given export directory
  class Pdf2Svg
    def initialize(pdf_file)
      @pdf_file = pdf_file
      export_dir = File.basename(@pdf_file, ".pdf")
      @svg_file = File.join(export_dir, "#{File.basename(pdf_file, ".pdf")}.svg")
      @reader = PDF::Reader.new(@pdf_file)
    end

    def to_svg(dir)
      page = @reader.page(1)
      @receiver = TopoMapReceiver.new(page)
      page.walk(@receiver)
      oc_names = @receiver.oc_names.map {|name, count| "  * #{name}: #{count}" }.join("\n")
      # puts "OC Marker names:\n#{oc_names}"
      @receiver.svg.write(@svg_file)
      missing_methods = @receiver.missing_stats.map {|name, count| "  * #{name}: #{count}" }.join("\n")
      puts "Receiver Missing Stats:\n#{missing_methods}"
    end
  end
end
