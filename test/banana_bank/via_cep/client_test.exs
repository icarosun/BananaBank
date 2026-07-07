defmodule BananaBank.ViaCep.ClientTest do
  use ExUnit.Case, async: true

  alias BananaBank.ViaCep.Client

  setup do
    bypass = Bypass.open()
    {:ok, bypass: bypass}
  end

  describe "call/1" do
    test "successfully returns cep info", %{bypass: bypass} do
      cep = "69023097"

      body = ~s({
        "bairro": "Taruma-Acu",
        "cep" : "69023-097",
        "complemento" : "",
        "ddd" : "92",
        "estado" : "Amazonas",
        "gia" : "",
        "ibge" : "1302603",
        "localidade" : "Manaus",
        "logradouro" : "Rua Mutum do Norte",
        "regiao" : "Norte",
        "siafi" : "0255",
        "uf" : "AM",
        "unidade" : ""
      })

      expected_response =
        {:ok,
         %{
           "bairro" => "Taruma-Acu",
           "cep" => "69023-097",
           "complemento" => "",
           "ddd" => "92",
           "estado" => "Amazonas",
           "gia" => "",
           "ibge" => "1302603",
           "localidade" => "Manaus",
           "logradouro" => "Rua Mutum do Norte",
           "regiao" => "Norte",
           "siafi" => "0255",
           "uf" => "AM",
           "unidade" => ""
         }}

      Bypass.expect(bypass, "GET", "/69023097/json", fn conn ->
        conn
        |> Plug.Conn.put_resp_content_type("application/json")
        |> Plug.Conn.resp(200, body)
      end)

      response =
        bypass.port
        |> endpoint_url()
        |> Client.call(cep)

      assert response == expected_response
    end
  end

  defp endpoint_url(port), do: "http://localhost:#{port}"
end
