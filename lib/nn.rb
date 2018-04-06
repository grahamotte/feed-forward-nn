class NN
  attr_accessor :graph

  def initialize(shape:)
    @graph = Graph.new(shape)
    graph.assign_edge_weights { 0.5; rand(0.2..0.8) }
  end

  def run(input_values)
    # seed the input layer with the values we wish to run
    graph.assign_input_values(input_values)

    # get the first layer of nodes
    nodes = graph.inputs

    # going left to right take each layer of nodes
    while graph.outputs_for(nodes).any?
      # get all the output nodes
      nodes = graph.outputs_for(nodes)

      # for every output node
      nodes.each do |node|

        # sum the product of its edges and their respective parent nodes
        node.value = sigmoid(
          node
            .inbound_edges
            .sum { |edge| edge.parent_node.value * edge.weight }
        )
      end
    end
  end

  def train(input_values, output_values)
    # clear all previous values
    graph.nodes.each(&:clean)

    # seed all edges and nodes
    run(input_values)

    # gather the outputs
    nodes = graph.outputs

    # set true values for outputs
    nodes.zip(output_values).each { |node, value| node.true_value = value }

    # going right to left, take each layer of nodes
    while graph.inputs_for(nodes).any?

      nodes.each do |node|
        if node.output?
          node.error = node.true_value - node.value
          node.delta = node.error * derivative_sigmoid(node.value)
        end

        node
          .inbound_edges
          .each { |edge| edge.parent_node.error += edge.weight * node.delta }
      end

      graph
        .inputs_for(nodes)
        .each { |n| n.delta = n.error * derivative_sigmoid(n.value) }

      nodes
        .map(&:inbound_edges)
        .flatten
        .each { |e| e.weight += e.parent_node.value * e.child_node.delta }

      nodes = graph.inputs_for(nodes)
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
