import asynchttpserver, asyncdispatch, sequtils

type
  Route* = ref object
    path: string
    verb: HttpMethod
    handler: Handler

  Router* = ref object
    routes: seq[Route]
    defaultHandler*: Handler

  Handler* = proc(req: Request): Future[void] {.gcsafe.}

proc findRoute(router: Router, req: Request): Route =
  for route in router.routes:
    if req.url.path == route.path and req.reqMethod == route.verb:
      return route
  return nil

proc defaultHandler(req: Request): Future[void] {.async.} =
  await req.respond(Http404, "not found")

proc newRouter*(): Router =
  Router(routes: @[], defaultHandler: defaultHandler)

proc add*(router: Router, verb: HttpMethod, path: string, handler: Handler) =
  let route = Route(path: path, verb: verb, handler: handler)
  router.routes.add(route)

proc handle*(router: Router): Handler =
  let h =
    proc (req: Request): Future[void] {.async, gcsafe.} =
      let route = findRoute(router, req)
      if route == nil:
        await router.defaultHandler(req)
      else:
        await route.handler(req)
  return h

