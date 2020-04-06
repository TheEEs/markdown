require "alizarin"

class Editor < WebView
  @await_channel = Channel(JSC::JSValue).new

  protected getter await_channel

  def initialize(ipc : Bool = false)
    super(ipc)
  end

  def await(js_code : String, &block : JSC::JSValue -> Nil)
    LibWebKit.eval_js @browser, js_code, nil,
      LibWebKit::GAsyncReadyCallback.new { |object, result, user_data|
        res = LibWebKit.script_finish_result object, result, nil
        if res.null?
          puts "JavaScript execution has cause error(s)".colorize(:red).on(:black)
          return
        end
        jsc_value = LibWebKit.get_jsc_from_js_result res
        data = Box({(JSC::JSValue -> Nil), Editor}).unbox(user_data)
        webview = data[1]
        b = data[0]
        b.call jsc_value
      }, Box.box({block, self})
  end
end
