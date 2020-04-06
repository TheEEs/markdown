require "./editor"
require "ecr"
require "sass"
require "./lib/**"

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
          var content = openFile();
          mde.value(content);
        }
      },
      {
        text : "Save file",
        action: function(e){
          e.preventDefault();
          saveFile(mde.value());
        }
      }
    ])
  JS
end

editor.window_size 800, 600

editor.run
