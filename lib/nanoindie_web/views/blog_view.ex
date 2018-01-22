defmodule NanoindieWeb.BlogView do
  use NanoindieWeb, :view

  # TODO: dont like this, but this is the only way to translate the
  # country code, the idea of the codes was to translate them to english
  # if necessary, but since we use only spanish maybe we should just use
  # the country name directly
  defimpl Phoenix.HTML.Safe, for: Countriex.Country do
    def to_iodata(country_data) do
      case country_data.name do
        "Spain" -> "España"
        "Venezuela, Bolivarian Republic of" -> "Venezuela"
        country_name -> country_name
      end
    end
  end

  def full_country_name(country_code) do
    Countriex.get_by(:alpha2, country_code)
  end
end
