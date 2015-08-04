//
//  ViewController.swift
//  TimeSlider
//
//  Created by Juan C. Mendez on 9/27/14.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2014 Juan C. Mendez (jcmendez@alum.mit.edu)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


import UIKit

class LayerSliderData: JCMTimeSliderControlDataSource {
  var data: Array<NSDate>?
  
  init(dataArray:[NSDate]) {
    data = dataArray
  }
  
  func numberOfDates() -> Int {
    return data!.count
  }
  
  var hasIcon: Bool = true
  func dataPointAtIndex(index: Int) -> JCMTimeSliderControlDataPoint {
    
//    // Assign approx. half fof the labels to have icons
//    if index % 2 == 0 {
//      hasIcon = true
//    } else {
//      hasIcon = false
//    }
    return JCMTimeSliderControlDataPoint(date: data![index], hasIcon: hasIcon)
  }
  
  
  }


class ViewController: UIViewController, JCMTimeSliderControlDelegate {
  
  @IBOutlet var timeControl1: JCMTimeSliderControl?
  @IBOutlet var timeControl2: JCMTimeSliderControl?
  @IBOutlet var timeControl3: JCMTimeSliderControl?
  @IBOutlet var timeControl4: JCMTimeSliderControl?
  
//  var sample1 = SampleData(points: 4)
//  var sample2 = SampleData(points: 12)
//  var sample3 = SampleData(points: 100)
//  var sample4 = SampleData(points: 800)
  
  var sample1:LayerSliderData?


  
  
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupIterisLayerWithDataType("radar_with_metrad_plus")
  }
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
  }

  
  func populateTimeControls(dataArray:[NSDate]) {

    sample1 = LayerSliderData(dataArray: dataArray)
    
    println("sample1.data.count = \(sample1!.data!.count)")
    
    timeControl1?.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
    timeControl1?.dataSource = sample1
    timeControl1?.delegate = self
    timeControl1?.tag = 1
    
    timeControl2?.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.4)
    timeControl2?.selectedTickColor = UIColor.blackColor()
    timeControl2?.labelColor = UIColor.blackColor()
    timeControl2?.inactiveTickColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
    timeControl2?.dataSource = sample1
    timeControl2?.delegate = self
    timeControl2?.tag = 2
    
    timeControl3?.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
    timeControl3?.dataSource = sample1
    timeControl3?.delegate = self
    timeControl3?.tag = 3
    
    timeControl4?.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
    timeControl4?.dataSource = sample1
    timeControl4?.delegate = self
    timeControl4?.tag = 4
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func hoveredOverDate(date: NSDate, index: Int, control: JCMTimeSliderControl) {
    //println("Hovered over control: \(control.tag) -> Date: \(date), loc: \(index)")
  }
  
  func selectedDate(date: NSDate, index: Int, control: JCMTimeSliderControl) {
    //println("Selected control: \(control.tag) -> Date: \(date), loc: \(index)")
  }
  
  
  private func setupIterisLayerWithDataType(dataType:String) {
    var tileURLs = [String]()
    var timestamps = [NSDate]()
    
    let iteris = IterisAPI.sharedInstance
    
    let layerURL = iteris.layerURL(dataType, startDate:NSDate(), endDate:NSDate(), displayInterval:1200, displayRange:24)
    let layerNSURL = NSURL(string:layerURL)
    
    NSURLConnection.sendAsynchronousRequest(NSURLRequest(URL:layerNSURL!), queue: NSOperationQueue()){
      (response, data, error) -> Void in
      if (error != nil) {
        println("error = \(error)")
      } else {
        
        var localError: NSError?
        if let parsedObject = NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions.MutableContainers, error:&localError) as? NSDictionary {
          var display_intervals = parsedObject["display_intervals"] as! NSMutableArray
          
          for dict in display_intervals {
            let keyPath = "layers.contigus." + "\(dataType)"
            let tile_url = dict.valueForKeyPath("\(keyPath)" + ".tile_url") as! String
            let valid_time = dict.valueForKeyPath("\(keyPath)" + ".valid_time") as! NSNumber
            if (tile_url != "") {
              tileURLs.insert(iteris.tileURLStringWithAuthParams(tile_url) as (String), atIndex:0)
              if (valid_time != 0) {
                let ts = NSDate(timeIntervalSince1970:valid_time.doubleValue)
                timestamps.insert(ts, atIndex:0)
              } else {
                timestamps.insert(NSDate(timeIntervalSince1970: 0.0), atIndex:0)
              }
            }
          }
          
          if (tileURLs.count > 0) {
            
            // duplicating the first tileJSONUrl & matching timestamp for display (and later removal) to help time slider
            tileURLs.insert(tileURLs[0], atIndex:0)
            timestamps.insert(timestamps[0], atIndex:0)
            
            //            println("tileURLs = \(tileURLs)")
            println("timestamps = \(timestamps)")
            
                        dispatch_async(dispatch_get_main_queue()) {
            self.populateTimeControls(timestamps)
                        }
            
            //            var tileURLsString:String? = tileURLs.description
            //            var timestampsString:String? = timestamps.description
            //            tileURLsString = tileURLsString!.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString:"()"))
            //            timestampsString = timestampsString!.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString:"()"))
            //
            //            // let currentZoom:Int? = Int(self.mapView!.zoom)
            //            let currentZoom:Int? = 6
            //
            //            let currentZoomPlusOne:Int? = currentZoom!+1
            //            var jsonString = "{\"tiles\": [" + "\(tileURLsString)"
            //            jsonString += "], \"timestamps\": ["
            //            jsonString += "\(timestampsString)"
            //            jsonString += "], \"minzoom\":"
            //            jsonString += "\(currentZoom)"
            //            jsonString += ", \"maxzoom\": "
            //            jsonString += "\(currentZoomPlusOne)"
            //            jsonString += "}"
            //            dispatch_async(dispatch_get_main_queue()) {
            //              //self.enableSecondLayerWithJSONString(jsonString)
            //              println("jsonString = \(jsonString)")
            //            }
          }
        }
      }
    }
  }

}

