@limit_words 700

def function(ingame_text_queue, transcription) do
  transcription_line = ~r/^\W+(GAMEMECH|NARRATIVE|DIALOGUE|BACKGROUND)/i

  scrubbed_transcription =
    transcription
    # Split by newlines
    |> String.split("\n")
    # remove all lines that match the transcription line regex
    |> Enum.filter(fn line -> Regex.match?(transcription_line, line) end)
    # Trim all nonword characters from the beginning of each line
    |> Enum.map(fn line -> Regex.replace(~r/^\W+/, line, "")<>"\n" end)

  queue =
    case ingame_text_queue do
      %{"queue" => queue} -> queue
      _ -> []
    end

  cond do
    num_words(queue ++ scrubbed_transcription) > @limit_words ->
      text_body =
        [queue ++ scrubbed_transcription]
        |> IO.inspect(label: "text_body PREJOIN")
        |> Enum.join("\n")
        |> IO.inspect(label: "text_body")

      %{
        "queue" => [],
        "text" => text_body,
        "ready" => true
      }
    true ->
      %{"queue" => queue ++ scrubbed_transcription, "text" => nil, "ready" => false}
  end
end

defp num_words([_|_] = list), do:
  list |> List.flatten() |> Enum.join("\n") |> num_words()
defp num_words(text), do:
  text |> String.split(~r/[^\w\']+/) |> Enum.count
