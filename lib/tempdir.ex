defmodule TempDir do
  @moduledoc """
    This GenServer is a module for creating temporary
    directories that auto cleanup after themselves on
    process exit.
  """

  use GenServer

  defmodule Directory do
    defstruct path: "", files: []
  end

  # Public API

  @doc """
    Starts a new tmp process that creates its own tmp
    directory.
  """
  def start_link(default \\ %{}) do
    GenServer.start_link(__MODULE__, default)
  end

  @doc """
    Manually terminates a tmp process and performs cleanup.
  """
  def stop(pid), do: GenServer.stop(pid)

  @doc """
    Gets the tmp path for the process.
  """
  def get_path(pid), do: GenServer.call(pid, :path)

  @doc """
    Gets the tmp path for the process.
  """
  def get_files(pid), do: GenServer.call(pid, :files)

  @doc """
    Creates a temporary file in the current processes'
    directory.
  """
  def create_file(pid), do: GenServer.call(pid, :create_file)

  # Server Callbacks

  def init(args) do
    case mkdir(args) do
      {:ok, state} -> {:ok, state}
      {:error, reason} -> {:stop, reason}
    end
  end

  def handle_call(:path, _from, state), do: {:reply, state.path, state}
  def handle_call(:files, _from, state), do: {:reply, state.files, state}

  def handle_call(:create_file, _from, state) do
    case mkfile(state, %{}) do
      {:ok, io_device} -> {:reply, io_device, %Directory{state | files: state.files ++ [io_device]}}
      {:error, reason} -> {:stop, reason, state}
    end
  end

  def handle_info({:DOWN, _, _, _, _}, state) do
    {:stop, "main process died", state}
  end

  def terminate(_reason, state), do: cleanup(state)

  defp cleanup(state), do: cleanup(File.exists?(state.path), state.path)
  defp cleanup(true, path), do: File.rm_rf(path)
  defp cleanup(false, _path), do: {:ok, []}

  @compile {:inline, i: 1}
  defp i(integer), do: Integer.to_string(integer)

  defp mkdir(args) do
    dir_prefix = args[:dir_prefix] || "elixir"
    tmp_dir = args[:tmp_dir] || "/tmp"
    path = gen_path(dir_prefix, tmp_dir)

    case File.mkdir_p(path) do
      :ok -> {:ok, %Directory{path: path}}
      {:error, reason} -> {:error, reason}
    end
  end

  defp mkfile(state, args) do
    file_prefix = args[:file_prefix] || ""
    file_path = state.path <> "/" <> file_prefix <> gen_name()

    File.open(file_path, [:write])
  end

  defp gen_name do
    {_mega, sec, micro} = :os.timestamp
    scheduler_id = :erlang.system_info(:scheduler_id)

    i(sec) <> "-" <> i(micro) <> "-" <> i(scheduler_id)
  end

  defp gen_path(prefix, tmp) do
    tmp <> "/" <> prefix <> "-" <> gen_name()
  end
end
