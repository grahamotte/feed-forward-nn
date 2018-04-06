class Edge
  attr_accessor :parent_node, :child_node, :weight

  def to_s
    [
      "#{parent_node.name}->#{child_node.name}",
      "w(#{weight&.round(4)})",
    ].compact.join(' ')
  end

  def update_gradient(grad)
    @prev_gradient = @gradient || 0.0
    @gradient = grad
  end
end
