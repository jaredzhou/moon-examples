// TinyTodo — Cedar policy-based authorization demo server.

///|
/// Middleware: catch PonyError raised by handlers and turn it into a
/// proper HTTP error response, instead of letting it bubble up and
/// turn into 502.
fn pony_error_middleware() -> @pony.Middleware {
  next => {
    @pony.Handler(ctx => {
      next(ctx) catch {
        err =>
          match err {
            @pony.PonyError::MissingParam(msg) =>
              ctx.reply_error(@pony.PonyError::MissingParam(msg))
            @pony.PonyError::MissingQuery(key) =>
              ctx.reply_error(@pony.PonyError::MissingQuery(key))
            @pony.PonyError::MissingForm(key) =>
              ctx.reply_error(@pony.PonyError::MissingForm(key))
            @pony.PonyError::MissingHeader(key) =>
              ctx.reply_error(@pony.PonyError::MissingHeader(key))
            @pony.PonyError::MissingExt(key) =>
              ctx.reply_error(@pony.PonyError::MissingExt(key))
            @pony.PonyError::ExtDecodeError(key, msg) =>
              ctx.reply_error(@pony.PonyError::ExtDecodeError(key, msg))
            @pony.PonyError::MissingFormFile(key) =>
              ctx.reply_error(@pony.PonyError::MissingFormFile(key))
            @pony.PonyError::InvalidArgument(msg) =>
              ctx.reply_error(@pony.PonyError::InvalidArgument(msg))
            @pony.PonyError::NotFound(msg) =>
              ctx.reply_error(@pony.PonyError::NotFound(msg))
            @pony.PonyError::PermissionDenied(msg) =>
              ctx.reply_error(@pony.PonyError::PermissionDenied(msg))
            _ => ctx.write_text(500, "internal error")
          }
      }
    })
  }
}

///|
async fn main {
  let policies_src =
    #|permit(
    #|  principal,
    #|  action in [Action::"CreateList", Action::"GetLists"],
    #|  resource == Application::"TinyTodo"
    #|);
    #|
    #|permit(
    #|  principal,
    #|  action,
    #|  resource
    #|)
    #|when { resource.owner == principal };
    #|
    #|permit(
    #|  principal,
    #|  action == Action::"GetList",
    #|  resource
    #|)
    #|when { principal in resource.readers || principal in resource.editors };
    #|
    #|permit(
    #|  principal,
    #|  action in [Action::"UpdateList", Action::"CreateTask", Action::"UpdateTask", Action::"DeleteTask"],
    #|  resource
    #|)
    #|when { principal in resource.editors };
  let entities_src =
    #|[{"uid":{"type":"Application","id":"TinyTodo"},"attrs":{},"tags":{},"parents":[]},{"uid":{"type":"User","id":"emina"},"attrs":{"location":["String","DEF33"],"joblevel":["Long","8"]},"tags":{},"parents":[{"type":"Application","id":"TinyTodo"},{"type":"Team","id":"admin"}]},{"uid":{"type":"User","id":"aaron"},"attrs":{"location":["String","ABC17"],"joblevel":["Long","5"]},"tags":{},"parents":[{"type":"Team","id":"interns"},{"type":"Application","id":"TinyTodo"}]},{"uid":{"type":"User","id":"andrew"},"attrs":{"location":["String","XYZ77"],"joblevel":["Long","5"]},"tags":{},"parents":[{"type":"Application","id":"TinyTodo"},{"type":"Team","id":"admin"},{"type":"Team","id":"temp"}]},{"uid":{"type":"User","id":"kesha"},"attrs":{"location":["String","ABC17"],"joblevel":["Long","5"]},"tags":{},"parents":[{"type":"Application","id":"TinyTodo"},{"type":"Team","id":"temp"}]},{"uid":{"type":"Team","id":"temp"},"attrs":{},"tags":{},"parents":[{"type":"Application","id":"TinyTodo"}]},{"uid":{"type":"Team","id":"admin"},"attrs":{},"tags":{},"parents":[{"type":"Application","id":"TinyTodo"}]},{"uid":{"type":"Team","id":"interns"},"attrs":{},"tags":{},"parents":[{"type":"Application","id":"TinyTodo"},{"type":"Team","id":"temp"}]}]

  let state = @store.init_state(policies_src, entities_src)
  let r = @pony.Router::Router()
  r.use_mw(pony_error_middleware())
  let _ = @handler.build_list_routes(r, state)
  let _ = @handler.build_task_routes(r, state)
  println("TinyTodo server starting on 127.0.0.1:3000")
  @pony.start("127.0.0.1:3000", r)
}
