def function (full_story) do
  manual_wrap = ~r/([\w,]) *\n([a-z])/

  # first in the whole text, unwrap lines
  Regex.replace(manual_wrap, full_story, "\\1 \\2")
  # Then split into lines by newline
  |> String.split("\n")
  # Now, reduce into an array of chunks:
  # 1. Add line by line to the current chunk
  # 2. If the current chunk is too long (> 400 words), start a new chunk
  |> Enum.reduce([], fn line, acc ->
    {current_chunk,acc} =
      case acc do
        [] -> {"",acc}
        [current_chunk|tail] -> {current_chunk,tail}
      end

    # If the line plus the current chunk is still less than 400 words, add the line to the current chunk
    case num_words(current_chunk <> "\n" <> line) < 400 do
      true -> [current_chunk <> "\n" <> line] ++ acc
      false -> [line, current_chunk] ++ acc
    end
  end)
  |> Enum.reverse()
end

defp num_words(text), do:
  text |> String.split(~r/[^\w\']+/) |> Enum.count
