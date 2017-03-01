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

import Kitura
import SwiftyJSON
import Dispatch
import LoggerAPI
import CloudFoundryEnv
import SwiftMetrics
import SwiftMetricsKitura
import SwiftMetricsBluemix
import Foundation

public class Controller {

  let router: Router
  let appEnv: AppEnv
  let sm: SwiftMetrics
  let monitor: SwiftMonitor
  var arrayList: [String] = ["XXXX"]
  let str = "XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
  var port: Int {
    get { return appEnv.port }
  }

  var url: String {
    get { return appEnv.url }
  }

  init() throws {
    appEnv = try CloudFoundryEnv.getAppEnv()
    
    sm = try SwiftMetrics()
    _ = SwiftMetricsKitura(swiftMetricsInstance: sm)
    _ = AutoScalar(swiftMetricsInstance: sm)
    monitor = sm.monitor()

    // All web apps need a Router instance to define routes
    router = Router()

    // Serve static content from "public"
    router.all("/", middleware: StaticFileServer())

    // Basic GET request
    router.get("/hello", handler: getHello)
    router.get("/justSleep", handler: justSleep)

    // Basic POST request
    router.post("/hello", handler: postHello)

    router.get("/addSynchronize", handler: addSynchronize)
    router.get("/addConcurrent", handler: addConcurrent)
    router.get("/justAdd", handler: justAdd)

    router.get("/remove", handler: remove)

    router.get("/destroy", handler: destroy)

    // JSON Get request
    router.get("/json", handler: getJSON)
  }
  private var queue = DispatchQueue(label: "queuename")

  func addBlockToArray(block: String,count:Int) {
      queue.sync {
        for _ in 1...count{
          self.arrayList.append(block)
        }
      } 
  }
  func removeBlockFromArray(count:Int){
    queue.sync{
      let len = self.arrayList.count
      let rmCount = count
      if len < count{
        self.arrayList.removeAll()
      }else{
        for _ in 1...rmCount{
          self.arrayList.removeLast()
        }
      }
      
      
    }
  }
  func removeAll(){
    queue.sync{
      self.arrayList.removeAll()
    }
  }
  func randomInt()->Int{
    #if os(Linux)
        return Int(random() % (1000 + 1))
    #else
        return Int(arc4random_uniform(UInt32(1000)))
    #endif
  }
  func bubbleSort() {
    var nums:[Int] = []
      for _ in 1...100000{//100000=11s

        nums.append(Int(randomInt()))
      }
    for j in 0...nums.count-1 {       
        for i in j...nums.count-1 {
            if nums[i] < nums[j] {
                let temp = nums[i]
                nums[i] = nums[j]
                nums[j] = temp
            }
        }
    }
  }
  public func justSleep(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
    Log.debug("GET - /add route handler...")
    sleep(30)
    response.headers["Content-Type"] = "text/plain; charset=utf-8"
    try response.status(.OK).send(String(arrayList.count)).end()
  }
  public func justAdd(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
    Log.debug("GET - /add route handler...")
    // let param = request.parameters["count"]
    // let count = Int(param)
    addBlockToArray(block:str,count:100);
    response.headers["Content-Type"] = "text/plain; charset=utf-8"
    try response.status(.OK).send(String(arrayList.count)).end()
  }
  public func addSynchronize(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
    Log.debug("GET - /add route handler...")
    // let param = request.parameters["count"]
    // let count = Int(param)
    let startTime = Date().timeIntervalSince1970 * 1000
    let uuid = UUID().uuidString
    Log.info("add to array " + uuid)
    addBlockToArray(block:str,count:100);
    Log.info("begin sort " + uuid)
    bubbleSort()   
    Log.info("finish sort " + uuid)
    let endTime = Date().timeIntervalSince1970 * 1000
    let responseTime = (endTime - startTime)/1000
    Log.info("request really response time is \(responseTime)"  )
    response.headers["Content-Type"] = "text/plain; charset=utf-8"
    try response.status(.OK).send(String(arrayList.count)).end()
  }
  public func addConcurrent(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
    Log.debug("GET - /add route handler...")
    // let param = request.parameters["count"]
    // let count = Int(param)
    let startTime = Date().timeIntervalSince1970 * 1000
    let uuid = UUID().uuidString
    Log.info("add to array " + uuid)
    // addBlockToArray(block:str,count:100);
    Log.info("begin sort " + uuid)
    bubbleSort()   
    Log.info("finish sort " + uuid)
    let endTime = Date().timeIntervalSince1970 * 1000
    let responseTime = (endTime - startTime)/1000
    Log.info("request really response time is \(responseTime)"  )
    response.headers["Content-Type"] = "text/plain; charset=utf-8"
    try response.status(.OK).send(String(arrayList.count)).end()
  }
  public func remove(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
    Log.debug("GET - /remove route handler...")
    // let param = request.parameters["count"]
    // let count = Int(param)
    removeBlockFromArray(count:100)
    response.headers["Content-Type"] = "text/plain; charset=utf-8"
    try response.status(.OK).send(String(arrayList.count)).end()
  }
  public func destroy(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
    Log.debug("GET - /remove route handler...")
    removeAll()
    response.headers["Content-Type"] = "text/plain; charset=utf-8"
    try response.status(.OK).send(String(arrayList.count)).end()
  }

  public func getHello(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
    Log.debug("GET - /hello route handler...")
    response.headers["Content-Type"] = "text/plain; charset=utf-8"
    try response.status(.OK).send("Hello from Kitura-Starter!").end()
  }

  public func postHello(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
    Log.debug("POST - /hello route handler...")
    response.headers["Content-Type"] = "text/plain; charset=utf-8"
    if let name = try request.readString() {
      try response.status(.OK).send("Hello \(name), from Kitura-Starter!").end()
    } else {
      try response.status(.OK).send("Kitura-Starter received a POST request!").end()
    }
  }

  public func getJSON(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
    Log.debug("GET - /json route handler...")
    response.headers["Content-Type"] = "application/json; charset=utf-8"
    var jsonResponse = JSON([:])
    jsonResponse["framework"].stringValue = "Kitura"
    jsonResponse["applicationName"].stringValue = "Kitura-Starter"
    jsonResponse["company"].stringValue = "IBM"
    jsonResponse["organization"].stringValue = "Swift @ IBM"
    jsonResponse["location"].stringValue = "Austin, Texas"
    try response.status(.OK).send(json: jsonResponse).end()
  }

}
