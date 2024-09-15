defmodule WritingAnInterpreterInElixirTest do
  use ExUnit.Case
  doctest WritingAnInterpreterInElixir

  test "greets the world" do
    assert WritingAnInterpreterInElixir.hello() == :world
  end
end
