require_relative 'lib/all'

def analyse(nn, input, output)
  nn.run(input)
  actual = nn.graph.outputs.map(&:value)

  {
    input: input,
    expected: output,
    actual: actual,
    diffs: output.zip(actual).map { |e, a| "%.2f" % (e - a) },
    predictions: actual.map { |v| v >= 0.5 ? 1 : 0 }
  }
end

def analyse_set(nn, training_set)
  results = training_set
    .map { |input, output| analyse(nn, input, output) }

  passes_or_failures = results
    .map { |r| r[:predictions] }
    .transpose
    .zip(results.map { |r| r[:expected] }.transpose)
    .flatten(1)
    .transpose
    .map { |p, a| p == a }

  {
    results: results,
    accuracy: passes_or_failures.count { |x| x }.to_f / passes_or_failures.length
  }
end

def puts_analyse_set(analysis)
  return if analysis[:accuracy] == 1.0

  rows = analysis[:results].map do |r|
    [
      r[:input],
      r[:expected],
      r[:predictions],
      r[:diffs],
      r[:actual],
    ]
  end

  puts TTY::Table.new(%w(input expected predicted diff actual), rows).render(:unicode)
  puts "accuracy = #{analysis[:accuracy]}"
end

poss_outputs = [0, 1].repeated_combination(4).to_a.map { |c| c.permutation.to_a }.flatten(1).uniq

sets = poss_outputs.map do |output|
  {
    [0, 0, 1] => [output[0]],
    [0, 1, 1] => [output[1]],
    [1, 0, 1] => [output[2]],
    [1, 1, 1] => [output[3]],
  }
end

sets.each do |training_set|
  nn = NN.new(shape: [3, 1])

  2_000.times do |i|
    break if i % 50 == 0 && i != 0 && analyse_set(nn, training_set)[:accuracy] == 1.0
    training_set.to_a.shuffle.to_h.each { |input, output| nn.train(input, output) }
  end

  puts_analyse_set(analyse_set(nn, training_set))
end
