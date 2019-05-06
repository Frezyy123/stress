defmodule StressFoundationdbTest do
  use ExUnit.Case
  doctest StressFoundationdb

  test "greets the world" do
    assert StressFoundationdb.hello() == :world
  end
end
