class Graph
  attr_accessor :nodes, :edges, :inputs, :outputs

  def initialize(shape)
    build_graph_from_shape(shape)
  end

  def assign_input_values(input_values)
    inputs
      .zip(input_values)
      .each { |node, value| node.value = value }
  end

  def assign_edge_weights(weight = 0.5)
    edges.each { |edge| edge.weight = block_given? ? yield : weight }
  end

  def outputs_for(inputs)
    inputs.map(&:outbound_child_nodes).flatten.uniq
  end

  def inputs_for(outputs)
    outputs.map(&:inbound_parent_nodes).flatten.uniq
  end

  def to_s
    @nodes.map do |n|
      [
        "#{n.to_s} #{'(input)' if inputs.include?(n)}#{'(output)' if outputs.include?(n)}",
        "  in : #{n.inbound_edges.map(&:to_s).join(', ')}",
        "  out: #{n.outbound_edges.map(&:to_s).join(', ')}",
      ].join("\n")
    end.join("\n")
  end

  private

  def build_graph_from_shape(shape)
    node_array = shape.map.with_index do |layer, layer_index|
      Array.new(layer).map.with_index { |_, node_index| Node.new(name: "l#{layer_index}p#{node_index}") }
    end
    @inputs = node_array.first
    @outputs = node_array.last
    @nodes = node_array.flatten
    @edges = []
    windows = window(node_array)
    windows.each do |creators, consumers|
      creators.each do |creator|
        consumers.each do |consumer|
          edge = Edge.new
          @edges << edge
          edge.parent_node = creator
          edge.child_node = consumer
          creator.outbound_edges << edge
          consumer.inbound_edges << edge
        end
      end
    end
  end

  def window(data, window: 2, index: 0)
    (index..(data.length - window)).map { |i| data[i..(i + window)] }
  end
end
