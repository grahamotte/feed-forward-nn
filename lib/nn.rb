class NN
  attr_accessor :graph

  def initialize(shape:)
    @graph = Graph.new(shape)
    graph.assign_edge_weights { 0.5 }
  end

  def run(input_values)
    graph.assign_input_values(input_values)

    nodes = graph.inputs
    while graph.outputs_for(nodes).any?
      nodes = graph.outputs_for(nodes)
      nodes.each do |node|
        node.value = sigmoid(
          node
            .inbound_edges
            .sum { |edge| edge.parent_node.value * edge.weight }
        )
      end
    end
  end

  def train(input_values, output_values)
    graph.clean_nodes
    run(input_values)

    # assign errors
    graph.outputs.zip(output_values).each do |node, value|
      node.error = node.value - value
    end

    nodes = graph.outputs
    while graph.inputs_for(nodes).any?
      nodes = graph.inputs_for(nodes)

      nodes.each do |node|
        node.error = node
          .outbound_edges
          .sum { |edge| edge.weight * edge.child_node.error }

      end
    end

    graph.edges.each do |edge|
      edge.weight -= (
        edge.parent_node.value *
        edge.child_node.error * derivative_sigmoid(edge.child_node.value)
      )
    end
  end

  private

  def sigmoid(v)
    val = 1 / (1 + Math.exp(-v))
  end

  def derivative_sigmoid(v)
    v * (1 - v)
  end
end
