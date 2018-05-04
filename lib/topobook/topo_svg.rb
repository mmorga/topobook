require "nokogiri"

module Topobook
  class TopoSvg
    attr_reader :content_markers
    attr_reader :svg

    def initialize
      @svg = Nokogiri::XML.parse(<<~BLANK_SVG
        <?xml version="1.0" standalone="no"?>
        <!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
        <svg version="1.1" xmlns="http://www.w3.org/2000/svg">
          <rect x="0" y="0" width="1638" height="2088" stroke-width="4" stroke="red" fill="none"/>
        </svg>
        BLANK_SVG
      )
      @content_markers = [svg.root]
    end

    # TODO: Add desc element to document
    def desc
    end

    def viewbox=(str)
      svg.root["viewBox"] = str
    end

    def width=(w)
      svg.root["width"] = w
    end

    def height=(h)
      svg.root["height"] = h
    end

    def content_marker_push(name)
      node_set = content_markers.last.add_child(<<~CONTENT_MARKER
          <g class=#{id_for(name, 'content-marker')}>
            <desc>#{name}</desc>
          </g>
          CONTENT_MARKER
        )
      content_markers.push(node_set.first)
    end

    def content_marker_pop
      content_markers.pop
    end

    def path(path)
      return if content_markers.empty?
      path ||= []
      content_markers.last.add_child(<<~PATH
        <path d="#{path.flatten.join(' ')}" stroke-width="1" fill="none" stroke="#000"/>
        PATH
      )
    end

    def transform(trans)
      # return if content_markers.empty?
      # content_markers.last['transform'] = [trans, content_markers.last['transform']].compact.join(' ').strip
    end

    # TODO: Happy case here is a set of single characters in texts and
    #       an array of positions
    #       However if any texts value is longer than 1 character, then the
    #       algorithm to display needs to change
    # TODO: Handle text orientation
    def text_with_position(font, font_size, text_leading, text_matrix, texts, positions)
      @just_once ||= 0
      @just_once += 1
      return unless @just_once < 2
      content_markers.last.add_child(<<~TEXT
        <text transform="#{text_matrix}" font-family="#{font}" font-size="#{font_size * 4}">
          <tspan dx="#{positions.map{|p| -p}.join(' ')}">#{texts.join('')}</tspan>
        </text>
        TEXT
      )
    end

    def text(font, font_size, text_leading, text_matrix, text_lines)
      x = 0
      y = 0
      text_lines.each do |line|
        content_markers.last.add_child(<<~TEXT
          <text dy="#{y}" transform="#{text_matrix}" font-family="#{font}" font-size="#{font_size * 4}">#{line}</text>
          TEXT
        )
        y += (text_leading || 0) * 4
      end
    end

    def id_for(str, suffix = '')
      str
        .split(' ')
        .concat(suffix.split(' '))
        .map(&:downcase)
        .join('-')
    end

    def write(filename)
      File.open(filename, "wb") do |f|
        f.write(@svg.to_xml)
      end
    end
  end
end

