require "nokogiri"
require "base64"

module Topobook
  # This class reads an SVG file and writes out each base64 encoded
  # image in the file to the given export directory
  class ExtractSvgImages
    attr_reader :svg_file_in
    attr_reader :svg_file_out
    attr_reader :export_dir

    def initialize(svg_file_in, svg_file_out, export_dir = nil)
      @svg_file_in = svg_file_in
      @svg_file_out = svg_file_out
      @export_dir = export_dir || File.join(File.dirname(svg_file_in), "images")
    end

    def extract
      Dir.mkdir(export_dir) unless Dir.exist?(export_dir)

      doc = Nokogiri::XML.parse(File.read(svg_file_in))

      images = doc.css("image")

      images.each do |image|
        type, data = image.attributes["href"].value.split(",")
        /data:image\/(\w+);base64/.match(type) do |m|
          filename = File.join(export_dir, "#{image["id"]}.#{m[1]}")
          File.open(filename, "wb") do |f|
            f.write(Base64.decode64(data))
          end
          image.unlink
        end
      end

      File.open(svg_file_out, "wb") do |f|
        f.write(doc.to_xml)
      end
    end
  end
end
