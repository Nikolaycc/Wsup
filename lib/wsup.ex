defmodule Wsup.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user" do
    field :name, :string
    field :email, :string
    field :password, :string
    field :age, :integer

    timestamps()
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :age, :password, :email])
    |> validate_required([:name, :age, :password, :email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end
end

defmodule Wsup do
  use Plug.Router
  import Plug.Conn
  require Logger
  alias Wsup.{User, Repo}
  import Plug.BasicAuth

  plug :basic_auth, username: "Niko", password: "nikoniko2"

  plug :match
  plug Plug.Parsers,
       parsers: [:urlencoded, :multipart, :json],
       pass: ["*/*"],
       json_decoder: Jason

  plug Plug.Static,
    at: "/public",
    from: :my_app,
    only: ~w(images)

  plug :auth

  plug Plug.Logger, log: :debug
  plug :dispatch

  defp auth(conn, opts) do
    username = "Niko"
    password = "nikoniko2"
    Plug.BasicAuth.basic_auth(conn, username: username, password: password)
  end

  def find_usr!(id) do
    case res = Repo.get!(User, id) do
     Ecto.NoResultsError -> {:error, "not found"}
     _ -> {:ok, res}
    end
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def photo(conn, %{"upload" => upload}) do
    IO.inspect upload, label: "Photo upload information"
    File.cp(upload.path, Path.absname("images/#{upload.filename}"))
    send_resp(conn, 200, "Uploaded: #{upload.filename}")
  end

  post "/upload_photo" do
    photo(conn, conn.body_params)
  end

  get "/auth" do
    IO.puts "Auth "
    send_resp(conn, 200, Wsup.EEx.compile("lib/template/index.eex"))
  end

  get "/hello" do
    send_resp(conn, 200, "<h1>Hello, world!</h1>")
  end

  get "/hello/:name" do
    send_resp(conn, 200, "hello, #{name}")
  end

  def finda(id) do
    try do
      result =
        Repo.get!(User, id)

        result
    rescue
      Ecto.NoResultsError ->
        "No result found"
    end
  end

  get "/user/:id" do
    res = finda(id)

    if res == "No result found" do
      send_resp(conn, 404, res)
    else
      usrStr = res |> Map.drop([:__meta__, :__struct__, :inserted_at, :updated_at]) |> Jason.encode!()
      IO.inspect res
      send_resp(conn, 200, usrStr)
    end
  end

  get "/user" do
    users = Repo.all(User) |> Enum.map(fn x -> x |> Map.drop([:__meta__, :__struct__, :inserted_at, :updated_at]) |> Jason.encode! end)
   # userStr = users |> Jason.encode!() gracefully_handle_get
    send_resp(conn, 200, "users: #{users}")
  end

  post "/user" do
    param = conn.body_params
    IO.inspect param
    create_user(param)

    send_resp(conn, 200, "Posted! user")
  end

  post "/postsomething" do
    param = conn.body_params
    paramStr = conn.body_params |> Jason.encode!()

    IO.inspect param
    send_resp(conn, 200, "Posted: #{paramStr}")
  end

  match _ do
    send_resp(conn, 404, "oops")
  end

  def start do
    Plug.Adapters.Cowboy.http Wsup, [], port: 8080
  end

  def stop do
    Plug.Adapters.Cowboy.shutdown Wsup.HTTP
  end
end

defmodule Wsup.EEx do
  require Logger

  def compile(html) do
    list = ["Nikolay", "hello", "ajameti", "Ayeoo"]
    body = EEx.compile_file(html)
    {result, _bindings} = Code.eval_quoted(body, a: 1, b: 2, list: list)
    Logger.info("Compile html: #{result}")
    resdata = "<html>#{result}</html>"
    resdata
  end
end
