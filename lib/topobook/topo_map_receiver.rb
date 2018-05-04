require "pdf/reader"
require "awesome_print"

module Topobook
  Color = Struct.new(:red, :green, :blue)
  GraphicsState = Struct.new(:non_stroke_color, :stroke_color) do
    def non_stroke_color=(color)
      @non_stroke_color = color
    end

    def stroke_color=(color)
      @stroke_color = color
    end
  end

  Point = Struct.new(:x, :y) do
    def +(pt)
      Point.new(x + pt.x, y + pt.y)
    end
  end

  class TopoMapReceiver
    attr_reader :page
    attr_reader :subpath # Collector for subpath construction
    attr_reader :svg
    attr_reader :oc_names # Debug, OC Marked Content names
    attr_reader :missing_stats # For Debug, looking for unhandled methods

    def initialize(page, context = nil, svg = nil)
      @context_stack = [context || page]
      @page = page # context.is_a?(PDF::Reader::Page) ? context :
      @svg = svg || TopoSvg.new
      @oc_names = Hash.new { |h, k| h[k] = 0 }
      @missing_stats = Hash.new {|h, k| h[k] = 0}
      @graphics_state_stack = [] # TODO: Do this as a class
      @current_graphics_state = {}
      @stroke_color = Color.new(0, 0, 0)
      @non_stroke_color = Color.new(1, 1, 1)
      @xobj_count = 0 # debug
      @text_leading = 0
      @line_width = 1
      @miter_limit = 10 # TODO: what is the default
      @line_join_style = 0 # TODO: what is the default
      @line_cap_style = 2 # TODO: what is the default
    end

    def context
      @context_stack.last
    end

    def page=(page)
      @page = page
      # STDERR.puts "Page attributes: #{page.attributes.keys}"
      # STDERR.puts "Page Resources: #{page.attributes[:Resources].keys}"
      # STDERR.puts "Media Box: #{page.attributes[:MediaBox]}"
      media_box = page.attributes[:MediaBox]
      svg.viewbox = media_box.map(&:to_s).join(" ")
      svg.width = media_box[2]
      svg.height = media_box[3]
    end

    # TODO: investigate making the tree of marked content consolidated
    # TODO: set a flag for the current stack indicating if things should
    #       be rendered inside this kind of marked content
    def begin_marked_content_with_pl(arg1, arg2)
      if arg2.is_a?(Symbol)
        obj = context.properties[arg2]
        name = obj.fetch(:Name, "")
        oc_names[name] += 1 # Debug
        svg.content_marker_push(name) if arg1 == :OC
      else
        # STDERR.puts "begin_marked_content_with_pl: #{arg2.inspect}"
      end
    end

    def end_marked_content
      svg.content_marker_pop
    end

    def save_graphics_state
      @graphics_state_stack.push(@current_graphics_state)
    end

    def restore_graphics_state
      @current_graphics_state = @graphics_state_stack.pop
    end

    def set_rgb_color_for_nonstroking(r, g, b)
      @non_stroke_color = Color.new(r, g, b)
    end

    def set_rgb_color_for_stroking(r, g, b)
      @stroke_color = Color.new(r, g, b)
    end

    def set_graphics_state_parameters(gs)
      @current_graphics_state = gs
    end

    def concatenate_matrix(a, b, c, d, e, f)
      svg.transform(svg_matrix(a, b, c, d, e, f))
    end

    def invoke_xobject(name)
      # @xobj_count += 1
      # return if @xobj_count > 10
      stream = context.xobjects[name] || page.xobjects[name]
      # STDERR.puts "invoke_xobject #{stream.class}"
      if stream.nil? # TODO: handle this failure
        # STDERR.puts "stream not found for name #{name}"
        return
      end
      # STDERR.puts "invoke_xobject #{name} #{stream.hash[:Type].inspect} #{stream.hash[:SubType].inspect} #{stream.hash[:Resources]&.keys&.join(',')}"
      if !name.to_s.start_with?("Im")
        @context_stack.push(PDF::Reader::FormXObject.new(page, stream))
        context.walk(self)
        @context_stack.pop
      else
        # STDERR.puts "Skipping"
      end
      # STDERR.puts "end invoke_xobject #{name}"
    end

    def begin_new_subpath(x, y)
      # STDERR.puts "begin_new_subpath(#{x}, #{y})"
      @subpath = [['M', x, y]]
    end

    def append_line(x, y)
      # STDERR.puts "append_line(#{x}, #{y})"
      @subpath ||= []
      subpath << ['L', x, y]
    end

    def close_subpath
      # STDERR.puts "close_subpath" # " #{subpath.flatten.join(' ')}"
      svg.path(subpath)
      @subpath = []
    end

    # TODO: Investigate using PDF::Reader::PageState for these things
    def begin_text_object
      STDERR.puts "begin_text_object"
      @text_line_position = Point.new(0, 0)
      @text_lines = []
    end

    # TODO: Investigate using PDF::Reader::PageState for these things
    def end_text_object
      STDERR.puts "end_text_object"
      # svg.text(@font, @font_size, @text_leading, @text_matrix, @text_lines)
    end

    # TODO: Investigate using PDF::Reader::PageState for these things
    def set_text_leading(leading)
      # STDERR.puts "set_text_leading #{leading}"
      @text_leading = leading
    end

    # TODO: Investigate using PDF::Reader::PageState for these things
    def set_text_font_and_size(name, size) # {[:TT0, 1]}
      font_obj = context.fonts[name]
      @font_size = size
      if font_obj
        @font = font_obj[:BaseFont].to_s.split('+').last
      else
        @font = "Arial" # TODO: make this a configurable font
      end
      STDERR.puts "set_text_font_and_size #{name}, #{size}: #{@font}"
    end

    # TODO: Investigate using PDF::Reader::PageState for these things
    def set_line_width(width)
      # STDERR.puts "set_line_width #{width}"
      @line_width = width
    end

    # TODO: Investigate using PDF::Reader::PageState for these things
    def set_miter_limit(limit)
      # STDERR.puts "set_miter_limit #{limit}"
      @miter_limit = limit
    end

    def set_line_join_style(style)
      # STDERR.puts "set_line_join_style #{style}"
      @line_join_style = style
    end

    def set_line_cap_style(style)
      # STDERR.puts "set_line_cap_style #{style}"
      @line_cap_style = style
    end

    def set_text_matrix_and_text_line_matrix(a, b, c, d, e, f)
      STDERR.puts "set_text_matrix_and_text_line_matrix(#{a}, #{b}, #{c}, #{d}, #{e}, #{f})"
      @text_line_matrix = @text_matrix = svg_matrix(a, b, c, d, e, f)
    end

    def show_text_with_positioning(ary)
      STDERR.puts "show_text_with_positioning(ary)"
      text_pos = ary.group_by { |i| i.is_a?(String) ? :text : :position }
      svg.text_with_position(@font, @font_size, @text_leading, @text_matrix, text_pos[:text], text_pos[:position])

      # @text_lines << text_with_position.select{ |i| i.is_a?(String) }.join("")
      # ["I", 25, "m", -36.6, "a", -35.6, "g", -2, "e", -6.9, "r", -6.3, "y", -17,
      # ".", 12.3, ".", -40.4, ".", 12.2, ".", -40.4, ".", 12.2, ".", 12.2, ".", -40.4,
      # ".", 12.2, ".", -40.4, ".", 12.2, ".", 12.2, ".", -40.4, ".", 12.3, ".", 12.2,
      # ".", -40.4, ".", 12.2, ".", -40.4, ".", 12.2, ".", 12.2, ".", -40.4, ".", 12.2,
      # ".", -40.4, ".", 12.2, ".", 12.3, ".", -40.4, ".", 12.2, ".", -40.4, ".", 12.2,
      # ".", 12.2, ".", -40.4, ".", 12.2, ".", -40.4, ".", 12.2, ".", 12.2, ".", -40.4,
      # ".", 12.2, ".", 12.3, ".", -40.4, ".", 12.2, ".", -40.4, ".", 12.2, ".", 12.2, ".", -40.4, ".", 12.2, ".", -40.4, ".", 12.2, ".", 12.2, ".", -40.4, "N", -3.1, "A", -31.4, "I", -27.7, "P", 16.8, ",", -40.4, " ", -482.8, "J", 16, "a", -35.5, "n", 5.8, "u", -59.9, "a", 17.1, "r", -6.3, "y", -17, " ", -482.8, "2", -58.2, "0", 16.8, "1", -36.3, "0"]
    end

    # −ty TL
    # tx ty Td
    def move_text_position_and_set_leading(tx, ty) # , :args=>[0, -1.158]}
      STDERR.puts "move_text_position_and_set_leading(#{tx}, #{ty})"
      @text_leading = -ty
      @text_line_position = @text_line_position + Point.new(tx, ty)
    end

    def respond_to?(meth)
      true
    end

    def method_missing(methodname, *args)
      # STDERR.puts("MISSING: #{{name: methodname.to_sym, args: args}.inspect}")
      missing_stats[methodname] += 1
    end

    private

    def svg_matrix(a, b, c, d, e, f)
      "matrix(#{[a,b,c,d,e,f].join(' ')})"
    end
  end
end
