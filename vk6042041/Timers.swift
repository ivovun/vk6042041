//
//  Timers.swift
//  vk6042041
//
//  Created by james404 on 15/07/2018.
//  Copyright © 2018 Vladimir Filippov. All rights reserved.
//

import Foundation
import CoreFoundation

func printTimeInterval(endTime:DispatchTime, beginTime:DispatchTime) -> Double {
  
  let nanoTime = endTime.uptimeNanoseconds - beginTime.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
  let timeInterval = Double(nanoTime) / 1_000_000_000 // Technically could overflow for long running tests
  
  print("Time : \(timeInterval) seconds")
  
  return timeInterval
}

func sleepIfNeeded(sleepFromTime: DispatchTime, sleepTime_ms: Double) {
  /*
   согласно vk api  https://vk.com/support?act=faqs_api&c=5&id=4156
   К методам API ВКонтакте (за исключением методов из секций https://vk.com/dev/secure и https://vk.com/dev/ads) можно обращаться
   не чаще 3 раз в секунду.
   
   я перестраховался взял 0,5 секунды
   
   идея взята https://stackoverflow.com/questions/38119742/how-to-sleep-for-few-milliseconds-in-swift-2-2
   и тут https://stackoverflow.com/questions/24755558/measure-elapsed-time-in-swift
   
   
   код для теста:
   
   для Playground
   
   var lastSearchTime = DispatchTime.now()
   let ms: UInt32 = 1000
   usleep(100 * ms) //will sleep for 2 milliseconds (.002 seconds)
   var timeStamp2 = DispatchTime.now()
   sleepIfNeeded(sleepFromTime: lastSearchTime, sleepTime_ms: 500)
   let end = DispatchTime.now()   // <<<<<<<<<<   end time
   
   
   printTimeInterval(endTime: end, beginTime: lastSearchTime)
   printTimeInterval(endTime: end, beginTime: timeStamp2)
   
 
   */
  
  let end = DispatchTime.now()   // <<<<<<<<<<   end time
  let nanoTime = end.uptimeNanoseconds - sleepFromTime.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
  
  let timeInterval_in_ms = Double(nanoTime) / 1_000_000
  
  let dif = sleepTime_ms - timeInterval_in_ms
  
  if dif > 0 {
    let ms: UInt32 = 1000
    usleep(UInt32(dif) * ms) //will sleep for dif  milliseconds
  }
  
}

func currentTimeString() -> String {
  let date = Date()
  let formatter = DateFormatter()
  formatter.dateFormat = "yyyy-MM-dd' time: 'HH:mm:ssZZZZZ"
  //formatter.timeZone = TimeZone(secondsFromGMT: 60 * 60 * 3)
  let result = formatter.string(from: date)
  return result
}

 

