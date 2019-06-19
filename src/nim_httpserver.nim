import asynchttpserver, asyncdispatch, json, times, router

proc greet(req: Request): Future[void] {.async.} =
  let headers = newHttpHeaders([("Content-Type", "application/json")])
  await req.respond(Http200, $(%*{"message": "Hello, world!"}), headers)

proc time(req: Request): Future[void] {.async.} =
  let headers = newHttpHeaders([("Content-Type", "application/json")])
  await req.respond(Http200, $(%*{"time": $now()}), headers)

proc notFound(req: Request): Future[void] {.async.} =
  let headers = newHttpHeaders([("Content-Type", "application/json")])
  await req.respond(Http200, $(%*{"error": "not found"}), headers)

when isMainModule:
  let r = newRouter()
  r.defaultHandler = notFound
  r.add(HttpGet, "/greet", greet)
  r.add(HttpGet, "/time", time)
  let server = newAsyncHttpServer()
  waitFor server.serve(Port(8080), r.handle)

