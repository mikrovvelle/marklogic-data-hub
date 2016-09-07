xquery version "1.0-ml";

module namespace mlcpFlow = "http://marklogic.com/data-hub/mlcp-flow-transform";

import module namespace flow = "http://marklogic.com/data-hub/flow-lib"
  at "/com.marklogic.hub/lib/flow-lib.xqy";

import module namespace perf = "http://marklogic.com/data-hub/perflog-lib"
  at "/com.marklogic.hub/lib/perflog-lib.xqy";

import module namespace trace = "http://marklogic.com/data-hub/trace"
  at "/com.marklogic.hub/lib/trace-lib.xqy";

declare namespace hub = "http://marklogic.com/data-hub";

declare option xdmp:mapping "false";

declare function mlcpFlow:transform(
  $content as map:map,
  $context as map:map
) as map:map*
{
  let $uri := map:get($content, "uri")
  return
    perf:log('mlcp-flow-transform(' || $uri || ')', function() {
      let $paramNodes := xdmp:unquote(map:get($context, 'transform_param'))/node()/*
      let $paramMap := map:new()
      let $_ := $paramNodes ! map:put($paramMap, fn:local-name(.), ./string())

      let $flow := flow:get-flow(
        map:get($paramMap, 'entity-name'),
        map:get($paramMap, 'flow-name'),
        map:get($paramMap, 'flow-type'))

      let $_ :=
        if ($flow) then ()
        else
          fn:error(xs:QName("MISSING_FLOW"), "The specified flow " || map:get($paramMap, "flow-name") || " is missing.")

      let $envelope := try {
        flow:run-plugins($flow, $uri, map:get($content, "value"), $paramMap)
      }
      catch($ex) {
        xdmp:log(xdmp:describe($ex, (), ())),
        xdmp:rethrow()
      }
      let $_ := map:put($content, "value", $envelope)
      let $_ :=
        if (trace:enabled()) then
          trace:plugin-trace(
            $uri,
            if ($envelope instance of element()) then ()
            else
              null-node {},
            "writer",
            $flow/hub:type,
            $envelope,
            if ($envelope instance of element()) then ()
            else
              null-node {},
            xs:dayTimeDuration("PT0S")
          )
        else ()
      let $_ := trace:write-trace()
      return
        $content
    })
};