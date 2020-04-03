require "alizarin"
require "./lib/**"

include WebExtension

initialize_extension do
  openFile = function params do
    dialog = GtkDialog.new_dialog "Open File", nil,
      GtkDialog::FileChooserAction::OPEN_FILE,
      "Cancel", 0,
      "Open", 1,
      nil
    file_filter = GtkDialog.new_file_filter
    GtkDialog.set_file_filter_name file_filter, "Markdown"
    GtkDialog.add_file_filter_pattern file_filter, "*.md"

    GtkDialog.add_file_filter dialog, file_filter

    res = GtkDialog.run_dialog dialog

    if res == 1
      file_name_ptr = GtkDialog.get_file_name dialog
      unless file_name_ptr.null?
        file_name = String.new file_name_ptr
        LibWebKit.destroy_widget dialog
        return JSCPrimative.new File.read file_name
      end
    end
    LibWebKit.destroy_widget dialog
    return JSCPrimative.new nil
  end

  JSCContext.set_value "openFile", openFile

  saveFile = function params do
    dialog = GtkDialog.new_dialog "Save File", nil,
      GtkDialog::FileChooserAction::SAVE_FILE,
      "Cancel", 0,
      "Save", 1,
      nil
    file_filter = GtkDialog.new_file_filter

    GtkDialog.add_file_filter dialog, file_filter

    GtkDialog.set_file_name dialog, "Untitled.md"
    res = GtkDialog.run_dialog dialog

    if res == 1
      file_name_ptr = GtkDialog.get_file_name dialog
      unless file_name_ptr.null?
        file_name = String.new file_name_ptr
        LibWebKit.destroy_widget dialog
        File.write file_name, params.first.to_s
        return JSCPrimative.new true 
      end
    end
    LibWebKit.destroy_widget dialog
    return JSCPrimative.new nil
  end

  JSCContext.set_value "saveFile", saveFile
end
