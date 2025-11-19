defmodule Qwynk.Traffic.SlugGenerator do
  @moduledoc """
  Generates "Goblin-Speak" slugs. 
  Format: CVC-CVC (e.g., 'zax-bop', 'miv-kud').
  Purely programmatic. No dictionaries.
  """

  # Crisp starting sounds (No Q, X)
  @onsets ~c"bdfgjklmnprstvwz" 
  # Vowels
  @nuclei ~c"aeiou"
  # Punchy ending sounds (x and z added for 'cool' factor)
  @codas  ~c"bdgkmnpstxz"

  @doc "Generates a bouncy slug (e.g., 'zax-bop')"
  def generate do
    "#{syllable()}-#{syllable()}"
  end

  @doc "Generates a slug with numeric suffix for collisions (e.g., 'zax-bop-9')"
  def generate_with_suffix do
    "#{generate()}-#{Enum.random(1..99)}"
  end

  defp syllable do
    c1 = Enum.random(@onsets)
    v  = Enum.random(@nuclei)
    c2 = Enum.random(@codas)
    List.to_string([c1, v, c2])
  end
end
