class Node
  attr_accessor :inbound_edges, :outbound_edges, :value, :true_value, :delta, :error, :name

  def initialize(name: '')
    @name = name
    @inbound_edges = []
    @outbound_edges = []
  end

  def clean
    @value = nil
    @true_value = nil
    @delta = nil
    @error = 0
  end

  def outbound_child_nodes
    outbound_edges.map(&:child_node)
  end

  def inbound_parent_nodes
    inbound_edges.map(&:parent_node)
  end

  def input?
    inbound_edges.none?
  end

  def output?
    outbound_edges.none?
  end

  def to_s
    [
      name,
      "v(#{value&.round(4)})",
      "tv(#{true_value&.round(4)})",
      "e(#{error&.round(4)})",
      "d(#{delta&.round(4)})",
    ].compact.join(' ')
  end
end
