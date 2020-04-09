require "alizarin"

include WebExtension

initialize_extension do
  IPC.init
  openFile = function params do
    IPC.send "readfile"
  end

  JSCContext.set_value "openFile", openFile

  saveFile = function params do
    IPC.send "writefile"
  end

  JSCContext.set_value "saveFile", saveFile

  readFile = function params do
    if params.size != 1
      JSCFunction.raise "1 parameter expected, #{params.size} given."
      return
    end
    path = params.first.to_s
    fileContent = File.read path
    mde = JSCContext.get_value "mde"
    mde.invoke "value", fileContent
    true
  end

  JSCContext.set_value "readFile", readFile

  writeFile = function params do
    if params.size != 1
      JSCFunction.raise "1 parameter expected, #{params.size} given."
      return
    end
    path = params.first.to_s
    mde = JSCContext.get_value "mde"
    string = mde.invoke("value").to_s
    File.write(path, string)
    true
  end

  JSCContext.set_value "writeFile", writeFile

  JSCContext.set_value "namedTupleToJSC", (function p do
    {
      age:   21,
      songs: StaticArray[
        {
          name: "A song of ice and fire",
        },
      ],
    }
  end)
end
