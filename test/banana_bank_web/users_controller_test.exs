defmodule BananaBankWeb.UsersControllerTest do
  use BananaBankWeb.ConnCase

  import Mox

  alias BananaBank.Users
  alias Users.User

  setup do
    params = %{
      "name" => "Joao",
      "cep" => "29650000",
      "password" => "123456",
      "email" => "joao@frutas.com"
    }

    body =
      %{
        "bairro" => "",
        "cep" => "29650-000",
        "complemento" => "",
        "ddd" => "27",
        "estado" => "Espírito Santo",
        "gia" => "",
        "ibge" => "3204609",
        "localidade" => "Santa Teresa",
        "logradouro" => "",
        "regiao" => "Sudeste",
        "siafi" => "5691",
        "uf" => "ES",
        "unidade" => ""
      }

    {:ok, %{user_params: params, body: body}}
  end

  describe "create/2" do
    test "successfully creates an user", %{conn: conn, body: body, user_params: params} do
      expect(BananaBank.ViaCep.ClientMock, :call, fn "29650000" -> {:ok, body} end)

      response =
        conn
        |> post(~p"/api/users", params)
        |> json_response(:created)

      assert %{
               "data" => %{"cep" => "29650000", "email" => "joao@frutas.com", "id" => _id, "name" => "Joao"},
               "message" => "User criado com sucesso!"
             } = response
    end

    test "when there are invalid params, returns an error", %{conn: conn} do
      params = %{
        name: nil,
        cep: "12",
        password: nil,
        email: "joao@frutas.com"
      }

      expect(BananaBank.ViaCep.ClientMock, :call, fn "12" -> {:ok, ""} end)

      response =
        conn
        |> post(~p"/api/users", params)
        |> json_response(:bad_request)

      expected_response = %{
        "errors" => %{
          "cep" => ["should be 8 character(s)"],
          "name" => ["can't be blank"],
          "password" => ["can't be blank"]
        }
      }

      assert response == expected_response
    end
  end

  describe "delete/2" do
    test "successfully deletes an user", %{conn: conn, body: body, user_params: params} do
      expect(BananaBank.ViaCep.ClientMock, :call, fn "29650000" -> {:ok, body} end)

      {:ok, %User{id: id}} = Users.create(params)

      response =
        conn
        |> delete(~p"/api/users/#{id}")
        |> json_response(:ok)

      expected_response = %{
        "data" => %{"cep" => "29650000", "email" => "joao@frutas.com", "id" => id, "name" => "Joao"}
      }

      assert response == expected_response
    end
  end
end
