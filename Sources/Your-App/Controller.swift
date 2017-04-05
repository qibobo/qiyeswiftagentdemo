/**
* Copyright IBM Corporation 2016
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
* http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
**/
import Configuration
import CloudFoundryConfig

import Kitura
import SwiftyJSON
import LoggerAPI
import CloudFoundryEnv
import SwiftMetrics
import SwiftMetricsKitura
import SwiftMetricsBluemix
import Foundation

public class Controller {

  let router: Router
  let configMgr: ConfigurationManager

  var port: Int {
      get { return configMgr.port }
  }
  var url: String {
      get { return configMgr.url }
  }

  let sm: SwiftMetrics
  let monitor: SwiftMonitor

  init() throws {
    configMgr = ConfigurationManager().load(.environmentVariables)

    sm = try SwiftMetrics()
    _ = SwiftMetricsKitura(swiftMetricsInstance: sm)
    _ = SwiftMetricsBluemix(swiftMetricsInstance: sm)
    monitor = sm.monitor()

    // All web apps need a Router instance to define routes
    router = Router()

    // Basic GET request
    router.get("/hello", handler: getHello)
  }


  public func getHello(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
    Log.debug("GET - /hello route handler...")
    response.headers["Content-Type"] = "text/plain; charset=utf-8"
    try response.status(.OK).send("Hello from Your-app!").end()
  }

}
