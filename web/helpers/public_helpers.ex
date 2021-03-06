defmodule Changelog.Helpers.PublicHelpers do
  use Phoenix.HTML

  alias Changelog.Regexp

  def error_class(form, field) do
    if form.errors[field], do: "error", else: ""
  end

  def error_message(form, field) do
    case form.errors[field] do
      {message, _} ->
        content_tag :p, class: "form_element_note" do
          message
        end
      nil -> ""
    end
  end

  def md_to_safe_html(md) when is_binary(md), do: Cmark.to_html(md, [:safe])
  def md_to_safe_html(md) when is_nil(md), do: ""

  def md_to_html(md) when is_binary(md), do: Cmark.to_html(md)
  def md_to_html(md) when is_nil(md), do: ""

  def md_to_text(md) when is_binary(md) do
    HtmlSanitizeEx.strip_tags(md_to_html(md))
  end
  def md_to_text(md) when is_nil(md), do: ""

  def no_widowed_words(string) when is_nil(string), do: no_widowed_words("")
  def no_widowed_words(string) do
    words = String.split(string, " ")

    case length(words) do
      0   -> ""
      1   -> string
      len ->
        first = Enum.take(words, len - 1) |> Enum.join(" ")
        last = List.last(words)
        [first, last] |> Enum.join("&nbsp;")
    end
  end

  def plural_form(list, singular, plural) when is_list(list), do: plural_form(length(list), singular, plural)
  def plural_form(1, singular, _plural), do: singular
  def plural_form(_count, _singular, plural), do: plural

  def sans_p_tags(html), do: String.replace(html, Regexp.p_tag, "")

  def tweet_url(text, url, via \\ "changelog")
  def tweet_url(text, url, nil), do: tweet_url(text, url)
  def tweet_url(text, url, via) do
    text = URI.encode(text)
    related = ["changelog", via] |> List.flatten |> Enum.uniq |> Enum.join(",")
    "https://twitter.com/intent/tweet?text=#{text}&url=#{url}&via=#{via}&related=#{related}"
  end

  def reddit_url(title, url) do
    title = URI.encode(title)
    "http://www.reddit.com/submit?url=#{url}&title=#{title}"
  end

  def hackernews_url(title, url) do
    title = URI.encode(title)
    "http://news.ycombinator.com/submitlink?u=#{url}&t=#{title}"
  end

  def facebook_url(url) do
    "https://www.facebook.com/sharer/sharer.php?u=#{url}"
  end

  def with_smart_quotes(string) do
    string
    |> String.replace_leading("\"", "“")
    |> String.replace_trailing("\"", "”")
  end

  def with_timestamp_links(string) do
    String.replace(string, Regexp.timestamp, ~S{<a class="timestamp" href="#t=\0">\0</a>})
  end
end
