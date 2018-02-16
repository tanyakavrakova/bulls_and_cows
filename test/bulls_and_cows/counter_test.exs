defmodule BullsAndCows.CounterTest do
  use ExUnit.Case
  
  alias BullsAndCows.Counter
  doctest Counter

  test "returns 2 bulls and 2 cows" do
    assert Counter.count(2467, 2764) === %{bulls: 2, cows: 2}
  end

  test "returns 4 cows" do
    assert Counter.count(1234, 3421) === %{bulls: 0, cows: 4}
  end

  test "returns 4 bulls" do
    assert Counter.count(3456, 3456) === %{bulls: 4, cows: 0}
  end

  test "returns no match" do
    assert Counter.count(1234, 5678) === %{bulls: 0, cows: 0}
  end

  test "returns error" do
    assert Counter.count(123.4, 2345) === {:error, "Invalid input"}
  end
end
