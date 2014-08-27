class RelationalGraph

  def initialize
    @edges = Relationship.all
  end

  def get_paths(origin_node, destination_node, weight = 'gradient')
    path = traverse_graph(origin_node, destination_node, weight)
  end

  private
  def traverse_graph(origin_node, destination_node, weight)
    visited = []

  end
end