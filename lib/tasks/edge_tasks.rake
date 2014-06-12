namespace :edge_tasks do
  desc 'Create edges from node and waypoint tables'
  task create_edges: :environment do
    intersections = Node.intersections
    intersections.each do |int|
      int.waypoints.each do |wpt|
        Edge.create_backwards_edge(wpt) if wpt.prev_node
        Edge.create_forwards_edge(wpt) if wpt.next_node
      end
    end
  end
end