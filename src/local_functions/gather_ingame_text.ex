def function(ingame_text_queue, transcription) do
  transcription_line = ~r/^\W+(GAMEMECH|NARRATIVE|DIALOGUE|BACKGROUND)/i

  scrubbed_transcription =
    transcription
    # Split by newlines
    |> String.split("\n")
    # remove all lines that match the transcription line regex
    |> Enum.filter(fn line -> Regex.match?(transcription_line, line) end)
    # Trim all nonword characters from the beginning of each line
    |> Enum.map(fn line -> Regex.replace(~r/^\W+/, line, "") end)

  queue =
    case ingame_text_queue do
      %{"queue" => queue} -> queue
      _ -> []
    end

  cond do
    Enum.count(queue ++ scrubbed_transcription) > 60 ->
      %{"queue" => [], "text" => [queue ++ scrubbed_transcription] |> Enum.join("\n"), "ready" => true}
    true ->
      %{"queue" => queue ++ scrubbed_transcription, "text" => nil, "ready" => false}
  end
end
