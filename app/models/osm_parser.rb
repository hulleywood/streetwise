class OSMParser
  def initialize(file)
    @file = file
    @sf_lat_range = [37.696132, 37.810234]
    @sf_lon_range = [-122.519413, -122.347423]
  end

  def prepare_parser
    xml = File.read(@file)
    @xml_doc  = Nokogiri::XML(xml)
  end

  def parse_nodes
    @nodes = @xml_doc.xpath("//node")
  end

  def parse_highways
    @ways = @xml_doc.xpath("//way")
    @highways = []
    @ways.each do |way|
      if return_all_tags(way).include?("highway")
        @highways << way
      end
    end
  end

  def return_bound_node_hashes
    parse_nodes_in_bounds
    format_node_set
    @sf_nodes
  end

  def return_highways
    @highways.map! do |way|
      { osm_highway_id: way.first.last, nodes: return_all_node_refs(way) }
    end
  end

  def generate_intersections
    # highway_nodes = return_all_highway_nodes
    parse_nodes_in_bounds
    format_node_set
    p @sf_nodes.first
    p @sf_nodes.last
    p @sf_nodes.length
    # return_intersections(highway_nodes)
  end

  private

  def return_all_node_refs(way)
    nodes = return_all_nodes(way)
    nodes.map! { |node| node.first.last }
  end

  def return_all_highway_nodes
    nodes = []
    @ways.each do |way|
      if return_all_tags(way).include?("highway")
        nodes << return_all_nodes(way)
      end
    end
    nodes.flatten
  end

  def return_all_tags(way)
    way_tags = []
    way.children.each do |k|
      way_tags << k.first.last if k.name == "tag"
    end
    way_tags
  end

  def return_all_nodes(way)
    nodes = []
    way.children.each do |child|
      nodes << child if child.name == "nd"
    end
    nodes
  end

  def return_formatted_node(node)
    { osm_node_id: node.attributes["id"].value.to_s,
      lat: node.attributes["lat"].value.to_f, 
      lon: node.attributes["lon"].value.to_f }
  end

  def return_node(node_ref)
    @nodes.select { |node| node.attributes["id"].value.to_s == node_ref }
  end

  def parse_nodes_in_bounds
    @sf_nodes = @nodes.reject { |node| not_in_range(node) }
  end

  def format_node_set
    @sf_nodes.map! { |node| return_formatted_node(node) }
  end

  def not_in_range(node)
    in_lat_range = @sf_lat_range.first < node.attributes["lat"].value.to_f && @sf_lat_range.last > node.attributes["lat"].value.to_f
    in_lon_range = @sf_lon_range.first < node.attributes["lon"].value.to_f && @sf_lon_range.last > node.attributes["lon"].value.to_f
    !(in_lon_range && in_lat_range)
  end

  # def return_node_ref(node)
  #   node.first.last.to_i
  # end

  # def return_intersections(nodes)
  #   node_refs = nodes.map { |node| return_node_ref(node) }
  #   @intersections = parse_nodes_for_inclusion_in_set(@sf_nodes, node_refs)
  # end

  # def parse_nodes_for_inclusion_in_set(nodes, set)
  #   included_nodes = []
  #   nodes.each do |node|
  #     if set.include?(node.attributes["id"].value.to_i)
  #       puts "#{node.attributes["lat"].value.to_f}, #{node.attributes["lon"].value.to_f}"
  #       included_nodes << node
  #     end
  #   end
  #   included_nodes
  # end
end
