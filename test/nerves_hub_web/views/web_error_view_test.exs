defmodule NervesHubWeb.WebErrorViewTest do
  use NervesHubWeb.ConnCase, async: true

  # Bring render_to_string/4 for testing custom views
  import Phoenix.Template, only: [render_to_string: 4]

  test "render 500.html" do
    assert render_to_string(NervesHubWeb.ErrorHTML, "500", "html", []) =~
             "Sorry, we tried to process your request but something went wrong."
  end

  test "render 400.html" do
    assert render_to_string(NervesHubWeb.ErrorHTML, "400", "html", []) =~
             "Sorry, your request was invalid or corrupted."
  end

  # Refs lawik/nerves_hub_web#8: error templates referenced /images/product.svg
  # after that asset was deleted, producing a broken image on every error page.
  for template <- ["400", "404", "500"] do
    test "#{template}.html only references static images that exist on disk" do
      html = render_to_string(NervesHubWeb.ErrorHTML, unquote(template), "html", [])

      static_dir = Path.join(Application.app_dir(:nerves_hub, "priv"), "static")

      referenced_images =
        Regex.scan(~r{(?:src|href)="(/images/[^"]+)"}, html)
        |> Enum.map(fn [_, path] -> path end)
        |> Enum.uniq()

      missing =
        Enum.reject(referenced_images, fn path ->
          File.exists?(Path.join(static_dir, String.trim_leading(path, "/")))
        end)

      assert missing == [],
             "Error page #{unquote(template)}.html references static images that do not exist " <>
               "under priv/static: #{inspect(missing)}"
    end
  end
end
