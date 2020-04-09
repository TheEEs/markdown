require "./editor"
require "ecr"
require "sass"
require "colorize"
editor = Editor.new true

editor.extension_dir = "./webExtension/"

editor.load_html ECR.render "./res/index.html.ecr"

editor.on_close do |e|
  exit 0
end

editor.when_script_finished do
  puts "JS finished".colorize :green
end

editor["enable-developer-extras"] = true
editor.show_inspector

editor.when_ipc_message_received do |msg|
  case msg
  when "readfile"
    dialog = WebView::OpenFileDialog.new webview: editor
    dialog.add_file_filter "Markdown", "*.md"
    path = dialog.show || ""
    if File.exists?(path)
      editor.execute_javascript "readFile('#{path}')"
    end
  when "writefile"
    dialog = WebView::SaveFileDialog.new webview: editor
    dialog.file_name = "Untitled.md"
    dialog.add_file_filter "Markdown", "*.md"
    path = dialog.show
    editor.execute_javascript "writeFile('#{path}')"
  end
end

editor.when_document_loaded do |webview|
  editor.await "document.title" do |value|
    webview.title = String.new JSC.to_string value
  end
  editor.execute_javascript <<-JS
    var mde = new SimpleMDE({
      spellChecker: false
    });
    context.init();
    context.attach(".CodeMirror",[
      {
        header: "Choose one"
      },
      {
        text : "Open File",
        action : function(e){
          e.preventDefault();
          openFile();
        }
      },
      {
        text : "Save file",
        action: function(e){
          e.preventDefault();
          saveFile();
        }
      }
    ])
  JS
end

editor.window_size 800, 600

editor.run
